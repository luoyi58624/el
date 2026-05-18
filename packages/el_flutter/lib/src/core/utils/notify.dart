import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/widgets.dart';

/// 使用 Set 集合实现最简单的 [Listenable] 侦听器
class ElNotify implements Listenable {
  final Set<VoidCallback> listeners = {};

  void notifyListeners() {
    for (final fun in listeners) {
      safeCallback(fun);
    }
  }

  @override
  void addListener(VoidCallback listener) => listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => listeners.remove(listener);

  void dispose() {
    listeners.clear();
  }
}

/// 当一个组件被 dispose 时，会通知侦听它的所有监听器
class ElDisposeNotify implements Listenable {
  final Set<VoidCallback> listeners = {};

  @override
  void addListener(VoidCallback listener) => listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => listeners.remove(listener);

  /// 销毁监听器，在这之前需要触发所有监听回调，注意：此方法应当在 super.dispose 之前调用
  void dispose() {
    for (final fun in listeners) {
      fun();
    }
    listeners.clear();
  }
}
