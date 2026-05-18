// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElDragStyleExt on ElDragStyle {
  ElDragStyle copyWith({
    void Function(PointerDownEvent)? onPointerDown,
    void Function(PointerMoveEvent)? onPointerMove,
    void Function(PointerUpEvent)? onPointerUp,
    void Function(PointerCancelEvent)? onPointerCancel,
    Axis? axis,
    double? horizontalAngle,
    bool? enabledAnimate,
    double? activeDelta,
    double? minFlingVelocity,
    double? maxFlingVelocity,
    void Function(ElDragStartDetails)? onDragStart,
    void Function(DragUpdateDetails)? onDragUpdate,
    void Function(DragEndDetails)? onDragEnd,
    void Function()? onDragCancel,
  }) {
    return ElDragStyle(
      onPointerDown: onPointerDown ?? this.onPointerDown,
      onPointerMove: onPointerMove ?? this.onPointerMove,
      onPointerUp: onPointerUp ?? this.onPointerUp,
      onPointerCancel: onPointerCancel ?? this.onPointerCancel,
      axis: axis ?? this.axis,
      horizontalAngle: horizontalAngle ?? this.horizontalAngle,
      enabledAnimate: enabledAnimate ?? this.enabledAnimate,
      activeDelta: activeDelta ?? this.activeDelta,
      minFlingVelocity: minFlingVelocity ?? this.minFlingVelocity,
      maxFlingVelocity: maxFlingVelocity ?? this.maxFlingVelocity,
      onDragStart: onDragStart ?? this.onDragStart,
      onDragUpdate: onDragUpdate ?? this.onDragUpdate,
      onDragEnd: onDragEnd ?? this.onDragEnd,
      onDragCancel: onDragCancel ?? this.onDragCancel,
    );
  }

  ElDragStyle merge([ElDragStyle? other]) {
    if (other == null) return this;
    return copyWith(
      onPointerDown: other.onPointerDown,
      onPointerMove: other.onPointerMove,
      onPointerUp: other.onPointerUp,
      onPointerCancel: other.onPointerCancel,
      axis: other.axis,
      horizontalAngle: other.horizontalAngle,
      enabledAnimate: other.enabledAnimate,
      activeDelta: other.activeDelta,
      minFlingVelocity: other.minFlingVelocity,
      maxFlingVelocity: other.maxFlingVelocity,
      onDragStart: other.onDragStart,
      onDragUpdate: other.onDragUpdate,
      onDragEnd: other.onDragEnd,
      onDragCancel: other.onDragCancel,
    );
  }

  List<Object?> get _props => [
    axis,
    horizontalAngle,
    enabledAnimate,
    activeDelta,
    minFlingVelocity,
    maxFlingVelocity,
    onDragStart,
    onDragUpdate,
    onDragEnd,
    onDragCancel,
  ];
}
