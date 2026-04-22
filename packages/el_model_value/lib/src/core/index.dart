import 'package:el_flutter/el_flutter.dart' show safeCallback;
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

abstract class ElModelValue<D> extends HookWidget {
  ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final D? value;
  final ValueNotifier<D>? modelValue;
  final ValueChanged<D>? onChanged;

  @protected
  final Map<String, dynamic> $model = {};

  @protected
  Widget builder(BuildContext context);

  @protected
  Obs<D> get $obs => $model['obs'] as Obs<D>;

  @override
  Widget build(BuildContext context) {
    $model['obs'] = _useModelValue<D>(value, modelValue, onChanged);
    return ListenableBuilder(listenable: $model['obs'], builder: (context, child) => builder(context));
  }
}
