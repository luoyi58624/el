// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElTooltipThemeDataExt on ElTooltipThemeData {
  ElTooltipThemeData copyWith({
    double? spacing,
    double? edgeSpacing,
    int? hoverDelayShow,
    int? hoverDelayHide,
    bool? staticHover,
    bool? showArrow,
  }) {
    return ElTooltipThemeData(
      spacing: spacing ?? this.spacing,
      edgeSpacing: edgeSpacing ?? this.edgeSpacing,
      hoverDelayShow: hoverDelayShow ?? this.hoverDelayShow,
      hoverDelayHide: hoverDelayHide ?? this.hoverDelayHide,
      staticHover: staticHover ?? this.staticHover,
      showArrow: showArrow ?? this.showArrow,
    );
  }

  ElTooltipThemeData merge([ElTooltipThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      spacing: other.spacing,
      edgeSpacing: other.edgeSpacing,
      hoverDelayShow: other.hoverDelayShow,
      hoverDelayHide: other.hoverDelayHide,
      staticHover: other.staticHover,
      showArrow: other.showArrow,
    );
  }

  List<Object?> get _props => [spacing, edgeSpacing, hoverDelayShow, hoverDelayHide, staticHover, showArrow];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElTooltipTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElTooltipTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElTooltipThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElTooltipThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElTooltipTheme>()?.data;

  static ElTooltipThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElTooltipThemeData.darkTheme : ElTooltipThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElTooltipTheme.of(context);
    return _ElTooltipTheme(data: parent.merge(data), child: child);
  }
}

class _ElTooltipTheme extends InheritedWidget {
  const _ElTooltipTheme({required super.child, required this.data});

  final ElTooltipThemeData data;

  @override
  bool updateShouldNotify(_ElTooltipTheme oldWidget) => data != oldWidget.data;
}
