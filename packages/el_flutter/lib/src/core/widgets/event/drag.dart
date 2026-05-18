import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:el_flutter/el_flutter.dart';
import 'pointer.dart';

class ElDragPointerManager extends ElPointerManager<_RenderDrag> {
  static final Map<int, ElDragPointerManager> managers = {};

  factory ElDragPointerManager(int pointer) => managers.putIfAbsent(pointer, () => ElDragPointerManager._());

  ElDragPointerManager._();
}

/// 监听拖拽事件小部件，对于嵌套拖拽引起的事件冒泡，需要分多种情况进行处理：
/// 1. 横向拖拽的优先级最高，无论横向拖拽是在底层还是上层；
/// 2. 多个相同方向的拖拽，优先响应内部拖拽事件；
/// 3. 未指定目标方向的拖拽，它的优先级最低；
/// 4. 拖拽支持代理，当内部拖拽满足一定条件时，其拖拽事件将由祖先进行消费；
class ElDrag extends SingleChildRenderObjectWidget {
  const ElDrag({super.key, this.style, super.child});

  final ElDragStyle? style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDrag(style);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderDrag).style = style;
  }
}

class _RenderDrag extends ElRenderPrimaryPointer<_RenderDrag> {
  _RenderDrag(ElDragStyle? style) : super(behavior: HitTestBehavior.opaque) {
    this.style = style;
  }

  ElDragStyle? _style;

  ElDragStyle? get style => _style;

  set style(ElDragStyle? v) {
    if (_style == v) return;
    _style = v;
    _updateAnimationController();
  }

  double get horizontalAngle => style?.horizontalAngle ?? 0.5;

  double get activeDelta => style?.activeDelta ?? 8.0;

  double get minFlingVelocity => style?.minFlingVelocity ?? kMinFlingVelocity;

  double get maxFlingVelocity => style?.maxFlingVelocity ?? kMaxFlingVelocity;

  ElDragPointerManager? get pointerManager => ElDragPointerManager.managers[primaryPointer!.pointer];

  /// 计算指针拖动结束时的速度，此变量可以作为判断是否触发拖拽
  VelocityTracker? _velocityTracker;

  /// 拖拽结束时甩出的方向
  double? _dragEndDirection;

  /// 拖拽惯性动画控制器
  AnimationController? _controller;
  double? _oldAnimateValue;

  void _animateListener() {
    assert(_controller != null && _dragEndDirection != null);

    late double details;
    if (_oldAnimateValue == null) {
      _oldAnimateValue = _controller!.value;
      details = _controller!.value;
    } else {
      details = _controller!.value - _oldAnimateValue!;
      _oldAnimateValue = _controller!.value;
    }

    var offsetDetails = Offset.fromDirection(_dragEndDirection!, details);

    onDragUpdate(
      DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: calcDelta(offsetDetails),
        primaryDelta: calcPrimaryDelta(offsetDetails),
      ),
    );
  }

  bool? _enabledAnimate;

  /// 更新惯性动画控制器
  void _updateAnimationController() {
    if (_enabledAnimate != style?.enabledAnimate) {
      if (_enabledAnimate != true) {
        _controller = AnimationController.unbounded(vsync: vsync)..addListener(_animateListener);
      } else if (_enabledAnimate == true) {
        assert(_controller != null);
        _controller!.dispose();
        _controller = null;
      }
      _enabledAnimate = style?.enabledAnimate;
    }
  }

  /// 决胜出唯一的拖拽手势，仅保留一个指针事件
  bool _eagerDragPointer(AxisDirection dragStartDireaction) {
    if (pointerManager == null) return false;

    final pointers = pointerManager!.pointers;
    _RenderDrag? result;

    if (dragStartDireaction.isHorizontal) {
      for (final drag in pointers) {
        if (drag.style?.axis == Axis.horizontal) {
          result = drag;
          break;
        }
      }
    } else {
      for (final drag in pointers) {
        if (drag.style?.axis == Axis.vertical) {
          result = drag;
          break;
        }
      }
    }

    result ??= this;

    for (final drag in pointers.where((e) => e != result).toList()) {
      if (drag.primaryPointer != null) {
        drag.stopTrackingPointer(drag.primaryPointer!.pointer);
      }
    }
    return result == this;
  }

  /// 创建惯性物理
  Simulation? createSimulation(DragEndDetails e) {
    return FrictionSimulation(
      0.005, // 定义拖拽阻力，值越小速度衰减越快，范围 0.0 - 1.0
      0.0,
      (e.primaryVelocity ?? e.velocity.pixelsPerSecond.distance).abs(),
      constantDeceleration: 100, // 速度低于该值将停止动画
    );
  }

  @protected
  void onDragStart(ElDragStartDetails e) {
    if (_controller != null) {
      if (_controller!.status != AnimationStatus.completed) {
        _controller!.stop();
      }

      _oldAnimateValue = null;
    }
    style?.onDragStart?.call(e);
  }

  @protected
  void onDragUpdate(DragUpdateDetails e) {
    style?.onDragUpdate?.call(e);
  }

  @protected
  void onDragEnd(DragEndDetails e) {
    if (_controller != null && e.velocity != Velocity.zero) {
      final simulation = createSimulation(e);
      if (simulation != null) {
        _dragEndDirection = e.velocity.pixelsPerSecond.direction;
        _controller!.animateWith(simulation);
      }
    }
    style?.onDragEnd?.call(e);
  }

  /// 判断指针滑动力度，如果力度小于 [minFlingVelocity]，那么它将返回 false
  bool _isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final double minDistance = computeHitSlop(kind, null);
    return estimate.pixelsPerSecond.distanceSquared > minFlingVelocity * minFlingVelocity &&
        estimate.offset.distanceSquared > minDistance * minDistance;
  }

  /// 计算拖拽增量，垂直拖拽 dx 必须为 0，水平拖拽 dy 必须为 0
  Offset calcDelta(Offset delta) => switch (style?.axis) {
    Axis.vertical => Offset(0.0, delta.dy),
    Axis.horizontal => Offset(delta.dx, 0.0),
    null => delta,
  };

  /// 计算主方向上的拖拽增量，垂直拖拽返回的是 dy，水平拖拽返回的是 dx
  double? calcPrimaryDelta(Offset delta) => switch (style?.axis) {
    Axis.vertical => delta.dy,
    Axis.horizontal => delta.dx,
    null => null,
  };

  /// 计算拖拽结束后的投掷速度
  Velocity? calcVelocity(VelocityEstimate estimate) => switch (style?.axis) {
    Axis.vertical => Velocity(
      pixelsPerSecond: Offset(0.0, clampDouble(estimate.pixelsPerSecond.dy, -maxFlingVelocity, maxFlingVelocity)),
    ),
    Axis.horizontal => Velocity(
      pixelsPerSecond: Offset(clampDouble(estimate.pixelsPerSecond.dx, -maxFlingVelocity, maxFlingVelocity), 0.0),
    ),
    null => Velocity(pixelsPerSecond: estimate.pixelsPerSecond).clampMagnitude(minFlingVelocity, maxFlingVelocity),
  };

  /// 计算拖拽结束后主方向上的投掷速度
  double? calcPrimaryVelocity(Offset? pixels) => switch (style?.axis) {
    Axis.vertical => pixels?.dy,
    Axis.horizontal => pixels?.dx,
    null => null,
  };

  @override
  void startTrackingPointer(PointerDownEvent event, [VoidCallback? callback]) {
    super.startTrackingPointer(event, () {
      if (ElDragPointerManager(event.pointer).prevent == false) {
        assert(pointerManager != null);
        pointerManager!.pointers.add(this);
        callback?.call();
      }
    });
  }

  @override
  void stopTrackingPointer(int pointer, [VoidCallback? callback]) {
    super.stopTrackingPointer(pointer, () {
      if (pointerManager?.pointers.remove(this) == true) {
        callback?.call();
        if (pointerManager?.pointers.isEmpty == true) {
          ElDragPointerManager.managers.remove(pointer);
        }
      }
    });
  }

  @override
  bool onPointerDown(PointerDownEvent e) {
    if (super.onPointerDown(e) == false) return false;
    style?.onPointerDown?.call(e);
    return true;
  }

  @override
  bool onPointerMove(PointerMoveEvent e) {
    final result = super.onPointerMove(e);
    if (result == false) return false;
    style?.onPointerMove?.call(e);

    if (pointerManager!.pointers.contains(this) != true) return false;

    // 指针首次移动会触发 onDragStart 事件，后续移动才触发 onDragUpdate 事件
    if (_velocityTracker == null) {
      final moveDelta = e.position - primaryPointer!.position;

      // 移动范围需要到达一定幅度才触发拖拽
      if (moveDelta.distance <= activeDelta) return false;

      // 计算拖拽方向
      final dragStartDireaction = moveDelta.toAxisDirection(horizontalAngle);

      // 决胜出唯一拖拽手势
      if (_eagerDragPointer(dragStartDireaction)) {
        ElTap.cancelAll(primaryPointer!.pointer);
        _velocityTracker = VelocityTracker.withKind(e.kind);
        onDragStart(
          ElDragStartDetails(
            globalPosition: e.position,
            localPosition: e.localPosition,
            sourceTimeStamp: e.timeStamp,
            kind: e.kind,
            pointerDownEvent: primaryPointer!,
            delta: moveDelta,
            direction: dragStartDireaction,
          ),
        );
      }
    } else {
      // 添加触摸的数据，当触摸结束后会计算最终的速度
      _velocityTracker!.addPosition(e.timeStamp, e.position);

      onDragUpdate(
        DragUpdateDetails(
          sourceTimeStamp: e.timeStamp,
          globalPosition: e.position,
          localPosition: e.localPosition,
          delta: calcDelta(e.delta),
          primaryDelta: calcPrimaryDelta(e.delta),
        ),
      );
    }

    return true;
  }

  @override
  bool onPointerUp(PointerUpEvent e) {
    final result = super.onPointerUp(e);
    if (result == false) return false;
    style?.onPointerUp?.call(e);

    if (_velocityTracker == null) return false;

    final VelocityEstimate? estimate = _velocityTracker!.getVelocityEstimate();
    Velocity velocity = Velocity.zero;
    if (estimate != null) {
      if (_isFlingGesture(estimate, e.kind)) {
        velocity = calcVelocity(estimate) ?? Velocity.zero;
      }
    }

    onDragEnd(
      DragEndDetails(
        velocity: velocity,
        primaryVelocity: calcPrimaryVelocity(velocity.pixelsPerSecond),
        globalPosition: e.position,
        localPosition: e.localPosition,
      ),
    );
    _velocityTracker = null;

    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerCancel(PointerCancelEvent e) {
    style?.onPointerCancel?.call(e);
    return true;
  }

  @override
  void dispose() {
    _enabledAnimate = null;
    _velocityTracker = null;
    _dragEndDirection = null;
    _oldAnimateValue = null;
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}
