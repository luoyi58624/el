part of 'index.dart';

class ElSegmentedButton<T> extends ElModelValue<dynamic> {
  ElSegmentedButton({super.key, required this.children}) : mandatory = null, _modelType = null, super();

  ElSegmentedButton.single({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    required this.children,
    this.mandatory,
  }) : _modelType = ElModelValueType.single;

  ElSegmentedButton.multi({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    required this.children,
    this.mandatory,
  }) : _modelType = ElModelValueType.multi;

  final ElModelValueType? _modelType;
  final List<ElLabelModel<T>> children;
  final bool? mandatory;

  Set<T> get _selected {
    switch (_modelType) {
      case null:
        return <T>{};
      case ElModelValueType.single:
        return $obs.value == null ? {} : {$obs.value as T};
      case ElModelValueType.multi:
        return ($obs.value as Iterable).toSet().cast<T>();
    }
  }

  void _onSelectionChanged(Set<dynamic> newSelection) {
    switch (_modelType) {
      case null:
        break;
      case ElModelValueType.single:
        if (mandatory == true) {
          if (newSelection.isNotEmpty) {
            $obs.value = newSelection.first;
          }
        } else {
          $obs.value = newSelection.isEmpty ? null : newSelection.first;
        }
        break;
      case ElModelValueType.multi:
        if (mandatory == true ? newSelection.isNotEmpty : true) {
          $obs.value = newSelection;
        }
        break;
    }
  }

  @override
  Widget obsBuilder(BuildContext context) {
    return SegmentedButton(
      segments: children
          .mapIndexed((i, e) => ButtonSegment(value: e.value ?? e.label, label: Text('${e.label}')))
          .toList(),
      selected: _selected,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: el.config.borderRadius)),
      ),
      emptySelectionAllowed: true,
      multiSelectionEnabled: _modelType == ElModelValueType.multi,
      onSelectionChanged: _onSelectionChanged,
    );
  }
}
