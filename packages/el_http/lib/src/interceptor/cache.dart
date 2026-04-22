part of '../index.dart';

class ElCacheInterceptor extends Interceptor {
  static const _defaultCacheKey = 'el_http_cache';

  /// 默认的缓存存储库
  static final ElStorage defaultCacheStorage = ElStorage.createStorage(_defaultCacheKey);

  ElCacheInterceptor({String cacheKey = _defaultCacheKey}) {
    if (cacheKey == _defaultCacheKey) {
      cacheStorage = defaultCacheStorage;
    } else {
      cacheStorage = ElStorage.createStorage(cacheKey);
    }
    cacheStorage.clearExpire();
  }

  late final ElStorage cacheStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final url = options.uri.toString();

    final extra = ElCacheExtra.fromJson(options.extra);
    // 若请求配置没有开启缓存，则走下一个拦截器
    if (extra.useCache != true) {
      handler.next(options);
    } else {
      final key = ElCryptoUtil.toMd5(url);
      final cacheData = cacheStorage.getItem(key);
      // 若本地没有缓存数据，则走下一个拦截器，否则直接响应缓存数据
      if (cacheData == null) {
        handler.next(options);
      } else {
        final resData = jsonDecode(cacheData);
        if (extra.printCacheLog == true) ElLog.d(resData, title: '响应缓存数据: $url');
        handler.resolve(Response(requestOptions: options, data: resData));
      }
    }
  }

  @override
  onResponse(Response response, ResponseInterceptorHandler handler) async {
    final extra = ElCacheExtra.fromJson(response.requestOptions.extra);

    // 如果开启缓存，则将结果保存到本地
    if (extra.useCache == true) {
      String key = ElCryptoUtil.toMd5(response.requestOptions.uri.toString());
      cacheStorage.setItem(key, jsonEncode(response.data), expire: extra.cacheExpire);
    }

    return handler.next(response);
  }
}

/// 请求缓存额外配置数据
class ElCacheExtra extends ElRequestExtra {
  const ElCacheExtra({this.enableCache, this.useCache, this.printCacheLog, this.cacheExpire});

  /// 是否开启缓存，若为true，接口响应成功后数据将会保存于本地
  final bool? enableCache;

  /// 是否使用缓存数据，如果本地存在数据，[ElCacheInterceptor] 会则直接响应本地数据。
  ///
  /// 提示：此选项的意义在于，一个接口可以在多个地方使用，而有些场景需要加载实时数据。
  final bool? useCache;

  /// 是否打印缓存日志
  final bool? printCacheLog;

  /// 缓存时间
  final Duration? cacheExpire;

  factory ElCacheExtra.fromJson(Map<String, dynamic>? json) => ElCacheExtra(
    enableCache: json?['enableCache'],
    useCache: json?['useCache'],
    printCacheLog: json?['printCacheLog'],
    cacheExpire: const ElDurationSerialize().deserialize(json?['cacheExpire']),
  );

  @override
  ElCacheExtra fromJson(Map<String, dynamic>? json) => ElCacheExtra.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    if (enableCache != null) 'enableCache': enableCache,
    if (useCache != null) 'useCache': useCache,
    if (printCacheLog != null) 'printCacheLog': printCacheLog,
    if (cacheExpire != null) 'cacheExpire': const ElDurationSerialize().serialize(cacheExpire),
  };
}
