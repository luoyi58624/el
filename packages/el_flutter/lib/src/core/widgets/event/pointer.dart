import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

/// 一个简单的指针管理器对象，它通过 [prevent] 标识来阻止上层事件获得指针
abstract class ElPointerManager<T extends ElRenderPointerListener> {
  /// 保存已添加的指针对象
  final Set<T> pointers = {};

  /// 是否阻止指针事件
  bool prevent = false;
}

/// 监听原始事件
abstract class ElRenderPointerListener extends RenderProxyBoxWithHitTestBehavior {
  ElRenderPointerListener({super.behavior});

  @protected
  bool onPointerDown(PointerDownEvent e) => true;

  @protected
  bool onPointerUp(PointerUpEvent e) => true;

  @protected
  bool onPointerMove(PointerMoveEvent e) => true;

  @protected
  bool onPointerHover(PointerHoverEvent e) => true;

  @protected
  bool onPointerPanZoomStart(PointerPanZoomStartEvent e) => true;

  @protected
  bool onPointerPanZoomUpdate(PointerPanZoomUpdateEvent e) => true;

  @protected
  bool onPointerPanZoomEnd(PointerPanZoomEndEvent e) => true;

  @protected
  bool onPointerSignal(PointerSignalEvent e) => true;

  @protected
  bool onPointerCancel(PointerCancelEvent e) => true;

  /// 开始监听指针事件，此方法在 [onPointerDown] 之前触发
  @protected
  void startTrackingPointer(PointerDownEvent event, [VoidCallback? callback]) {}

  /// 停止监听指针事件，此方法在 [onPointerUp]、[onPointerPanZoomEnd]、[onPointerCancel] 之后触发
  @protected
  void stopTrackingPointer(int pointer, [VoidCallback? callback]) {}

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) => constraints.biggest;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    switch (event) {
      case PointerDownEvent():
        startTrackingPointer(event);
        onPointerDown(event);
        break;
      case PointerUpEvent():
        onPointerUp(event);
        stopTrackingPointer(event.pointer);
        break;
      case PointerMoveEvent():
        onPointerMove(event);
        break;
      case PointerPanZoomStartEvent():
        onPointerPanZoomStart(event);
        break;
      case PointerPanZoomUpdateEvent():
        onPointerPanZoomUpdate(event);
        break;
      case PointerPanZoomEndEvent():
        onPointerPanZoomEnd(event);
        stopTrackingPointer(event.pointer);
        break;
      case PointerSignalEvent():
        onPointerSignal(event);
        break;
      case PointerCancelEvent():
        onPointerCancel(event);
        stopTrackingPointer(event.pointer);
        break;
    }
  }
}

/// 此 RenderObject 只监听一个指针事件
abstract class ElRenderPrimaryPointer<T extends ElRenderPointerListener> extends ElRenderPointerListener {
  ElRenderPrimaryPointer({super.behavior});

  PointerDownEvent? get primaryPointer => _primaryPointer;
  PointerDownEvent? _primaryPointer;

  @override
  @mustCallSuper
  void startTrackingPointer(PointerDownEvent event, [VoidCallback? callback]) {
    if (primaryPointer == null) {
      _primaryPointer = event;
      callback?.call();
    }
  }

  @override
  @mustCallSuper
  void stopTrackingPointer(int pointer, [VoidCallback? callback]) {
    if (primaryPointer?.pointer == pointer) {
      callback?.call();
      _primaryPointer = null;
    }
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerDown(PointerDownEvent e) => primaryPointer?.pointer == e.pointer;

  @override
  @protected
  @mustCallSuper
  bool onPointerUp(PointerUpEvent e) => primaryPointer?.pointer == e.pointer;

  @override
  @protected
  @mustCallSuper
  bool onPointerMove(PointerMoveEvent e) => primaryPointer?.pointer == e.pointer;
}
