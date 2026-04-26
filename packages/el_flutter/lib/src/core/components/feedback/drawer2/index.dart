import 'package:el_dart/ext.dart';
import 'package:el_flutter/el_flutter.dart';

import 'package:flutter/material.dart';

/// 声明式抽屉小部件
class ElDrawer2 extends ElModelValue<bool> {
  const ElDrawer2(
    super.modelValue, {
    super.key,
    this.size = 300.0,
    this.direction = AxisDirection.right,
    required this.overlayBuilder,
    required this.child,
  });

  /// 抽屉尺寸，支持百分比字符串：'30%'
  final dynamic size;

  /// 抽屉打开方向，支持上下左右 4 种方向
  final AxisDirection direction;

  /// 构建抽屉浮层小部件回调
  final WidgetBuilder overlayBuilder;

  /// 子组件
  final Widget child;

  @override
  State<ElDrawer2> createState() => _ElDrawer2State();
}

class _ElDrawer2State extends State<ElDrawer2> with ElModelValueMixin<ElDrawer2, bool> {
  final overlayController = OverlayPortalController();
  final animationController = AnimationController(vsync: vsync, duration: 250.ms);
  late final curveAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
  late final modalColorAnimation = ColorTween(begin: Colors.transparent, end: Colors.black54).animate(curveAnimation);

  void listener() {
    if (modelValue) {
      animationController.forward();
      overlayController.show();
    } else {
      animationController.reverse().then((v) {
        overlayController.hide();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obs.addListener(listener);
  }

  @override
  void dispose() {
    obs.removeListener(listener);
    curveAnimation.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget obsBuild(BuildContext context) {
    final overlaySize = MediaQuery.sizeOf(context);
    final direction = widget.direction.applyTextDirection(Directionality.of(context));
    double? left = 0.0;
    double? right = 0.0;
    double? top = 0.0;
    double? bottom = 0.0;
    double width;
    double height;

    bool isVertical = direction.isVertical;
    AlignmentGeometry innerAlignment;

    switch (direction) {
      case AxisDirection.left:
        right = null;
        innerAlignment = Alignment.centerRight;
        break;
      case AxisDirection.right:
        left = null;
        innerAlignment = Alignment.centerLeft;
        break;
      case AxisDirection.up:
        bottom = null;
        innerAlignment = Alignment.bottomCenter;
        break;
      case AxisDirection.down:
        top = null;
        innerAlignment = Alignment.topCenter;
        break;
    }

    Widget result = widget.overlayBuilder(context);
    if (widget.size is String) {}
    if (widget.size is num) {
      if (direction.isHorizontal) {
        width = ElTypeUtil.safeDouble(widget.size);
        height = double.infinity;
      } else {
        width = double.infinity;
        height = ElTypeUtil.safeDouble(widget.size);
      }
    } else {
      final sizeRatio = ElDartUtil.parseRatio(widget.size);
      if (direction.isHorizontal) {
        width = overlaySize.width * sizeRatio;
        height = double.infinity;
      } else {
        width = double.infinity;
        height = overlaySize.height * sizeRatio;
      }
    }

    result = AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Align(
          alignment: innerAlignment,
          widthFactor: isVertical ? null : curveAnimation.value,
          heightFactor: isVertical ? curveAnimation.value : null,
          child: child,
        );
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Material(child: result),
      ),
    );

    result = GestureDetector(
      onTap: () {
        modelValue = false;
      },
      child: ElModalTransition2(
        color: modalColorAnimation,
        child: Stack(
          children: [Positioned(left: left, right: right, top: top, bottom: bottom, child: result)],
        ),
      ),
    );

    result = ListenableBuilder(
      listenable: obs,
      builder: (context, child) {
        return IgnorePointer(ignoring: modelValue == false, child: child!);
      },
      child: result,
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: overlayController,
      // 强制将抽屉放置顶层，可以节省很多额外的计算
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (context) {
        return obsBuild(context);
      },
      child: widget.child,
    );
  }
}
