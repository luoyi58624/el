part of 'index.dart';

ValueNotifier<T> _useModelValue<T>(T? value, ValueNotifier<T>? modelValue) {
  assert(modelValue != null || value != null, 'ElModelValue Error: if modelValue is null, The value cannot be null.');
  return use(_ModelValueHook<T>(value: value, modelValue: modelValue));
}

class _ModelValueHook<T> extends Hook<ValueNotifier<T>> {
  const _ModelValueHook({this.value, this.modelValue});

  final T? value;
  final ValueNotifier<T>? modelValue;

  @override
  _ModelValueHookState<T> createState() => _ModelValueHookState<T>();
}

class _ModelValueHookState<T> extends HookState<ValueNotifier<T>, _ModelValueHook<T>> {
  /// 无外部 [modelValue] 时本 Hook 创建并负责 dispose。
  ValueNotifier<T>? _owned;

  @override
  void initHook() {
    super.initHook();
    if (hook.modelValue == null) {
      _owned = ValueNotifier(hook.value as T);
    }
  }

  @override
  void didUpdateHook(_ModelValueHook<T> oldHook) {
    super.didUpdateHook(oldHook);
    if (oldHook.modelValue == null && hook.modelValue != null) {
      _owned?.dispose();
      _owned = null;
    } else if (oldHook.modelValue != null && hook.modelValue == null) {
      assert(hook.value != null, 'ElModelValue: 从外部 `modelValue` 切到内部状态时需同时提供 `value`。');
      _owned ??= ValueNotifier(hook.value as T);
    }
  }

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  ValueNotifier<T> build(BuildContext context) {
    final m = hook.modelValue;
    if (m != null) {
      return m;
    }
    assert(_owned != null, 'ElModelValue: 内部 `ValueNotifier` 未初始化。');
    return _owned!;
  }

  @override
  String get debugLabel => 'useModelValue<$T>';
}
