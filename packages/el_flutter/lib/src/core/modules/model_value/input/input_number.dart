part of 'index.dart';

abstract class ElInputNumModelValue extends ElInputModelValue<num?> {
  ElInputNumModelValue({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    super.prop,
    super.controller,
    super.focusNode,
    super.scrollController,
  });

  @override
  String toTextEditing(num? value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  num? toModelValue(String text) {
    if (text == '') return null;
    return num.parse(text);
  }
}
