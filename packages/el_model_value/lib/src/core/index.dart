import 'package:el_flutter/el_flutter.dart' show safeCallback, ElLog;
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

abstract class ElModelValue<D> extends HookWidget with ElHookWidgetModelMixin {
  ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final D? value;
  final ValueNotifier<D>? modelValue;
  final ValueChanged<D>? onChanged;

  /// 访问 obs 响应式变量
  @protected
  Obs<D> get $obs => $hooks['obs'] as Obs<D>;

  @override
  Widget build(BuildContext context) {
    final obs = addHook('obs', _useModelValue<D>(value, modelValue, onChanged));
    return ListenableBuilder(listenable: obs, builder: (context, child) => obsBuild(context));
  }

  /// 构建响应式组件
  @protected
  Widget obsBuild(BuildContext context);
}

mixin ElHookWidgetModelMixin on HookWidget {
  /// 保留 hooks 的引用，避免在多个方法中进行不断传参
  @protected
  final Map<String, dynamic> $hooks = {};

  /// 将 hook 添加到 Map 集合中，如果已存在相同的 key，则返回已有 hook 结果
  @protected
  T addHook<T>(String key, T value) {
    if ($hooks.containsKey(key)) return $hooks[key] as T;
    return $hooks[key] = value;
  }
}
