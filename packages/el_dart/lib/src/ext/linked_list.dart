import 'package:meta/meta.dart';

/// 双向链表
class ElLinkedList<N extends ElLinkedNode<N>> extends Iterable<N> {
  /// 链表长度
  @override
  int get length => _length;
  int _length = 0;

  /// 第一个节点
  @override
  N get first {
    assert(_first != null, 'ElLinkedList Error: 访问 first 错误，链表还未初始化！');
    return _first!;
  }

  N? get firstOrNull => _first;
  N? _first;

  /// 最后一个节点
  @override
  N get last {
    assert(_last != null, 'ElLinkedList Error: 访问 last 错误，链表还未初始化！');
    return _last!;
  }

  N? get lastOrNull => _last;
  N? _last;

  @override
  Iterator<N> get iterator => _ElLinkedListIterator<N>(this);

  @override
  bool get isEmpty => length == 0;

  /// 初始化节点
  void initNode(N node) {
    assert(
      _length == 0 && _first == null && _last == null,
      'ElLinkedList Error: 初始化节点出现错误，链表内部状态不一致！\n'
      'length: $length\n' // coverage:ignore-line
      'first: $first\n' // coverage:ignore-line
      'last: $last\n', // coverage:ignore-line
    );
    node.mount(this, null, null);
    _first = node;
    _last = node;
  }

  /// 添加一个节点
  void add(N node) {
    if (_last != null) {
      last._next = node;
      node.mount(this, last, null);
      _last = node;
    } else {
      initNode(node);
    }
  }

  /// 在前面添加一个节点
  void addFirst(N node) {
    if (_first != null) {
      first._prev = node;
      node.mount(this, null, first);
      _first = node;
    } else {
      initNode(node);
    }
  }

  /// 添加多个节点
  void addAll(Iterable<N> nodes) {
    nodes.forEach(add);
  }

  /// 在前面添加多个节点，注意：如果要保持 List 插入顺序，请反转集合
  void addAllFirst(Iterable<N> nodes) {
    nodes.forEach(addFirst);
  }

  /// 在目标节点插入新的节点：
  /// * targetNode 目标节点
  /// * newNode 插入的新节点，如果已关联，则执行移动操作
  /// * isBefore 是否将新节点将插入到前面
  void insert(N targetNode, N newNode, {bool isBefore = false}) {
    if (isBefore) {
      newNode.mount(this, targetNode.prev, targetNode);
      if (targetNode.prev != null) targetNode.prev!._next = newNode;
      targetNode._prev = newNode;
      if (newNode.prev == null) _first = newNode;
    } else {
      newNode.mount(this, targetNode, targetNode.next);
      if (targetNode.next != null) targetNode.next!._prev = newNode;
      targetNode._next = newNode;
      if (newNode.next == null) _last = newNode;
    }
  }

  /// 交换两个节点的位置
  void swap(N node1, N node2) {
    assert(
      node1.mounted && node2.mounted,
      'ElLinkedList Error: swap 交换的两个节点必须都处于挂载状态！\n'
      '$node1\n'
      '$node2',
    );

    assert(
      node1.list == this && node2.list == this,
      'ElLinkedList Error: swap 交换的两个节点必须指向同一个链表对象！\n'
      '$node1\n'
      '$node2',
    );

    assert(node1 != node2, 'ElLinkedList Error: swap 交换的两个节点不能相同！');

    if (node1.next == node2) {
      assert(node2.prev == node1);
      node1._next = node2.next;
      node2._prev = node1.prev;
      node1._prev = node2;
      node2._next = node1;
    } else if (node1.prev == node2) {
      assert(node2.next == node1);
      node1._prev = node2.prev;
      node2._next = node1.next;
      node1._next = node2;
      node2._prev = node1;
    } else {
      final prev1 = node1.prev;
      final next1 = node1.next;
      final prev2 = node2.prev;
      final next2 = node2.next;

      node1._prev = prev2;
      node1._next = next2;
      node2._prev = prev1;
      node2._next = next1;
    }

    if (node1.prev == null) {
      _first = node1;
    } else {
      node1.prev!._next = node1;
    }

    if (node2.prev == null) {
      _first = node2;
    } else {
      node2.prev!._next = node2;
    }

    if (node1.next == null) {
      _last = node1;
    } else {
      node1.next!._prev = node1;
    }

    if (node2.next == null) {
      _last = node2;
    } else {
      node2.next!._prev = node2;
    }
  }

  /// 按条件查找节点
  N? find(bool Function(N element) test) {
    var currentNode = _first;
    while (currentNode != null) {
      if (test(currentNode)) return currentNode;
      currentNode = currentNode.next;
    }
    return null;
  }

  /// 根据下标寻找目标节点，首尾查找很便宜，寻找中间节点耗时最长，时间复杂度 O(n) / 2
  @override
  N elementAt(int index) {
    assert(index >= 0 && index < length, 'ElLinkedList Error: 链表索引溢出异常 (0 <= $index < $length)');
    late N currentNode;

    if (index > length / 2) {
      currentNode = last;
      for (int i = length - 2; i >= index; i--) {
        currentNode = currentNode.prev!;
      }
    } else {
      currentNode = first;
      for (int i = 1; i <= index; i++) {
        currentNode = currentNode.next!;
      }
    }

    return currentNode;
  }

  /// 删除节点
  void remove(N node) {
    if (node.prev != null) {
      node.prev!._next = node.next;
    } else {
      _first = node.next;
    }

    if (node.next != null) {
      node.next!._prev = node.prev;
    } else {
      _last = node.prev;
    }

    node.unmount();

    if (length == 0) {
      _first = null;
      _last = null;
    }
  }

  /// 清空链表
  void clear() {
    var currentNode = _first;
    while (currentNode != null) {
      final nextNode = currentNode.next;
      currentNode.unmount();
      currentNode = nextNode;
    }
    _first = null;
    _last = null;
  }

  /// 打印链表时限制最大长度
  int get maxPrintLength => 100;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType [');

    int maxPrintLength = this.maxPrintLength;
    var currentNode = _first;

    if (length <= maxPrintLength) {
      while (currentNode != null) {
        buffer.write(currentNode.debugLabel);
        if (currentNode.next != null) buffer.write(', ');
        currentNode = currentNode.next;
      }
    } else {
      while (currentNode != null) {
        buffer.write(currentNode.debugLabel);

        if (currentNode.next != null) buffer.write(', ');
        currentNode = currentNode.next;

        maxPrintLength--;
        if (maxPrintLength <= 0) {
          buffer.write('...');
          break;
        }
      }

      buffer.write(', ${last.debugLabel}');
    }

    buffer.write(']');
    return buffer.toString();
  }
}

/// 双向链表节点对象，你需要继承此类才能在 [ElLinkedList] 中使用：
/// ```dart
/// class _Node extends ElLinkedNode<_Node> {}
///
/// void main() {
///   final list = ElLinkedList<_Node>();
///   list.add(_Node());
/// }
/// ```
///
/// 或者使用 mixin 混入：
/// ```dart
/// // 扩展链表类（可选）
/// class _LinkedList<D> extends ElLinkedList<_Node<D>> {}
///
/// class _Node<D> with ElLinkedNode<_Node<D>> {
///   _Node(this.data);
///
///   D data; // 添加数据
/// }
///
/// void main() {
///   final list = _LinkedList<int>(); // 子节点必须设置 int 类型数据
///   list.add(_Node(1));
///   list.add(_Node(2));
/// }
/// ```
abstract mixin class ElLinkedNode<N extends ElLinkedNode<N>> {
  /// 上一个节点
  N? get prev => _prev;
  N? _prev;

  /// 下一个节点
  N? get next => _next;
  N? _next;

  /// 当前节点是否处于挂载中，当一个节点对象已经挂载，就不能再继续插入，
  /// 除非先解除当前关联，才可以将节点重新插入到链表中
  bool get mounted => _list != null;

  /// 访问当前节点所在的链表
  ElLinkedList<N> get list {
    assert(_list != null, 'ElLinkedNode Error: 请在 mount 挂载之后再访问 list 对象');
    return _list!;
  }

  ElLinkedList<N>? _list;

  /// 调试标签
  String get debugLabel => hashCode.toString();

  /// 当节点被关联时调用
  @protected
  @mustCallSuper
  void mount(ElLinkedList<N> list, N? prev, N? next) {
    assert(
      _list == null,
      'ElLinkedNode Error: 节点已经挂载，不可重复关联链表！\n'
      '$this',
    );
    _prev = prev;
    _next = next;
    _list = list;
    list._length++;
  }

  /// 当节点被移除时调用
  @protected
  @mustCallSuper
  void unmount() {
    list._length--;
    _list = null;
    _prev = null;
    _next = null;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType [');
    buffer.write('${prev?.debugLabel} <- ');
    buffer.write(debugLabel);
    buffer.write(' -> ${next?.debugLabel}');
    buffer.write(']');
    return buffer.toString();
  }
}

class _ElLinkedListIterator<N extends ElLinkedNode<N>> implements Iterator<N> {
  final ElLinkedList<N> _list;
  late final int _modificationLength; // 迭代期间不要增删节点
  N? _current;

  _ElLinkedListIterator(this._list) {
    _modificationLength = _list.length;
  }

  @override
  N get current => _current as N;

  @override
  bool moveNext() {
    if (_modificationLength != _list.length) {
      throw ConcurrentModificationError(this);
    }
    if (_current == null) {
      _current = _list._first;
      return _current != null;
    } else {
      if (_current!._next != null) {
        _current = _current!.next;
        return true;
      }
    }
    return false;
  }
}
