import 'package:el_flutter/ext.dart';
import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/widgets.dart';

part 'input_number.dart';

abstract class ElInputModelValue<D> extends ElFormModelValue<D> {
  ElInputModelValue({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    super.prop,
    this.controller,
    this.focusNode,
    this.scrollController,
  });

  /// 输入框控制器
  final TextEditingController? controller;

  /// 焦点控制器
  final FocusNode? focusNode;

  /// 定义滚动控制器
  final ScrollController? scrollController;

  /// value -> editor text
  String toTextEditing(D value) => value.toString();

  /// editor text -> value
  D toModelValue(String text) => text as D;

  @protected
  TextEditingController get $textController => $model['textController'] as TextEditingController;

  @protected
  FocusNode get $focusNode => $model['focusNode'] as FocusNode;

  @protected
  ScrollController get $scrollController => $model['scrollController'] as ScrollController;

  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);

    final text = toTextEditing($obs.value);
    $model['textController'] = useTextEditingController(text: text);
    $model['focusNode'] = useFocusNode();
    $model['scrollController'] = useScrollController();

    return result;
  }

  @override
  Widget obsBuilder(BuildContext context) {
    final text = toTextEditing($obs.value);
    final textController = $textController;
    if (text != textController.text) {
      textController.value = TextEditingValue(text: text);
    }
    return buildInput(context);
  }

  /// 构建输入框小部件。
  ///
  /// 在 [ListenableBuilder] 的 builder 中调用，不属于 [HookWidget.build] 的 Hook 上下文，
  /// 因此不能在此方法内调用 [useState]、[useMemoized] 等。若子类需要 Hook，
  /// 请重写 [build]（在调用 `super.build` 之前）将结果存入 [$model] 供此处读取。
  Widget buildInput(BuildContext context);
}
