part of 'index.dart';

class ElSegmentedButton<T> extends ElModelValue {
  const ElSegmentedButton({super.key, required this.children}) : mandatory = null, _modelType = null, super(null);

  const ElSegmentedButton.single(super.modelValue, {super.key, required this.children, this.mandatory})
    : _modelType = ElModelValueType.single;

  const ElSegmentedButton.multi(super.modelValue, {super.key, required this.children, this.mandatory})
    : _modelType = ElModelValueType.multi;

  final ElModelValueType? _modelType;

  /// 按钮组数据集合，如果是单选、多选按钮组，若不指定 value 则使用 label 作为数据
  final List<ElLabelModel<T>> children;

  /// 是否必须选择一项
  final bool? mandatory;

  @override
  State<ElSegmentedButton<T>> createState() => _ElSegmentedButtonState<T>();
}

class _ElSegmentedButtonState<T> extends State<ElSegmentedButton<T>> with ElModelValueMixin {
  Set<T> get selected {
    switch (widget._modelType) {
      case null:
        return <T>{};
      case ElModelValueType.single:
        return super.modelValue == null ? {} : {super.modelValue};
      case ElModelValueType.multi:
        return (super.modelValue as Iterable).toSet().cast<T>();
    }
  }

  void onSelectionChanged(Set newSelection) {
    switch (widget._modelType) {
      case null:
        break;
      case ElModelValueType.single:
        if (widget.mandatory == true) {
          if (newSelection.isNotEmpty) {
            setState(() {
              modelValue = newSelection.first;
            });
          }
        } else {
          setState(() {
            modelValue = newSelection.isEmpty ? null : newSelection.first;
          });
        }
        break;
      case ElModelValueType.multi:
        if (widget.mandatory == true ? newSelection.isNotEmpty : true) {
          setState(() {
            modelValue = newSelection;
          });
        }
        break;
    }
  }

  @override
  Widget obsBuild(BuildContext context) {
    return SegmentedButton(
      segments: widget.children
          .mapIndexed((i, e) => ButtonSegment(value: e.value ?? e.label, label: Text('${e.label}')))
          .toList(),
      selected: selected,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: el.config.borderRadius)),
      ),
      emptySelectionAllowed: true,
      multiSelectionEnabled: widget._modelType == ElModelValueType.multi,
      onSelectionChanged: onSelectionChanged,
    );
  }
}
