import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

part 'render.dart';

/// 网格布局容器，允许指定 [width]、[crossAxisCount] 来确定网格布局，
/// 如果都不指定，则取第一条数据的布局尺寸为基准，自动应用每个网格布局约束。
///
/// 注意：不要拿该组件去渲染大量数据，有此需求请使用 [GridView] 小部件。
class ElGrid extends MultiChildRenderObjectWidget {
  const ElGrid({
    super.key,
    required this.width,
    this.height,
    this.crossAxisCount,
    this.aspectRatio = 1.0,
    this.rowSpacing = 0.0,
    this.columnSpacing = 0.0,
    this.spacingColor,
    required super.children,
  });

  /// 单个网格的预估宽度，在布局时会根据剩余空间来拉伸大小，例如：
  /// * 父级传递的约束 maxWidth 为 400，当 [width] 为 150 时，400 / 150 约等于 2.6，
  /// 那么一行最多只能渲染 2 个网格，布局时子项的实际宽度将为 400 / 2 = 200；
  /// * 同理当父级传递的约束 maxWidth 为 1280，而 1280 / 150 约等于 8.5，
  /// 那么一行最多可以渲染 8 个网格，布局时子项的实际宽度将为 1280 / 8 = 160；
  ///
  /// 当然，网格的实际宽高还会受 [rowSpacing]、[columnSpacing] 影响，在确定布局宽高的基础上，
  /// 应用给子项的约束会减去 [rowSpacing]、[columnSpacing] 空白尺寸。
  final double width;

  /// 指定子元素高度，指定该属性后网格高度将不受 [width] 缩放影响
  final double? height;

  /// 指定一行显示几个元素，此属性会覆盖 [width] 选项，推荐仅在移动端指定该选项
  final int? crossAxisCount;

  /// 网格宽高比
  final double aspectRatio;

  /// 网格行之间的间隔
  final double rowSpacing;

  /// 网格列之间的间隔
  final double columnSpacing;

  /// 绘制网格间隙颜色
  final Color? spacingColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGrid(
      width: width,
      height: height,
      crossAxisCount: crossAxisCount,
      aspectRatio: aspectRatio,
      rowSpacing: rowSpacing,
      columnSpacing: columnSpacing,
      spacingColor: spacingColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    renderObject as _RenderGrid
      ..width = width
      ..height = height
      ..crossAxisCount = crossAxisCount
      ..aspectRatio = aspectRatio
      ..rowSpacing = rowSpacing
      ..columnSpacing = columnSpacing
      ..spacingColor = spacingColor;
  }
}

/// 动画版本 [Grid] 小部件
class ElAnimatedGrid extends ElImplicitlyAnimatedWidget {
  const ElAnimatedGrid({
    super.key,
    required this.width,
    this.height,
    this.crossAxisCount,
    this.aspectRatio = 1.0,
    this.rowSpacing = 0.0,
    this.columnSpacing = 0.0,
    this.spacingColor,
    required this.children,
    super.duration,
    super.curve,
    super.onEnd,
  });

  final double width;
  final double? height;
  final int? crossAxisCount;
  final double aspectRatio;
  final double rowSpacing;
  final double columnSpacing;
  final Color? spacingColor;
  final List<Widget> children;

  @override
  List<Object?> get effects => [aspectRatio, rowSpacing, columnSpacing, spacingColor];

  @override
  void forEachTween(visitor) {
    visitor('aspectRatio', aspectRatio, Tween<double>());
    visitor('rowSpacing', rowSpacing, Tween<double>());
    visitor('columnSpacing', columnSpacing, Tween<double>());
    visitor('spacingColor', spacingColor, ColorTween());
  }

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return ElGrid(
      width: width,
      height: height,
      crossAxisCount: crossAxisCount,
      aspectRatio: (tweenMap['aspectRatio']! as Tween<double>).evaluate(animation),
      rowSpacing: (tweenMap['rowSpacing']! as Tween<double>).evaluate(animation),
      columnSpacing: (tweenMap['columnSpacing']! as Tween<double>).evaluate(animation),
      spacingColor: spacingColor == null ? null : (tweenMap['spacingColor']! as ColorTween).evaluate(animation),
      children: children,
    );
  }
}
