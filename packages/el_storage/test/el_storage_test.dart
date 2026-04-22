import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:el_dart/el_dart.dart';
import 'package:el_storage/el_storage.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempRoot;
  late String storageDirName;

  int seq = 0;

  String nextKey([String prefix = 'el_storage_test']) {
    seq += 1;
    return '${prefix}_$seq';
  }

  File fileOfKey(String key) => File(p.join(ElStorage.storagePath, key));

  Future<void> waitDebounce([int ms = 30]) => Future<void>.delayed(Duration(milliseconds: ms));

  Future<void> eventually(
    bool Function() predicate, {
    Duration timeout = const Duration(seconds: 2),
    Duration interval = const Duration(milliseconds: 10),
  }) async {
    final start = DateTime.now();
    while (true) {
      if (predicate()) return;
      if (DateTime.now().difference(start) > timeout) {
        fail('等待条件超时: $timeout');
      }
      await Future<void>.delayed(interval);
    }
  }

  setUpAll(() {
    // 将测试产生的文件放在“当前文件夹”下，便于排查与避免系统临时目录差异
    tempRoot = Directory(p.join(Directory.current.path, '.el_storage_test_tmp'));
    if (!tempRoot.existsSync()) tempRoot.createSync(recursive: true);
    storageDirName = p.join('.el_storage_test_tmp', 'data_${DateTime.now().microsecondsSinceEpoch}');

    // 初始化一次即可（ElStorage.init 内部做了单例保护）
    // 传 null 走 IO 端默认 Directory.current.path 分支，保证覆盖率统计到对应行
    ElStorage.init(storagePath: null, storageDir: storageDirName, debounceTime: 10);
  });

  tearDownAll(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  test('init 后会创建存储目录，storagePath 可访问', () {
    expect(ElStorage.storagePath, isNotEmpty);
    final dir = Directory(ElStorage.storagePath);
    expect(dir.existsSync(), isTrue);
  });

  test('checkExpire: includeNull=false 时，缺失 key 不视为过期', () {
    final key = nextKey('include_null');
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    expect(storage.checkExpire('missing', includeNull: false), isFalse);
  });

  test('createStorage / checkStorageKey / removeStorage 生命周期', () async {
    final key = nextKey();
    expect(ElStorage.checkStorageKey(key), isFalse);

    final storage = ElStorage.createStorage(key, debounceTime: 10);
    expect(ElStorage.checkStorageKey(key), isTrue);

    storage.setItem('a', 1);
    await waitDebounce();
    expect(storage.getItem<int>('a'), 1);

    storage.removeStorage();
    expect(ElStorage.checkStorageKey(key), isFalse);
    await eventually(() => fileOfKey(key).existsSync() == false);
  });

  test('createStorage: 相同 key 重复创建会抛出断言', () {
    final key = nextKey('duplicate');
    final s1 = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(s1.removeStorage);

    expect(() => ElStorage.createStorage(key, debounceTime: 10), throwsA(isA<AssertionError>()));
  });

  test('setItem/getItem/removeItem/clear', () async {
    final key = nextKey();
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    storage.setItem('k1', 'v1');
    storage.setItem('k2', 2);
    storage.setItem('k3', true);
    await waitDebounce();

    expect(storage.length, 3);
    expect(storage.hasKey('k1'), isTrue);
    expect(storage.getItem<String>('k1'), 'v1');
    expect(storage.getItem<int>('k2'), 2);
    expect(storage.getItem<bool>('k3'), true);

    storage.removeItem('k2');
    await waitDebounce();
    expect(storage.hasKey('k2'), isFalse);
    expect(storage.getItem<int>('k2'), isNull);

    storage.clear();
    await waitDebounce();
    expect(storage.length, 0);
    expect(storage.keys, isEmpty);
  });

  test('removeMultiItem 会批量删除', () async {
    final key = nextKey();
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    storage.setItem('a', 1);
    storage.setItem('b', 2);
    storage.setItem('c', 3);
    await waitDebounce();

    storage.removeMultiItem(['a', 'c']);
    await waitDebounce();

    expect(storage.hasKey('a'), isFalse);
    expect(storage.hasKey('b'), isTrue);
    expect(storage.hasKey('c'), isFalse);
  });

  test('enqueuePersist: 串行执行 + dispose 后跳过后续任务', () async {
    final key = nextKey('enqueue_persist');
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    final log = <int>[];
    final gate = Completer<void>();

    // 任务1：先开始，但会等待 gate 才结束
    (storage as dynamic).enqueuePersist(() async {
      log.add(1);
      await gate.future;
      log.add(2);
    });

    // 任务2：必须等任务1完成后才会开始
    (storage as dynamic).enqueuePersist(() {
      log.add(3);
    });

    // 等待任务1至少开始
    await eventually(() => log.isNotEmpty);
    expect(log, [1]);

    // 放行任务1结束
    gate.complete();
    await eventually(() => log.contains(3));
    expect(log, [1, 2, 3]);

    // dispose 后，后续排队任务应当被跳过
    storage.removeStorage();
    (storage as dynamic).enqueuePersist(() {
      log.add(4);
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(log, isNot(contains(4)));
  });

  test('写入会持久化到文件（io 平台）', () async {
    final key = nextKey('persist');
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    final file = fileOfKey(key);
    expect(file.existsSync(), isTrue);

    storage.setItem('foo', 'bar');
    await waitDebounce();

    await eventually(() {
      try {
        final content = file.readAsStringSync();
        if (content.trim().isEmpty) return false;
        final json = jsonDecode(content) as Map<String, dynamic>;
        return json['foo'] == 'bar';
      } catch (_) {
        return false;
      }
    });
  });

  test('io: 初始化会读取非空 JSON 文件', () async {
    final key = nextKey('load_json');
    final file = fileOfKey(key);
    file.writeAsStringSync(jsonEncode({'x': 1}));

    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    expect(storage.getItem<int>('x'), 1);
  });

  test('io: 初始化读取坏 JSON 会走异常分支并置空数据', () {
    final key = nextKey('load_bad_json');
    final file = fileOfKey(key);
    file.writeAsStringSync('{not_json');

    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    expect(storage.length, 0);
  });

  test('serialize + expire：过期后 getItem 返回 null 且会移除', () async {
    final key = nextKey('expire');
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    final now = DateTime.now();
    storage.setItem<DateTime>(
      'dt',
      now,
      serialize: const ElDateTimeSerialize(),
      expire: const Duration(milliseconds: 200),
    );
    await waitDebounce();

    final v1 = storage.getItem<DateTime>('dt', serialize: const ElDateTimeSerialize());
    expect(v1?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final v2 = storage.getItem<DateTime>('dt', serialize: const ElDateTimeSerialize());
    expect(v2, isNull);
    expect(storage.hasKey('dt'), isFalse);
    await waitDebounce();
  });

  test('setExpire/clearExpire/expireKeys', () async {
    final key = nextKey('clear_expire');
    final storage = ElStorage.createStorage(key, debounceTime: 10);
    addTearDown(storage.removeStorage);

    storage.setItem('a', 1);
    storage.setItem('b', 2);
    await waitDebounce();

    storage.setExpire('a', const Duration(milliseconds: 10));
    await waitDebounce();

    expect(storage.expireKeys, contains('a'));
    await Future<void>.delayed(const Duration(milliseconds: 15));

    final removed = storage.clearExpire();
    await waitDebounce();
    expect(removed, contains('a'));
    expect(storage.hasKey('a'), isFalse);
    expect(storage.hasKey('b'), isTrue);
  });
}
