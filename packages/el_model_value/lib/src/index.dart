import 'package:el_flutter/el_flutter.dart' show safeCallback;
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

abstract class ElModelValue<T> extends HookWidget {
  const ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final T? value;
  final ValueNotifier<T>? modelValue;
  final ValueChanged<T>? onChanged;

  @protected
  Widget builder(BuildContext context, Obs<T> obs);

  @override
  Widget build(BuildContext context) {
    final obs = _useModelValue<T>(value, modelValue, onChanged);
    return ListenableBuilder(
      listenable: obs,
      builder: (context, child) => builder(context, obs),
    );
  }
}

class MySwitch extends ElModelValue<bool> {
  const MySwitch({
    super.key,
    super.value = false,
    super.modelValue,
    super.onChanged,
  });

  @override
  Widget builder(BuildContext context, Obs<bool> obs) {
    return Switch(
      value: obs.value,
      onChanged: (v) {
        obs.value = v;
      },
    );
  }
}

class MyInput extends ElModelValue<String> {
  const MyInput({
    super.key,
    super.value = '',
    super.modelValue,
    super.onChanged,
  });

  @override
  Widget builder(BuildContext context, Obs<String> obs) {
    return HookBuilder(
      builder: (context) {
        final controller = useTextEditingController();
        return TextField(
          controller: controller,
          onChanged: (v) {
            obs.value = v;
          },
        );
      },
    );
  }
}
