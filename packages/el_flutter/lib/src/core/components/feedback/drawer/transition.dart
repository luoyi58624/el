part of 'index.dart';

/// 抽屉动画
class _Transition extends StatelessWidget {
  const _Transition({
    required this.controller,
    this.modalColor,
    required this.direction,
    required this.ignoreModalPointer,
    required this.child,
    required this.onModalTap,
  });

  final AnimationController controller;
  final Color? modalColor;
  final AxisDirection direction;
  final bool ignoreModalPointer;
  final Widget child;
  final VoidCallback onModalTap;

  @override
  Widget build(BuildContext context) {
    double? left = 0.0;
    double? right = 0.0;
    double? top = 0.0;
    double? bottom = 0.0;

    bool isVertical = direction.isVertical;
    AlignmentGeometry outerAlignment;
    AlignmentGeometry innerAlignment;

    switch (direction) {
      case AxisDirection.left:
        right = null;
        outerAlignment = Alignment.centerLeft;
        innerAlignment = Alignment.centerRight;
        break;
      case AxisDirection.right:
        left = null;
        outerAlignment = Alignment.centerRight;
        innerAlignment = Alignment.centerLeft;
        break;
      case AxisDirection.up:
        bottom = null;
        outerAlignment = Alignment.topCenter;
        innerAlignment = Alignment.bottomCenter;
        break;
      case AxisDirection.down:
        top = null;
        outerAlignment = Alignment.bottomCenter;
        innerAlignment = Alignment.topCenter;
        break;
    }

    Widget result = Align(
      alignment: outerAlignment,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Align(
            alignment: innerAlignment,
            widthFactor: isVertical ? null : controller.value,
            heightFactor: isVertical ? controller.value : null,
            child: child,
          );
        },
        child: Material(color: context.elDefaultColor, child: child),
        // child: Material(color: context.elCardColor, child: child),
      ),
    );

    return ElModalTransition(
      onTap: onModalTap,
      controller: controller,
      color: modalColor,
      ignorePointer: ignoreModalPointer,
      child: Positioned(left: left, right: right, top: top, bottom: bottom, child: result),
    );
  }
}
