import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
class ElThemeGenerator {
  /// 生成局部主题配置类，主题类必须提供 theme、darkTheme 默认静态对象：
  /// ```dart
  /// class MyThemeData {
  ///   static const theme = MyThemeData();
  ///   static const darktheme = MyThemeData();
  ///
  ///   const MyThemeData();
  /// }
  /// ```
  const ElThemeGenerator({this.generateThemeWidget = true, this.generateAnimatedThemeWidget = false});

  /// 是否生成局部主题小部件，默认 true
  final bool generateThemeWidget;

  /// 生成局部动画主题小部件，默认 false，如果 [generateThemeWidget] 为 false，那么此选项会失效
  final bool generateAnimatedThemeWidget;
}
