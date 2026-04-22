import 'package:collection/collection.dart';

extension ElDartMapExt<K, V> on Map<K, V> {
  static const _mapEquality = MapEquality();

  /// 判断两个 Map 是否相等
  bool eq(Map other) => _mapEquality.equals(this, other);

  /// 判断两个 Map 是否不相等
  bool neq(Map other) => !eq(other);

  /// 根据过滤条件返回一个新的Map
  Map<K, V> filter(bool Function(K key, V value) test) {
    Map<K, V> newMap = {};
    for (K k in keys) {
      if (test(k, this[k] as V)) {
        newMap[k] = this[k] as V;
      }
    }
    return newMap;
  }

  /// 根据keys集合，返回一个新的Map
  Map<K, V> filterFromKeys(List<K> keys) {
    Map<K, V> newMap = {};
    for (K key in keys) {
      newMap[key] = this[key] as V;
    }
    return newMap;
  }

  /// 根据 value 查找 key
  K? getKeyByValue(V value) {
    for (final entry in entries) {
      if (entry.value == value) return entry.key;
    }
    return null;
  }

  /// 将 Map 转成 List
  List<T> mapToList<T>(T Function(K key, V value) toElement) {
    final List<T> result = [];
    for (final entry in entries) {
      result.add(toElement(entry.key, entry.value));
    }
    return result;
  }

  /// 将 Map 转成 Set
  Set<T> mapToSet<T>(T Function(K key, V value) toElement) {
    final Set<T> result = {};
    for (final entry in entries) {
      result.add(toElement(entry.key, entry.value));
    }
    return result;
  }
}
