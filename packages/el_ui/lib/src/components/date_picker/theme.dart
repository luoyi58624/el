part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElDatePickerThemeData with EquatableMixin {
  static const theme = ElDatePickerThemeData();
  static const darkTheme = ElDatePickerThemeData();

  const ElDatePickerThemeData({this.primaryColor, this.format});

  /// 颜色选择器主题色
  final Color? primaryColor;

  /// 日期字符串格式化
  final String? format;

  @override
  List<Object?> get props => _props;
}
