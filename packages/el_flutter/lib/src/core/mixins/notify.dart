import 'package:flutter/widgets.dart';

/// 监听滚动触顶、触底事件
mixin ElScrollHitMixin {
  bool scrollHitStart = false;
  bool scrollHitEnd = false;

  /// 滚动容器击中顶部（不限垂直、水平滚动）
  @protected
  @mustCallSuper
  void onScrollHitStart() {
    scrollHitStart = true;
  }

  /// 滚动容器击中底部
  @protected
  @mustCallSuper
  void onScrollHitEnd() {
    scrollHitEnd = true;
  }

  @protected
  @mustCallSuper
  bool scrollMetricsNotification(ScrollMetricsNotification notification) {
    scrollHitStart = notification.metrics.pixels <= 0.0;
    scrollHitEnd = notification.metrics.pixels >= notification.metrics.maxScrollExtent;
    return false;
  }

  @protected
  @mustCallSuper
  bool scrollHitNotification(ScrollNotification notification) {
    scrollHitStart = false;
    scrollHitEnd = false;
    if (notification.metrics.pixels.floor() <= 0.0) {
      onScrollHitStart();
    } else if (notification.metrics.pixels >= notification.metrics.maxScrollExtent) {
      onScrollHitEnd();
    }
    return false;
  }

  /// 构建滚动监听器组件
  @protected
  Widget buildScrollHitListener({required Widget child}) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: scrollMetricsNotification,
      child: NotificationListener<ScrollEndNotification>(onNotification: scrollHitNotification, child: child),
    );
  }
}
