library;

import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';

export 'package:el_state/el_state.dart' show Obs;

export 'src/core/index.dart';
export 'src/form/index.dart';

class MySwitch extends ElModelValue<bool> {
  const MySwitch({super.key, super.value = false, super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, Obs<bool> obs, Map<String, dynamic> model) {
    return Switch(
      value: obs.value,
      onChanged: (v) {
        obs.value = v;
      },
    );
  }
}

class MyInput extends ElInputModelValue<String> {
  const MyInput({super.key, super.value = '', super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, Obs<String> obs, Map<String, dynamic> model) {
    final controller = getTextController(model);
    return TextField(
      controller: controller,
      onChanged: (v) {
        obs.value = v;
      },
    );
  }

  @override
  Widget buildInput(BuildContext context) {
    // TODO: implement buildInput
    throw UnimplementedError();
  }
}
