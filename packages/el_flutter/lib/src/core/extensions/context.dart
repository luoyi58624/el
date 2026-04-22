import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

extension ElBuildContextExt on BuildContext {
  /// 访问自适应主题，如果当前是暗黑模式，则获取注入的暗黑主题，否则获取注入的亮色主题
  ElThemeData get elTheme => ElBrightness.isDark(this) ? el.darkTheme : el.theme;

  Map<ElThemeType, Color> get elThemeColors {
    final data = elTheme;
    return {
      .primary: data.primary,
      .secondary: data.secondary,
      .success: data.success,
      .info: data.info,
      .warning: data.warning,
      .error: data.error,
    };
  }

  /// 访问祖先提供的默认颜色
  Color get elDefaultColor =>
      dependOnInheritedWidgetOfExactType<ElDefaultColor>()?.color ??
      (ElBrightness.isDark(this) ? el.darkTheme.bgColor : el.theme.bgColor);

  /// 构建默认颜色的边框对象
  Border elBorder({Color? color, double? width}) =>
      Border.all(color: color ?? elTheme.borderColor, width: width ?? el.config.borderWidth);

  /// 构建主题颜色的边框对象
  Border elPrimaryBorder({Color? color, double? width}) =>
      Border.all(color: color ?? elTheme.primary, width: width ?? el.config.borderWidth);

  TextStyle get elTextStyle {
    return TextStyle(
      color: elTheme.textColor,
      fontSize: el.config.fontSize,
      fontFamily: el.config.fontFamily,
      fontFamilyFallback: el.config.fontFamilyFallback,
    );
  }

  TextStyle get elRegularTextStyle {
    return TextStyle(
      color: elTheme.regularTextColor,
      fontSize: el.config.fontSize,
      fontFamily: el.config.fontFamily,
      fontFamilyFallback: el.config.fontFamilyFallback,
    );
  }

  TextStyle get elSecondaryTextStyle {
    return TextStyle(
      color: elTheme.secondaryTextColor,
      fontSize: el.config.fontSize,
      fontFamily: el.config.fontFamily,
      fontFamilyFallback: el.config.fontFamilyFallback,
    );
  }

  TextStyle get elPlaceholderTextStyle {
    return TextStyle(
      color: elTheme.placeholderTextColor,
      fontSize: el.config.fontSize,
      fontFamily: el.config.fontFamily,
      fontFamilyFallback: el.config.fontFamilyFallback,
    );
  }
}
