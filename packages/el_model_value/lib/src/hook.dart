part of 'index.dart';

Obs<T> _useModelValue<T>(T? value, ValueNotifier<T>? modelValue) {
  assert(modelValue != null || value != null, 'ElModelValue Error: if modelValue is null, The value cannot be null.');
  return use(_ModelValueHook<T>(value: value, modelValue: modelValue));
}

class _ModelValueHook<T> extends Hook<Obs<T>> {
  const _ModelValueHook({this.value, this.modelValue});

  final T? value;
  final ValueNotifier<T>? modelValue;

  @override
  _ModelValueHookState<T> createState() => _ModelValueHookState<T>();
}

class _ModelValueHookState<T> extends HookState<Obs<T>, _ModelValueHook<T>> {
  late final Obs<T> _obs;

  @override
  void initHook() {
    super.initHook();
    if (hook.modelValue is ValueNotifier) {
      final raw = hook.modelValue as ValueNotifier<T>;
      _obs = Obs<T>(raw.value);
      raw.addListener(_linkRawObs);
    } else {
      _obs = Obs<T>(hook.value as T);
    }
  }

  void _linkRawObs() {
    _obs.rawValue = (hook.modelValue as ValueNotifier).value;
    _obs.notify();
  }

  @override
  void didUpdateHook(_ModelValueHook<T> oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.modelValue != oldHook.modelValue) {
      if (oldHook.modelValue is ValueNotifier) {
        (oldHook.modelValue as ValueNotifier).removeListener(_linkRawObs);
      }
      if (hook.modelValue is ValueNotifier) {
        final raw = hook.modelValue as ValueNotifier<T>;
        raw.addListener(_linkRawObs);
        safeCallback(() => _obs.value = raw.value);
      } else {
        assert(hook.value != null);
        safeCallback(() => _obs.value = hook.value as T);
      }
    }
  }

  @override
  void dispose() {
    if (hook.modelValue is ValueNotifier) {
      (hook.modelValue as ValueNotifier).removeListener(_linkRawObs);
    }
    _obs.dispose();
    super.dispose();
  }

  @override
  Obs<T> build(BuildContext context) => _obs;

  @override
  String get debugLabel => 'useModelValue<$T>';
}
