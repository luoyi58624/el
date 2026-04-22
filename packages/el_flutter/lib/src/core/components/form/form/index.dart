import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

part 'form_rule.dart';

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
class ElForm extends ElModelValue<Map<String, dynamic>> {
  const ElForm(
    super.modelValue, {
    super.key,
    this.rules,
    this.errorTextStyle = const TextStyle(fontSize: 12, color: Colors.red),
    super.onChanged,
    this.child,
  });

  /// 表单规则集合，其中 key 对应模型数据的 key，value 为表单规则对象
  final Map<String, List<ElFormRule>>? rules;

  /// 错误文本样式
  final TextStyle errorTextStyle;

  final Widget? child;

  /// 从当前上下文获取表单对象（不注册依赖）
  static ElFormState of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, '当前 context 没有找到 ElForm 实例，如果你确定祖先存在 ElForm，那么请使用 Builder 转发 context 对象');
    return result!;
  }

  /// 判断祖先是否存在表单
  static ElFormState? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<_ElFormScope>()?.state;

  @override
  State<ElForm> createState() => ElFormState();
}

class ElFormState<T extends ElForm> extends State<T> with ElModelValueMixin<T, Map<String, dynamic>> {
  /// 收集带 [ElFormModelValue.prop] 的字段；使用 [Set] 避免子组件多次 [build] 重复注册。
  Set<ElFormModelValueState> fields = {};

  /// 收集验证失败的错误消息，你可以直接操作此对象，它会自动更新 UI 上的错误信息
  final errorMessages = MapObs<String, String>({});

  /// 保存表单初始值
  Map<String, dynamic> get initialValue => _initialValue!;
  Map<String, dynamic>? _initialValue;

  /// 验证表单
  bool validate() {
    for (final field in fields) {
      final prop = field.widget.prop!;

      String? msg;

      if (widget.rules != null && widget.rules!.containsKey(prop)) {
        List<ElFormRule> rules = widget.rules![prop]!;
        for (final rule in rules) {
          if (rule.validator(rule, modelValue[prop]) != true) {
            msg = rule.message;
            break;
          }
        }
      }

      if (msg == null) {
        errorMessages.remove(prop);
      } else {
        errorMessages[prop] = msg;
      }
    }

    return errorMessages.value.isEmpty;
  }

  /// 重置表单
  void reset() {
    errorMessages.clear();
    modelValue = Map.from(initialValue);
  }

  @override
  void initState() {
    super.initState();
    _initialValue = Map.from(modelValue);
  }

  @override
  void dispose() {
    super.dispose();
    fields.clear();
    errorMessages.dispose();
    _initialValue = null;
  }

  @override
  Widget obsBuilder(BuildContext context) {
    return widget.child ?? ElEmptyWidget.instance;
  }

  @override
  Widget build(BuildContext context) {
    assert(ElForm.maybeOf(context) == null, 'ElForm 不允许嵌套！');
    return FocusScope(child: _ElFormScope(this, child: super.build(context)));
  }
}

class _ElFormScope extends InheritedWidget {
  const _ElFormScope(this.state, {required super.child});

  final ElFormState state;

  @override
  bool updateShouldNotify(_ElFormScope oldWidget) => false;
}
