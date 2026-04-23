import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';

class MySwitch extends ElModelValue<bool> {
  MySwitch({super.key, super.value = false, super.modelValue, super.onChanged});

  @override
  Widget obsBuilder(BuildContext context) {
    return Switch(
      value: $obs.value,
      onChanged: (v) {
        $obs.value = v;
      },
    );
  }
}

class MyInput extends ElInputModelValue<String> {
  MyInput({super.key, super.value = '', super.modelValue, super.onChanged});

  @override
  Widget buildInput(BuildContext context) {
    return TextField(
      controller: $textController,
      onChanged: (v) {
        $obs.value = v;
      },
    );
  }
}
