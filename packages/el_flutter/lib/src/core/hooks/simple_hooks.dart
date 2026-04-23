import 'dart:async';

import 'package:el_flutter/ext.dart';
import 'package:flutter/widgets.dart';

import 'package:el_flutter/el_flutter.dart';

/// 在 build 完成后执行（只触发一次）
void useMounted(VoidCallback fun) {
  useEffect(() {
    nextTick(fun);
    return null;
  }, const []);
}

/// 与 [useEffect] 完全一样，只不过此 hook 的回调函数不会在初始化时执行
void useUpdateEffect(VoidCallback? Function() effect, [List<Object?>? keys]) {
  final isInit = useRef(false);

  useEffect(() {
    VoidCallback? dispose;
    if (isInit.value) {
      dispose = effect();
    } else {
      isInit.value = true;
    }

    return dispose;
  }, keys);
}

/// 定时器钩子，当组件被卸载时会自动取消
Timer useInterval(VoidCallback fun, int wait) {
  final timer = useMemoized(() => ElAsyncUtil.setInterval(fun, wait));

  useEffect(() {
    return () => timer.cancel();
  }, []);

  return timer;
}

/// 支持在 [HookWidget] 中使用 [Obs] 响应式变量
Obs<T> useObs<T>(
  T value, {
  ValueChanged<T>? onChanged,
  bool? immediate,
  bool? ignoreBuilder,
  String? cacheKey,
  ElSerialize? serialize,
  Duration? expire,
}) {
  final obs = useMemoized(
    () => Obs<T>(
      value,
      onChanged: onChanged,
      immediate: immediate,
      ignoreBuilder: ignoreBuilder,
      cacheKey: cacheKey,
      serialize: serialize,
      expire: expire,
    ),
  );

  useEffect(() => obs.dispose, []);

  return obs;
}
