import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

/// Element 顶级小部件，它只构建组件库自身所必要的内容，你可以搭配任意顶级 App 构建应用：[WidgetsApp]、[MaterialApp]、[CupertinoApp]
class ElApp extends StatefulWidget {
  const ElApp({super.key, this.brightness, required this.child});

  /// 应用的主题模式，若为 null，则跟随系统。
  ///
  /// Element 很多组件依赖隐式动画，为了确保更新暗黑模式时页面颜色过渡一致性，
  /// 更新 [brightness] 会同步所有动画小部件的动画时间、动画曲线。
  final Brightness? brightness;

  final Widget child;

  /// 访问滚动通知监听器，当滚动触发时，会通知依赖的副作用
  static Listenable scrollNotifyOf(BuildContext context) {
    final result = context.getInheritedWidgetOfExactType<_ElScrollNotifyScope>();
    assert(result != null, '当前 context 未找到 ElApp 小部件！');
    return result!.notifier!;
  }

  @override
  State<ElApp> createState() => _ElAppState();
}

class _ElAppState extends State<ElApp> {
  final scrollNotify = ElNotify();
  Timer? timer;

  bool onScrollNotification(ScrollNotification e) {
    scrollNotify.notifyListeners();
    return false;
  }

  @override
  void didUpdateWidget(covariant ElApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.brightness != oldWidget.brightness) {
      if (timer != null) {
        timer!.cancel();
        timer = null;
      }
      ElExt.$themeAnimation = (
        duration: el.config.animationStyle.duration ?? .zero,
        curve: el.config.animationStyle.curve ?? Curves.linear,
      );
      timer = ElAsyncUtil.setTimeout(() {
        timer = null;
        ElExt.$themeAnimation = null;
      }, el.config.animationStyle.duration?.inMilliseconds ?? 0);
    }
  }

  @override
  void dispose() {
    timer = null;
    ElExt.$themeAnimation = null;
    scrollNotify.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = ElBrightness(
      widget.brightness,
      child: NotificationListener<ScrollStartNotification>(
        onNotification: onScrollNotification,
        child: _ElScrollNotifyScope(notifier: scrollNotify, child: widget.child),
      ),
    );

    // 如果用户没有自定义响应式断点，则构建一个默认的响应式断点
    if (ElResponsive.maybeOf(context) == null) result = ElResponsive(child: result);

    return result;
  }
}

class _ElScrollNotifyScope extends InheritedNotifier {
  const _ElScrollNotifyScope({super.notifier, required super.child});
}
