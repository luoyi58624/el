part of 'index.dart';

class ElInputNumber extends ElInputModelValue<num?> {
  const ElInputNumber(
    super.modelValue, {
    super.key,
    super.onChanged,
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
  State<ElInputNumber> createState() => _ElInputNumberState();
}

class _ElInputNumberState extends ElInputModelValueState<ElInputNumber, num?> {
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

  @override
  Widget buildInput(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      scrollController: scrollController,
      decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none)),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, const ElNumberFormatter()],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);

    if (widget.width != null) {
      result = SizedBox(width: widget.width, child: result);
    } else {
      result = Expanded(child: result);
    }

    result = Row(
      children: [
        ElButton(onPressed: () {}, child: Icons.remove),
        result,
        ElButton(onPressed: () {}, child: Icons.add),
      ],
    );

    return result;
  }
}

/// 数字输入框格式化，去除前导零
class ElNumberFormatter extends TextInputFormatter {
  const ElNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(oldValue, newValue) {
    String newText = newValue.text;

    if (newText.isEmpty) return newValue;

    if (newText.length > 1) {
      newText = newText.replaceAll(RegExp(r'^0+'), '');
      if (newText == '') newText = '0';
    }

    return newValue.copyWith(
      text: newText,
      selection: newText.length < newValue.text.length ? TextSelection.collapsed(offset: 0) : newValue.selection,
    );
  }
}
