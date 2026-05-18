// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElInputThemeDataExt on ElInputThemeData {
  ElInputThemeData copyWith({
    double? width,
    double? height,
    double? fontSize,
    double? iconSize,
    double? activeBorderWidth,
  }) {
    return ElInputThemeData(
      width: width ?? this.width,
      height: height ?? this.height,
      fontSize: fontSize ?? this.fontSize,
      iconSize: iconSize ?? this.iconSize,
      activeBorderWidth: activeBorderWidth ?? this.activeBorderWidth,
    );
  }

  ElInputThemeData merge([ElInputThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      width: other.width,
      height: other.height,
      fontSize: other.fontSize,
      iconSize: other.iconSize,
      activeBorderWidth: other.activeBorderWidth,
    );
  }

  List<Object?> get _props => [width, height, fontSize, iconSize, activeBorderWidth];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElInputTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElInputTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElInputThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElInputThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElInputTheme>()?.data;

  static ElInputThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElInputThemeData.darkTheme : ElInputThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElInputTheme.of(context);
    return _ElInputTheme(data: parent.merge(data), child: child);
  }
}

class _ElInputTheme extends InheritedWidget {
  const _ElInputTheme({required super.child, required this.data});

  final ElInputThemeData data;

  @override
  bool updateShouldNotify(_ElInputTheme oldWidget) => data != oldWidget.data;
}
