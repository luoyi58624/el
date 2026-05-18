part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElInputThemeData with EquatableMixin {
  static const theme = ElInputThemeData.defaultData();
  static const darkTheme = theme;

  const ElInputThemeData({this.width, this.height, this.fontSize, this.iconSize, this.activeBorderWidth});

  /// 带有默认配置的构造函数，通常用于全局配置、或者重新覆盖祖先注入的主题配置
  const ElInputThemeData.defaultData({
    this.width = 72.0,
    this.height = 40.0,
    this.fontSize = 15.0,
    this.iconSize = 18.0,
    this.activeBorderWidth = 2.0,
  });

  /// 按钮默认宽度
  final double? width;

  /// 按钮默认高度
  final double? height;

  /// 按钮默认字体大小
  final double? fontSize;

  /// 按钮默认图标大小
  final double? iconSize;

  /// 激活的边框宽度，默认的边框宽度使用 [ElButtonThemeData] 的 borderWidth 属性
  final double? activeBorderWidth;

  @override
  List<Object?> get props => _props;
}
