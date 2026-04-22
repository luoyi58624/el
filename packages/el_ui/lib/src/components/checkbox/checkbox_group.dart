part of 'index.dart';

const _assert = 'ElCheckboxGroup 只支持 List、Set 集合';

class ElCheckboxGroup extends ElFormModelValue<Iterable> {
  /// Element UI 复选框组，[ElCheckboxGroup] 本身只提供双向绑定机制，你可以组合任意 UI 代码。
  ///
  /// 提示：如果数据量很大，建议使用 Set 集合。
  const ElCheckboxGroup(
    super.modelValue, {
    super.key,
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

  static ElCheckboxGroupState of(BuildContext context) => maybeOf(context)!;

  static ElCheckboxGroupState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElCheckboxGroupInheritedWidget>()?.state;

  @override
  State<ElCheckboxGroup> createState() => ElCheckboxGroupState();
}

class ElCheckboxGroupState extends ElFormModelValueState<ElCheckboxGroup, Iterable> {
  /// 判断多选框是否包含指定元素，提示：List 集合此方法时间复杂度为 O(n) ，而 Set 集合复杂度为 O(1)，
  /// 如果数据量很多请使用 Set 集合避免影响性能
  bool hasElement(dynamic v) => modelValue.contains(v);

  /// 添加元素
  void addElement(dynamic v) {
    if (modelValue is List) {
      super.modelValue = [...modelValue, v];
    } else if (modelValue is Set) {
      super.modelValue = {...modelValue, v};
    } else {
      throw _assert;
    }
  }

  /// 移除元素
  void removeElement(dynamic v) {
    if (modelValue is List) {
      super.modelValue = (modelValue as List).where((e) => e != v).toList();
    } else if (modelValue is Set) {
      super.modelValue = (modelValue as Set).where((e) => e != v).toSet();
    } else {
      throw _assert;
    }
  }

  /// 清空元素
  void clear() {
    if (modelValue is List) {
      super.modelValue = [];
    } else if (modelValue is Set) {
      super.modelValue = {};
    } else {
      throw _assert;
    }
  }

  /// 智能添加、移除目标值，此方法会自动处理 List、Set、以及任意类型的单条数据
  @override
  set modelValue(dynamic v) {
    if (v is List) {
      super.modelValue = List.from(v);
    } else if (v is Set) {
      super.modelValue = Set.from(v);
    } else if (v is Iterable) {
      if (modelValue is List) {
        super.modelValue = v.toList();
      } else if (modelValue is Set) {
        super.modelValue = v.toSet();
      } else {
        throw _assert;
      }
    } else {
      hasElement(v) ? removeElement(v) : addElement(v);
    }
  }

  /// 是否禁止移除
  bool get disabledRemove => widget.min != null && modelValue.length <= widget.min!;

  /// 是否禁止添加
  bool get disabledAdd => widget.max != null && modelValue.length >= widget.max!;

  @override
  Widget obsBuilder(BuildContext context) {
    return _ElCheckboxGroupInheritedWidget(this, child: widget.child);
  }
}

class _ElCheckboxGroupInheritedWidget extends InheritedWidget {
  const _ElCheckboxGroupInheritedWidget(this.state, {required super.child});

  final ElCheckboxGroupState state;

  @override
  bool updateShouldNotify(_ElCheckboxGroupInheritedWidget oldWidget) => true;
}
