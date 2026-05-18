import 'dart:collection';
import 'package:el_dart/ext.dart';

import 'package:test/test.dart';

class _Node<D> extends ElLinkedNode<_Node<D>> {
  _Node(this.value);

  D value;

  int mountedCount = 0;

  List<D> toList() => list.map((e) => e.value).toList();

  @override
  void mount(ElLinkedList<_Node<D>> list, _Node<D>? prev, _Node<D>? next) {
    mountedCount++;
    super.mount(list, prev, next);
  }

  @override
  String get debugLabel => value.toString();
}

base class _Entry<D> extends LinkedListEntry<_Entry<D>> {
  _Entry(this.value);

  D value;
}

void main() {
  group('双向链表测试', () {
    test('基础测试', () {
      final linkedList = ElLinkedList<_Node<int>>();
      final node = _Node(1);
      final node2 = _Node(2);
      final node3 = _Node(3);
      final node4 = _Node(4);
      final node5 = _Node(5);

      linkedList.add(node);
      expect(node.toList().eq([1]), true);

      linkedList.insert(linkedList.last, node2);
      expect(node.toList().eq([1, 2]), true);

      linkedList.insert(node2, node3, isBefore: true);
      expect(node.toList().eq([1, 3, 2]), true);

      linkedList.insert(node3, node4);
      expect(node.toList().eq([1, 3, 4, 2]), true);

      linkedList.insert(node3, node5, isBefore: true);
      expect(node.toList().eq([1, 5, 3, 4, 2]), true);

      expect(linkedList.elementAt(0).value, 1);
      expect(linkedList.elementAt(1).value, 5);
      expect(linkedList.elementAt(2).value, 3);
      expect(linkedList.elementAt(3).value, 4);
      expect(linkedList.elementAt(4).value, 2);

      linkedList.addFirst(_Node(-100));
      expect(node.toList().eq([-100, 1, 5, 3, 4, 2]), true);

      expect(linkedList.elementAt(0).value, -100);
      expect(linkedList.elementAt(1).value, 1);
      expect(linkedList.elementAt(2).value, 5);
      expect(linkedList.elementAt(3).value, 3);
      expect(linkedList.elementAt(4).value, 4);
      expect(linkedList.elementAt(5).value, 2);

      expect(linkedList.where((e) => e.value > 3).map((e) => e.value).toList().eq([5, 4]), true);
    });

    test('集合操作', () {
      final list = List.generate(10, (index) => index);
      final linkedList = ElLinkedList<_Node<int>>();
      linkedList.addAll(list.map((e) => _Node(e)));

      expect(linkedList.first.toList().eq(list), true);
      expect(linkedList.first.value, 0);
      expect(linkedList.first.prev?.value, null);
      expect(linkedList.first.next?.value, 1);
      expect(linkedList.length, 10);
      expect(linkedList.last.value, 9);
      expect(linkedList.last.next?.value, null);
      expect(linkedList.last.prev?.value, 8);
      expect(linkedList.elementAt(0).value, 0);
      expect(linkedList.elementAt(1).value, 1);
      expect(linkedList.elementAt(4).value, 4);
      expect(linkedList.elementAt(9).value, 9);
      expect(linkedList.find((e) => e.value == 5)?.value, 5);
      expect(linkedList.find((e) => e.value > 10)?.value, null);

      // 在最前面插入一个节点
      linkedList.insert(linkedList.first, _Node(-1), isBefore: true);
      expect(linkedList.first.toList().eq([-1, ...list]), true);
      expect(linkedList.length, 11);
      expect(linkedList.first.value, -1);
      expect(linkedList.elementAt(4).value, 3);

      // 解除第二个节点
      linkedList.remove(linkedList.elementAt(1));
      expect(linkedList.first.toList().eq([-1, ...list.skip(1)]), true);

      // 在第二个节点后面插入一个名为 100 的节点
      linkedList.insert(linkedList.elementAt(1), _Node(100));
      expect(linkedList.first.toList().eq([-1, 1, 100, ...list.skip(2)]), true);
      expect(linkedList.elementAt(2).value, 100);
      expect(linkedList.elementAt(2).prev?.value, 1);
      expect(linkedList.elementAt(2).next?.value, 2);
      expect(linkedList.elementAt(3).value, 2);
      expect(linkedList.elementAt(3).prev?.value, 100);
      expect(linkedList.elementAt(3).next?.value, 3);
    });

    test('交换节点位置', () {
      final linkedList = ElLinkedList<_Node<int>>()..addAll(List.generate(5, (index) => _Node(index)));

      linkedList.swap(linkedList.first, linkedList.elementAt(1));
      expect(linkedList.first.toList().eq([1, 0, 2, 3, 4]), true);

      linkedList.swap(linkedList.first, linkedList.elementAt(2));
      expect(linkedList.first.toList().eq([2, 0, 1, 3, 4]), true);

      linkedList.swap(linkedList.first, linkedList.last);
      expect(linkedList.first.toList().eq([4, 0, 1, 3, 2]), true);

      linkedList.swap(linkedList.elementAt(1), linkedList.elementAt(2));
      expect(linkedList.first.toList().eq([4, 1, 0, 3, 2]), true);

      linkedList.swap(linkedList.elementAt(1), linkedList.elementAt(3));
      expect(linkedList.first.toList().eq([4, 3, 0, 1, 2]), true);

      linkedList.swap(linkedList.last, linkedList.last.prev!);
      expect(linkedList.first.toList().eq([4, 3, 0, 2, 1]), true);

      linkedList.swap(linkedList.last, linkedList.first.next!);
      expect(linkedList.first.toList().eq([4, 1, 0, 2, 3]), true);

      linkedList.swap(linkedList.last.prev!, linkedList.first.next!);
      expect(linkedList.first.toList().eq([4, 2, 0, 1, 3]), true);

      linkedList.swap(linkedList.last.prev!, linkedList.first);
      expect(linkedList.first.toList().eq([1, 2, 0, 4, 3]), true);
    });

    test('节点重复卸载、挂载', () {
      final linkedList = ElLinkedList<_Node<int>>();

      final node = _Node(1);
      final node2 = _Node(2);

      linkedList.add(node);
      expect(node.mountedCount, 1);

      linkedList.add(node2);
      expect(linkedList.first.toList().eq([1, 2]), true);

      linkedList.remove(node);
      linkedList.add(node);
      expect(node.mountedCount, 2);
      expect(linkedList.first.toList().eq([2, 1]), true);
      expect(linkedList.first.value, 2);
      expect(linkedList.first.prev?.value, null);
      expect(linkedList.first.next?.value, 1);

      linkedList.remove(node);
      linkedList.insert(linkedList.first, node, isBefore: true);
      expect(node.mountedCount, 3);
      expect(linkedList.first.toList().eq([1, 2]), true);
    });
  });

  test('ElLinkedList 性能测试', () {
    final nodes = List.generate(100000, (index) => _Node(index));
    final linkedList = ElLinkedList<_Node<int>>();
    final stopwatch = Stopwatch()..start();
    linkedList.addAll(nodes);
    stopwatch.stop();
    print('ElLinkedList 添加 10 万条数据耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    linkedList.insert(linkedList.elementAt(linkedList.length - 100), _Node(1000000));
    stopwatch.stop();
    print('ElLinkedList 插入节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    linkedList.remove(linkedList.elementAt(linkedList.length - 100));
    stopwatch.stop();
    print('ElLinkedList 删除节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    linkedList.swap(linkedList.first, linkedList.last);
    stopwatch.stop();
    print('ElLinkedList 移动节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    linkedList.clear();
    stopwatch.stop();
    print('ElLinkedList 清空节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
  });

  test('LinkedList 性能测试', () {
    final entrys = List.generate(100000, (index) => _Entry(index));
    final linkedList = LinkedList<_Entry<int>>();
    final stopwatch = Stopwatch()..start();
    linkedList.addAll(entrys);
    stopwatch.stop();
    print('LinkedList 添加 10 万条数据耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    entrys[entrys.length - 100].insertAfter(_Entry(100000));
    stopwatch.stop();
    print('LinkedList 插入节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    linkedList.remove(entrys[entrys.length - 100]);
    stopwatch.stop();
    print('LinkedList 删除节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
    stopwatch.reset();
    stopwatch.start();
    linkedList.clear();
    stopwatch.stop();
    print('LinkedList 清空节点耗时：${stopwatch.elapsedMicroseconds / 1000} 毫秒');
  });
}
