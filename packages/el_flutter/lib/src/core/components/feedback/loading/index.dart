import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

part 'service.dart';

part 'model.dart';

/// Element 加载小部件，允许将任意小部件进行旋转处理
class ElLoading extends HookWidget {
  const ElLoading({
    super.key,
    this.loading = true,
    this.duration = const Duration(seconds: 2),
    this.child = const Icon(ElIcons.loading),
  });

  final bool loading;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);

    useEffect(() {
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
          controller.forward();
        }
      });
      return null;
    });

    useEffect(() {
      loading ? controller.forward() : controller.stop();
      return null;
    }, [loading]);

    return RotationTransition(alignment: Alignment.center, turns: controller, child: child);
  }
}
