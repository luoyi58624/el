part of 'index.dart';

class ElRadioGroup extends ElFormModelValue<Object?> {
  /// Element UI 单选框组，[ElRadioGroup] 本身只提供双向绑定机制，你可以组合任意 UI 代码
  ElRadioGroup({
    super.key,
    super.value,
    super.modelValue,
    required this.child,
    this.required = true,
    super.prop,
    super.onChanged,
  });

  final Widget child;

  /// 是否必须选择一项，默认 true，若为 false，点击选中目标会将其设置为 null，
  /// 当为 false 时请确保数据类型添加 ? 可选符号，否则会出现错误
  final bool required;

  static ElRadioGroupScope? maybeOf(BuildContext context, {bool listen = true}) {
    final _ElRadioGroupInheritedWidget? result = listen
        ? context.dependOnInheritedWidgetOfExactType<_ElRadioGroupInheritedWidget>()
        : context.getInheritedWidgetOfExactType<_ElRadioGroupInheritedWidget>();
    return result?.scope;
  }

  static ElRadioGroupScope of(BuildContext context, {bool listen = true}) {
    final scope = maybeOf(context, listen: listen);
    assert(scope != null, '当前上下文 context 没有找到类型为 ElRadioGroup 的单选框组');
    return scope!;
  }

  @override
  Widget obsBuild(BuildContext context) {
    final scope = ElRadioGroupScope(this, $obs);
    return _ElRadioGroupInheritedWidget(
      scope: scope,
      child: RadioGroup<Object?>(
        groupValue: scope.modelValue,
        onChanged: (value) => scope.modelValue = value,
        child: child,
      ),
    );
  }
}

class ElRadioGroupScope {
  ElRadioGroupScope(this.widget, this._obs);

  final ElRadioGroup widget;
  final Obs<Object?> _obs;

  Object? get modelValue => _obs.value;

  set modelValue(Object? v) {
    if (widget.required) {
      _obs.value = v;
    } else {
      if (_obs.value == v) {
        _obs.value = null;
      } else {
        _obs.value = v;
      }
    }
  }
}

class _ElRadioGroupInheritedWidget extends InheritedWidget {
  const _ElRadioGroupInheritedWidget({required this.scope, required super.child});

  final ElRadioGroupScope scope;

  @override
  bool updateShouldNotify(_ElRadioGroupInheritedWidget oldWidget) => true;
}
