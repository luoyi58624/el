import 'package:el_flutter/el_flutter.dart' show safeCallback;
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

abstract class ElModelValue<T> extends HookWidget {
  const ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final T? value;
  final ValueNotifier<T>? modelValue;
  final ValueChanged<T>? onChanged;

  /// 与 [ElModelValueMixin] 的 [modelValue] setter 一致：有外部 [modelValue] 时写其 [ValueNotifier]，否则只写 [obs]。
  @protected
  void commitValue(T v, Obs<T> obs) {
    if (modelValue != null) {
      modelValue!.value = v;
    } else {
      obs.value = v;
    }
    onChanged?.call(v);
  }

  @protected
  Widget builder(BuildContext context, Obs<T> obs);

  @override
  Widget build(BuildContext context) {
    final obs = _useModelValue<T>(value, modelValue);
    return ListenableBuilder(
      listenable: obs,
      builder: (context, child) => builder(context, obs),
    );
  }
}

class MySwitch extends ElModelValue<bool> {
  const MySwitch({super.key, super.value = false, super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, Obs<bool> obs) {
    return Switch(
      value: obs.value,
      onChanged: (v) {
        commitValue(v, obs);
      },
    );
  }
}

class MyInput extends ElModelValue<String> {
  const MyInput({super.key, super.value = '', super.modelValue, super.onChanged});

  @override
  Widget builder(BuildContext context, Obs<String> obs) {
    return HookBuilder(
      builder: (context) {
        final controller = useTextEditingController();
        return TextField(
          controller: controller,
          onChanged: (v) {
            commitValue(v, obs);
          },
        );
      },
    );
  }
}
