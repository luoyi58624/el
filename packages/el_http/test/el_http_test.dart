import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:el_dart/el_dart.dart';
import 'package:el_http/el_http.dart';
import 'package:el_storage/el_storage.dart';
import 'package:test/test.dart';

class _TestElHttp extends ElHttp {
  Options handlerReqPublic(String method, Options? options, ElRequestExtra? extra) {
    return handlerReq(method, options, extra);
  }
}

class _ElHttpWithInterceptors extends ElHttp {
  _ElHttpWithInterceptors(this._interceptors);

  final List<Interceptor> _interceptors;

  @override
  List<Interceptor> get interceptors => _interceptors;
}

class _CountingJsonAdapter implements HttpClientAdapter {
  _CountingJsonAdapter(this.data);

  final dynamic data;
  int fetchCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter({required this.type, this.message, this.error});

  final DioExceptionType type;
  final String? message;
  final Object? error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      type: type,
      requestOptions: options,
      message: message,
      error: error,
      response: type == DioExceptionType.badResponse
          ? Response(requestOptions: options, statusCode: 404, data: {'code': 404})
          : null,
    );
  }
}

void main() {
  setUpAll(() {
    // 让缓存文件落在 el_http 当前目录，方便肉眼确认
    ElStorage.init(storagePath: Directory.current.path, debounceTime: 1);
  });

  group('ElHttpModel', () {
    test('fromJson/toJson roundtrip', () {
      final message = faker.lorem.sentence();
      final payload = {
        'id': faker.guid.guid(),
        'name': faker.person.name(),
        'email': faker.internet.email(),
        'age': faker.randomGenerator.integer(100, min: 1),
        'tags': List.generate(3, (_) => faker.lorem.word()),
        'profile': {'address': faker.address.streetAddress(), 'ip': faker.internet.ipv4Address()},
      };
      final m = ElHttpModel.fromJson({'code': 200, 'message': message, 'data': payload});
      expect(m.code, 200);
      expect(m.message, message);
      expect(m.data, payload);
      expect(m.toJson(), {'code': 200, 'message': message, 'data': payload});
    });

    test('fromJson null uses defaults', () {
      final m = ElHttpModel.fromJson(null);
      expect(m.code, 0);
      expect(m.message, '');
      expect(m.data, isNull);
    });
  });

  group('ElHttp.handlerReq', () {
    test('merges extras with correct precedence', () {
      final http = _TestElHttp();

      final options = http.handlerReqPublic(
        'GET',
        Options(extra: {'printReqLog': false, 'custom': 1}),
        const ElRequestExtra(printReqLog: true, printExceptionLog: false),
      );

      expect(options.extra?['printReqLog'], false);
      expect(options.extra?['printExceptionLog'], false);
      expect(options.extra?['custom'], 1);
    });
  });

  group('ElCacheInterceptor', () {
    test('creates default cache file in current dir', () async {
      // 先清理历史文件，避免“本来就存在”的误判
      final cacheFile = File('${Directory.current.path}${Platform.pathSeparator}el_http_cache');
      if (cacheFile.existsSync()) cacheFile.deleteSync();
      if (ElStorage.checkStorageKey('el_http_cache')) {
        ElCacheInterceptor.defaultCacheStorage.removeStorage();
      }

      addTearDown(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        if (cacheFile.existsSync()) cacheFile.deleteSync();
        if (ElStorage.checkStorageKey('el_http_cache')) {
          ElCacheInterceptor.defaultCacheStorage.removeStorage();
        }
      });

      final cache = ElCacheInterceptor(); // 使用默认 key: el_http_cache
      final mockRes = {
        'code': 200,
        'message': faker.lorem.sentence(),
        'data': {'id': faker.guid.guid(), 'name': faker.person.name(), 'title': faker.job.title()},
      };
      final adapter = _CountingJsonAdapter(mockRes);
      final http = _ElHttpWithInterceptors([cache]);
      http.dio.httpClientAdapter = adapter;

      await http.get('https://example.com/c', options: Options(extra: const ElCacheExtra(useCache: true).toJson()));

      // ElStorage 写入带防抖 + 异步落盘，稍等一下确保文件可见
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cacheFile.existsSync(), isTrue);
      // 简单确认文件内容是 json
      expect(() => jsonDecode(cacheFile.readAsStringSync()), returnsNormally);
    });

    test('uses cache when hit and skips adapter', () async {
      final cache = ElCacheInterceptor(cacheKey: 't_cache_hit');
      addTearDown(cache.cacheStorage.removeStorage);

      final adapter = _CountingJsonAdapter({'unused': true});
      final http = _ElHttpWithInterceptors([cache]);
      http.dio.httpClientAdapter = adapter;

      final url = 'https://example.com/a';
      final md5 = ElCryptoUtil.toMd5(Uri.parse(url).toString());
      final cached = {
        'code': 200,
        'message': faker.lorem.sentence(),
        'data': {
          'list': List.generate(5, (_) => faker.randomGenerator.integer(9999)),
          'ts': faker.date.dateTime().millisecondsSinceEpoch,
        },
      };
      cache.cacheStorage.setItem(md5, jsonEncode(cached));

      final res = await http.get(url, options: Options(extra: const ElCacheExtra(useCache: true).toJson()));

      expect(res.data, cached);
      expect(adapter.fetchCount, 0);

      // 等待 setItem 的防抖写入完成，避免 tearDown dispose 时仍有回调在队列中
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });

    test('stores response when useCache enabled', () async {
      final cache = ElCacheInterceptor(cacheKey: 't_cache_store');
      addTearDown(cache.cacheStorage.removeStorage);

      final mockRes = {
        'code': 200,
        'message': faker.lorem.sentence(),
        'data': {
          'items': List.generate(
            3,
            (_) => {
              'id': faker.guid.guid(),
              'price': faker.randomGenerator.decimal(min: 0, scale: 9999),
              'title': faker.lorem.words(3).join(' '),
            },
          ),
        },
      };
      final adapter = _CountingJsonAdapter(mockRes);
      final http = _ElHttpWithInterceptors([cache]);
      http.dio.httpClientAdapter = adapter;

      final url = 'https://example.com/b';
      final res = await http.get(url, options: Options(extra: const ElCacheExtra(useCache: true).toJson()));

      expect(res.data, mockRes);
      expect(adapter.fetchCount, 1);

      final md5 = ElCryptoUtil.toMd5(Uri.parse(url).toString());
      final raw = cache.cacheStorage.getItem<String>(md5);
      expect(raw, isNotNull);
      expect(jsonDecode(raw!), mockRes);

      // 等待 onResponse -> setItem 的防抖写入完成，避免 tearDown dispose 后再触发 write
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
  });

  group('ElErrorInterceptor', () {
    test('connectionTimeout maps message', () async {
      String? got;
      final http = _ElHttpWithInterceptors([ElErrorInterceptor()]);
      http.dio.httpClientAdapter = _ThrowingAdapter(type: DioExceptionType.connectionTimeout);
      await expectLater(
        () => http.get(
          'https://example.com/timeout',
          options: Options(extra: {'errorMessageFun': (String msg) => got = msg}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(got, '服务器连接超时，请稍后重试！');
    });

    test('receiveTimeout maps message', () async {
      String? got;
      final http = _ElHttpWithInterceptors([ElErrorInterceptor()]);
      http.dio.httpClientAdapter = _ThrowingAdapter(type: DioExceptionType.receiveTimeout);
      await expectLater(
        () =>
            http.get('https://example.com/rt', options: Options(extra: {'errorMessageFun': (String msg) => got = msg})),
        throwsA(isA<DioException>()),
      );
      expect(got, '服务器响应超时，请稍后重试！');
    });

    test('badResponse 404 maps message by err.message', () async {
      String? got;
      final http = _ElHttpWithInterceptors([ElErrorInterceptor()]);
      http.dio.httpClientAdapter = _ThrowingAdapter(type: DioExceptionType.badResponse, message: 'status 404');
      await expectLater(
        () => http.get(
          'https://example.com/404',
          options: Options(extra: {'errorMessageFun': (String msg) => got = msg}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(got, '请求接口404');
    });

    test('unknown socketException maps message', () async {
      String? got;
      final http = _ElHttpWithInterceptors([ElErrorInterceptor()]);
      http.dio.httpClientAdapter = _ThrowingAdapter(
        type: DioExceptionType.unknown,
        error: const SocketException('no network'),
      );
      await expectLater(
        () => http.get(
          'https://example.com/unknown',
          options: Options(extra: {'errorMessageFun': (String msg) => got = msg}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(got, '网络连接错误，请检查网络连接！');
    });

    test('supports custom messageMapper', () async {
      String? got;
      final http = _ElHttpWithInterceptors([
        ElErrorInterceptor(
          messageMapper: (err) {
            if (err.type == DioExceptionType.receiveTimeout) return 'CUSTOM_TIMEOUT';
            return null;
          },
        ),
      ]);
      http.dio.httpClientAdapter = _ThrowingAdapter(type: DioExceptionType.receiveTimeout);

      await expectLater(
        () => http.get(
          'https://example.com/custom',
          options: Options(extra: {'errorMessageFun': (String msg) => got = msg}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(got, 'CUSTOM_TIMEOUT');
    });
  });
}
