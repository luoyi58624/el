import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:el_flutter/el_flutter.dart';

class ElCursorUtil {
  ElCursorUtil._();

  static OverlayEntry? _overlayEntry;

  /// 插入全局光标
  static void insertGlobalCursor([MouseCursor cursor = MouseCursor.defer]) {
    if (ElPlatform.isDesktop && _overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Listener(
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(cursor: cursor),
        ),
      );
      el.overlay.insert(_overlayEntry!);
    }
  }

  /// 移除全局光标
  static void removeGlobalCursor() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry!.dispose();
      _overlayEntry = null;
    }
  }

  /// loading 加载光标
  static MouseCursor get loadingCursor {
    if (kIsWeb) return SystemMouseCursors.wait;
    if (ElPlatform.isMacOS) {
      return SystemMouseCursors.forbidden;
    } else {
      return SystemMouseCursors.wait;
    }
  }

  /// 构建抓握样式，手指张开
  static MouseCursor get grab {
    if (kIsWeb) return SystemMouseCursors.grab;
    if (ElPlatform.isWindows) {
      return SystemMouseCursors.click;
    } else {
      return SystemMouseCursors.grab;
    }
  }

  /// 构建抓握样式，手指闭合
  static MouseCursor get grabbing {
    if (kIsWeb) return SystemMouseCursors.grabbing;
    if (ElPlatform.isWindows) {
      return SystemMouseCursors.click;
    } else {
      return SystemMouseCursors.grabbing;
    }
  }
}
