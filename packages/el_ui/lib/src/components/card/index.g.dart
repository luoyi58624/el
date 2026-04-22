// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElCardThemeDataExt on ElCardThemeData {
  ElCardThemeData copyWith({double? elevation, double? radius, TextStyle? titleStyle, EdgeInsets? titlePadding}) {
    return ElCardThemeData(
      elevation: elevation ?? this.elevation,
      titleStyle: this.titleStyle == null ? titleStyle : this.titleStyle!.merge(titleStyle),
      titlePadding: titlePadding ?? this.titlePadding,
    );
  }

  ElCardThemeData merge([ElCardThemeData? other]) {
    if (other == null) return this;
    return copyWith(elevation: other.elevation, titleStyle: other.titleStyle, titlePadding: other.titlePadding);
  }

  List<Object?> get _props => [elevation, titleStyle, titlePadding];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElCardTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElCardTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElCardThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElCardThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElCardTheme>()?.data;

  static ElCardThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElCardThemeData.darkTheme : ElCardThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElCardTheme.of(context);
    return _ElCardTheme(data: parent.merge(data), child: child);
  }
}

class _ElCardTheme extends InheritedWidget {
  const _ElCardTheme({required super.child, required this.data});

  final ElCardThemeData data;

  @override
  bool updateShouldNotify(_ElCardTheme oldWidget) => data != oldWidget.data;
}
