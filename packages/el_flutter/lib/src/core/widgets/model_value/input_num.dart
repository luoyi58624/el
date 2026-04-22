part of 'index.dart';

abstract class ElInputNumModelValue extends ElInputModelValue<num?> {
  const ElInputNumModelValue(
    super.modelValue, {
    super.key,
    super.onChanged,
    super.controller,
    super.focusNode,
    super.scrollController,
  });

  @override
  State<ElInputNumModelValue> createState();
}

abstract class ElInputNumModelValueState<T extends ElInputNumModelValue> extends ElInputModelValueState<T, num?> {
  @override
  String toTextEditing(num? modelValue) {
    if (modelValue == null) return '';
    return modelValue.toString();
  }

  @override
  num? toModelValue(String text) {
    if (text == '') return null;
    return num.parse(text);
  }
}
