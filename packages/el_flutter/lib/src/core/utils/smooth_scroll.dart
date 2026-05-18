import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

class ElSmoothScrollController extends ScrollController {
  /// 桌面鼠标平滑滚动控制器
  ElSmoothScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
    super.onAttach,
    super.onDetach,
  });

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) {
    // Mac 可以借助第三方软件实现平滑滚动（例如 Mos）
    if (ElPlatform.isMacOS == false) {
      return _ScrollPosition(
        physics: physics,
        context: context,
        initialPixels: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        oldPosition: oldPosition,
        debugLabel: debugLabel,
      );
    } else {
      return super.createScrollPosition(physics, context, oldPosition);
    }
  }
}

/// 滚动动画时间
const _duration = Duration(milliseconds: 250);

/// 判断是否为触摸板的阈值
const _touchDelta = 20.0;

/// 鼠标滚轮单次事件的最小移动偏移
const _minDelta = 100.0;

/// 鼠标滚轮最大移动偏移
const _maxDelta = 300.0;

/// 在动画还未完成时，朝同一方向多次触发滚动事件，会不断累计一个加速度，
/// 直到最终速度到达 [_maxDelta] 阈值
const _speedUpDelta = 25.0;

class _ScrollPosition extends ScrollPositionWithSingleContext {
  _ScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  }) {
    controller = AnimationController.unbounded(value: pixels, duration: _duration, vsync: context.vsync)
      ..addListener(_listener)
      ..addStatusListener(_statusListener);
  }

  /// 滚动动画控制器，它的 value 与 [pixels] 同步，当 [pointerScroll] 每次接收到鼠标事件时，
  /// 会将单次 delta 以动画形式生成多个 [pixels] 目标值
  late final AnimationController controller;

  /// 最终目标滚动位置
  double targetPosition = 0.0;

  /// 当不断朝同一方向快速滚动时叠加的速度
  double currentSpeed = 0.0;

  /// 滚动是否是正向
  bool? isForwardScroll;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 滚动动画结束时的状态监听，清理一些资源
  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      currentSpeed = 0.0;
      isScrollingNotifier.value = false;
      isForwardScroll = null;

      didEndScroll();
      context.setIgnorePointer(false);
    }
  }

  /// 滚动动画监听器，执行滚动逻辑
  void _listener() {
    if (controller.value == pixels) return;
    final double oldPixels = pixels;
    correctPixels(controller.value); // 直接更新偏移位置
    notifyListeners(); // 触发通知，让页面发生滚动
    didUpdateScrollPositionBy(pixels - oldPixels); // 告知滚动位置变化（也就是通知滚动条更新）
  }

  /// 重写指针滚动逻辑，支持鼠标平滑滚动
  @override
  void pointerScroll(double delta) {
    if (delta == 0.0) {
      goIdle();
      return;
    }

    // 在 web 平台触摸板若接管了逻辑，则忽略下方的代码
    if (touchHandler(delta)) return;

    // 滚动时忽略指针命中测试
    context.setIgnorePointer(true);

    // 同步滚动位置到动画控制器（拖拽滚动条、触摸板滑动等非鼠标滚轮滚动引起的偏移）
    if (controller.value != pixels) controller.value = pixels;

    double targetPosition = this.targetPosition;
    // 向下滚动
    if (delta > 0) {
      final $delta = max(_minDelta, delta);
      if (isForwardScroll == null) {
        goIdle();
        // 向上滚动的方向为 forward，向下滚动的方向为 reverse
        updateUserScrollDirection(ScrollDirection.reverse);
        isScrollingNotifier.value = true;
        didStartScroll();
        isForwardScroll = true;
        targetPosition = pixels + $delta;
      }
      // 滚动动画还未结束又接收到新的增量事件，我们只需要计算最终的滚动位置即可
      else if (isForwardScroll == true) {
        currentSpeed += _speedUpDelta;
        targetPosition += min($delta + currentSpeed, _maxDelta);
      }
      // 当向上滚动动画还未结束，然后鼠标又朝反方向向下滚动，我们需要打断当前滚动动画，
      // 重置当前速度，并以当前滚动的位置为起点，计算新的最终滚动位置
      else {
        updateUserScrollDirection(ScrollDirection.reverse);
        isForwardScroll = true;
        currentSpeed = 0.0;
        targetPosition = controller.value + $delta;
      }

      if (targetPosition >= maxScrollExtent) {
        targetPosition = maxScrollExtent;
      }
    }
    // 向上滚动，逻辑与上面的一样
    else {
      final $delta = min(-_minDelta, delta);
      if (isForwardScroll == null) {
        goIdle();
        updateUserScrollDirection(ScrollDirection.forward);
        isScrollingNotifier.value = true;
        didStartScroll();
        isForwardScroll = false;
        targetPosition = pixels + $delta;
      } else if (isForwardScroll == false) {
        currentSpeed += _speedUpDelta;
        targetPosition += max($delta - currentSpeed, -_maxDelta);
      } else {
        updateUserScrollDirection(ScrollDirection.forward);
        isForwardScroll = false;
        currentSpeed = 0.0;
        targetPosition = controller.value + $delta;
      }

      if (targetPosition <= minScrollExtent) {
        targetPosition = minScrollExtent;
      }
    }

    if (targetPosition != this.targetPosition) {
      this.targetPosition = targetPosition;
      controller.animateTo(targetPosition, curve: Curves.decelerate);
    }
  }

  // =========================================================================
  // 处理 Web 平台触摸板滚动，在客户端触摸板不会进入 pointerScroll 方法，
  // 但 Web 平台却没有区分鼠标、触摸板，若 flutter 官方解决了此问题，可以删除这段逻辑
  bool? triggerTouch;
  Timer? _triggerTouchTimer;

  void _addTriggerTouchTimer() {
    _triggerTouchTimer = Timer(Duration(milliseconds: 100), () {
      triggerTouch = null;
      _triggerTouchTimer = null;
    });
  }

  bool touchHandler(double delta) {
    if (delta.abs() <= _touchDelta && triggerTouch == null) {
      triggerTouch = true;
      super.pointerScroll(delta);
      _addTriggerTouchTimer();
      return true;
    }

    if (triggerTouch == true) {
      if (_triggerTouchTimer != null) {
        _triggerTouchTimer!.cancel();
        _triggerTouchTimer = null;
      }
      super.pointerScroll(delta);
      _addTriggerTouchTimer();
      return true;
    }

    return false;
  }

  // =========================================================================
}
