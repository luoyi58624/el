// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElSplitResizerThemeDataExt on ElSplitResizerThemeData {
  ElSplitResizerThemeData copyWith({
    Axis? axis,
    double? size,
    double? triggerSize,
    Color? color,
    Color? activeColor,
    ElSplitPosition? position,
  }) {
    return ElSplitResizerThemeData(
      axis: axis ?? this.axis,
      size: size ?? this.size,
      triggerSize: triggerSize ?? this.triggerSize,
      color: color ?? this.color,
      activeColor: activeColor ?? this.activeColor,
      position: position ?? this.position,
    );
  }

  ElSplitResizerThemeData merge([ElSplitResizerThemeData? other]) {
    if (other == null) return this;
    return copyWith(
      axis: other.axis,
      size: other.size,
      triggerSize: other.triggerSize,
      color: other.color,
      activeColor: other.activeColor,
      position: other.position,
    );
  }

  List<Object?> get _props => [axis, size, triggerSize, color, activeColor, position];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElSplitResizerTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElSplitResizerTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElSplitResizerThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElSplitResizerThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElSplitResizerTheme>()?.data;

  static ElSplitResizerThemeData of(BuildContext context) =>
      maybeOf(context) ??
      (ElBrightness.isDark(context) ? ElSplitResizerThemeData.darkTheme : ElSplitResizerThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElSplitResizerTheme.of(context);
    return _ElSplitResizerTheme(data: parent.merge(data), child: child);
  }
}

class _ElSplitResizerTheme extends InheritedWidget {
  const _ElSplitResizerTheme({required super.child, required this.data});

  final ElSplitResizerThemeData data;

  @override
  bool updateShouldNotify(_ElSplitResizerTheme oldWidget) => data != oldWidget.data;
}
