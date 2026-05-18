part of 'index.dart';

class ElScaleAnimation extends ElSwitcherAnimation {
  const ElScaleAnimation(
    super.show, {
    super.key,
    super.duration,
    super.curve = ElScaleAnimation.defaultCurve,
    super.reverseCurve,
    this.alignment = Alignment.topLeft,
    required super.child,
  });

  final Alignment alignment;

  static const Curve defaultCurve = Curves.decelerate;

  @override
  Duration get $duration => duration ?? el.config.fastDuration;

  @override
  Widget builder(context, controller) {
    return ElScaleTransition(
      controller: controller,
      curve: curve!,
      reverseCurve: reverseCurve,
      alignment: alignment,
      child: child,
    );
  }
}

class ElScaleTransition extends HookWidget {
  const ElScaleTransition({
    super.key,
    required this.controller,
    this.curve = ElScaleAnimation.defaultCurve,
    this.reverseCurve,
    this.alignment = Alignment.topLeft,
    required this.child,
  });

  final AnimationController controller;
  final Curve curve;
  final Curve? reverseCurve;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curveAnimation = useCurvedAnimation(parent: controller, curve: curve, reverseCurve: reverseCurve);
    final scaleTween = Tween(begin: 0.3, end: 1.0).animate(curveAnimation);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: curveAnimation,
          child: Transform.scale(
            scaleX: scaleTween.value,
            scaleY: scaleTween.value,
            alignment: alignment,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
