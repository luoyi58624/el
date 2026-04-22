import 'dart:async';
import 'dart:io';

import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';

import './src/web.dart' if (dart.library.io) './src/io.dart';
import 'src/config.dart';

bool _isInit = false;

/// 默认序列化防抖时间
int _debounceTime = 200;

/// 携带过期时间的 Map key
const _expireKey = 'expire_date';
const _expireDataKey = 'data';

/// 存储已创建的 ElStorage 的 key，防止重复创建
final Set<String> _storageKeys = {};

/// 一个简单的 key - value 本地存储类，在 web 端，它使用 localStorage 进行存储，在客户端则将其保存到文件
abstract class ElStorage {
  /// 访问当前客户端本地存储路径
  static String get storagePath {
    assert($storagePath != null, 'ElStorage Error: The storagePath has not been initialized yet!');
    return $storagePath!;
  }

  /// 初始化 ElStorage 存储配置
  /// * storagePath 存储路径，在 Web 端会被忽略，在客户端默认使用 [Directory.current] 访问当前路径
  /// * storageDir 存储文件夹，若不为 null，则会与 [storagePath] 进行拼接
  /// * debounceTime 设置默认的序列化防抖时间，默认：200 毫秒
  ///
  /// 提示：对于 Flutter App 项目，必须使用 path_provider 设置存储目录，示例：
  /// ```dart
  /// import 'package:flutter/foundation.dart';
  /// import 'package:path_provider/path_provider.dart';
  ///
  /// void main() async {
  ///   ElStorage.init(
  ///     storagePath: kIsWeb ? null : (await getApplicationSupportDirectory()).path
  ///   );
  /// }
  /// ```
  static void init({String? storagePath, String? storageDir, int debounceTime = 200}) {
    if (_isInit) return;
    _isInit = true;
    _debounceTime = debounceTime;
    $init(storagePath, storageDir);
  }

  /// 创建本地存储对象，你可以指定不同的 key 创建多个隔离的存储对象。
  /// * debounceTime 序列化防抖时间，默认 200 毫秒
  ///
  /// 注意：禁止重复创建相同 key 的存储对象，执行 [removeStorage] 方法会将 key 从集合中移除
  static ElStorage createStorage(String key, {int? debounceTime}) {
    assert(_isInit, 'ElStorage Error: Please call ElStorage.init()');
    assert(!_storageKeys.contains(key), 'ElStorage Error: The key "$key" has already been used');
    return $Storage(key, debounceTime ?? _debounceTime);
  }

  /// 检查存储 key 是否存在
  static bool checkStorageKey(String key) => _storageKeys.contains(key);

  ElStorage(this.key, int debounceTime) {
    _storageKeys.add(key);
    execSerialize = ElAsyncUtil.debounce(write, debounceTime);
  }

  /// 用于区分多个存储对象
  @protected
  final String key;

  /// 本地存储对象，默认情况下，数据直接以 key - value 存储，但如果设置了缓存时间，
  /// 那么 value 会再包裹一层 Map，其结构包含 2 个关键 key：[_expireKey]、[_expireDataKey]
  @protected
  late final Map<String, dynamic> data;

  /// 执行序列化，将数据保存到本地，此方法添加了防抖处理
  @protected
  late Function execSerialize;

  /// 判断是否执行了 [removeStorage] 方法
  @protected
  bool? isDispose;

  /// 写入本地数据方法，web 平台会将数据写入到 localStorage 中，客户端则写入到文件中
  @protected
  @mustCallSuper
  void write() {
    assert(isDispose != true, 'ElStorage Error: The ElStorage has been disposed');
  }

  Future<void> _persistQueue = Future<void>.value();

  /// 统一的“串行持久化队列”，避免并发写入导致竞态，dispose 后会自动跳过后续排队任务。
  @protected
  void enqueuePersist(FutureOr<void> Function() task) {
    _persistQueue = _persistQueue.then((_) async {
      if (isDispose == true) return;
      await task();
    });
  }

  /// 彻底移除本地存储，此方法在 Web 端会移除 localStorage 数据，在客户端则删除本地存储文件。
  ///
  /// 注意：如果只是为了清除数据，请优先考虑调用 [clear] 方法，此方法应当只用于清理临时存储对象，
  /// 一旦执行此 Api，当前 Storage 对象将不可使用，你必须解除当前 Storage 对象的引用：
  /// ```dart
  /// ElStorage? _storage;
  ///
  /// void dispose(){
  ///   if(_storage == null) return;
  ///   _storage!.removeStorage();
  ///   _storage = null;
  /// }
  /// ```
  ///
  @mustCallSuper
  void removeStorage() {
    isDispose = true;
    data.clear();
    _storageKeys.remove(key);
  }

  /// 存储的 key 数量
  int get length => data.length;

  /// 访问所有 key
  Iterable<String> get keys => data.keys;

  /// 访问所有过期 key
  List<String> get expireKeys {
    List<String> result = [];
    for (final key in data.keys) {
      if (checkExpire(key)) result.add(key);
    }
    return result;
  }

  /// 检查是否存在 key 数据
  bool hasKey(String key) => data.containsKey(key);

  /// 判断当前数据是否携带过期对象
  bool isExpireData(dynamic result) {
    return result is Map && result.containsKey(_expireKey);
  }

  /// 设置数据
  void setItem<T>(
    String key,
    T value, {
    ElSerialize? serialize, // 如果 value 不是基本类型，那么必须指定序列化才能正确缓存
    Duration? expire, // 设置过期时间
  }) {
    var result = serialize == null ? value : serialize.serialize(value);

    if (expire != null) {
      result = {_expireKey: ElDateUtil.currentMilliseconds + expire.inMilliseconds, _expireDataKey: result};
    }

    data[key] = result;
    execSerialize();
  }

  /// 获取数据
  T? getItem<T>(String key, {ElSerialize? serialize}) {
    if (checkExpire(key)) {
      removeItem(key);
      return null;
    } else {
      var result = data[key];
      if (result == null) return null;
      if (isExpireData(result)) result = result[_expireDataKey];
      return serialize == null ? result : serialize.deserialize(result);
    }
  }

  /// 删除数据
  void removeItem(String key) {
    data.remove(key);
    execSerialize();
  }

  /// 批量删除数据
  void removeMultiItem(Iterable<String> keys) {
    for (final key in keys) {
      data.remove(key);
    }
    execSerialize();
  }

  /// 清空数据
  void clear() {
    data.clear();
    execSerialize();
  }

  /// 给已有的数据设置过期时间
  /// * includeUpdate 是否允许更新过期时间，若为 false，目标已经设置过期时间将不进行任何操作
  void setExpire(String key, Duration expire, {bool includeUpdate = true}) {
    var result = getItem(key);
    if (result == null) return;

    if (result is Map) {}
    result = {_expireKey: ElDateUtil.currentMilliseconds + expire.inMilliseconds, _expireDataKey: result};
    data[key] = result;
    execSerialize();
  }

  /// 检查数据是否已过期
  /// * includeNull 是否包含 null 数据，默认情况下 null 结果也会当作过期数据
  bool checkExpire(String key, {bool includeNull = true}) {
    final result = data[key];
    if (result == null) return includeNull;

    if (isExpireData(result)) {
      if (result[_expireKey] <= ElDateUtil.currentMilliseconds) {
        return true;
      }
    }

    return false;
  }

  /// 清除已过期的数据
  List<String> clearExpire() {
    final keys = expireKeys;
    for (final key in keys) {
      data.remove(key);
    }

    execSerialize();
    return keys;
  }
}
