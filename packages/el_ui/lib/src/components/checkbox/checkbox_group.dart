part of 'index.dart';

class ElCheckboxGroup extends ElFormModelValue<List<Object?>> {
  /// Element UI 复选框组，[ElCheckboxGroup] 本身只提供双向绑定机制，你可以组合任意 UI 代码。
  ///
  /// 绑定值为 [List]（若需 Set，请自行在业务层与 List 互转）。
  ElCheckboxGroup({
    super.key,
    super.value,
    super.modelValue,
    required this.child,
    this.min,
    this.max,
    super.prop,
    super.onChanged,
  });

  final Widget child;

  /// 限制最小选择数量
  final int? min;

  /// 限制最大选择数量
  final int? max;

  static ElCheckboxGroupScope of(BuildContext context) => maybeOf(context)!;

  static ElCheckboxGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElCheckboxGroupInheritedWidget>()?.scope;

  @override
  Widget obsBuilder(BuildContext context) {
    return _ElCheckboxGroupInheritedWidget(
      scope: ElCheckboxGroupScope(this, $obs),
      child: child,
    );
  }
}

class ElCheckboxGroupScope {
  ElCheckboxGroupScope(this.widget, this._obs);

  final ElCheckboxGroup widget;
  final Obs<List<Object?>> _obs;

  List<Object?> get modelValue => _obs.value;

  set modelValue(Object? v) {
    if (v is Iterable<Object?>) {
      _obs.value = List<Object?>.from(v);
    } else {
      hasElement(v) ? removeElement(v) : addElement(v);
    }
  }

  bool hasElement(Object? v) => _obs.value.contains(v);

  void addElement(Object? v) {
    _obs.value = [..._obs.value, v];
  }

  void removeElement(Object? v) {
    _obs.value = _obs.value.where((e) => e != v).toList();
  }

  void clear() {
    _obs.value = <Object?>[];
  }

  bool get disabledRemove => widget.min != null && modelValue.length <= widget.min!;

  bool get disabledAdd => widget.max != null && modelValue.length >= widget.max!;
}

class _ElCheckboxGroupInheritedWidget extends InheritedWidget {
  const _ElCheckboxGroupInheritedWidget({required this.scope, required super.child});

  final ElCheckboxGroupScope scope;

  @override
  bool updateShouldNotify(_ElCheckboxGroupInheritedWidget oldWidget) => true;
}
