part of 'index.dart';

class _Transition extends HookWidget {
  const _Transition({required this.controller, required this.axisDirection, required this.child});

  final AnimationController controller;
  final AxisDirection axisDirection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final contentAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(0.25, 1.0, curve: Curves.easeIn),
    );

    return ElSlideTransition(
      controller: controller,
      axisDirection: axisDirection,
      slideTween: Tween(begin: 0.5, end: 1.0),
      child: ElCardTheme(
        data: ElCardThemeData(elevation: 4),
        child: ElCard(
          child: FadeTransition(opacity: contentAnimation, child: child),
        ),
      ),
    );
  }
}
