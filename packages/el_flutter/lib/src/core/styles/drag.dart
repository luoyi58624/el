import 'package:el_flutter/el_flutter.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

part 'drag.g.dart';

@ElModelGenerator.copy()
// ignore: must_be_immutable
class ElDragStyle extends ElListenerStyle {
  ElDragStyle({
    super.onPointerDown,
    super.onPointerMove,
    super.onPointerUp,
    super.onPointerCancel,
    this.axis,
    this.horizontalAngle,
    this.enabledAnimate,
    this.activeDelta,
    this.minFlingVelocity,
    this.maxFlingVelocity,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
  });

  /// 指定拖拽方向
  final Axis? axis;

  /// 定义触发水平拖拽的角度，该值作用于拖拽偏移 [Offset] 的 direction 属性，
  /// 拖拽的 4 个方向值如下：
  /// * left -> 3.14
  /// * right -> 0
  /// * up -> -1.57
  /// * down -> 1.57
  ///
  /// 该值表示在 left、right 两个水平方向上的值区间，值越小，
  /// 意味着触发水平拖拽的角度越接近水平线，默认 0.5（大约 30 度的角）
  final double? horizontalAngle;

  /// 是否启用拖拽惯性动画
  final bool? enabledAnimate;

  /// 激活拖拽的最小偏移，默认 8.0
  final double? activeDelta;

  /// 触碰触发投掷动作的最小速度，默认 [kMinFlingVelocity]
  final double? minFlingVelocity;

  /// 限制触发投掷动作的最大速度，默认 [kMaxFlingVelocity]
  final double? maxFlingVelocity;

  /// 开始拖拽事件，它会在第一次指针移动时触发
  final ElGestureDragStartCallback? onDragStart;

  /// 拖拽更新事件
  final GestureDragUpdateCallback? onDragUpdate;

  /// 拖拽结束事件
  final GestureDragEndCallback? onDragEnd;

  /// 拖拽取消事件，当嵌套多个拖拽事件时，只会响应一个拖拽手势
  final GestureDragCancelCallback? onDragCancel;

  @override
  List<Object?> get props => [...super.props, _props];
}

typedef ElGestureDragStartCallback = void Function(ElDragStartDetails details);

class ElDragStartDetails extends DragStartDetails {
  ElDragStartDetails({
    super.globalPosition,
    super.localPosition,
    super.sourceTimeStamp,
    super.kind,
    required this.pointerDownEvent,
    required this.delta,
    required this.direction,
  });

  final PointerDownEvent pointerDownEvent;

  /// 触发拖拽时 Offset 偏移值
  final Offset delta;

  /// 首次拖拽时的方向
  final AxisDirection direction;
}
