part of 'index.dart';

/// Zoom 缩放动画类型
enum ElZoomTransitionType { left, center, top, bottom }

class ElZoomAnimation extends ElSwitcherAnimation {
  /// 实现 Element UI 内置的 Zoom 缩放动画，https://cn.element-plus.org/en-US/guide/transitions.html#zoom
  const ElZoomAnimation(
    super.show, {
    super.key,
    required super.child,
    super.duration,
    super.curve = ElZoomAnimation.defaultCurve,
    super.reverseCurve,
    this.opacityCurve = Curves.easeIn,
    this.type = ElZoomTransitionType.top,
  });

  /// 透明动画曲线
  final Curve opacityCurve;

  /// 缩放动画类型
  final ElZoomTransitionType type;

  static const Curve defaultCurve = Curves.fastOutSlowIn;

  @override
  Duration get $duration => duration ?? el.config.fastDuration;

  @override
  Widget builder(context, controller) {
    return ElZoomTransition(
      controller: controller,
      curve: curve!,
      reverseCurve: reverseCurve,
      opacityCurve: opacityCurve,
      type: type,
      child: child,
    );
  }
}

class ElZoomTransition extends HookWidget {
  const ElZoomTransition({
    super.key,
    required this.controller,
    this.curve = Curves.decelerate,
    this.reverseCurve,
    this.opacityCurve = Curves.easeIn,
    this.type = ElZoomTransitionType.top,
    required this.child,
  });

  final AnimationController controller;
  final Curve curve;
  final Curve? reverseCurve;
  final Curve opacityCurve;
  final ElZoomTransitionType type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = useCurvedAnimation(parent: controller, curve: curve, reverseCurve: reverseCurve);
    final opacityAnimation = useCurvedAnimation(parent: controller, curve: opacityCurve);

    switch (type) {
      case ElZoomTransitionType.left:
        final scaleTween = Tween(begin: 0.45, end: 1.0).animate(scaleAnimation);
        return AnimatedBuilder(
          animation: controller.view,
          builder: (context, child) {
            return FadeTransition(
              opacity: opacityAnimation,
              child: Transform.scale(
                scaleX: scaleTween.value,
                scaleY: scaleTween.value,
                alignment: Alignment.topLeft,
                child: child,
              ),
            );
          },
          child: child,
        );
      case ElZoomTransitionType.center:
        return AnimatedBuilder(
          animation: controller.view,
          builder: (context, child) {
            return FadeTransition(
              opacity: opacityAnimation,
              child: Transform.scale(scaleX: scaleAnimation.value, alignment: Alignment.center, child: child),
            );
          },
          child: child,
        );
      case ElZoomTransitionType.top:
      case ElZoomTransitionType.bottom:
        final slideTween = Tween(begin: 0.3, end: 1.0).animate(scaleAnimation);
        return AnimatedBuilder(
          animation: controller.view,
          builder: (context, child) {
            return FadeTransition(
              opacity: opacityAnimation,
              child: Transform.scale(
                scaleY: slideTween.value,
                alignment: type == ElZoomTransitionType.top ? Alignment.topCenter : Alignment.bottomCenter,
                child: child,
              ),
            );
          },
          child: child,
        );
    }
  }
}
