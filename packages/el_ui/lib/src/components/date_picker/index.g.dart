// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElDatePickerThemeDataExt on ElDatePickerThemeData {
  ElDatePickerThemeData copyWith({Color? primaryColor, String? format}) {
    return ElDatePickerThemeData(primaryColor: primaryColor ?? this.primaryColor, format: format ?? this.format);
  }

  ElDatePickerThemeData merge([ElDatePickerThemeData? other]) {
    if (other == null) return this;
    return copyWith(primaryColor: other.primaryColor, format: other.format);
  }

  List<Object?> get _props => [primaryColor, format];
}

// **************************************************************************
// ElThemeGenerator
// **************************************************************************

class ElDatePickerTheme extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const ElDatePickerTheme({super.key, required this.child, required this.data});

  final Widget child;
  final ElDatePickerThemeData data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static ElDatePickerThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElDatePickerTheme>()?.data;

  static ElDatePickerThemeData of(BuildContext context) =>
      maybeOf(context) ??
      (ElBrightness.isDark(context) ? ElDatePickerThemeData.darkTheme : ElDatePickerThemeData.theme);

  @override
  Widget build(BuildContext context) {
    final parent = ElDatePickerTheme.of(context);
    return _ElDatePickerTheme(data: parent.merge(data), child: child);
  }
}

class _ElDatePickerTheme extends InheritedWidget {
  const _ElDatePickerTheme({required super.child, required this.data});

  final ElDatePickerThemeData data;

  @override
  bool updateShouldNotify(_ElDatePickerTheme oldWidget) => data != oldWidget.data;
}
