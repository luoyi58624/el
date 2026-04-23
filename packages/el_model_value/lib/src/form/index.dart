import 'package:el_flutter/el_flutter.dart' hide ElModelValue;
import 'package:el_flutter/ext.dart';
import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

part 'state.dart';

part 'rule.dart';

part 'model_value.dart';

/// 表单小部件，此组件拥有表单校验、数据重置功能，但不包含任何 UI 外观，
/// 创建 model 时必须明确指定 `Map<String, dynamic>` 类型，否则无法通过 dart 类型校验：
/// ```
/// class Example extends HookWidget {
///   const Example({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final form = useState<Map<String, dynamic>>({}); // 必须明确指定类型
///     return ElForm(form);
///   }
/// }
/// ```
///
/// 对于任何实现 [ElFormModelValue] 的小部件，都会将自身添加到 [ElForm] 的依赖列表中（仅限设置 prop 的字段），
/// [ElForm] 会统一更新数据、表单规则校验。
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
