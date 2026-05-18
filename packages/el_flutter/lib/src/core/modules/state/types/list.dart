import 'dart:math';

import '../core/obs.dart';

class ListObs<E> extends Obs<List<E>> implements List<E> {
  /// 创建实现 List 接口的响应式变量，操作集合方法会自动绑定、通知副作用函数
  ListObs(
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
    return List<E>.from(result);
  }

  @override
  E get first => value.first;

  @override
  set first(E value) {
    rawValue.first = value;
    notify();
  }

  @override
  E get last => value.last;

  @override
  set last(E value) {
    rawValue.last = value;
    notify();
  }

  @override
  int get length => value.length;

  @override
  set length(int newLength) {
    rawValue.length = newLength;
    notify();
  }

  @override
  List<E> operator +(List<E> other) {
    return value + other;
  }

  @override
  E operator [](int index) {
    return value[index];
  }

  @override
  void operator []=(int index, E value) {
    rawValue[index] = value;
    notify();
  }

  @override
  void add(E value) {
    rawValue.add(value);
    notify();
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
  Map<int, E> asMap() {
    return value.asMap();
  }

  @override
  List<R> cast<R>() {
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
  void fillRange(int start, int end, [E? fillValue]) {
    rawValue.fillRange(start, end, fillValue);
    notify();
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
  Iterable<E> getRange(int start, int end) {
    return value.getRange(start, end);
  }

  @override
  int indexOf(E element, [int start = 0]) {
    return value.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) {
    return value.indexWhere(test, start);
  }

  @override
  void insert(int index, E element) {
    rawValue.insert(index, element);
    notify();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    rawValue.insertAll(index, iterable);
    notify();
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
  int lastIndexOf(E element, [int? start]) {
    return value.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    return value.lastIndexWhere(test, start);
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.lastWhere(test, orElse: orElse);
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
  E removeAt(int index) {
    return value.removeAt(index);
  }

  @override
  E removeLast() {
    return value.removeLast();
  }

  @override
  void removeRange(int start, int end) {
    rawValue.removeRange(start, end);
    notify();
  }

  @override
  void removeWhere(bool Function(E element) test) {
    rawValue.removeWhere(test);
    notify();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    rawValue.replaceRange(start, end, replacements);
    notify();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    rawValue.retainWhere(test);
    notify();
  }

  @override
  Iterable<E> get reversed => value.reversed;

  @override
  void setAll(int index, Iterable<E> iterable) {
    value.setAll(index, iterable);
    notify();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    value.setRange(start, end, iterable, skipCount);
    notify();
  }

  @override
  void shuffle([Random? random]) {
    value.shuffle(random);
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
  void sort([int Function(E a, E b)? compare]) {
    rawValue.sort(compare);
    notify();
  }

  @override
  List<E> sublist(int start, [int? end]) {
    return value.sublist(start, end);
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
  Iterable<E> where(bool Function(E element) test) {
    return value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }
}
