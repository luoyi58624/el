import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 快捷键处理，如果返回 true，那么将阻止快捷键冒泡
typedef ElShortcutHandler = bool Function();

/// 处理快捷键混入
mixin ElShortcutMixin {
  /// 注册的快捷键列表
  Map<ShortcutActivator, ElShortcutHandler> get shortcuts;

  /// 监听按键
  KeyEventResult shortcutListener(FocusNode node, KeyEvent event) {
    for (final ShortcutActivator activator in shortcuts.keys) {
      if (activator.accepts(event, HardwareKeyboard.instance)) {
        final result = shortcuts[activator]!.call();
        return result == true ? KeyEventResult.handled : KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  }
}

class ElShortcut extends StatelessWidget with ElShortcutMixin {
  const ElShortcut({
    super.key,
    required this.child,
    this.autofocus,
    this.canRequestFocus,
    required Map<ShortcutActivator, ElShortcutHandler> shortcuts,
  }) : _shortcuts = shortcuts;

  final Widget child;
  final bool? autofocus;
  final bool? canRequestFocus;
  final Map<ShortcutActivator, ElShortcutHandler> _shortcuts;

  @override
  Map<ShortcutActivator, ElShortcutHandler> get shortcuts => _shortcuts;

  @override
  Widget build(BuildContext context) {
    return Focus(
      debugLabel: '$Shortcuts',
      autofocus: autofocus ?? false,
      canRequestFocus: canRequestFocus ?? autofocus != null,
      onKeyEvent: shortcutListener,
      child: child,
    );
  }
}
