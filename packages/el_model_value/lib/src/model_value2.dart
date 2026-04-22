import 'package:el_flutter/el_flutter.dart';
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

class ElModelValueState<T> extends ElHookState {
  T? _value;

  T? get value => _value;

  set value(T? v) {
    if (_value == v) return;
    _value = v;
    notify();
  }
}

abstract class ElModelValue<T, D extends ElModelValueState<T>> extends HookWidget {
  const ElModelValue({super.key, required this.state});

  final D state;

  @protected
  Widget builder(BuildContext context, D state);

  @override
  Widget build(BuildContext context) {
    final hookState = useHookState(() => state);
    return builder(context, hookState);
  }
}

class MySwitch extends ElModelValue<bool, ElModelValueState<bool>> {
  MySwitch({super.key}) : super(state: ElModelValueState());

  @override
  Widget builder(BuildContext context, ElModelValueState<bool> state) {
    return Switch(value: state.value ?? false, onChanged: (v) => state.value = v);
  }
}
