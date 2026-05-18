import 'package:el_flutter/el_flutter.dart';
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'hook.dart';

/// 支持双向绑定的组件类型
enum ElModelValueType {
  /// 支持单个数据的双向绑定
  single,

  /// 支持多个数据的双向绑定
  multi,
}

abstract class ElModelValue<D> extends HookWidget with ElStatelessMapMixin {
  ElModelValue({super.key, this.value, this.modelValue, this.onChanged});

  final D? value;
  final ValueNotifier<D>? modelValue;
  final ValueChanged<D>? onChanged;

  static final obsKey = UniqueKey();

  /// 访问 Hook 上下文存储的 obs 响应式对象
  @protected
  Obs<D> get $obs => $get<Obs<D>>(obsKey);

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    final obs = $set(obsKey, useModelValue<D>(value, modelValue, onChanged));
    return ListenableBuilder(listenable: obs, builder: (context, child) => obsBuilder(context));
  }

  /// 构建响应式组件
  @protected
  Widget obsBuilder(BuildContext context);
}
