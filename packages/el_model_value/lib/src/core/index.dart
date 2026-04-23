import 'package:el_flutter/el_flutter.dart' show safeCallback;
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

abstract class ElModelValue<D> extends HookWidget {
  ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final D? value;
  final ValueNotifier<D>? modelValue;
  final ValueChanged<D>? onChanged;

  /// 保存创建的数据，避免在每个方法进行传参，它所记录的是临时数据，所以无需担心状态问题。
  ///
  /// 提示：双向绑定的组件基本都依赖可变值，所以基本用不上 const 修饰。
  @protected
  final Map<String, dynamic> $model = {};

  /// 访问 obs 响应式变量
  @protected
  Obs<D> get $obs => $model['obs'] as Obs<D>;

  @override
  Widget build(BuildContext context) {
    // 创建双向绑定钩子，根据 value、modelValue 返回全新的 Obs 响应式变量
    $model['obs'] = _useModelValue<D>(value, modelValue, onChanged);
    return ListenableBuilder(listenable: $model['obs'], builder: (context, child) => obsBuilder(context));
  }

  /// 构建响应式组件
  @protected
  Widget obsBuilder(BuildContext context);
}
