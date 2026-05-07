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
  TextEditingController get $textEditingController => $get<TextEditingController>('textEditingController');

  @protected
  FocusNode get $focusNode => $get<FocusNode>('focusNode');

  @protected
  ScrollController get $scrollController => $get<ScrollController>('scrollController');

  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);

    final text = toTextEditing($obs.value);
    $add('textEditingController', useTextEditingController(text: text));
    $add('focusNode', useFocusNode());
    $add('scrollController', useScrollController());
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
