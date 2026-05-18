part of 'index.dart';

class ElRenderVirtualScroll extends RenderBox {
  ElRenderVirtualScroll(this._ele);

  ElVirtualScrollElement? _ele;

  ElVirtualScrollElement get ele {
    assert(_ele != null, 'ElVirtualScroll 已卸载，不能再访问 element 实例！');
    return _ele!;
  }

  // @override
  // ElTapStyle get style => ElTapStyle(dragAnimate: true);

  Offset scrollPosition = Offset(0.0, 0.0);

  void insertChild(RenderBox box) {
    adoptChild(box);
  }

  void removeChild(RenderBox box) {
    dropChild(box);
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _visibleCallback((node) {
      visitor(node.renderObject);
    });
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    assert(constraints.biggest.isInfinite == false, 'ElVirtualScroll 必须放置在有限宽高的容器内！');
    return constraints.biggest;
  }

  Element? get currentElement {
    return ele._currentLayoutNode?.element;
  }

  Offset get currentOffset {
    return ele._currentLayoutNode!.offset;
  }

  @override
  void performLayout() {
    if (ele._firstNode == null) return;

    final childConstraints = constraints.loosen();

    final start = -scrollPosition.dy;
    final end = constraints.maxHeight + start;

    var firstNode = ele._firstNode;

    // 确认滚动开始边界
    if (firstNode?.element != null && firstNode!.offset.dy != start) {
      if (firstNode.offset.dy + firstNode.renderObject.size.height < start) {
        while (firstNode!.offset.dy < start && firstNode.offset.dy + constraints.maxHeight < end) {
          // safeCallback((){
          //   ele._removeElement(firstNode!);
          // });
          firstNode = firstNode.next;
        }
      } else {
        while (firstNode != null && firstNode.offset.dy > start) {
          firstNode = firstNode.prev;
        }
      }
      ele._firstNode = firstNode;
    }

    ele._currentLayoutNode = ele._firstNode;

    while (ele._currentLayoutNode != null) {
      if (ele._currentLayoutNode!.element == null) {
        invokeLayoutCallback(ele._rebuild);
        final child = ele._currentLayoutNode!.renderObject;
        child.layout(childConstraints, parentUsesSize: true);
        final childParentData = child.parentData as BoxParentData;
        if (ele._currentLayoutNode?.prev == null) {
          childParentData.offset = Offset(0, 0);
        } else {
          childParentData.offset = Offset(
            0,
            (ele._currentLayoutNode!.prev!.offset.dy) + ele._currentLayoutNode!.prev!.renderObject.size.height,
          );
        }
      }
      if (ele._currentLayoutNode!.offset.dy > end) break;
      ele._currentLayoutNode = ele._currentLayoutNode!.next;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _visibleCallback((node) {
      context.paintChild(node.renderObject, offset + node.offset + scrollPosition);
    });
  }

  /// 可视节点回调
  void _visibleCallback(void Function(_Node node) fun) {
    var currentNode = ele._firstNode;
    while (currentNode != null &&
        currentNode.element != null &&
        currentNode.offset.dy < (constraints.maxHeight - scrollPosition.dy)) {
      fun(currentNode);
      currentNode = currentNode.next;
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  // @override
  // double get damping => 0.865;
  //
  // @override
  // double get constantDeceleration => 10.0;
  //
  // @override
  // void onDragUpdate(DragUpdateDetails e) {
  //   double maxDy = double.infinity;
  //   if (ele.linkedList.last.element != null) {
  //     maxDy = ele.linkedList.last.offset.dy - constraints.maxHeight;
  //   }
  //
  //   final newScrollPosition = Offset(
  //     0,
  //     max(min(scrollPosition.dy + e.delta.dy, 0), -maxDy),
  //   );
  //
  //   if (newScrollPosition != scrollPosition) {
  //     scrollPosition = newScrollPosition;
  //     markNeedsLayout();
  //   }
  //
  //   // super.onDragUpdate(e);
  // }

  @override
  void dispose() {
    _ele = null;
    super.dispose();
  }
}
