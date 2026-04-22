import 'package:flutter/widgets.dart';

import 'package:el_flutter/el_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 访问全局默认的滚动控制器，由 [El] 全局服务提供
ScrollController useGlobalScrollController({ScrollController? controller, String? cacheKey}) {
  return use(_Hook(controller, cacheKey));
}

class _Hook extends Hook<ScrollController> {
  const _Hook(this.controller, this.cacheKey);

  final ScrollController? controller;

  /// 记录滚动位置缓存，注意：初始化定位时需要将位置传递给控制器，若你使用自定义控制器只能自己处理缓存
  final String? cacheKey;

  @override
  _HookState createState() => _HookState();
}

class _HookState extends HookState<ScrollController, _Hook> {
  late ScrollController controller;

  ScrollController get defaultController {
    return el.config.scrollControllerBuilder(
      ElScrollControllerAttrModel(
        initialScrollOffset: hook.cacheKey == null ? 0.0 : localStorage.getItem(hook.cacheKey!) ?? 0.0,
      ),
    );
  }

  void cacheListener() {
    localStorage.setItem(hook.cacheKey!, controller.position.pixels, expire: Duration(minutes: 1));
  }

  @override
  void initHook() {
    super.initHook();
    controller = hook.controller ?? defaultController;

    if (hook.controller == null && hook.cacheKey != null) {
      controller.addListener(cacheListener);
    }
  }

  @override
  void didUpdateHook(_Hook oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.controller != hook.controller) {
      if (hook.controller != null) {
        controller.dispose();
        controller = hook.controller!;
      } else {
        controller = defaultController;
        if (hook.cacheKey != null) {
          controller.addListener(cacheListener);
        }
      }
    }
  }

  @override
  void dispose() {
    if (hook.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  ScrollController build(BuildContext context) => controller;
}
