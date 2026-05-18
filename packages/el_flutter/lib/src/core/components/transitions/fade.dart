part of 'index.dart';

class ElFadeAnimation extends ElSwitcherAnimation {
  /// 实现 Element UI 内置的 Fade 缩放动画，https://cn.element-plus.org/en-US/guide/transitions.html#fade
  const ElFadeAnimation(
    super.show, {
    super.key,
    required super.child,
    super.duration = const Duration(milliseconds: 200),
    super.curve = Curves.easeIn,
  });

  @override
  Widget builder(context, controller) {
    return FadeTransition(opacity: controller, child: child);
  }
}
