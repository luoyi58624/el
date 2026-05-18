import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 当 Widget 发生更新时执行，此 hook 会传递旧 Widget 实例
void useDidUpdate<W extends Widget>(void Function(W oldWidget) fun, W widget) {
  use(_Hook(fun, widget));
}

class _Hook<W extends Widget> extends Hook {
  const _Hook(this.fun, this.widget);

  final void Function(W oldWidget) fun;
  final W widget;

  @override
  _HookState<W> createState() => _HookState<W>();
}

class _HookState<W extends Widget> extends HookState<void, _Hook<W>> {
  W? oldWidget;

  @override
  void reassemble() {
    // 热更新时清除缓存，避免执行 hook 回调，因为 StatefulWidget 在热刷新期间也不会重新执行
    oldWidget = null;
    super.reassemble();
  }

  @override
  void didUpdateHook(_Hook<W> oldHook) {
    super.didUpdateHook(oldHook);
    if (oldWidget != null && oldWidget != hook.widget) hook.fun(oldWidget!);
    oldWidget = hook.widget;
  }

  @override
  void build(BuildContext context) {}
}
