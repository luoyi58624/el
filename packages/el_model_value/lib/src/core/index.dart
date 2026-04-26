import 'package:el_flutter/el_flutter.dart' show safeCallback;
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

// /// 支持双向绑定的组件类型
// enum ElModelValueType {
//   /// 支持单个数据的双向绑定
//   single,
//
//   /// 支持多个数据的双向绑定
//   multi,
// }

abstract class ElModelValue<D> extends HookWidget with ElStatelessModelMixin {
  ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final D? value;
  final ValueNotifier<D>? modelValue;
  final ValueChanged<D>? onChanged;

  /// 访问 obs 响应式变量
  @protected
  Obs<D> get $obs => m['obs'] as Obs<D>;

  @override
  Widget build(BuildContext context) {
    // 创建双向绑定钩子，根据 value、modelValue 返回全新的 Obs 响应式变量
    m['obs'] = _useModelValue<D>(value, modelValue, onChanged);
    return ListenableBuilder(listenable: m['obs'], builder: (context, child) => obsBuild(context));
  }

  /// 构建响应式组件
  @protected
  Widget obsBuild(BuildContext context);
}

mixin ElStatelessModelMixin on StatelessWidget {
  /// 声明一个 Map，方便 [StatelessWidget] 无状态组件的数据访问，避免每个方法进行不断传参
  @protected
  final Map<String, dynamic> m = {};
}
