// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElContextMenuThemeDataExt on ElContextMenuThemeData {
  ElContextMenuThemeData copyWith({int? hoverDelayShow, int? hoverDelayHide}) {
    return ElContextMenuThemeData(
      hoverDelayShow: hoverDelayShow ?? this.hoverDelayShow,
      hoverDelayHide: hoverDelayHide ?? this.hoverDelayHide,
    );
  }

  ElContextMenuThemeData merge([ElContextMenuThemeData? other]) {
    if (other == null) return this;
    return copyWith(hoverDelayShow: other.hoverDelayShow, hoverDelayHide: other.hoverDelayHide);
  }

  List<Object?> get _props => [hoverDelayShow, hoverDelayHide];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElContextMenuTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElContextMenuTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElContextMenuThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElContextMenuThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElContextMenuTheme>()?.data;

  static ElContextMenuThemeData of(BuildContext context) =>
      maybeOf(context) ??
      (ElBrightness.isDark(context) ? ElContextMenuThemeData.darkTheme : ElContextMenuThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElContextMenuTheme.of(context);
    return _ElContextMenuTheme(data: parent.merge(data), child: child);
  }
}

class _ElContextMenuTheme extends InheritedWidget {
  const _ElContextMenuTheme({required super.child, required this.data});

  final ElContextMenuThemeData data;

  @override
  bool updateShouldNotify(_ElContextMenuTheme oldWidget) => data != oldWidget.data;
}
