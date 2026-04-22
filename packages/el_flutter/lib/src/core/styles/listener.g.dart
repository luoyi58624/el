// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listener.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElListenerStyleExt on ElListenerStyle {
  ElListenerStyle copyWith({
    HitTestBehavior? behavior,
    bool? disabled,
    void Function(PointerDownEvent)? onPointerDown,
    void Function(PointerMoveEvent)? onPointerMove,
    void Function(PointerUpEvent)? onPointerUp,
    void Function(PointerHoverEvent)? onHover,
    void Function(PointerPanZoomStartEvent)? onPointerPanZoomStart,
    void Function(PointerPanZoomUpdateEvent)? onPointerPanZoomUpdate,
    void Function(PointerPanZoomEndEvent)? onPointerPanZoomEnd,
    void Function(PointerSignalEvent)? onPointerSignal,
    void Function(PointerCancelEvent)? onPointerCancel,
  }) {
    return ElListenerStyle(
      behavior: behavior ?? this.behavior,
      disabled: disabled ?? this.disabled,
      onPointerDown: onPointerDown ?? this.onPointerDown,
      onPointerMove: onPointerMove ?? this.onPointerMove,
      onPointerUp: onPointerUp ?? this.onPointerUp,
      onHover: onHover ?? this.onHover,
      onPointerPanZoomStart: onPointerPanZoomStart ?? this.onPointerPanZoomStart,
      onPointerPanZoomUpdate: onPointerPanZoomUpdate ?? this.onPointerPanZoomUpdate,
      onPointerPanZoomEnd: onPointerPanZoomEnd ?? this.onPointerPanZoomEnd,
      onPointerSignal: onPointerSignal ?? this.onPointerSignal,
      onPointerCancel: onPointerCancel ?? this.onPointerCancel,
    );
  }

  ElListenerStyle merge([ElListenerStyle? other]) {
    if (other == null) return this;
    return copyWith(
      behavior: other.behavior,
      disabled: other.disabled,
      onPointerDown: other.onPointerDown,
      onPointerMove: other.onPointerMove,
      onPointerUp: other.onPointerUp,
      onHover: other.onHover,
      onPointerPanZoomStart: other.onPointerPanZoomStart,
      onPointerPanZoomUpdate: other.onPointerPanZoomUpdate,
      onPointerPanZoomEnd: other.onPointerPanZoomEnd,
      onPointerSignal: other.onPointerSignal,
      onPointerCancel: other.onPointerCancel,
    );
  }

  List<Object?> get _props => [
    behavior,
    disabled,
    onPointerDown,
    onPointerMove,
    onPointerUp,
    onHover,
    onPointerPanZoomStart,
    onPointerPanZoomUpdate,
    onPointerPanZoomEnd,
    onPointerSignal,
    onPointerCancel,
  ];
}
