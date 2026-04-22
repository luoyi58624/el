import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 给响应式变量添加监听函数
void useAddListener(ValueListenable listenable, VoidCallback callback) {
  use(_Hook(listenable, callback));
}

class _Hook extends Hook {
  const _Hook(this.listenable, this.callback);

  final ValueListenable listenable;
  final VoidCallback callback;

  @override
  _HookState createState() => _HookState();
}

class _HookState extends HookState<void, _Hook> {
  @override
  void initHook() {
    super.initHook();
    hook.listenable.addListener(hook.callback);
  }

  @override
  void didUpdateHook(_Hook oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.listenable != oldHook.listenable) {
      oldHook.listenable.removeListener(hook.callback);
      hook.listenable.addListener(hook.callback);
    }
  }

  @override
  void dispose() {
    hook.listenable.removeListener(hook.callback);
    super.dispose();
  }

  @override
  void build(BuildContext context) {}
}
