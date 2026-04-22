import 'package:flutter/material.dart';
import 'package:el_ui/el_ui.dart';

// 官方提供的 Switch 是 StatelessWidget 小部件，所以没办法通过继承暴露 Switch 全部参数，
// 要自定义外观请自行封装即可，代码也就 10 行左右
class ElSwitch extends ElFormModelValue<bool> {
  const ElSwitch(super.modelValue, {super.key, super.prop, super.onChanged});

  @override
  State<ElSwitch> createState() => _ElSwitchState();
}

class _ElSwitchState extends ElFormModelValueState<ElSwitch, bool> {
  @override
  Widget obsBuilder(BuildContext context) {
    return Switch.adaptive(value: modelValue, onChanged: (v) => modelValue = v);
  }
}
