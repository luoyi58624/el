import '../core/obs.dart';

class MapObs<K, V> extends Obs<Map<K, V>> implements Map<K, V> {
  /// 创建实现 Map 接口的响应式变量，操作集合方法会自动绑定、通知副作用函数
  MapObs(
    super.value, {
    super.onChanged,
    super.immediate,
    super.cacheKey,
    super.serialize,
    super.expire,
    super.keepAliveTime,
    super.storage,
  });

  @override
  initLocalValue() {
    final result = storage.getItem(cacheKey!);
    if (result == null) return null;
    return Map<K, V>.from(result);
  }

  /// 等价于原始 Map 的 [] 运算符
  V? getValueOrNull(Object? key) => value[key];

  /// 为了节省空值判断，默认情况下通过 obs['key'] 访问不允许返回 null
  @override
  V operator [](Object? key) {
    assert(
      value[key] != null,
      'MapObs Error: 通过 [] 访问 value 不允许 null 值，'
      '如果你不确定 value 是否为 null，可以通过 getValueOrNull 方法获取 value',
    );
    return value[key]!;
  }

  @override
  void operator []=(K key, V value) {
    rawValue[key] = value;
    notify();
  }

  @override
  void addAll(Map<K, V> other) {
    rawValue.addAll(other);
    notify();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    rawValue.addEntries(newEntries);
    notify();
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return value.cast<RK, RV>();
  }

  @override
  void clear() {
    rawValue.clear();
    notify();
  }

  @override
  bool containsKey(Object? key) {
    return value.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return this.value.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries => value.entries;

  @override
  void forEach(void Function(K key, V value) action) {
    value.forEach(action);
  }

  @override
  bool get isEmpty => value.isEmpty;

  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  Iterable<K> get keys => value.keys;

  @override
  int get length => value.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    return value.map(convert);
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    return value.putIfAbsent(key, ifAbsent);
  }

  @override
  V? remove(Object? key) {
    final result = rawValue.remove(key);
    notify();
    return result;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    rawValue.removeWhere(test);
    notify();
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final result = rawValue.update(key, update, ifAbsent: ifAbsent);
    notify();
    return result;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    rawValue.updateAll(update);
    notify();
  }

  @override
  Iterable<V> get values => value.values;
}
