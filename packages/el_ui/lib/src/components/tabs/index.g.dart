// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElTabsThemeDataExt on ElTabsThemeData {
  ElTabsThemeData copyWith({
    double? height,
    AxisDirection? direction,
    Color? bgColor,
    Color? activeBgColor,
    TextStyle? textStyle,
    TextStyle? activeTextStyle,
    EdgeInsets? padding,
    double? itemGap,
    bool? enabledDrag,
    Duration? dragDelay,
    double? autoScrollerVelocityScalar,
    Widget Function(Widget, int, Animation<double>)? dragProxyDecorator,
  }) {
    return ElTabsThemeData(
      height: height ?? this.height,
      direction: direction ?? this.direction,
      bgColor: bgColor ?? this.bgColor,
      activeBgColor: activeBgColor ?? this.activeBgColor,
      textStyle: this.textStyle == null ? textStyle : this.textStyle!.merge(textStyle),
      activeTextStyle: this.activeTextStyle == null ? activeTextStyle : this.activeTextStyle!.merge(activeTextStyle),
      padding: padding ?? this.padding,
      itemGap: itemGap ?? this.itemGap,
      enabledDrag: enabledDrag ?? this.enabledDrag,
      dragDelay: dragDelay ?? this.dragDelay,
      autoScrollerVelocityScalar: autoScrollerVelocityScalar ?? this.autoScrollerVelocityScalar,
      dragProxyDecorator: dragProxyDecorator ?? this.dragProxyDecorator,
    );
  }

  ElTabsThemeData merge([ElTabsThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      height: other.height,
      direction: other.direction,
      bgColor: other.bgColor,
      activeBgColor: other.activeBgColor,
      textStyle: other.textStyle,
      activeTextStyle: other.activeTextStyle,
      padding: other.padding,
      itemGap: other.itemGap,
      enabledDrag: other.enabledDrag,
      dragDelay: other.dragDelay,
      autoScrollerVelocityScalar: other.autoScrollerVelocityScalar,
      dragProxyDecorator: other.dragProxyDecorator,
    );
  }

  List<Object?> get _props => [
    height,
    direction,
    bgColor,
    activeBgColor,
    textStyle,
    activeTextStyle,
    padding,
    itemGap,
    enabledDrag,
    dragDelay,
    autoScrollerVelocityScalar,
    dragProxyDecorator,
  ];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElTabsTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElTabsTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElTabsThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElTabsThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElTabsTheme>()?.data;

  static ElTabsThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElTabsThemeData.darkTheme : ElTabsThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElTabsTheme.of(context);
    return _ElTabsTheme(data: parent.merge(data), child: child);
  }
}

class _ElTabsTheme extends InheritedWidget {
  const _ElTabsTheme({required super.child, required this.data});

  final ElTabsThemeData data;

  @override
  bool updateShouldNotify(_ElTabsTheme oldWidget) => data != oldWidget.data;
}
