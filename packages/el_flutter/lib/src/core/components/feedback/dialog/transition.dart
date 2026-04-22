part of 'index.dart';

class _Transition extends HookWidget {
  const _Transition({
    required this.controller,
    this.modalColor,
    required this.ignoreModalPointer,
    required this.child,
    required this.onModalTap,
  });

  final AnimationController controller;
  final Color? modalColor;
  final bool ignoreModalPointer;
  final Widget child;
  final VoidCallback onModalTap;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = useCurvedAnimation(parent: controller, curve: Curves.easeOut);

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0),
    ).animate(curvedAnimation);

    return ElModalTransition(
      onTap: onModalTap,
      controller: controller,
      color: modalColor,
      ignorePointer: ignoreModalPointer,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: controller, child: child),
            );
          },
          child: child,
        ),
      ),
    );
  }
}
