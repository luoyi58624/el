part of 'index.dart';

/// 模态框动画
class ElModalTransition extends HookWidget {
  const ElModalTransition({
    super.key,
    required this.controller,
    this.curve = Curves.decelerate,
    this.color,
    this.ignorePointer = false,
    this.child,
    this.onTap,
  });

  final AnimationController controller;
  final Curve curve;

  /// 模态框背景颜色，默认半透明黑色
  final Color? color;

  /// 忽略模态框的指针事件
  final bool ignorePointer;

  /// 在模态框上绘制小部件
  final Widget? child;

  /// 点击模态框事件
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final modalColor = color ?? Colors.black54;
    final curveAnimation = useCurvedAnimation(parent: controller, curve: curve);

    final modalColorAnimation = Tween<double>(begin: 0.0, end: modalColor.a).animate(curveAnimation);

    Widget result = AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(color: modalColor.elOpacity(modalColorAnimation.value));
      },
    );

    if (onTap != null) {
      result = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        child: result,
      );
    }

    if (ignorePointer) {
      result = IgnorePointer(ignoring: ignorePointer, child: result);
    }

    return ClipRect(
      child: Stack(clipBehavior: Clip.none, children: [result, ?child]),
    );
  }
}
