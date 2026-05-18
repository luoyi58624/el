import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 监听响应式变量发生变化：
/// ```dart
/// useWatch(listenable, (newValue, oldValue) {});
/// ```
void useWatch<T>(ValueListenable<T> listenable, ElUpdateCallback<T> watchFun) {
  use(_Hook(listenable, watchFun));
}

class _Hook<T> extends Hook {
  const _Hook(this.listenable, this.watchFun);

  final ValueListenable<T> listenable;
  final ElUpdateCallback<T> watchFun;

  @override
  _HookState<T> createState() => _HookState();
}

class _HookState<T> extends HookState<void, _Hook<T>> {
  late T oldValue;

  void _listenFun() {
    if (oldValue != hook.listenable.value) {
      hook.watchFun(hook.listenable.value, oldValue);
      oldValue = hook.listenable.value;
    }
  }

  @override
  void initHook() {
    super.initHook();
    oldValue = hook.listenable.value;
    hook.listenable.addListener(_listenFun);
  }

  @override
  void didUpdateHook(_Hook<T> oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.listenable != oldHook.listenable) {
      oldHook.listenable.removeListener(_listenFun);
      hook.listenable.addListener(_listenFun);
    }
  }

  @override
  void dispose() {
    hook.listenable.removeListener(_listenFun);
    super.dispose();
  }

  @override
  void build(BuildContext context) {}
}
