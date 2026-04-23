import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';

class ElSwitch extends ElFormModelValue<bool> {
  ElSwitch({super.key, super.value, super.modelValue, super.prop, super.onChanged});

  @override
  Widget obsBuilder(BuildContext context) {
    return Switch.adaptive(value: $obs.value, onChanged: (v) => $obs.value = v);
  }
}
