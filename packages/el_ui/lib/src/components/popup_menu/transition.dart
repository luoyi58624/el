part of 'index.dart';

/// 基于 ElPopup 弹出层的菜单动画小部件，其动画特征为：
/// * 显示菜单动画：淡入 + 缩放
/// * 隐藏菜单动画：淡出
class ElPopupMenuTransition extends StatefulWidget {
  const ElPopupMenuTransition({super.key, required this.controller, required this.alignment, required this.child});

  final AnimationController controller;
  final Alignment alignment;
  final Widget child;

  @override
  State<ElPopupMenuTransition> createState() => _ElPopupMenuTransitionState();
}

class _ElPopupMenuTransitionState extends State<ElPopupMenuTransition> {
  late CurvedAnimation showAnimation;
  late CurvedAnimation hideAnimation;
  late Animation<double> opacityTween;
  late Animation<double> scaleTween;

  // 显示菜单动画还未结束时，记录当前缩放值，优化快速显示、隐藏菜单的动画连贯性
  late double forwardScale;

  @override
  void initState() {
    super.initState();
    showAnimation = CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    hideAnimation = CurvedAnimation(parent: widget.controller, curve: Curves.easeIn);

    opacityTween = Tween(begin: 0.0, end: 1.0).animate(showAnimation);
    scaleTween = Tween(begin: 0.2, end: 1.0).animate(showAnimation);
    forwardScale = scaleTween.value;
  }

  @override
  void dispose() {
    showAnimation.dispose();
    hideAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        bool isForward =
            widget.controller.status == AnimationStatus.forward ||
            widget.controller.status == AnimationStatus.completed;
        if (isForward) forwardScale = scaleTween.value;

        return FadeTransition(
          opacity: isForward ? opacityTween : hideAnimation,
          child: Transform.scale(
            scaleX: isForward ? scaleTween.value : forwardScale,
            scaleY: isForward ? scaleTween.value : forwardScale,
            alignment: widget.alignment,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
