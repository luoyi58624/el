part of 'index.dart';

class ElVirtualScrollElement<D> extends RenderObjectElement {
  ElVirtualScrollElement(super.widget);

  @override
  ElVirtualScroll<D> get widget => super.widget as ElVirtualScroll<D>;

  @override
  ElRenderVirtualScroll get renderObject => super.renderObject as ElRenderVirtualScroll;

  final linkedList = _LinkedList<D>();

  /// 记录页面上开始布局、结束布局、当前处于布局中的节点
  _Node<D>? _firstNode, _currentLayoutNode;

  /// 当 RenderObject 开始循环布局子元素时，会调用此方法
  void builderCallback() {
    final result = widget.itemBuilder(_currentLayoutNode!.value);
    _currentLayoutNode!.element = updateChild(_currentLayoutNode!.element, result, _currentLayoutNode.hashCode);
  }

  // void _removeElement(_Node node) {
  //   node.element = updateChild(node.element, null, node.hashCode);
  // }

  void _rebuild(Constraints constraints) {
    owner!.buildScope(this, builderCallback);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    linkedList.addAll(widget.items.map((e) => _Node(e)));
    _firstNode = linkedList.first;
  }

  @override
  void unmount() {
    linkedList.clear();
    super.unmount();
  }

  @override
  void insertRenderObjectChild(RenderBox child, slot) {
    renderObject.insertChild(child);
  }

  @override
  void moveRenderObjectChild(RenderBox child, oldSlot, newSlot) {}

  @override
  void removeRenderObjectChild(RenderBox child, slot) {
    renderObject.removeChild(child);
  }
}
