import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 创建 [CurvedAnimation] 动画 Hook
CurvedAnimation useCurvedAnimation({required Animation<double> parent, required Curve curve, Curve? reverseCurve}) {
  return use(_Hook(parent, curve, reverseCurve));
}

class _Hook extends Hook<CurvedAnimation> {
  const _Hook(this.parent, this.curve, this.reverseCurve);

  final Animation<double> parent;
  final Curve curve;
  final Curve? reverseCurve;

  @override
  _HookState createState() => _HookState();
}

class _HookState extends HookState<CurvedAnimation, _Hook> {
  late final curveAnimation = CurvedAnimation(parent: hook.parent, curve: hook.curve, reverseCurve: hook.reverseCurve);

  @override
  void didUpdateHook(_Hook oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.curve != oldHook.curve) {
      curveAnimation.curve = hook.curve;
    }
    if (hook.reverseCurve != oldHook.reverseCurve) {
      curveAnimation.reverseCurve = hook.reverseCurve;
    }
  }

  @override
  void dispose() {
    curveAnimation.dispose();
    super.dispose();
  }

  @override
  CurvedAnimation build(BuildContext context) => curveAnimation;
}
