import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

part 'stateless.dart';

// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: invalid_use_of_protected_member

/// 支持双向绑定的组件类型
enum ElModelValueType {
  /// 支持单个数据的双向绑定
  single,

  /// 支持多个数据的双向绑定
  multi,
}

/// 双向绑定抽象类
abstract class ElModelValue<D> extends StatefulWidget {
  const ElModelValue(this.modelValue, {super.key, this.onChanged});

  /// 支持基础数据类型和响应式变量，如果变量类型为 [ValueNotifier]，
  /// 则无需监听 [onChanged] 方法手动更新 UI。以 [ElSwitch] 组件为例：
  /// ```dart
  /// bool flag = false;
  ///
  /// ElSwitch(
  ///   flag,
  ///   onChanged: (v) => setState(() => flag = v),
  /// );
  /// ```
  ///
  /// 使用响应式变量则可以减少样板代码：
  /// ```dart
  /// final flag = ValueNotifier(false);
  ///
  /// ElSwitch(flag);
  /// ```
  ///
  /// 对于局部状态，建议搭配 flutter_hooks 来使用组件，它比 [StatefulWidget] 更简洁：
  /// ```dart
  /// class Example extends HookWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final flag = useState(false);
  ///     return ElSwitch(flag);
  ///   }
  /// }
  /// ```
  ///
  /// 提示：使用 useState 会重新 build 整个代码块，而双向绑定内部本身提供局部刷新，
  /// 所以你可以使用 useMemoized 来避免不必要的重建：
  /// ```dart
  /// class Example extends HookWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final flag = useMemoized(() => ValueNotifier(false));
  ///     debugPrint('build');
  ///
  ///     return ElSwitch(flag);
  ///   }
  /// }
  /// ```
  final dynamic modelValue;

  /// 变量更新通知方法
  final ValueChanged<D>? onChanged;
}

/// 双向绑定实现类，对于继承 [ElModelValue] 的小部件，还需要在 [State] 中混入此类
mixin ElModelValueMixin<T extends ElModelValue<D>, D> on State<T> {
  /// 内部维护一个独立的响应式变量，初始化时会与外部响应式变量建立联系：[_linkRawObs]，
  /// 当用户传递普通变量时，组件内部依然可以维持响应式
  @protected
  late final Obs<D> obs;

  /// 锁定响应式变量更新
  @protected
  bool? lockObsUpdate;

  /// 返回响应式原始数据
  D get modelValue => obs.value;

  /// 更新响应式变量
  set modelValue(D v) {
    if (modelValue == v || lockObsUpdate == true || mounted == false) return;
    if (widget.modelValue is ValueNotifier) {
      (widget.modelValue as ValueNotifier).value = v;
    } else {
      obs.value = v;
    }
    widget.onChanged?.call(v);
  }

  /// 强制触发响应变更，[ValueNotifier] 有 2 种情况无法自动响应副作用函数：
  /// 1. 原始值是一个对象，如果修改对象本身，则无法被 setter 方法拦截；
  /// 2. setter 方法在通知前会将新增与旧值做对比，如果新值与旧值一样则不会响应监听；
  void notify() {
    if (widget.modelValue is ValueNotifier) {
      (widget.modelValue as ValueNotifier).notifyListeners();
    } else {
      obs.notify();
    }
    widget.onChanged?.call(modelValue);
  }

  /// 如果 modelValue 是响应式变量，则将其与 [obs] 建立关联，
  /// 这样当 modelValue 发生变化时也会通知内部的 [obs] 触发监听
  void _linkRawObs() {
    obs.rawValue = (widget.modelValue as ValueNotifier).value;
    obs.notify();
  }

  @override
  void initState() {
    super.initState();
    if (widget.modelValue is ValueNotifier) {
      final rawObs = widget.modelValue as ValueNotifier<D>;
      obs = Obs<D>(rawObs.value);
      rawObs.addListener(_linkRawObs);
    } else {
      obs = Obs<D>(widget.modelValue);
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.modelValue != oldWidget.modelValue) {
      if (oldWidget.modelValue is ValueNotifier) {
        (oldWidget.modelValue as ValueNotifier).removeListener(_linkRawObs);
      }
      if (widget.modelValue is ValueNotifier) {
        final rawObs = widget.modelValue as ValueNotifier<D>;
        rawObs.addListener(_linkRawObs);
        safeCallback(() => obs.value = rawObs.value);
      } else {
        safeCallback(() => obs.value = widget.modelValue);
      }
    }
  }

  @override
  void dispose() {
    if (widget.modelValue is ValueNotifier) {
      (widget.modelValue as ValueNotifier).removeListener(_linkRawObs);
    }
    obs.dispose();
    super.dispose();
  }

  /// 构建响应式小部件，当响应式变量发生更新时，会自动重建此方法
  @protected
  Widget obsBuild(BuildContext context);

  /// 监听 [obs] 变量更新，重建 [obsBuild] 代码块
  @override
  @protected
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: obs, builder: (context, child) => obsBuild(context));
  }
}
