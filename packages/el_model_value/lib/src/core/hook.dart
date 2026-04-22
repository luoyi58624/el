part of 'index.dart';

Obs<D> _useModelValue<D>(D? value, ValueNotifier<D>? modelValue, ValueChanged<D>? onChanged) {
  assert(modelValue != null || value != null, 'ElModelValue Error: if modelValue is null, The value cannot be null.');
  return use(_ModelValueHook<D>(value: value, modelValue: modelValue, onChanged: onChanged));
}

class _ModelValueHook<D> extends Hook<Obs<D>> {
  const _ModelValueHook({this.value, this.modelValue, this.onChanged});

  final D? value;
  final ValueNotifier<D>? modelValue;
  final ValueChanged<D>? onChanged;

  @override
  _ModelValueHookState<D> createState() => _ModelValueHookState<D>();
}

class _ModelValueHookState<D> extends HookState<Obs<D>, _ModelValueHook<D>> {
  late final Obs<D> _obs;

  void _onChanged() {
    hook.modelValue?.value = _obs.value;
    hook.onChanged?.call(_obs.value);
  }

  @override
  void initHook() {
    super.initHook();
    final rawObs = hook.modelValue;
    if (rawObs != null) {
      _obs = Obs<D>(rawObs.value);
      rawObs.addListener(_linkRawObs);
    } else {
      _obs = Obs<D>(hook.value as D);
    }
    _obs.addListener(_onChanged);
  }

  /// 给外部响应式变量添加监听，将更新同步到内部的 [_obs] 变量
  void _linkRawObs() {
    assert(hook.modelValue != null, 'ElModelValue Error: _linkRawObs has Exception.');
    _obs.rawValue = hook.modelValue!.value;
    _obs.notify();
  }

  @override
  void didUpdateHook(_ModelValueHook<D> oldHook) {
    super.didUpdateHook(oldHook);
    bool? ignoreValueUpdate; // 如果是 modelValue 发生变更，则不需要更新 value
    if (hook.modelValue != oldHook.modelValue) {
      oldHook.modelValue?.removeListener(_linkRawObs);
      if (hook.modelValue != null) {
        ignoreValueUpdate = true;
        final rawObs = hook.modelValue!;
        rawObs.addListener(_linkRawObs);
        safeCallback(() => _obs.value = rawObs.value);
      }
    }

    if (ignoreValueUpdate != true) {
      if (hook.value != oldHook.value) {
        safeCallback(() => _obs.value = hook.value as D);
      }
    }
  }

  @override
  void dispose() {
    hook.modelValue?.removeListener(_linkRawObs);
    _obs.removeListener(_onChanged);
    _obs.dispose();
    super.dispose();
  }

  @override
  Obs<D> build(BuildContext context) => _obs;

  @override
  String get debugLabel => 'useModelValue<$D>';
}
