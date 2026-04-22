// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElPopupMenuThemeDataExt on ElPopupMenuThemeData {
  ElPopupMenuThemeData copyWith({double? minWidth, double? maxWidth, EdgeInsets? padding}) {
    return ElPopupMenuThemeData(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      padding: padding ?? this.padding,
    );
  }

  ElPopupMenuThemeData merge([ElPopupMenuThemeData? other]) {
    if (other == null) return this;
    return copyWith(minWidth: other.minWidth, maxWidth: other.maxWidth, padding: other.padding);
  }

  List<Object?> get _props => [minWidth, maxWidth, padding];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElPopupMenuTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElPopupMenuTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElPopupMenuThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElPopupMenuThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElPopupMenuTheme>()?.data;

  static ElPopupMenuThemeData of(BuildContext context) =>
      maybeOf(context) ?? (ElBrightness.isDark(context) ? ElPopupMenuThemeData.darkTheme : ElPopupMenuThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElPopupMenuTheme.of(context);
    return _ElPopupMenuTheme(data: parent.merge(data), child: child);
  }
}

class _ElPopupMenuTheme extends InheritedWidget {
  const _ElPopupMenuTheme({required super.child, required this.data});

  final ElPopupMenuThemeData data;

  @override
  bool updateShouldNotify(_ElPopupMenuTheme oldWidget) => data != oldWidget.data;
}
