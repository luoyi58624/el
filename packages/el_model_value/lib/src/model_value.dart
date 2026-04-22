import 'package:el_flutter/el_flutter.dart';
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

class ElModelValueState<T> extends ElHookState {}

abstract class ElModelValue<T, D extends ElModelValueState<T>> extends HookWidget {
  const ElModelValue({super.key, required this.state});

  final D state;

  @protected
  Widget builder(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final hookState = useHookState(() => state);
    return ListenableBuilder(listenable: hookState, builder: (context, child) => builder(context));
  }
}
