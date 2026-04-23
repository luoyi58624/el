part of 'index.dart';

abstract class ElInputNumModelValue extends ElInputModelValue<num?> {
  ElInputNumModelValue({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    super.controller,
    super.focusNode,
    super.scrollController,
  });

  @override
  String toTextEditing(num? value) {
    if (modelValue == null) return '';
    return modelValue.toString();
  }

  @override
  num? toModelValue(String text) {
    if (text == '') return null;
    return num.parse(text);
  }
}
