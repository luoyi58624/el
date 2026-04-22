part of 'index.dart';

/// 基于 [Route] 实现的命令式弹出层，通过路由打开的弹窗是一次性的，关闭即销毁
class ElPopupRoute<T> extends PopupRoute<T> {
  ElPopupRoute({super.settings, super.requestFocus, super.filter, super.traversalEdgeBehavior, required this.builder});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final overlayList = super.createOverlayEntries();

    // 不使用默认的 modal 模态框
    return [overlayList.last];
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
