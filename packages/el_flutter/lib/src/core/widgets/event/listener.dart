import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

import 'pointer.dart';

part 'tap.dart';

class ElListenerPointerManager extends ElPointerManager<_RenderListener> {
  static final Map<int, ElListenerPointerManager> managers = {};

  factory ElListenerPointerManager(int pointer) => managers.putIfAbsent(pointer, () => ElListenerPointerManager._());

  ElListenerPointerManager._();
}

/// 对原始指针进行一层浅封装，使其支持事件冒泡
class ElListener extends SingleChildRenderObjectWidget {
  const ElListener({super.key, this.style, super.child});

  final ElListenerStyle? style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderListener(style);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    renderObject as _RenderListener
      ..style = style
      ..behavior = style?.behavior ?? HitTestBehavior.deferToChild;
  }
}

class _RenderListener extends ElRenderPrimaryPointer<_RenderListener> {
  _RenderListener(this.style) : super(behavior: style?.behavior ?? HitTestBehavior.deferToChild);

  ElListenerStyle? style;

  ElListenerPointerManager? get pointerManager => ElListenerPointerManager.managers[primaryPointer!.pointer];

  bool get hasPointer => pointerManager?.pointers.contains(this) == true;

  @override
  void startTrackingPointer(PointerDownEvent event, [VoidCallback? callback]) {
    super.startTrackingPointer(event, () {
      if (ElListenerPointerManager(event.pointer).prevent == false) {
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
          ElListenerPointerManager.managers.remove(pointer);
        }
      }
    });
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerDown(PointerDownEvent e) {
    if (super.onPointerDown(e) == false) return false;
    if (!hasPointer) return false;
    style?.onPointerDown?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerUp(PointerUpEvent e) {
    if (super.onPointerUp(e) == false) return false;
    if (!hasPointer) return false;
    style?.onPointerUp?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerMove(PointerMoveEvent e) {
    if (super.onPointerMove(e) == false) return false;
    if (!hasPointer) return false;
    style?.onPointerMove?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerHover(PointerHoverEvent e) {
    style?.onHover?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerPanZoomStart(PointerPanZoomStartEvent e) {
    style?.onPointerPanZoomStart?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerPanZoomUpdate(PointerPanZoomUpdateEvent e) {
    style?.onPointerPanZoomUpdate?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerPanZoomEnd(PointerPanZoomEndEvent e) {
    style?.onPointerPanZoomEnd?.call(e);
    return true;
  }

  @override
  @protected
  @mustCallSuper
  bool onPointerSignal(PointerSignalEvent e) {
    style?.onPointerSignal?.call(e);
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
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return style?.disabled != true && super.hitTest(result, position: position);
  }

  @override
  void dispose() {
    style = null;
    super.dispose();
  }
}
