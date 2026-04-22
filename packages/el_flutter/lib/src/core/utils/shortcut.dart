import 'package:flutter/services.dart';
import 'package:el_flutter/el_flutter.dart';

class ShortcutUtil {
  ShortcutUtil._();

  /// 定义 ctrl 修饰键，但在 Mac 操作系统上，ctrl 修饰键相当于 command 键
  static final ctrl = !ElPlatform.isMacOS ? LogicalKeyboardKey.control : LogicalKeyboardKey.meta;
}
