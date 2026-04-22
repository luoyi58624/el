import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

part 'tap.g.dart';

@ElModelGenerator.copy()
// ignore: must_be_immutable
class ElTapStyle extends ElListenerStyle {
  ElTapStyle({
    super.disabled,
    super.behavior,
    super.onPointerDown,
    super.onPointerMove,
    super.onPointerUp,
    super.onHover,
    super.onPointerPanZoomStart,
    super.onPointerPanZoomUpdate,
    super.onPointerPanZoomEnd,
    super.onPointerSignal,
    super.onPointerCancel,
    this.tapUpDelay,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onForwardTapDown,
    this.onForwardTapUp,
    this.onBackTapDown,
    this.onBackTapUp,
    this.onCancel,
    this.doubleTapInterval,
    this.onDoubleTap,
    this.onScaleUpdate,
    this.onRotationUpdate,
  });

  /// 延迟响应 [onTapUp] 事件，[ElEvent] 会将其设置为默认 100 毫秒，
  /// 因为 [ElEvent] 提供了 hasTap 状态，如果不设置延迟，那么在轻击时状态可能会一闪而过。
  int? tapUpDelay;

  /// 主指针点击事件（响应事件冒泡）
  PointerUpEventListener? onTap;

  /// 主指针按下事件（响应事件冒泡）
  PointerDownEventListener? onTapDown;

  /// 主指针抬起事件（响应事件冒泡），它与 [onTap] 没有本质区别，只不过允许延迟响应
  PointerUpEventListener? onTapUp;

  /// 设备第二个按钮指针事件，对应鼠标右键事件（不响应事件冒泡）
  PointerDownEventListener? onSecondaryTapDown;
  PointerUpEventListener? onSecondaryTapUp;

  /// 设备第三个按钮指针事件，对应鼠标中间按钮事件（不响应事件冒泡）
  PointerDownEventListener? onTertiaryTapDown;
  PointerUpEventListener? onTertiaryTapUp;

  /// 点击了鼠标前进按钮（不响应事件冒泡）
  PointerDownEventListener? onForwardTapDown;
  PointerUpEventListener? onForwardTapUp;

  /// 点击了鼠标后退按钮（不响应事件冒泡）
  PointerDownEventListener? onBackTapDown;
  PointerUpEventListener? onBackTapUp;

  /// 指针被取消事件
  PointerRoute? onCancel;

  /// 自定义连击间隔，默认 300 毫秒
  int? doubleTapInterval;

  /// 主指针连击事件，其中 tapCount 表示当前连击次数，用于监听双击、三击事件：
  /// ```dart
  /// if(tapCount == 2) // 处理双击
  /// if(tapCount == 3) // 处理三击
  /// ```
  ///
  /// 在触发连击后，需要等待 [doubleTapInterval] 结束后才会重置计时器，
  /// 这个逻辑符合 Web 上的双击事件。
  ///
  /// 注意：连击事件不会阻塞 [onTap]、[onTapUp] 等点击事件，
  /// 而官方提供的 [DoubleTapGestureRecognizer] 手势会延迟触发点击事件，
  /// 如果你需要官方的特性，请直接使用 [GestureDetector] 小部件。
  void Function(int tapCount)? onDoubleTap;

  /// 监听双指捏合事件，回调是一个 delta 增量值，使用时直接与当前 scale 相加即可
  void Function(double scale)? onScaleUpdate;

  /// 监听双指旋转事件，回调是一个 delta 增量值，使用时直接与当前 rotation 相加即可，
  /// 提示：第一次触发旋转有一定的阈值
  void Function(double rotation)? onRotationUpdate;

  @override
  List<Object?> get props => [...super.props, _props];
}
