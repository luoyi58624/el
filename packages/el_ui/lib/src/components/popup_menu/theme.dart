part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElPopupMenuThemeData with EquatableMixin {
  static const theme = ElPopupMenuThemeData.defaultData();
  static const darkTheme = ElPopupMenuThemeData.defaultData();

  const ElPopupMenuThemeData({this.minWidth, this.maxWidth, this.padding});

  const ElPopupMenuThemeData.defaultData({
    this.minWidth = 120.0,
    this.maxWidth = 300.0,
    this.padding = const .fromLTRB(16.0, 8.0, 24.0, 8.0),
  });

  final double? minWidth;
  final double? maxWidth;

  /// 菜单内边距，其中上下边距作用于容器，左右边距作用于每个子项
  final EdgeInsets? padding;

  @override
  List<Object?> get props => _props;
}
