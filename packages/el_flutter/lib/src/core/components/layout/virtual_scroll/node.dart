part of 'index.dart';

base class _LinkedList<D> extends ElLinkedList<_Node<D>> {}

base class _Node<D> extends ElLinkedNode<_Node<D>> {
  _Node(this.value);

  final D value;

  Element? element;

  RenderBox get renderObject => element!.renderObject as RenderBox;

  Offset get offset => (renderObject.parentData as BoxParentData).offset;

  set offset(Offset v) {
    (renderObject.parentData as BoxParentData).offset = v;
  }

  @override
  void mount(ElLinkedList<_Node<D>> list, _Node<D>? prev, _Node<D>? next) {
    super.mount(list, prev, next);
  }

  @override
  void unmount() {
    element?.unmount();
    element = null;
    super.unmount();
  }
}

// mixin _VirtualScrollElementMixin<D> on RenderObjectElement {
//   /// 当前绘制元素指针索引：起始、结束
//   late int start, end;
//
//   /// 记录 [ElRenderVirtualScroll] 循环布局子元素的当前索引
//   late int layoutCurrentIndex;
// }
