part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElTabsThemeData with EquatableMixin {
  static const theme = ElTabsThemeData.defaultData(
    bgColor: .fromRGBO(245, 245, 245, 1.0),
    activeBgColor: .fromRGBO(255, 255, 255, 1.0),
    textStyle: TextStyle(fontSize: 13, color: .fromRGBO(94, 80, 80, 1.0)),
    activeTextStyle: TextStyle(fontSize: 13, color: .fromRGBO(26, 0, 0, 1.0)),
  );
  static const darkTheme = ElTabsThemeData.defaultData(
    bgColor: .fromRGBO(30, 31, 34, 1.0),
    activeBgColor: .fromRGBO(79, 82, 84, 1.0),
    textStyle: TextStyle(fontSize: 13, color: .fromRGBO(176, 188, 191, 1.0)),
    activeTextStyle: TextStyle(fontSize: 13, color: .fromRGBO(211, 224, 228, 1.0)),
  );

  const ElTabsThemeData({
    this.height,
    this.direction,
    this.bgColor,
    this.activeBgColor,
    this.textStyle,
    this.activeTextStyle,
    this.padding,
    this.itemGap,
    this.enabledDrag,
    this.dragDelay,
    this.autoScrollerVelocityScalar,
    this.dragProxyDecorator,
  });

  const ElTabsThemeData.defaultData({
    this.height = 36,
    this.direction = AxisDirection.right,
    this.bgColor,
    this.activeBgColor,
    this.textStyle,
    this.activeTextStyle,
    this.padding = .zero,
    this.itemGap = 0,
    this.enabledDrag,
    this.dragDelay,
    this.autoScrollerVelocityScalar,
    this.dragProxyDecorator,
  });

  /// 标签容器高度，默认 28
  final double? height;

  /// 标签方向
  final AxisDirection? direction;

  /// 标签背景颜色
  final Color? bgColor;

  /// 标签激活背景颜色
  final Color? activeBgColor;

  /// 标签文本样式
  final TextStyle? textStyle;

  /// 标签激活文本样式
  final TextStyle? activeTextStyle;

  /// 标签容器内边距，默认 0
  final EdgeInsets? padding;

  /// 子标签之间的间距，默认 0
  final double? itemGap;

  /// 开启拖拽排序，默认 false
  final bool? enabledDrag;

  /// 触发拖拽延迟时间，默认 100 毫秒，移动端目前强制为长按触发：[kLongPressTimeout]
  final Duration? dragDelay;

  /// 拖拽到临界点时自动滚动速率，默认 100
  final double? autoScrollerVelocityScalar;

  /// 自定义拖拽代理
  final ReorderItemProxyDecorator? dragProxyDecorator;

  @override
  List<Object?> get props => _props;
}
