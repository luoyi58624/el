// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElButtonThemeDataExt on ElButtonThemeData {
  ElButtonThemeData copyWith({
    double? width,
    double? height,
    double? fontSize,
    double? iconSize,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool? autoInsertSpace,
    double? iconChildFactor,
    MouseCursor? cursor,
    MouseCursor? loadingCursor,
    MouseCursor? disabledCursor,
  }) {
    return ElButtonThemeData(
      width: width ?? this.width,
      height: height ?? this.height,
      fontSize: fontSize ?? this.fontSize,
      iconSize: iconSize ?? this.iconSize,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      autoInsertSpace: autoInsertSpace ?? this.autoInsertSpace,
      iconChildFactor: iconChildFactor ?? this.iconChildFactor,
      cursor: cursor ?? this.cursor,
      loadingCursor: loadingCursor ?? this.loadingCursor,
      disabledCursor: disabledCursor ?? this.disabledCursor,
    );
  }

  ElButtonThemeData merge([ElButtonThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      width: other.width,
      height: other.height,
      fontSize: other.fontSize,
      iconSize: other.iconSize,
      padding: other.padding,
      margin: other.margin,
      autoInsertSpace: other.autoInsertSpace,
      iconChildFactor: other.iconChildFactor,
      cursor: other.cursor,
      loadingCursor: other.loadingCursor,
      disabledCursor: other.disabledCursor,
    );
  }

  List<Object?> get _props => [
    width,
    height,
    fontSize,
    iconSize,
    padding,
    margin,
    autoInsertSpace,
    iconChildFactor,
    cursor,
    loadingCursor,
    disabledCursor,
  ];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElButtonTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElButtonTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElButtonThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElButtonThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElButtonTheme>()?.data;

  static ElButtonThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElButtonThemeData.darkTheme : ElButtonThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElButtonTheme.of(context);
    return _ElButtonTheme(data: parent.merge(data), child: child);
  }
}

class _ElButtonTheme extends InheritedWidget {
  const _ElButtonTheme({required super.child, required this.data});

  final ElButtonThemeData data;

  @override
  bool updateShouldNotify(_ElButtonTheme oldWidget) => data != oldWidget.data;
}
