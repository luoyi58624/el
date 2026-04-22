import 'dart:math' as math;

import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

part 'models.g.dart';

enum ElThemeType implements ElSerialize<ElThemeType> {
  primary,
  secondary,
  success,
  info,
  warning,
  error;

  static const List<ElThemeType> statusTypes = [success, info, warning, error];

  static const List<ElThemeType> types = [primary, ...statusTypes];

  @override
  ElThemeType? deserialize(String? str) {
    if (str == null) return null;
    if (str == 'primary') return primary;
    if (str == 'secondary') return secondary;
    if (str == 'success') return success;
    if (str == 'info') return info;
    if (str == 'warning') return warning;
    if (str == 'error') return error;
    return null;
  }

  @override
  String? serialize(ElThemeType? obj) {
    return obj?.name;
  }
}

enum ElLevelType implements ElSerialize<ElLevelType> {
  xs,
  sm,
  md,
  lg,
  xl;

  static const List<ElLevelType> types = [xs, sm, md, lg, xl];

  @override
  ElLevelType? deserialize(String? str) {
    if (str == null) return null;
    if (str == 'xs') return xs;
    if (str == 'sm') return sm;
    if (str == 'md') return md;
    if (str == 'lg') return lg;
    if (str == 'xl') return xl;
    return null;
  }

  @override
  String? serialize(ElLevelType? obj) {
    return obj?.name;
  }
}

@ElModelGenerator(generateProps: true, copyWith: true)
@immutable
class ElThemeData with EquatableMixin {
  const ElThemeData({
    this.primary = const Color(0xff409EFF),
    this.secondary = const Color(0xff409EFF),
    this.success = const Color(0xff67C23A),
    this.info = const Color(0xff909399),
    this.warning = const Color(0xffE6A23C),
    this.error = const Color(0xffF56C6C),
    this.bgColor = const Color.fromRGBO(248, 248, 248, 1.0),
    this.headerColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.footerColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.sideColor = const Color.fromRGBO(248, 248, 248, 1.0),
    this.iconColor = const Color.fromRGBO(108, 108, 108, 1.0),
    this.textColor = const Color.fromRGBO(56, 56, 56, 1.0),
    this.regularTextColor = const Color.fromRGBO(64, 64, 64, 1.0),
    this.secondaryTextColor = const Color.fromRGBO(108, 108, 108, 1.0),
    this.placeholderTextColor = const Color.fromRGBO(166, 166, 166, 1.0),
    this.disabledTextColor = const Color.fromRGBO(56, 56, 56, 1.0),
    this.darkerBorderColor = const Color(0xffCDD0D6),
    this.darkBorderColor = const Color(0xffD4D7DE),
    this.borderColor = const Color(0xffDCDFE6),
    this.lightBorderColor = const Color(0xffE4E7ED),
    this.lighterBorderColor = const Color(0xffEBEEF5),
    this.cardColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.selectionColor = const Color.fromRGBO(33, 150, 243, 0.36),
    this.tooltipColor = const Color.fromRGBO(60, 60, 60, 0.8),
    this.linkColor = const Color.fromRGBO(9, 105, 218, 1.0),
    this.linkActiveColor = const Color.fromRGBO(9, 105, 218, 1.0),
  });

  const ElThemeData.dark({
    this.primary = const Color(0xff409EFF),
    this.secondary = const Color(0xff0164c6),
    this.success = const Color(0xff67C23A),
    this.info = const Color(0xff909399),
    this.warning = const Color(0xffE6A23C),
    this.error = const Color(0xffF56C6C),
    this.bgColor = const Color.fromRGBO(43, 43, 43, 1.0),
    this.headerColor = const Color.fromRGBO(43, 45, 48, 1.0),
    this.footerColor = const Color.fromRGBO(43, 45, 48, 1.0),
    this.sideColor = const Color.fromRGBO(43, 45, 48, 1.0),
    this.iconColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.textColor = const Color.fromRGBO(255, 255, 255, 1.0),
    this.regularTextColor = const Color.fromRGBO(237, 237, 237, 1.0),
    this.secondaryTextColor = const Color.fromRGBO(214, 214, 214, 1.0),
    this.placeholderTextColor = const Color.fromRGBO(186, 186, 186, 1.0),
    this.disabledTextColor = const Color.fromRGBO(56, 56, 56, 1.0),
    this.darkerBorderColor = const Color(0xff636466),
    this.darkBorderColor = const Color(0xff58585B),
    this.borderColor = const Color(0xff4C4D4F),
    this.lightBorderColor = const Color(0xff414243),
    this.lighterBorderColor = const Color(0xff363637),
    this.cardColor = const Color.fromRGBO(43, 45, 48, 1.0),
    this.selectionColor = const Color.fromRGBO(68, 138, 255, 0.5),
    this.tooltipColor = const Color.fromRGBO(234, 234, 234, 1.0),
    this.linkColor = const Color.fromRGBO(64, 158, 255, 1.0),
    this.linkActiveColor = const Color.fromRGBO(64, 158, 255, 1.0),
  });

  /// 主颜色
  final Color primary;

  /// 次要主题色，这是一个低对比度主颜色，有时候主题色可能会应用高对比度颜色（例如 yellow），
  /// 这会导致一些组件显得格外刺眼，所以部分组件会取 secondary 主题色（例如 Switch）
  final Color secondary;

  /// 成功颜色
  final Color success;

  /// 普通颜色
  final Color info;

  /// 警告颜色
  final Color warning;

  /// 错误颜色
  final Color error;

  /// 全局背景色
  final Color bgColor;

  /// 头部颜色
  final Color headerColor;

  /// 底部颜色
  final Color footerColor;

  /// 侧边栏颜色
  final Color sideColor;

  /// 图标颜色
  final Color iconColor;

  /// 主要文本颜色
  final Color textColor;

  /// 常规文本颜色
  final Color regularTextColor;

  /// 次要文本颜色
  final Color secondaryTextColor;

  /// 占位符文本颜色
  final Color placeholderTextColor;

  /// 被禁用的文本颜色
  final Color disabledTextColor;

  /// 更暗的边框颜色
  final Color darkerBorderColor;

  /// 暗色边框
  final Color darkBorderColor;

  /// 边框颜色
  final Color borderColor;

  /// 亮色边框
  final Color lightBorderColor;

  /// 更亮的边框颜色
  final Color lighterBorderColor;

  /// 卡片背景颜色
  final Color cardColor;

  /// 文本选中颜色
  final Color selectionColor;

  /// 提示文本颜色
  final Color tooltipColor;

  /// 超链接颜色
  final Color linkColor;

  /// 超链接激活颜色
  final Color linkActiveColor;

  @override
  List<Object?> get props => _props;
}

@ElModelGenerator(generateProps: true, copyWith: true)
@immutable
class ElConfigData with EquatableMixin {
  const ElConfigData({
    this.animationStyle = const AnimationStyle(duration: kThemeChangeDuration, curve: Curves.linear),
    this.duration = const Duration(milliseconds: 300),
    this.fastDuration = const Duration(milliseconds: 200),
    this.rounded = const {.xs: 2.0, .sm: 4.0, .md: 6.0, .lg: 8.0, .xl: 12.0},
    this.borderWidth = 1.0,
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontSize = 15.0,
    this.iconSize = 24.0,
    this.fontWeight = .normal,
    this.fontWeightBuilder = _fontWeightBuilder,
    this.scrollControllerBuilder = _scrollControllerBuilder,
    this.arrowRightBuilder = _arrowRightBuilder,
    this.arrowDownBuilder = _arrowDownBuilder,
    this.messageDuration = 3000,
    this.loadingIndex = 100,
    this.promptIndex = 200,
    this.messageIndex = 250,
    this.toastIndex = 300,
  });

  /// 全局主题动画样式
  final AnimationStyle animationStyle;

  /// 默认的动画时间
  final Duration duration;

  /// 快速的动画时间
  final Duration fastDuration;

  /// 五种级别的圆角
  final Map<ElLevelType, double> rounded;

  /// 默认的边框宽度
  final double borderWidth;

  /// 全局字族
  final String? fontFamily;

  /// 全局字体回退
  final List<String>? fontFamilyFallback;

  /// 全局字体大小
  final double fontSize;

  /// 全局图标大小
  final double iconSize;

  /// 默认的字重级别，当指定不同的字重级别时，所有字重会根据
  final FontWeight fontWeight;

  /// 定义全局默认的字重构建逻辑
  final ElFontWeightBuilder fontWeightBuilder;

  /// 定义全局默认的滚动控制器，Element 所有与滚动相关的小部件都使用全局滚动控制器，默认返回 [ElSmoothScrollController]，
  /// 若要自定义全局滚动控制器，只需在 main 方法中覆写此配置即可：
  /// ```dart
  /// el.config = el.config.copyWith(
  ///   scrollControllerBuilder: ([ElScrollControllerAttrModel? model]) => ScrollController(),
  /// );
  /// ```
  ///
  /// 当使用滚动小部件时，通过 el.config 统一构建滚动控制器：
  /// ```dart
  /// final controller = el.config.scrollControllerBuilder();
  /// ```
  final ElScrollControllerBuilder scrollControllerBuilder;

  /// 构建全局右箭头图标
  final WidgetBuilder arrowRightBuilder;

  /// 构建全局下箭头图标
  final WidgetBuilder arrowDownBuilder;

  /// 消息提示持续时间，默认 3000
  final int messageDuration;

  /// loading 反馈层级
  final int loadingIndex;

  /// prompt 反馈层级
  final int promptIndex;

  /// message 反馈层级
  final int messageIndex;

  /// toast 反馈层级
  final int toastIndex;

  /// 基础控件边框圆角（按钮、输入框）
  BorderRadius get borderRadius => .circular(rounded[ElLevelType.sm]!);

  /// 卡片布局控件圆角
  BorderRadius get cardBorderRadius => .circular(rounded[ElLevelType.lg]!);

  /// 默认的字重计算逻辑
  static FontWeight _fontWeightBuilder([FontWeight? weight]) {
    final w = el.config.fontWeight;
    weight ??= w;

    if (w == .normal) return weight;

    if (w.value > FontWeight.normal.value) {
      return math.max(w.value, weight.value).toFontWeight();
    }

    return (weight.value - (FontWeight.normal.value - w.value)).toFontWeight();
  }

  static ScrollController _scrollControllerBuilder([ElScrollControllerAttrModel? model]) {
    return ElSmoothScrollController(
      initialScrollOffset: model?.initialScrollOffset ?? 0.0,
      keepScrollOffset: model?.keepScrollOffset ?? true,
      debugLabel: model?.debugLabel,
      onAttach: model?.onAttach,
      onDetach: model?.onDetach,
    );
  }

  static Widget _arrowRightBuilder(BuildContext context) {
    return Icon(Icons.arrow_forward_ios);
  }

  static Widget _arrowDownBuilder(BuildContext context) {
    return Transform.rotate(angle: math.pi / 2, child: Icon(Icons.arrow_forward_ios));
  }

  @override
  List<Object?> get props => _props;
}

/// 响应式断点配置
@immutable
class ElResponsiveData with EquatableMixin {
  const ElResponsiveData({this.xs = 320, this.sm = 640, this.md = 1024, this.lg = 1920, this.xl = 2560});

  /// 特小号设备最大尺寸
  final double xs;

  /// 移动设备最大尺寸
  final double sm;

  /// 平板设备最大尺寸
  final double md;

  /// 桌面设备最大尺寸
  final double lg;

  /// 大屏桌面设备最大尺寸
  final double xl;

  @override
  List<Object?> get props => [xs, sm, md, lg, xl];
}

/// 菜单模型类
final class ElMenuModel<T> extends ElNestModel<ElMenuModel<T>> {
  const ElMenuModel({required super.key, required this.title, this.icon, this.data, super.children = const []});

  /// 菜单名字
  final String title;

  /// 菜单图标
  final Widget? icon;

  /// 自定义额外数据
  final T? data;

  @override
  List<Object?> get props => [...super.props, title, icon, data];

  @override
  String toString() {
    return 'ElMenuModel{key: $key, title: $title}';
  }
}

extension ElMenuModelExt<T> on List<ElMenuModel<T>> {
  /// 转换 [List] 菜单集合，此函数通常用于路由中，它会将嵌套子菜单的 key 转换成完整路径（拼接父级 key 地址）
  List<ElMenuModel<T>> toFullPath({String? parentPath}) {
    List<ElMenuModel<T>> buildNestPaths(List<ElMenuModel<T>> menus, String? parentPath) {
      return menus.map((menu) {
        final currentPath = _buildFullPath(parentPath, menu.key);
        final newMenu = ElMenuModel<T>(
          key: currentPath,
          title: menu.title,
          data: menu.data,
          children: menu.children.isNotEmpty ? buildNestPaths(menu.children, currentPath) : [],
        );

        return newMenu;
      }).toList();
    }

    return buildNestPaths(this, parentPath);
  }

  String _buildFullPath(String? parentPath, String currentKey) {
    if (parentPath == null) return currentKey;
    return '$parentPath/$currentKey'.replaceAll('//', '/');
  }
}

/// 创建默认的滚动控制器所支持的参数模型
class ElScrollControllerAttrModel {
  const ElScrollControllerAttrModel({
    this.initialScrollOffset,
    this.keepScrollOffset,
    this.onAttach,
    this.onDetach,
    this.debugLabel,
  });

  final double? initialScrollOffset;
  final bool? keepScrollOffset;
  final ScrollControllerCallback? onAttach;
  final ScrollControllerCallback? onDetach;
  final String? debugLabel;
}
