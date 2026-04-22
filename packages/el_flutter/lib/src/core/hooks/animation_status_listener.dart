import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 给动画控制器添加状态监听
void useAnimationStatusListener(AnimationController controller, AnimationStatusListener callback) {
  use(_Hook(controller, callback));
}

class _Hook extends Hook {
  const _Hook(this.controller, this.callback);

  final AnimationController controller;
  final AnimationStatusListener callback;

  @override
  _HookState createState() => _HookState();
}

class _HookState extends HookState<void, _Hook> {
  AnimationStatusListener? _callback;

  @override
  void initHook() {
    super.initHook();
    _callback = hook.callback;
    hook.controller.addStatusListener(_callback!);
  }

  @override
  void didUpdateHook(_Hook oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.controller != oldHook.controller) {
      oldHook.controller.removeStatusListener(_callback!);
      _callback = hook.callback;
      hook.controller.addStatusListener(_callback!);
    }
  }

  @override
  void dispose() {
    hook.controller.removeStatusListener(_callback!);
    _callback = null;
    super.dispose();
  }

  @override
  void build(BuildContext context) {}
}
