import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

part 'event.g.dart';

@ElModelGenerator.copy()
// ignore: must_be_immutable
class ElEventStyle extends ElTapStyle {
  ElEventStyle({
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
    super.tapUpDelay,
    super.onTap,
    super.onTapDown,
    super.onTapUp,
    super.onSecondaryTapDown,
    super.onSecondaryTapUp,
    super.onTertiaryTapDown,
    super.onTertiaryTapUp,
    super.onForwardTapDown,
    super.onForwardTapUp,
    super.onBackTapDown,
    super.onBackTapUp,
    super.onCancel,
    super.doubleTapInterval,
    super.onDoubleTap,
    super.onScaleUpdate,
    this.ignoreStatus,
    this.longPressFeedback,
    this.onLongPress,
    this.longPressGestureRecognizer,
    this.hoverBehavior,
    this.cursor,
    this.disabledCursor,
    this.onEnter,
    this.onExit,
    this.onActivate,
    this.focusNode,
    this.parentNode,
    this.autofocus,
    this.canRequestFocus,
    this.skipTraversal,
    this.descendantsAreFocusable,
    this.descendantsAreTraversable,
    this.includeFocusSemantics,
    this.activeThrottle,
    this.onFocusChange,
  });

  /// 是否忽略交互状态，若为 true 将不会注入 hasHover、hasTap、hasFocus 变量
  bool? ignoreStatus;

  // =========================================================================
  // LongPress 长按相关属性
  // =========================================================================

  /// 是否启用长按反馈，在移动端默认为 true
  bool? longPressFeedback;

  /// 监听长按事件
  PointerDownEventListener? onLongPress;

  /// 监听长按手势其他事件，其中长按事件会被 [onLongPress] 覆盖
  LongPressGestureRecognizer? longPressGestureRecognizer;

  // =========================================================================
  // Hover 悬停相关属性
  // =========================================================================

  /// 设置悬停命中行为，默认情况下会跟随 [behavior]，但是如果 [disabled] 为 true，
  /// [hoverBehavior] 将强制为 [HitTestBehavior.opaque]，用于防止 [cursor] 失效。
  HitTestBehavior? hoverBehavior;

  /// 鼠标悬停光标样式，默认 [MouseCursor.defer]
  MouseCursor? cursor;

  /// 指针被禁用时悬停光标样式，默认 [SystemMouseCursors.forbidden]
  MouseCursor? disabledCursor;

  /// 鼠标进入事件
  PointerEnterEventListener? onEnter;

  /// 鼠标离开事件
  PointerExitEventListener? onExit;

  // =========================================================================
  // 焦点相关属性
  // =========================================================================

  /// 监听聚焦元素键盘事件（监听 enter 键回调），只有当指定了此事件，
  /// ElEvent 才会构建与焦点相关的内容，例如：[Focus]、[Actions] 小部件，
  /// 之所以添加此限制，是因为如果没有监听键盘事件，那么与焦点相关的任何内容都毫无意义。
  VoidCallback? onActivate;

  /// 设置焦点控制器
  FocusNode? focusNode;

  /// 链接父焦点
  FocusNode? parentNode;

  /// 是否自动聚焦
  bool? autofocus;

  /// 是否允许聚焦，默认 false
  bool? canRequestFocus;

  /// 是否跳过焦点遍历
  bool? skipTraversal;

  /// 让后代无法聚焦（自身依然可以得到焦点）
  bool? descendantsAreFocusable;

  /// 跳过后代焦点遍历（自身依然可以遍历）
  bool? descendantsAreTraversable;

  /// 是否构建焦点语义，默认 true
  bool? includeFocusSemantics;

  /// 给键盘事件回调 [onActivate] 添加节流时间，默认 100 毫秒
  int? activeThrottle;

  /// 监听焦点变化
  ValueChanged<bool>? onFocusChange;

  @override
  List<Object?> get props => [...super.props, _props];
}
