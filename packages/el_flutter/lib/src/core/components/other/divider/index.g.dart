// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElDividerThemeDataExt on ElDividerThemeData {
  ElDividerThemeData copyWith({double? size, double? thickness, double? indent, Color? color}) {
    return ElDividerThemeData(
      size: size ?? this.size,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      color: color ?? this.color,
    );
  }

  ElDividerThemeData merge([ElDividerThemeData? other]) {
    if (other == null) return this;
    return copyWith(size: other.size, thickness: other.thickness, indent: other.indent, color: other.color);
  }

  List<Object?> get _props => [size, thickness, indent, color];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElDividerTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElDividerTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElDividerThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElDividerThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElDividerTheme>()?.data;

  static ElDividerThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElDividerThemeData.darkTheme : ElDividerThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElDividerTheme.of(context);
    return _ElDividerTheme(data: parent.merge(data), child: child);
  }
}

class _ElDividerTheme extends InheritedWidget {
  const _ElDividerTheme({required super.child, required this.data});

  final ElDividerThemeData data;

  @override
  bool updateShouldNotify(_ElDividerTheme oldWidget) => data != oldWidget.data;
}
