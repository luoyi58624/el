part of 'index.dart';

/// 继承 StatelessWidget 双向绑定的小部件
abstract class ElStatelessModelValue<D> extends StatelessWidget {
  /// 仅支持基础数据类型，使用此构造的小部件需要手动调用 [onChanged] 更新界面
  const ElStatelessModelValue(this._modelValue, {super.key, this.onChanged});

  final dynamic _modelValue;
  final ValueChanged<D>? onChanged;

  /// 访问双向绑定的原始值
  D get modelValue {
    if (_modelValue is ValueNotifier) {
      return _modelValue.value;
    } else {
      return _modelValue;
    }
  }

  /// 更新双向绑定的值
  set modelValue(D value) {
    if (_modelValue is ValueNotifier) {
      _modelValue.value = value;
    }
    onChanged?.call(value);
  }

  /// 构建响应式小部件，当响应式变量发生更新时，会自动重建此方法
  @protected
  Widget obsBuilder(BuildContext context, D value);

  @override
  Widget build(BuildContext context) {
    if (_modelValue is ValueNotifier) {
      return ValueListenableBuilder(
        valueListenable: _modelValue,
        builder: (context, value, child) => obsBuilder(context, value),
      );
    } else {
      return obsBuilder(context, _modelValue);
    }
  }
}
