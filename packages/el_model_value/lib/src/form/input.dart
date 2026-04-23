part of 'index.dart';

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

  /// 构建输入框小部件
  Widget buildInput(BuildContext context);
}
