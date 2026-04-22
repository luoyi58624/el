part of 'listener.dart';

/// 在原始指针事件的基础上进行扩展，使其支持单击、双击、三击、右键、长按等功能
class ElTap extends ElListener {
  const ElTap({super.key, required super.style, super.child});

  /// 取消目标指针激活的所有 tap 冒泡事件，例如：拖拽、长按触发时均会调用此方法
  static void cancelAll(int pointer) {
    final manager = ElListenerPointerManager.managers[pointer];
    if (manager != null) {
      for (final pointer in manager.pointers.toList()) {
        if (pointer is _RenderTap) {
          pointer.onCancel();
        }
      }
    }
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTap(style);
  }
}

class _RenderTap extends _RenderListener {
  _RenderTap(super.style);

  @override
  ElTapStyle? get style => super.style as ElTapStyle?;

  /// 记录当前的按下时间
  int? _tapDownTime;

  /// 连续按压次数
  int? _tapCount;

  Timer? _tapUpTimer;

  void _cancelTapUpTimer() {
    if (_tapUpTimer != null) {
      _tapUpTimer!.cancel();
      _tapUpTimer = null;
    }
  }

  /// 连击事件计时器
  Timer? _doubleTapTimer;

  void _cancelDoubleTapTimer() {
    if (_doubleTapTimer != null) {
      _doubleTapTimer!.cancel();
      _doubleTapTimer = null;
    }
  }

  /// 双击事件间隔时间
  int get doubleTapInterval => style?.doubleTapInterval ?? 300;

  /// 触发双击、三击指针事件的位置范围
  double get doubleTapTriggerScope => ElPlatform.isDesktop ? 4.0 : 16.0;

  @protected
  @override
  bool onPointerDown(PointerDownEvent e) {
    final result = super.onPointerDown(e);

    if (result) {
      if (primaryPointer!.buttons == kPrimaryButton) {
        onTapDown(e);
      } else {
        bool flag = false;
        if (primaryPointer!.buttons == kSecondaryButton) {
          flag = onSecondaryTapDown(e);
        } else if (primaryPointer!.buttons == kTertiaryButton) {
          flag = onTertiaryTapDown(e);
        } else if (primaryPointer!.buttons == kForwardMouseButton) {
          flag = onForwardTapDown(e);
        } else if (primaryPointer!.buttons == kBackMouseButton) {
          flag = onBackTapDown(e);
        }

        // 其他类型指针均不允许冒泡，只响应最内层事件
        if (flag) pointerManager!.prevent = true;
      }
    }

    return result;
  }

  @mustCallSuper
  @override
  bool onPointerUp(PointerUpEvent e) {
    final result = super.onPointerUp(e);

    if (result) {
      if (primaryPointer!.buttons == kPrimaryButton) {
        _doubleTapHandler(e); // 处理连击事件
        style?.onTap?.call(e);
        onTapUp(e);
      } else {
        if (primaryPointer!.buttons == kSecondaryButton) {
          onSecondaryTapUp(e);
        } else if (primaryPointer!.buttons == kTertiaryButton) {
          onTertiaryTapUp(e);
        } else if (primaryPointer!.buttons == kForwardMouseButton) {
          onForwardTapUp(e);
        } else if (primaryPointer!.buttons == kBackMouseButton) {
          onBackTapUp(e);
        }
      }
    }

    return result;
  }

  @mustCallSuper
  @override
  bool onPointerMove(PointerMoveEvent e) {
    final result = super.onPointerMove(e);

    if (result) {
      assert(primaryPointer != null);
      if ((e.position - primaryPointer!.position).distance > kTouchSlop) {
        onCancel();
      }
    }

    return result;
  }

  @protected
  @mustCallSuper
  bool onTapDown(PointerDownEvent e) {
    if (style?.onTapDown == null && style?.onTapUp == null) {
      return false;
    }

    _tapDownTime = ElDateUtil.currentMilliseconds;
    _cancelTapUpTimer();
    style?.onTapDown?.call(e);

    return true;
  }

  @protected
  @mustCallSuper
  void onTapUp(PointerUpEvent e) {
    if (style?.onTapUp != null) {
      if (style?.tapUpDelay == null || style!.tapUpDelay! <= 0) {
        style?.onTapUp?.call(e);
      } else {
        final time = style!.tapUpDelay! - (ElDateUtil.currentMilliseconds - _tapDownTime!);
        if (time <= 0) {
          style?.onTapUp?.call(e);
        } else {
          _tapUpTimer = ElAsyncUtil.setTimeout(() {
            _tapUpTimer = null;
            style?.onTapUp?.call(e);
          }, time);
        }
      }
    }
  }

  /// 记录连击的当前指针位置，在下次连击时，如果位置太远，则不会触发连击
  Offset? _doubleTapPosition;

  /// 连击事件处理
  void _doubleTapHandler(PointerUpEvent e) {
    if (style?.onDoubleTap == null) return;
    if (primaryPointer == null) return;
    if (_doubleTapTimer == null) {
      _tapCount = 1;
      _doubleTapPosition = primaryPointer!.position;
      _doubleTapTimer = ElAsyncUtil.setTimeout(() {
        _tapCount = null;
        _doubleTapTimer = null;
      }, doubleTapInterval);
      return;
    }

    if ((primaryPointer!.position - _doubleTapPosition!).distance < doubleTapTriggerScope) {
      _tapCount = _tapCount! + 1;
      _doubleTapTimer!.cancel();

      _doubleTapPosition = primaryPointer!.position;
      _doubleTapTimer = ElAsyncUtil.setTimeout(() {
        _tapCount = null;
        _doubleTapTimer = null;
      }, doubleTapInterval);

      assert(_tapCount != null && _tapCount! >= 2);
      style?.onDoubleTap?.call(_tapCount!);
    }
  }

  @protected
  @mustCallSuper
  bool onSecondaryTapDown(PointerDownEvent e) {
    if (style?.onSecondaryTapDown == null && style?.onSecondaryTapUp == null) {
      return false;
    }
    // 在 web 端需要阻止浏览器原生右键事件
    if (kIsWeb) BrowserContextMenu.disableContextMenu();
    style?.onSecondaryTapDown?.call(e);
    return true;
  }

  @protected
  @mustCallSuper
  void onSecondaryTapUp(PointerUpEvent e) {
    // 重置 web 原生右键事件
    if (kIsWeb) {
      ElAsyncUtil.setTimeout(() {
        BrowserContextMenu.enableContextMenu();
      }, 1);
    }
    style?.onSecondaryTapUp?.call(e);
  }

  @protected
  @mustCallSuper
  bool onTertiaryTapDown(PointerDownEvent e) {
    style?.onTertiaryTapDown?.call(e);
    return style?.onTertiaryTapDown != null || style?.onTertiaryTapUp != null;
  }

  @protected
  @mustCallSuper
  void onTertiaryTapUp(PointerUpEvent e) {
    style?.onTertiaryTapUp?.call(e);
  }

  @protected
  @mustCallSuper
  bool onForwardTapDown(PointerDownEvent e) {
    style?.onForwardTapDown?.call(e);
    return style?.onForwardTapDown != null || style?.onForwardTapUp != null;
  }

  @protected
  @mustCallSuper
  void onForwardTapUp(PointerUpEvent e) {
    style?.onForwardTapUp?.call(e);
  }

  @protected
  @mustCallSuper
  bool onBackTapDown(PointerDownEvent e) {
    style?.onBackTapDown?.call(e);
    return style?.onBackTapDown != null || style?.onBackTapUp != null;
  }

  @protected
  @mustCallSuper
  void onBackTapUp(PointerUpEvent e) {
    style?.onBackTapUp?.call(e);
  }

  @protected
  @mustCallSuper
  void onCancel() {
    if (primaryPointer != null) {
      _cancelDoubleTapTimer();
      _cancelTapUpTimer();
      style?.onCancel?.call(primaryPointer!);
      stopTrackingPointer(primaryPointer!.pointer);
    }
  }

  @override
  void dispose() {
    _tapDownTime = null;
    _tapCount = null;
    _cancelTapUpTimer();
    _cancelDoubleTapTimer();
    super.dispose();
  }
}
