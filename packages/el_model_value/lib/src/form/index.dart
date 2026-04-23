import 'package:el_flutter/el_flutter.dart' hide ElModelValue;
import 'package:el_flutter/ext.dart';
import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

part 'state.dart';

part 'model_value.dart';

class ElForm extends HookWidget {
  const ElForm({super.key, required this.controller, required this.child});

  final ElFormController controller;
  final Widget child;

  static ElFormController of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, '当前 context 没有找到 ElForm 实例，如果你确定祖先存在 ElForm，那么请使用 Builder 转发 context 对象');
    return result!;
  }

  static ElFormController? maybeOf(BuildContext context) {
    return context.read<ElFormController?>();
  }

  @override
  Widget build(BuildContext context) {
    final formState = useHookState(() => controller);

    return Provider.value(value: formState, child: child);
  }
}
