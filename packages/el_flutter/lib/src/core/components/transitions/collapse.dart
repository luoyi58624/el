part of 'index.dart';

/// 折叠动画
class ElCollapseAnimation extends ElSwitcherAnimation {
  const ElCollapseAnimation(
    super.show, {
    super.key,
    super.duration,
    super.curve,
    required super.child,
    this.alignment = Alignment.topLeft,
    this.keepState = true,
  });

  /// 子组件对齐位置
  final AlignmentGeometry alignment;

  /// 折叠时是否保存状态，若为 false，折叠时会销毁 [child]
  final bool keepState;

  static const defaultDuration = Duration(milliseconds: 250);
  static const defaultCurve = Curves.easeOut;

  @override
  Duration get $duration => duration ?? defaultDuration;

  @override
  Curve get $curve => curve ?? defaultCurve;

  @override
  Widget build(BuildContext context) {
    final flag = useObs(show);
    useEffect(() {
      if (show && flag.value == false) flag.value = true;
      return null;
    }, [show]);

    return ClipRect(
      child: AnimatedAlign(
        duration: $duration,
        curve: $curve,
        alignment: alignment,
        heightFactor: show ? 1.0 : 0.0,
        onEnd: () {
          if (show == false && flag.value) flag.value = false;
        },
        child: keepState ? child : ObsBuilder(builder: (context) => flag.value ? child : ElEmptyWidget.instance),
      ),
    );
  }

  @override
  Widget builder(BuildContext context, AnimationController controller) {
    throw UnimplementedError();
  }
}
