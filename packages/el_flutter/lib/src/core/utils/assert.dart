import 'package:el_flutter/el_flutter.dart';

abstract class ElAssert {
  static String elementError(String message) {
    return 'Element UI 内部错误: $message';
  }

  static void themeType(ElThemeType? type, String componentName) {
    assert(type == null || ElThemeType.types.contains(type), '$componentName: 主题字符串常量断言失败，建议通过 El 访问主题类型，错误类型：$type');
  }

  static void themeTypeRequired(ElThemeType type, String componentName) {
    assert(ElThemeType.types.contains(type), '$componentName: 主题字符串常量断言失败，建议通过 El 访问主题类型，错误类型：$type');
  }
}
