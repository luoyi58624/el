part of 'index.dart';

/// 为任意输入框添加双向绑定，示例：
/// ```dart
/// class _Input extends ElInputModelValue<String> {
///   const _Input(super.modelValue);
///
///   @override
///   State<_Input> createState() => _InputState();
/// }
///
/// class _InputState extends ElInputModelValueState<_Input, String> {
///   @override
///   Widget buildInput(BuildContext context) {
///     return TextField(controller: controller, onChanged: onChanged);
///   }
/// }
/// ```
abstract class ElInputModelValue<D> extends ElFormModelValue<D> {
  const ElInputModelValue(
    super.modelValue, {
    super.key,
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

  @override
  State<ElInputModelValue> createState();
}

abstract class ElInputModelValueState<T extends ElInputModelValue<D>, D> extends ElFormModelValueState<T, D> {
  /// 输入框控制器
  late TextEditingController controller;

  /// 焦点控制器
  late FocusNode focusNode;

  /// 滚动控制器
  late ScrollController scrollController;

  /// 将 [modelValue] 转成输入框 String 字符串
  String toTextEditing(D modelValue) {
    return modelValue.toString();
  }

  /// 将输入框 String 字符串转成 [modelValue]，
  /// 注意：如果泛型 D 不是 String 类型，那么将抛出异常
  D toModelValue(String text) {
    return text as D;
  }

  void onChanged(D v) {
    modelValue = v;
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController(text: toTextEditing(modelValue));
    focusNode = widget.focusNode ?? FocusNode();
    scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      controller.dispose();
      controller = widget.controller ?? TextEditingController(text: toTextEditing(modelValue));
    }
    if (widget.focusNode != oldWidget.focusNode) {
      focusNode.dispose();
      focusNode = widget.focusNode ?? FocusNode();
    }
    if (widget.scrollController != oldWidget.scrollController) {
      scrollController.dispose();
      scrollController = widget.scrollController ?? ScrollController();
    }
  }

  @override
  dispose() {
    super.dispose();
    if (widget.controller == null) controller.dispose();
    if (widget.focusNode == null) focusNode.dispose();
    if (widget.scrollController == null) scrollController.dispose();
  }

  /// 构建输入框小部件
  Widget buildInput(BuildContext context);

  @mustCallSuper
  @override
  Widget obsBuilder(BuildContext context) {
    final text = toTextEditing(modelValue);

    if (controller.text != text) {
      controller.value = TextEditingValue(text: text);
    }

    return buildInput(context);
  }
}
