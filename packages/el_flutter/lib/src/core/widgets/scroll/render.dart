part of 'index.dart';

class _RenderViewport extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WrapParentData>
    implements RenderAbstractViewport {
  _RenderViewport(
    this._offset,
    this._clipBehavior,
    this._padding,
    this._center,
    this._excludeSemantics,
    this._debugLabel,
  );

  RenderBox? _emptyChild;

  RenderBox get emptyChild => _emptyChild!;

  set emptyChild(RenderBox? v) {
    if (_emptyChild == v) return;
    if (_emptyChild != null) {
      dropChild(_emptyChild!);
    }
    _emptyChild = v;
    if (_emptyChild != null) {
      adoptChild(_emptyChild!);
    }
  }

  ViewportOffset get offset => _offset;
  ViewportOffset _offset;

  set offset(ViewportOffset value) {
    if (value == _offset) return;
    if (attached) {
      _offset.removeListener(scrollListener);
    }
    _offset = value;
    if (attached) {
      _offset.addListener(scrollListener);
    }
    markNeedsLayout();
  }

  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.none;

  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  EdgeInsets get padding => _padding;
  EdgeInsets _padding;

  set padding(EdgeInsets value) {
    assert(value.isNonNegative);
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsLayout();
  }

  bool _center = false;

  set center(bool value) {
    if (value != _center) {
      _center = value;
      markNeedsLayout();
    }
  }

  bool _excludeSemantics = false;

  set excludeSemantics(bool value) {
    if (value != _excludeSemantics) {
      _excludeSemantics = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  String? _debugLabel;

  set debugLabel(String? value) {
    if (value != _debugLabel) {
      _debugLabel = value;
      markNeedsLayout();
    }
  }

  @override
  bool get isRepaintBoundary => true;

  void scrollListener() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(scrollListener);
    _emptyChild?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _offset.removeListener(scrollListener);
    _emptyChild?.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    if (_emptyChild != null) visitor(emptyChild);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapParentData) {
      child.parentData = WrapParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return getDryLayout(BoxConstraints(maxHeight: height)).width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return getDryLayout(BoxConstraints(maxHeight: height)).width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      height = max(height, child.getMinIntrinsicHeight(double.infinity));
      child = childAfter(child);
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      height += child.getMaxIntrinsicHeight(double.infinity);
      child = childAfter(child);
    }
    return height;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_excludeSemantics) return;

    for (int i = paintEnd; i >= paintStart; i--) {
      visitor(children[i]);
    }
  }

  List<RenderBox> children = [];
  Size childrenSize = Size.zero;
  int paintStart = 0; // 记录开始绘制的节点索引
  int paintEnd = 0; // 记录结束绘制的节点索引

  BoxConstraints get childConstraints => BoxConstraints(
    maxWidth: max(constraints.maxWidth - padding.horizontal, 0),
    maxHeight: double.infinity,
    minWidth: 0,
    minHeight: 0,
  );

  double get _viewportExtent => size.height;

  double get _minScrollExtent => 0.0;

  double get _maxScrollExtent => max(childrenSize.height - size.height, 0.0);

  Offset get _paintOffset => _paintOffsetForPosition(offset.pixels);

  Offset _paintOffsetForPosition(double position) {
    return Offset(0.0, -position);
  }

  @override
  void performLayout() {
    () {
      emptyChild.layout(const BoxConstraints(maxWidth: 0.0, maxHeight: 0.0));

      final childConstraints = this.childConstraints;
      var child = firstChild;
      double height = 0.0;
      children = [];
      while (child != null) {
        final childParentData = child.parentData as WrapParentData;

        child.layout(childConstraints, parentUsesSize: true);

        double dx = padding.left;
        if (_center) {
          dx += (constraints.maxWidth - padding.horizontal) / 2 - child.size.width / 2;
        }
        childParentData.offset = Offset(dx, padding.top + height);
        height += child.size.height;
        children.add(child);
        child = childAfter(child);
      }

      paintStart = 0;
      paintEnd = children.length - 1;

      childrenSize = Size(constraints.maxWidth, height + padding.vertical);
      size = constraints.constrain(childrenSize);

      if (offset.hasPixels) {
        if (offset.pixels > _maxScrollExtent) {
          offset.correctBy(_maxScrollExtent - offset.pixels);
        } else if (offset.pixels < _minScrollExtent) {
          offset.correctBy(_minScrollExtent - offset.pixels);
        }
      }

      offset.applyViewportDimension(_viewportExtent);
      offset.applyContentDimensions(_minScrollExtent, _maxScrollExtent);
    }.time(debugLabel: '${_debugLabel}ElScroll 布局', enabled: _debugLabel != null);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void paintContents(PaintingContext context, Offset offset) {
      if (children.isEmpty) return;

      // 将绘制的起始坐标点、结束坐标点限制在滚动的当前页面内，在此范围之外的所有元素都不会绘制
      final startOffset = this.offset.pixels;
      final endOffset = startOffset + size.height;
      final currentOffset = (children[paintStart].parentData as BoxParentData).offset.dy;

      // 记录新的起始节点，必须等绘制结束时再设置到 paintStart 变量
      int newStart = 0;

      // 当起始坐标点大于之前的偏移位置时，意味着用户开始向下滚动，否则向上滚动，
      // 向下滚动我们需要寻找后面的元素作为新的起始值，向上滚动则寻找前面的元素作为新的起始值
      if (startOffset > currentOffset) {
        for (int i = paintStart; i < children.length; i++) {
          final dy = (children[i].parentData as BoxParentData).offset.dy + children[i].size.height;
          if (dy >= startOffset) {
            newStart = i;
            break;
          }
        }
      } else {
        for (int i = paintStart; i >= 0; i--) {
          final dy = (children[i].parentData as BoxParentData).offset.dy;
          if (dy <= startOffset) {
            newStart = i;
            break;
          }
        }
      }

      bool? flag;

      // 确定好新的起始点后，开始绘制
      for (int i = newStart; i < children.length; i++) {
        final childOffset = (children[i].parentData as BoxParentData).offset;

        // 绘制元素的偏移值如果在屏幕之外，则中断循环
        if (childOffset.dy > endOffset) {
          flag = true;
          paintEnd = i;
          break;
        }

        context.paintChild(
          children[i],
          Offset(offset.dx + childOffset.dx, offset.dy + childOffset.dy - this.offset.pixels),
        );
      }
      paintStart = newStart;

      // 当最后一批数据全都绘制完成后，中断循环是不会执行的，我们需要在此设置结束索引，
      // 如果不设置，事件命中测试将出现 bug
      if (flag != true) paintEnd = children.length - 1;
    }

    // 裁剪溢出的滚动区域元素，防止局部滚动内容溢出
    if (_shouldClipAtPaintOffset(_paintOffset)) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        paintContents,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      paintContents(context, offset);
    }
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset) {
    switch (clipBehavior) {
      case Clip.none:
        return false;
      case .hardEdge:
      case Clip.antiAlias:
      case Clip.antiAliasWithSaveLayer:
        return paintOffset.dx < 0 ||
            paintOffset.dy < 0 ||
            paintOffset.dx + childrenSize.width > size.width ||
            paintOffset.dy + childrenSize.height > size.height;
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    children.clear();
    super.dispose();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final pixelsOffset = Offset(0, offset.pixels);
    for (int i = paintEnd; i >= paintStart; i--) {
      final bool isHit = result.addWithPaintOffset(
        offset: (children[i].parentData as BoxParentData).offset - pixelsOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return children[i].hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = (child.parentData as BoxParentData).offset + _paintOffset;
    transform.translateByDouble(offset.dx, offset.dy, 0.0, 1.0);
  }

  /// 实现目标元素自动滚动到可视窗口，此方法用于计算其偏移值
  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment, {Rect? rect, Axis? axis}) {
    axis = Axis.vertical;
    rect ??= target.paintBounds;
    if (target is! RenderBox) {
      return RevealedOffset(offset: offset.pixels, rect: rect);
    }

    // 此处的计算似乎需要以滚动容器中最顶端的 RenderBox 作为参照点才能正确得到偏移距离，
    // 注意是整个可滚动容器范围内的最上面的元素，不能是当前滚动视图，也不能取 children 第一个元素（会受 padding 影响）
    final Rect bounds = MatrixUtils.transformRect(target.getTransformTo(emptyChild), rect);

    final double targetOffset = bounds.top - (size.height - bounds.height) * alignment;
    final Rect targetRect = bounds.shift(_paintOffsetForPosition(targetOffset));

    return RevealedOffset(offset: targetOffset, rect: targetRect);
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    if (!offset.allowImplicitScrolling) {
      return super.showOnScreen(descendant: descendant, rect: rect, duration: duration, curve: curve);
    }

    final Rect? newRect = RenderViewportBase.showInViewport(
      descendant: descendant,
      viewport: this,
      offset: offset,
      rect: rect,
      duration: duration,
      curve: curve,
    );

    super.showOnScreen(rect: newRect, duration: duration, curve: curve);
  }
}
