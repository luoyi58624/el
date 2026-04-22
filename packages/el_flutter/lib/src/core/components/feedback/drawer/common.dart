part of 'index.dart';

// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: invalid_use_of_protected_member

bool _allowedDrag(bool? enabledDrag) {
  if (enabledDrag == null) {
    return ElPlatform.isMobile;
  } else {
    return enabledDrag == true;
  }
}

/// 计算抽屉最大尺寸
Size _calcDrawerMaxSize({double? size, required Size overlaySize, required AxisDirection direction}) {
  if (size == null) {
    if (direction.isVertical) {
      size = 0.5;
    } else {
      size = 300.0;
    }
  }

  assert(size >= 0.0);

  late double width;
  late double height;

  if (direction.isHorizontal) {
    if (size <= 1.0) size = overlaySize.width * size;
    width = min(size, overlaySize.width);
    height = min(double.infinity, overlaySize.height);
  } else {
    if (size <= 1.0) size = overlaySize.height * size;
    width = min(double.infinity, overlaySize.width);
    height = min(size, overlaySize.height);
  }

  return Size(width, height);
}

/// 抽屉拖拽小部件，这个小部件使用 [ElDrag] 处理拖拽，用于解决抽屉内部滚动、拖拽事件的冲突问题，
/// 当抽屉内部滚动到达临界点时，继续拖拽将由抽屉的拖拽事件接管
class _DrawerDrag extends StatefulWidget {
  const _DrawerDrag({
    this.onDragUpdate,
    this.onDragEnd,
    this.behavior,
    required this.direction,
    required this.getContentKey,
    required this.child,
  });

  final void Function(double delta)? onDragUpdate;
  final void Function(double delta)? onDragEnd; // delta 为拖拽结束后的速度 / primarySize
  final HitTestBehavior? behavior;
  final AxisDirection direction;
  final GlobalKey Function() getContentKey;
  final Widget child;

  @override
  State<_DrawerDrag> createState() => _DrawerDragState();
}

class _DrawerDragState extends State<_DrawerDrag> with ElScrollHitMixin {
  late DragGestureRecognizer drag;
  double? primarySize;

  // ElDrag 不参与手势竞技场，所以它只能作为中间人处理嵌套滚动的事件，
  // 而实际拖拽还是需要由官方提供的手势去完成
  void setGestureRecognizer() {
    if (widget.direction.isVertical) {
      drag = VerticalDragGestureRecognizer()
        ..onStart = _dragStart
        ..onEnd = _dragEnd
        ..onUpdate = _dragUpdate;
    } else {
      drag = HorizontalDragGestureRecognizer()
        ..onStart = _dragStart
        ..onEnd = _dragEnd
        ..onUpdate = _dragUpdate;
    }
  }

  void _dragStart(DragStartDetails e) {
    final size = widget.getContentKey().currentContext!.size!;
    if (widget.direction.isVertical) {
      primarySize = size.height;
    } else {
      primarySize = size.width;
    }
  }

  void _dragUpdate(DragUpdateDetails e) {
    late double delta;
    switch (widget.direction) {
      case AxisDirection.left:
        delta = e.delta.dx / primarySize!;
        break;
      case AxisDirection.right:
        delta = -e.delta.dx / primarySize!;
        break;
      case AxisDirection.up:
        delta = e.delta.dy / primarySize!;
        break;
      case AxisDirection.down:
        delta = -e.delta.dy / primarySize!;
        break;
    }
    widget.onDragUpdate?.call(delta);
  }

  void _dragEnd(DragEndDetails e) {
    late double velocityValue;
    switch (widget.direction) {
      case AxisDirection.left:
        velocityValue = e.velocity.pixelsPerSecond.dx;
        break;
      case AxisDirection.right:
        velocityValue = -e.velocity.pixelsPerSecond.dx;
        break;
      case AxisDirection.up:
        velocityValue = e.velocity.pixelsPerSecond.dy;
        break;
      case AxisDirection.down:
        velocityValue = -e.velocity.pixelsPerSecond.dy;
        break;
    }
    widget.onDragEnd?.call(velocityValue / primarySize!);
  }

  @override
  void initState() {
    super.initState();
    setGestureRecognizer();
  }

  @override
  void didUpdateWidget(covariant _DrawerDrag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction != oldWidget.direction) {
      drag.dispose();
      setGestureRecognizer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    drag.dispose();
  }

  @override
  Widget build(BuildContext context) {
    drag.gestureSettings = MediaQuery.gestureSettingsOf(context);
    Widget result = buildScrollHitListener(child: widget.child);

    result = ElDrag(
      style: ElDragStyle(
        axis: Axis.vertical,
        onPointerDown: (e) {
          drag.addPointer(e);
        },
        onDragStart: (e) {
          // 当内部滚动到达临界点时，继续拖拽会触发抽屉事件
          bool flag = false;
          final direction = e.delta.fromAxis(Axis.vertical);
          if (widget.direction == AxisDirection.down) {
            if (scrollHitStart) {
              if (direction == AxisDirection.down) {
                flag = true;
              }
            }
          } else if (widget.direction == AxisDirection.up) {
            if (scrollHitEnd) {
              if (direction == AxisDirection.up) {
                flag = true;
              }
            }
          }

          // 让拖拽抽屉手势在竞技场中获胜
          if (flag) drag.resolve(GestureDisposition.accepted);
        },
      ),
      child: result,
    );

    return result;
  }
}
