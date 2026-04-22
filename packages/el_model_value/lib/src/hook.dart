part of 'index.dart';

ValueNotifier<T> _useModelValue<T>(T? value, ValueNotifier<T>? modelValue) {
  return use(_Hook(value, modelValue));
}

class _Hook<T> extends Hook<T> {
  const _Hook(this.value, this.modelValue);

  final T? value;
  final ValueNotifier<T>? modelValue;

  @override
  _HookState<T> createState() => _HookState();
}

class _HookState<T> extends HookState<ValueNotifier<T>, _Hook<ValueNotifier<T>>> {
  ValueNotifier<T>? _valueNotifier;

  @override
  void initHook() {
    super.initHook();
    if (hook.modelValue != null) {
      _valueNotifier = hook.modelValue;
    } else {
      _valueNotifier = ValueNotifier(hook.value as T);
    }
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
    _valueNotifier!.dispose();
    _valueNotifier = null;
  }

  @override
  ValueNotifier<T> build(BuildContext context) => _valueNotifier!;

  void _listener() {
    setState(() {});
  }

  @override
  Object? get debugValue => _valueNotifier;

  @override
  String get debugLabel => 'useModelValue<$T>';
}
