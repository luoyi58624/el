part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElButtonThemeData with EquatableMixin {
  static const theme = ElButtonThemeData.defaultData();
  static const darkTheme = theme;

  const ElButtonThemeData({
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
    this.padding,
    this.margin,
    this.autoInsertSpace,
    this.iconChildFactor,
    this.cursor,
    this.loadingCursor,
    this.disabledCursor,
  });

  /// 带有默认配置的构造函数，通常用于全局配置、或者重新覆盖祖先注入的主题配置
  const ElButtonThemeData.defaultData({
    this.width = 72.0,
    this.height = 40.0,
    this.fontSize = 15.0,
    this.iconSize = 18.0,
    this.padding = const .symmetric(horizontal: 18.0),
    this.margin = .zero,
    this.autoInsertSpace = true,
    this.iconChildFactor = 1.2,
    this.cursor = SystemMouseCursors.click,
    this.loadingCursor = MouseCursor.defer,
    this.disabledCursor = SystemMouseCursors.forbidden,
  });

  /// 按钮默认宽度
  final double? width;

  /// 按钮默认高度
  final double? height;

  /// 按钮默认字体大小
  final double? fontSize;

  /// 按钮默认图标大小
  final double? iconSize;

  /// 按钮默认内边距
  final EdgeInsets? padding;

  /// 按钮默认外边距
  final EdgeInsets? margin;

  /// 在两个连续的中文自动设置间隔
  final bool? autoInsertSpace;

  /// 如果按钮是纯图标，可能需要应用一个放大因子调整视觉外观
  final double? iconChildFactor;

  /// 按钮悬停光标样式，默认为原始指针
  final MouseCursor? cursor;

  /// 当按钮处于 loading 状态时的悬停光标，默认为原始指针
  final MouseCursor? loadingCursor;

  /// 当按钮处于 disabled 状态时的悬停光标，默认为 forbidden 禁用样式
  final MouseCursor? disabledCursor;

  @override
  List<Object?> get props => _props;
}
