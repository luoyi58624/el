import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

class ElSwitch extends ElFormModelValue<bool> {
  ElSwitch({super.key, super.value, super.modelValue, super.prop, super.onChanged});

  @override
  Widget obsBuilder(BuildContext context) {
    return Switch.adaptive(value: $obs.value, onChanged: (v) => $obs.value = v);
  }
}
