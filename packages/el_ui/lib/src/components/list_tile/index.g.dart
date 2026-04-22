// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElListTileThemeDataExt on ElListTileThemeData {
  ElListTileThemeData copyWith({
    Color? color,
    double? elevation,
    double? radius,
    TextStyle? titleStyle,
    EdgeInsets? contentPadding,
  }) {
    return ElListTileThemeData(
      color: color ?? this.color,
      elevation: elevation ?? this.elevation,
      radius: radius ?? this.radius,
      titleStyle: this.titleStyle == null ? titleStyle : this.titleStyle!.merge(titleStyle),
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  ElListTileThemeData merge([ElListTileThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      color: other.color,
      elevation: other.elevation,
      radius: other.radius,
      titleStyle: other.titleStyle,
      contentPadding: other.contentPadding,
    );
  }

  List<Object?> get _props => [color, elevation, radius, titleStyle, contentPadding];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElListTileTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElListTileTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElListTileThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElListTileThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElListTileTheme>()?.data;

  static ElListTileThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElListTileThemeData.darkTheme : ElListTileThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElListTileTheme.of(context);
    return _ElListTileTheme(data: parent.merge(data), child: child);
  }
}

class _ElListTileTheme extends InheritedWidget {
  const _ElListTileTheme({required super.child, required this.data});

  final ElListTileThemeData data;

  @override
  bool updateShouldNotify(_ElListTileTheme oldWidget) => data != oldWidget.data;
}
