import 'package:collection/collection.dart';

extension ElDartListExt<E> on List<E> {
  static const _listEquality = ListEquality();

  /// 判断两个 List 是否相等
  bool eq(List other) => _listEquality.equals(this, other);

  /// 判断两个 List 是否不相等
  bool neq(List other) => !eq(other);

  /// 复制指定数量的新数组
  List<E> operator *(int num) {
    List<E> newList = [];
    for (int i = 0; i < num; i++) {
      newList.addAll(this);
    }
    return newList;
  }

  /// 在数组之间插入元素
  List<E> insertBetween(E value) {
    if (isEmpty) return this;

    List<E> newList = [];
    for (int i = 0; i < length; i++) {
      newList.add(this[i]);
      if (i < length - 1) newList.add(value);
    }

    return newList;
  }

  /// 将数组元素从指定位置移到新的位置，若移动成功将返回 true
  bool move(int from, int to, [E? target]) {
    if (from == to) return false;
    if (from < 0 || from >= length || to < 0 || to >= length) return false;

    final element = target ?? this[from];
    if (from < to) {
      // 向后移动：保留原元素，覆盖后续位置
      setRange(from, to, this, from + 1);
    } else {
      // 向前移动：先移动后续元素，再插入
      setRange(to + 1, from + 1, this, to);
    }
    this[to] = element;
    return true;
  }

  /// 循环获取列表的内容，如果其索引大于列表的长度，则重头开始继续获取
  E loopGetContent(int index) {
    if (index <= 0) {
      return this[0];
    } else if (index < length) {
      return this[index];
    } else {
      return loopGetContent(index - length);
    }
  }
}

extension ElDartSetExt<E> on Set<E> {
  static const _setEquality = SetEquality();

  /// 判断两个 Set 是否相等
  bool eq(Set other) => _setEquality.equals(this, other);

  /// 判断两个 Set 是否不相等
  bool neq(Set other) => !eq(other);
}

extension ElDartIterableExt<E> on Iterable<E> {
  /// 判断集合是否只有一个有效值，例如：
  /// * [1, null, null] -> true
  /// * [1, 1, null] -> false
  ///
  /// 设置 allowAllNull 则允许所有变量都可以为 null
  bool onlyOne({bool allowAllNull = false}) {
    final l = where((e) => e != null).length;
    return allowAllNull ? l == 0 || l == 1 : l == 1;
  }
}
