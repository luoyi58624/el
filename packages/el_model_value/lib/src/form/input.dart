part of 'index.dart';

abstract class ElInputModelValue<D> extends ElFormModelValue<D> {
  const ElInputModelValue({
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
  TextEditingController getTextController(Map<String, dynamic> model) {
    return model['textController'] as TextEditingController;
  }

  @protected
  @override
  Map<String, dynamic> registerModel() {
    final model = super.registerModel();
    final text = toTextEditing(getObs(model).value);
    final textController = useTextEditingController(text: text);
    model['textController'] = textController;
    model['focusNode'] = useFocusNode();
    model['scrollController'] = useScrollController();

    return model;
  }

  @override
  Widget builder(BuildContext context, Obs<D> obs, Map<String, dynamic> model) {
    final text = toTextEditing(getObs(model).value);
    final textController = getTextController(model);
    if (text != textController.text) {
      textController.value = TextEditingValue(text: text);
    }
    return buildInput(context);
  }

  /// 构建输入框小部件
  Widget buildInput(BuildContext context);
}
