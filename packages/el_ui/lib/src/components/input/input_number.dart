part of 'index.dart';

class ElInputNumber extends ElInputModelValue<num?> {
  ElInputNumber({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    super.prop,
    super.controller,
    super.focusNode,
    super.scrollController,
    this.width = 80.0,
    this.min,
    this.max,
    this.precision = 0,
    this.step = 1.0,
    this.required = false,
  });

  final double? width;

  /// 最小值
  final num? min;

  /// 最大值
  final num? max;

  /// 精度值，当大于 0 时，将允许设置 double 浮点数字
  final int precision;

  /// 点击按钮时计数器步长
  final double step;

  /// 数字输入框内容是否不为 null，若为 true，输入框为 null 时将为自动转换为 0，
  /// 但若存在 [min] 最小值，则在 0 与 [min] 之间取最大值
  final bool required;

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

  @override
  Widget obsBuilder(BuildContext context) {
    final text = toTextEditing($obs.value);
    final tc = controller ?? $textController;
    if (text != tc.text) {
      tc.value = TextEditingValue(text: text);
    }
    return buildInput(context);
  }

  @override
  Widget buildInput(BuildContext context) {
    return TextField(
      controller: controller ?? $textController,
      onChanged: (s) => $obs.value = toModelValue(s),
      focusNode: focusNode ?? $focusNode,
      scrollController: scrollController ?? $scrollController,
      decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none)),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, const ElNumberFormatter()],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);

    if (width != null) {
      result = SizedBox(width: width, child: result);
    } else {
      result = Expanded(child: result);
    }

    return Row(
      children: [
        ElButton(onPressed: () {}, child: Icons.remove),
        result,
        ElButton(onPressed: () {}, child: Icons.add),
      ],
    );
  }
}

/// 数字输入框格式化，去除前导零
class ElNumberFormatter extends TextInputFormatter {
  const ElNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (newText.isEmpty) return newValue;

    if (newText.length > 1) {
      newText = newText.replaceAll(RegExp(r'^0+'), '');
      if (newText == '') newText = '0';
    }

    return newValue.copyWith(
      text: newText,
      selection: newText.length < newValue.text.length ? const TextSelection.collapsed(offset: 0) : newValue.selection,
    );
  }
}
