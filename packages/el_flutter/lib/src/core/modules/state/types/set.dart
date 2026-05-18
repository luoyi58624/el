import '../core/obs.dart';

class SetObs<E> extends Obs<Set<E>> implements Set<E> {
  /// 创建实现 Set 接口的响应式变量，操作集合方法会自动绑定、通知副作用函数
  SetObs(
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
    return Set<E>.from(result);
  }

  @override
  E get first => value.first;

  @override
  E get last => value.last;

  @override
  int get length => value.length;

  @override
  bool add(E value) {
    final result = rawValue.add(value);
    notify();
    return result;
  }

  @override
  void addAll(Iterable<E> elements) {
    rawValue.addAll(elements);
    notify();
  }

  @override
  bool any(bool Function(E element) test) {
    return value.any(test);
  }

  @override
  Set<R> cast<R>() {
    return value.cast<R>();
  }

  @override
  void clear() {
    rawValue.clear();
    notify();
  }

  @override
  bool contains(Object? element) {
    return value.contains(element);
  }

  @override
  bool containsAll(Iterable<Object?> other) {
    return value.containsAll(other);
  }

  @override
  Set<E> difference(Set<Object?> other) {
    return value.difference(other);
  }

  @override
  E elementAt(int index) {
    return value.elementAt(index);
  }

  @override
  bool every(bool Function(E element) test) {
    return value.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    return value.expand(toElements);
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return value.fold(initialValue, combine);
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return value.followedBy(other);
  }

  @override
  void forEach(void Function(E element) action) {
    rawValue.forEach(action);
  }

  @override
  Set<E> intersection(Set<Object?> other) {
    return value.intersection(other);
  }

  @override
  bool get isEmpty => value.isEmpty;

  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  String join([String separator = ""]) {
    return value.join(separator);
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.lastWhere(test, orElse: orElse);
  }

  @override
  E? lookup(Object? object) {
    return value.lookup(object);
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    return value.map(toElement);
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    return value.reduce(combine);
  }

  @override
  bool remove(Object? value) {
    final result = this.value.remove(value);
    notify();
    return result;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    rawValue.removeAll(elements);
    notify();
  }

  @override
  void removeWhere(bool Function(E element) test) {
    rawValue.removeWhere(test);
    notify();
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    rawValue.retainAll(elements);
    notify();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    rawValue.retainWhere(test);
    notify();
  }

  @override
  E get single => value.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<E> skip(int count) {
    return value.skip(count);
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return value.skipWhile(test);
  }

  @override
  Iterable<E> take(int count) {
    return value.take(count);
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return value.takeWhile(test);
  }

  @override
  List<E> toList({bool growable = true}) {
    return value.toList(growable: growable);
  }

  @override
  Set<E> toSet() {
    return value.toSet();
  }

  @override
  Set<E> union(Set<E> other) {
    return value.union(other);
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    return value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }
}
