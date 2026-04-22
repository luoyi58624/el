// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElTagThemeDataExt on ElTagThemeData {
  ElTagThemeData copyWith({
    Duration? duration,
    Curve? curve,
    ElThemeType? type,
    Widget? icon,
    double? width,
    double? height,
    Color? bgColor,
    Color? textColor,
    double? textSize,
    Color? iconColor,
    double? iconSize,
    bool? plain,
    bool? round,
    bool? closable,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return ElTagThemeData(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      width: width ?? this.width,
      height: height ?? this.height,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      plain: plain ?? this.plain,
      round: round ?? this.round,
      closable: closable ?? this.closable,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  ElTagThemeData merge([ElTagThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      duration: other.duration,
      curve: other.curve,
      type: other.type,
      icon: other.icon,
      width: other.width,
      height: other.height,
      bgColor: other.bgColor,
      textColor: other.textColor,
      textSize: other.textSize,
      iconColor: other.iconColor,
      iconSize: other.iconSize,
      plain: other.plain,
      round: other.round,
      closable: other.closable,
      borderRadius: other.borderRadius,
      padding: other.padding,
    );
  }

  List<Object?> get _props => [
    duration,
    curve,
    type,
    icon,
    width,
    height,
    bgColor,
    textColor,
    textSize,
    iconColor,
    iconSize,
    plain,
    round,
    closable,
    borderRadius,
    padding,
  ];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElTagTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElTagTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElTagThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElTagThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElTagTheme>()?.data;

  static ElTagThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElTagThemeData.darkTheme : ElTagThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElTagTheme.of(context);
    return _ElTagTheme(data: parent.merge(data), child: child);
  }
}

class _ElTagTheme extends InheritedWidget {
  const _ElTagTheme({required super.child, required this.data});

  final ElTagThemeData data;

  @override
  bool updateShouldNotify(_ElTagTheme oldWidget) => data != oldWidget.data;
}
