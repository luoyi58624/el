import 'package:el_flutter/el_flutter.dart';
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
  TextEditingController get $textEditingController => m['textEditingController'] as TextEditingController;

  @protected
  FocusNode get $focusNode => m['focusNode'] as FocusNode;

  @protected
  ScrollController get $scrollController => m['scrollController'] as ScrollController;

  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);

    final text = toTextEditing($obs.value);
    m['textEditingController'] = useTextEditingController(text: text);
    m['focusNode'] = useFocusNode();
    m['scrollController'] = useScrollController();

    return result;
  }

  /// 子类必须实现
  @mustCallSuper
  @override
  Widget obsBuild(BuildContext context) {
    final text = toTextEditing($obs.value);
    final textEditingController = $textEditingController;
    if (text != textEditingController.text) {
      textEditingController.value = TextEditingValue(text: text);
    }
    return ElNullWidget.instance;
  }
}
