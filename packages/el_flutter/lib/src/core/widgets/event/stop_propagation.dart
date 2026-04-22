import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'drag.dart';
import 'listener.dart';

class ElStopPropagation extends SingleChildRenderObjectWidget {
  /// 阻止事件冒泡小部件
  const ElStopPropagation({
    super.key,
    this.behavior = HitTestBehavior.opaque,
    super.child,
    this.prevent = true,
    this.preventDrag = false,
    this.preventTapGesture = false,
  });

  final HitTestBehavior behavior;

  /// 阻止指针冒泡，默认 true
  final bool prevent;

  /// 阻止指针拖拽冒泡，默认 false
  final bool preventDrag;

  /// 是否阻止上层 [TapGestureRecognizer] 单击手势，默认 false
  final bool preventTapGesture;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderStopPropagation(prevent, preventDrag, preventTapGesture, behavior: behavior);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    renderObject as _RenderStopPropagation
      ..behavior = behavior
      ..prevent = prevent
      ..preventDrag = preventDrag
      ..preventTapGesture = preventTapGesture;
  }
}

class _RenderStopPropagation extends RenderProxyBoxWithHitTestBehavior {
  _RenderStopPropagation(this.prevent, this.preventDrag, this._preventGesture, {super.behavior}) {
    if (_preventGesture) _tapGestureRecognizer = TapGestureRecognizer();
  }

  bool prevent;
  bool preventDrag;
  bool _preventGesture;

  set preventTapGesture(bool v) {
    if (_preventGesture == v) return;
    _preventGesture = v;
    if (v) {
      _tapGestureRecognizer = TapGestureRecognizer();
    } else {
      assert(_tapGestureRecognizer != null);
      _tapGestureRecognizer!.dispose();
      _tapGestureRecognizer = null;
    }
  }

  TapGestureRecognizer? _tapGestureRecognizer;

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) => constraints.biggest;

  bool? _autoRemoveListener;
  bool? _autoRemoveDrag;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      if (prevent) {
        if (ElListenerPointerManager.managers.containsKey(event.pointer)) {
          ElListenerPointerManager.managers[event.pointer]?.prevent = true;
        } else {
          ElListenerPointerManager(event.pointer).prevent = true;
          _autoRemoveListener = true;
        }
      }

      if (preventDrag) {
        if (ElDragPointerManager.managers.containsKey(event.pointer)) {
          ElDragPointerManager.managers[event.pointer]?.prevent = true;
        } else {
          ElDragPointerManager(event.pointer).prevent = true;
          _autoRemoveDrag = true;
        }
      }

      if (_tapGestureRecognizer != null) {
        _tapGestureRecognizer!
          ..onTap = () {}
          ..addPointer(event);
      }
    } else if (event is PointerUpEvent || event is PointerPanZoomEndEvent || event is PointerCancelEvent) {
      if (_autoRemoveListener == true) {
        _autoRemoveListener = null;
        ElListenerPointerManager.managers.remove(event.pointer);
      }
      if (_autoRemoveDrag == true) {
        _autoRemoveDrag = null;
        ElDragPointerManager.managers.remove(event.pointer);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tapGestureRecognizer?.dispose();
  }
}
