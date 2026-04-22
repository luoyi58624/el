import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

abstract class ElModelValue<T> extends HookWidget {
  const ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final T? value;
  final ValueNotifier<T>? modelValue;
  final ValueChanged<T>? onChanged;

  @protected
  Widget builder(BuildContext context, ValueNotifier<T> modelValue);

  @override
  Widget build(BuildContext context) {
    final modelValue = _useModelValue<T>(value, this.modelValue);
    return ValueListenableBuilder(
      valueListenable: modelValue,
      builder: (context, value, child) => builder(context, modelValue),
    );
  }
}

class MySwitch extends ElModelValue<bool> {
  const MySwitch({super.key, super.value = false, super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, ValueNotifier<bool> modelValue) {
    return Switch(
      value: modelValue.value,
      onChanged: (v) {
        modelValue.value = v;
        onChanged?.call(v);
      },
    );
  }
}

class MyInput extends ElModelValue<String> {
  const MyInput({super.key, super.value = '', super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, ValueNotifier<String> modelValue) {
    return HookBuilder(
      builder: (context) {
        final controller = useTextEditingController();
        return TextField(
          controller: controller,
          onChanged: (v) {
            modelValue.value = v;
            onChanged?.call(v);
          },
        );
      },
    );
  }
}
