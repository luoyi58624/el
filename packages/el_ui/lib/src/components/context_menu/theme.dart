part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElContextMenuThemeData with EquatableMixin {
  static const theme = ElContextMenuThemeData();
  static const darkTheme = ElContextMenuThemeData();

  const ElContextMenuThemeData({this.hoverDelayShow, this.hoverDelayHide});

  /// 鼠标悬停多少毫秒才展开子菜单，默认立即展开
  final int? hoverDelayShow;

  /// 鼠标悬停多少毫秒才隐藏子菜单，默认立即关闭
  final int? hoverDelayHide;

  @override
  List<Object?> get props => _props;
}
