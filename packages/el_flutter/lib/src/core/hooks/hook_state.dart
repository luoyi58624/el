import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

/// 将 Hook 状态抽离到独立的 class 类中
abstract class ElHookState with ChangeNotifier {
  /// 通知页面更新
  @mustCallSuper
  void notify() {
    notifyListeners();
  }

  /// 初始化状态
  void initState() {}

  /// 销毁状态
  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}

/// 页面局部状态 Hook，类似于 useState，只不过将状态抽离到独立的 class 中，示例：
/// ```dart
/// class _State extends ElHookState {
///   int count = 0;
/// }
///
/// class _Example extends HookWidget {
///   const _Example({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final state = usePageState(() => _State());
///
///     return ElevatedButton(
///       onPressed: () {
///         state.count++;
///         state.notify();
///       },
///       child: Text('count: ${state.count}'),
///     );
///   }
/// }
/// ```
///
/// * ignoreListener 是否忽略当前 HookWidget 的重建监听
T useHookState<T extends ElHookState>(T Function() builder, {bool ignoreListener = false}) {
  return use(_Hook(builder, ignoreListener));
}

class _Hook<T extends ElHookState> extends Hook<T> {
  const _Hook(this.builder, this.ignoreListener);

  final T Function() builder;
  final bool ignoreListener;

  @override
  _HookState<T> createState() => _HookState();
}

class _HookState<T extends ElHookState> extends HookState<T, _Hook<T>> {
  T? _state;

  @override
  void initHook() {
    super.initHook();
    _state = hook.builder();
    if (hook.ignoreListener == false) _state!.addListener(_listener);
    _state!.initState();
  }

  @override
  void didUpdateHook(_Hook<T> oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.ignoreListener != oldHook.ignoreListener) {
      if (hook.ignoreListener) {
        _state!.removeListener(_listener);
      } else {
        _state!.addListener(_listener);
      }
    }
  }

  @override
  void dispose() {
    _state!.dispose();
    _state = null;
  }

  @override
  T build(BuildContext context) => _state!;

  void _listener() {
    setState(() {});
  }

  @override
  Object? get debugValue => _state;

  @override
  String get debugLabel => 'usePageState<$T>';
}
