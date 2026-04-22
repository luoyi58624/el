import 'package:el_flutter/el_flutter.dart';
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

abstract class ElModelValue<T> extends HookWidget {
  const ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final T? value;
  final ValueNotifier<T>? modelValue;
  final ValueChanged<T>? onChanged;

  @protected
  ValueNotifier<T> createModelValue(BuildContext context) {
    if (modelValue != null) return modelValue!;
    assert(value != null, 'ElModelValue Error: if modelValue is null, The value cannot be null.');
    return useState(value as T);
  }

  @protected
  Widget builder(BuildContext context, T value);

  @override
  Widget build(BuildContext context) {
    final modelValue = createModelValue(context);
    return ValueListenableBuilder(
      valueListenable: modelValue,
      builder: (context, value, child) => builder(context, value),
    );
  }
}

class MySwitch extends ElModelValue<bool> {
  const MySwitch({super.key, super.value = false, super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, bool value) {
    return Switch(
      value: value,
      onChanged: (v) {
        if (modelValue != null) modelValue!.value = v;
        onChanged?.call(v);
      },
    );
  }
}

class MyInput extends ElModelValue<String> {
  const MyInput({super.key, super.value = '', super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, String value) {
    return HookBuilder(
      builder: (context) {
        final controller = useTextEditingController();
        return TextField(
          controller: controller,
          onChanged: (v) {
            if (modelValue != null) modelValue!.value = v;
            onChanged?.call(v);
          },
        );
      },
    );
  }
}
