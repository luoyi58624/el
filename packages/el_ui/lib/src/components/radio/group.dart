part of 'index.dart';

class ElRadioGroup extends ElFormModelValue {
  /// Element UI 单选框组，[ElRadioGroup] 本身只提供双向绑定机制，你可以组合任意 UI 代码
  const ElRadioGroup(
    super.modelValue, {
    super.key,
    required this.child,
    this.required = true,
    super.prop,
    super.onChanged,
  });

  final Widget child;

  /// 是否必须选择一项，默认 true，若为 false，点击选中目标会将其设置为 null，
  /// 当为 false 时请确保数据类型添加 ? 可选符号，否则会出现错误
  final bool required;

  /// 从当前上下文 context 获取单选框实例对象
  static ElRadioGroupState of(BuildContext context, {bool listen = true}) {
    final _ElRadioGroupScope? result = listen
        ? context.dependOnInheritedWidgetOfExactType<_ElRadioGroupScope>()
        : context.getInheritedWidgetOfExactType<_ElRadioGroupScope>();
    assert(result != null, '当前上下文 context 没有找到类型为 ElRadioGroup 的单选框组');
    return result!.state;
  }

  @override
  State<ElRadioGroup> createState() => ElRadioGroupState();
}

class ElRadioGroupState extends ElFormModelValueState<ElRadioGroup, dynamic> {
  @override
  set modelValue(v) {
    if (widget.required) {
      super.modelValue = v;
    } else {
      if (modelValue == v) {
        super.modelValue = null;
      } else {
        super.modelValue = v;
      }
    }
  }

  @override
  Widget obsBuilder(context) {
    return _ElRadioGroupScope(
      this,
      child: RadioGroup<dynamic>(
        groupValue: modelValue,
        onChanged: (value) {
          modelValue = value;
        },
        child: widget.child,
      ),
    );
  }
}

class _ElRadioGroupScope extends InheritedWidget {
  const _ElRadioGroupScope(this.state, {required super.child});

  final ElRadioGroupState state;

  @override
  bool updateShouldNotify(_ElRadioGroupScope oldWidget) => true;
}
