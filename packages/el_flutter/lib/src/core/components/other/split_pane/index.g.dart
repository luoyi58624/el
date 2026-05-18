// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElSplitPaneThemeDataExt on ElSplitPaneThemeData {
  ElSplitPaneThemeData copyWith({Axis? axis}) {
    return ElSplitPaneThemeData(axis: axis ?? this.axis);
  }

  ElSplitPaneThemeData merge([ElSplitPaneThemeData? other]) {
    if (other == null) return this;
    return copyWith(axis: other.axis);
  }

  List<Object?> get _props => [axis];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElSplitPaneTheme extends StatelessWidget {
  const ElSplitPaneTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElSplitPaneThemeData data;

  static ElSplitPaneThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElSplitPaneTheme>()?.data;

  static ElSplitPaneThemeData of(BuildContext context) =>
      maybeOf(context) ??
      (ElBrightness.isDark(context)
          ? ElSplitPaneThemeData.darkTheme
          : ElSplitPaneThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElSplitPaneTheme.of(context);
    return _ElSplitPaneTheme(data: parent.merge(data), child: child);
  }
}

class _ElSplitPaneTheme extends InheritedWidget {
  const _ElSplitPaneTheme({required super.child, required this.data});

  final ElSplitPaneThemeData data;

  @override
  bool updateShouldNotify(_ElSplitPaneTheme oldWidget) =>
      data != oldWidget.data;
}
