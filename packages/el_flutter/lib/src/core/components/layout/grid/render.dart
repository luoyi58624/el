part of 'index.dart';

class _RenderGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WrapParentData> {
  _RenderGrid({
    required double width,
    double? height,
    int? crossAxisCount,
    required double aspectRatio,
    required double rowSpacing,
    required double columnSpacing,
    Color? spacingColor,
  }) {
    _width = width;
    _height = height;
    _crossAxisCount = crossAxisCount;
    _aspectRatio = aspectRatio;
    _rowSpacing = rowSpacing;
    _columnSpacing = columnSpacing;
    _spacingColor = spacingColor;
  }

  late double _width;

  set width(double v) {
    if (_width == v) return;
    _width = v;
    markNeedsLayout();
  }

  double? _height;

  set height(double? v) {
    if (_height == v) return;
    _height = v;
    markNeedsLayout();
  }

  int? _crossAxisCount;

  set crossAxisCount(int? v) {
    if (_crossAxisCount == v) return;
    _crossAxisCount = v;
    markNeedsLayout();
  }

  late double _aspectRatio;

  set aspectRatio(double v) {
    if (_aspectRatio == v) return;
    _aspectRatio = v;
    markNeedsLayout();
  }

  late double _rowSpacing;

  set rowSpacing(double v) {
    if (_rowSpacing == v) return;
    _rowSpacing = v;
    markNeedsLayout();
  }

  late double _columnSpacing;

  set columnSpacing(double v) {
    if (_columnSpacing == v) return;
    _columnSpacing = v;
    markNeedsLayout();
  }

  late Color? _spacingColor;

  set spacingColor(Color? v) {
    if (_spacingColor == v) return;
    _spacingColor = v;
    markNeedsPaint();
  }

  /// 当前网格布局一共包含几行、几列
  late int rows, columns;

  /// 对网格子组件应用的约束
  late BoxConstraints childConstraints;

  @override
  bool get isRepaintBoundary => true;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapParentData) {
      child.parentData = WrapParentData();
    }
  }

  @override
  void performLayout() {
    var child = firstChild;

    // 没有子组件直接返回
    if (child == null) return;

    // 若父级传递的宽度约束为无限，则固定行、列
    if (constraints.maxWidth.isInfinite) {
      columns = childCount;
      rows = 1;
      childConstraints = constraints.loosen();
    } else {
      late double childWidth;

      // 优先处理固定数量的网格
      if (_crossAxisCount != null) {
        columns = _crossAxisCount!;
        rows = (childCount / columns).ceil();
        childWidth = (constraints.maxWidth - ((columns - 1) * _columnSpacing)) / columns;
      }
      // 再处理指定固定宽度的网格
      else if (constraints.maxWidth.isInfinite) {
        childWidth = _width;
        columns = childCount;
        rows = 1;
      } else if (_width > constraints.maxWidth) {
        childWidth = constraints.maxWidth;
        columns = 1;
        rows = childCount;
      } else {
        columns = (constraints.maxWidth / _width).floor();
        rows = (childCount / columns).ceil();
        childWidth = (constraints.maxWidth - ((columns - 1) * _columnSpacing)) / columns;
      }

      childConstraints = BoxConstraints.tight(
        Size(childWidth, (_height ?? childWidth * _aspectRatio) - _rowSpacing / 2),
      );
    }

    int currentRow = 0, currentColumn = 0;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final childParentData = child.parentData as WrapParentData;
      childParentData.offset = Offset(
        currentColumn * childConstraints.maxWidth + currentColumn * _columnSpacing,
        currentRow * childConstraints.maxHeight + currentRow * _rowSpacing,
      );
      child = childParentData.nextSibling;
      if (currentColumn >= columns - 1) {
        currentColumn = 0;
        currentRow++;
      } else {
        currentColumn++;
      }
    }

    size = constraints.constrain(
      Size(constraints.maxWidth, childConstraints.maxHeight * rows + (rows - 1) * _rowSpacing),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_spacingColor == null) {
      defaultPaint(context, offset);
    } else {
      final paint = Paint()..color = _spacingColor!;

      int currentRow = 0, currentColumn = 0;
      var child = firstChild;
      while (child != null) {
        final childParentData = child.parentData! as WrapParentData;
        final childOffset = childParentData.offset + offset;

        if (_columnSpacing > 0 && currentColumn < columns - 1) {
          double spacingHeight = childConstraints.maxHeight;
          if (_columnSpacing >= _rowSpacing && currentRow < rows - 1) {
            spacingHeight += _rowSpacing;
          }
          context.canvas.drawRect(
            Rect.fromLTWH(childOffset.dx + childConstraints.maxWidth, childOffset.dy, _columnSpacing, spacingHeight),
            paint,
          );
        }

        if (_rowSpacing > 0 && currentRow < rows - 1) {
          double spacingWidth = childConstraints.maxWidth;
          if (_rowSpacing > _columnSpacing) {
            spacingWidth += _columnSpacing;
          }
          context.canvas.drawRect(
            Rect.fromLTWH(childOffset.dx, childOffset.dy + childConstraints.maxHeight, spacingWidth, _rowSpacing),
            paint,
          );
        }

        context.paintChild(child, childOffset);
        child = childParentData.nextSibling;

        if (currentColumn >= columns - 1) {
          currentColumn = 0;
          currentRow++;
        } else {
          currentColumn++;
        }
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
