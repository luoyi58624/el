import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

extension ElUIThemeExt on BuildContext {
  /// 根据 Element 主题数据构建 Material 全局主题数据（可选），
  /// ```dart
  /// ElApp(
  ///   // 必须包裹 Builder 访问正确的 context
  ///   child: Builder(
  ///     builder: (context) {
  ///       return MaterialApp(theme: context.elMaterialThemeData);
  ///     }
  ///   ),
  /// );
  /// ```
  ThemeData get elMaterialThemeData {
    final isDesktop = ElPlatform.isDesktop;
    final brightness = ElBrightness.of(this);
    final isDark = brightness.isDark;

    final lightTheme = el.theme;
    final darkTheme = el.darkTheme;
    final elTheme = isDark ? darkTheme : lightTheme;

    final colorScheme = ColorScheme.fromSeed(brightness: brightness, seedColor: elTheme.primary);
    final themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Material 小部件默认颜色
      canvasColor: elTheme.bgColor,
      splashFactory: isDesktop ? InkRipple.splashFactory : InkSparkle.splashFactory,
      scaffoldBackgroundColor: elTheme.bgColor,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: isDesktop ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
      fontFamily: el.config.fontFamily,
      fontFamilyFallback: el.config.fontFamilyFallback,
      iconTheme: IconThemeData(color: elTheme.iconColor, size: el.config.iconSize),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    final secondaryTextStyle = elSecondaryTextStyle;
    final placeholderTextStyle = elPlaceholderTextStyle;
    final normalTextStyle = themeData.textTheme.bodyMedium!.copyWith(fontWeight: .normal.elFontWeight);
    final mediumTextStyle = themeData.textTheme.bodyMedium!.copyWith(fontWeight: .w500.elFontWeight);
    final boldTextStyle = themeData.textTheme.bodyMedium!.copyWith(fontWeight: .bold.elFontWeight);

    final borderWidth = el.config.borderWidth;
    final cardColor = elTheme.cardColor;

    final cardShape = RoundedRectangleBorder(borderRadius: el.config.cardBorderRadius);

    final buttonStyle = ButtonStyle(textStyle: WidgetStatePropertyAll(mediumTextStyle));

    final inputBorder = OutlineInputBorder(
      borderRadius: el.config.borderRadius,
      borderSide: BorderSide(width: borderWidth, strokeAlign: BorderSide.strokeAlignOutside),
    );

    final inputActiveBorder = OutlineInputBorder(
      borderRadius: el.config.borderRadius,
      borderSide: BorderSide(
        color: elTheme.primary,
        width: ElInputTheme.of(this).activeBorderWidth!,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );

    return themeData.copyWith(
      textTheme: themeData.textTheme.copyWith(
        titleLarge: themeData.textTheme.titleLarge?.merge(TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        bodyMedium: normalTextStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
      textButtonTheme: TextButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
      filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
      iconButtonTheme: IconButtonThemeData(style: ButtonStyle()),
      floatingActionButtonTheme: FloatingActionButtonThemeData(extendedTextStyle: mediumTextStyle),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(StadiumBorder(side: BorderSide())),
          textStyle: WidgetStatePropertyAll(mediumTextStyle),
          side: WidgetStatePropertyAll(BorderSide(color: Colors.grey)),
        ),
      ),
      sliderTheme: SliderThemeData(
        showValueIndicator: ShowValueIndicator.onDrag,
        valueIndicatorTextStyle: normalTextStyle.copyWith(
          color: colorScheme.primary.isDark ? darkTheme.textColor : lightTheme.textColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: elTheme.headerColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        // titleTextStyle: boldTextStyle.copyWith(
        //   fontSize: 18,
        //   color: elTheme.headerColor.isDark
        //       ? darkTextTheme.textStyle.color
        //       : textTheme.textStyle.color,
        // ),
        iconTheme: IconThemeData(color: elTheme.headerColor.elSecondaryTextColor(this)),
      ),
      tabBarTheme: TabBarThemeData(
        unselectedLabelStyle: mediumTextStyle.copyWith(fontSize: 15),
        labelStyle: mediumTextStyle.copyWith(fontSize: 15, color: elTheme.primary),
        unselectedLabelColor: elTheme.headerColor.isDark ? darkTheme.textColor.deepen(10) : lightTheme.regularTextColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 4,
        enableFeedback: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: elTheme.footerColor,
        unselectedLabelStyle: mediumTextStyle.copyWith(fontSize: 12),
        selectedLabelStyle: mediumTextStyle.copyWith(fontSize: 12, color: elTheme.primary),
        unselectedItemColor: secondaryTextStyle.color,
        selectedItemColor: elTheme.primary,
        selectedIconTheme: IconThemeData(color: elTheme.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(mediumTextStyle.copyWith(fontSize: 12)),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        // m3会将此颜色和color进行混合从而产生一个新的material颜色 (生成一个淡淡的Primary Color)，
        // 这里将其重置为透明，表示卡片用默认color展示
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: .zero,
        shape: cardShape,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: .circular(0)),
      ),
      datePickerTheme: DatePickerThemeData(
        headerHeadlineStyle: normalTextStyle,
        headerHelpStyle: normalTextStyle,
        weekdayStyle: normalTextStyle,
        dayStyle: normalTextStyle,
        yearStyle: normalTextStyle,
        rangePickerHeaderHelpStyle: normalTextStyle,
        rangePickerHeaderHeadlineStyle: normalTextStyle,
        cancelButtonStyle: buttonStyle,
        confirmButtonStyle: buttonStyle,
      ),
      timePickerTheme: themeData.timePickerTheme.copyWith(
        dayPeriodTextStyle: normalTextStyle,
        helpTextStyle: normalTextStyle,
        dialTextStyle: normalTextStyle.copyWith(fontSize: 18),
        hourMinuteTextStyle: normalTextStyle.copyWith(fontSize: 48),
        cancelButtonStyle: buttonStyle,
        confirmButtonStyle: buttonStyle,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: mediumTextStyle.copyWith(fontSize: 15),
        subtitleTextStyle: mediumTextStyle.copyWith(color: secondaryTextStyle.color, fontSize: 13),
        iconColor: secondaryTextStyle.color,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: mediumTextStyle.copyWith(fontSize: 16),
        hintStyle: normalTextStyle.copyWith(color: placeholderTextStyle.color),
        contentPadding: const .all(8.0),
        // 清除默认图标限制（48*48），如果不这么做，当输入框尺寸低于 48 像素时图标会被压扁
        prefixIconConstraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
        suffixIconConstraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputActiveBorder,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        textColor: elTheme.primary,
        shape: Border.all(width: 0, style: BorderStyle.none),
        collapsedShape: Border.all(width: 0, style: BorderStyle.none),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        enableFeedback: true,
        textStyle: normalTextStyle.copyWith(fontSize: 14),
        shape: cardShape,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: boldTextStyle.copyWith(fontSize: 18),
        contentTextStyle: normalTextStyle.copyWith(color: elRegularTextStyle.color),
        elevation: 6,
        backgroundColor: elTheme.bgColor,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        actionsPadding: const .all(8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        refreshBackgroundColor: isDark ? Colors.grey.shade700 : Colors.white,
        color: elTheme.primary,
      ),
    );
  }
}
