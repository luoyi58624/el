import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

extension ElColorContextExt on Color {
  Color elLight1(BuildContext context, {bool reverse = false}) => _elLight(context, 1, reverse);

  Color elLight2(BuildContext context, {bool reverse = false}) => _elLight(context, 2, reverse);

  Color elLight3(BuildContext context, {bool reverse = false}) => _elLight(context, 3, reverse);

  Color elLight4(BuildContext context, {bool reverse = false}) => _elLight(context, 4, reverse);

  Color elLight5(BuildContext context, {bool reverse = false}) => _elLight(context, 5, reverse);

  Color elLight6(BuildContext context, {bool reverse = false}) => _elLight(context, 6, reverse);

  Color elLight7(BuildContext context, {bool reverse = false}) => _elLight(context, 7, reverse);

  Color elLight8(BuildContext context, {bool reverse = false}) => _elLight(context, 8, reverse);

  Color elLight9(BuildContext context, {bool reverse = false}) => _elLight(context, 9, reverse);

  Color elTextColor(BuildContext context) {
    return isDark ? el.darkTheme.textColor : el.theme.textColor;
  }

  Color elRegularTextColor(BuildContext context) {
    return isDark ? el.darkTheme.regularTextColor : el.theme.regularTextColor;
  }

  Color elSecondaryTextColor(BuildContext context) {
    return isDark ? el.darkTheme.secondaryTextColor : el.theme.secondaryTextColor;
  }

  Color elPlaceholderTextColor(BuildContext context) {
    return isDark ? el.darkTheme.placeholderTextColor : el.theme.placeholderTextColor;
  }

  Color elIconColor(BuildContext context) {
    return isDark ? el.darkTheme.iconColor : el.theme.iconColor;
  }

  /// 根据当前颜色生成 Element UI 9 种级别的渐变颜色
  List<Color> elLights(BuildContext context) {
    return [
      elLight1(context),
      elLight2(context),
      elLight3(context),
      elLight4(context),
      elLight5(context),
      elLight6(context),
      elLight7(context),
      elLight8(context),
      elLight9(context),
    ];
  }
}

extension _ColorExtension on Color {
  Color _darken(int level) => mix(const Color(0xff222222), level * 9);

  Color _brighten(int level) => mix(const Color(0xffffffff), level * 10);

  /// 根据当前颜色返回符合 Element 主题系统颜色。
  /// * 如果当前是亮色模式，则与白色进行混合，level 级别越高，颜色越接近白色
  /// * 如果当前是暗色模式，则与黑色进行混合，level 级别越高，颜色越接近黑色
  /// * reverse - 是否应用反转颜色
  Color _elLight(BuildContext context, int level, bool reverse) {
    assert(level >= 1 && level <= 9, 'elLight 颜色级别范围必须是 1 - 9，但却得到: $level');
    if (!reverse) {
      return ElBrightness.isDark(context) ? _darken(level) : _brighten(level);
    } else {
      return ElBrightness.isDark(context) ? _brighten(level) : _darken(level);
    }
  }
}
