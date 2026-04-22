import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

extension ElEventExt on BuildContext {
  /// 从当前上下文 context 访问最近的 ElEvent 注入的 hover 悬停状态
  bool get hasHover =>
      InheritedModel.inheritFrom<_EventStatus>(this, aspect: _EventStatusAspect.hover)?.hasHover ?? false;

  /// 从当前上下文 context 访问最近的 ElEvent 注入的 tap 点击状态
  bool get hasTap => InheritedModel.inheritFrom<_EventStatus>(this, aspect: _EventStatusAspect.tap)?.hasTap ?? false;

  /// 从当前上下文 context 访问最近的 ElEvent 注入的 focus 聚焦状态
  bool get hasFocus =>
      InheritedModel.inheritFrom<_EventStatus>(this, aspect: _EventStatusAspect.focus)?.hasFocus ?? false;
}

/// 构建通用的事件小部件，在 [ElTap] 的基础上加入 [MouseRegion]、[Focus]、[Actions] 组成完整的事件，
/// 后代小部件可以通过 context 访问 hover、tap、focus 状态，例如：
/// ```dart
/// ElEvent(
///   child: Builder(
///     builder: (context) {
///       return Container(
///         color: context.hasTap ? Colors.red
///             : context.hasHover ? Colors.green
///             : null,
///       );
///     },
///   ),
/// );
/// ```
class ElEvent extends StatefulWidget {
  const ElEvent({super.key, this.style, required this.child});

  final ElEventStyle? style;
  final Widget child;

  @override
  State<ElEvent> createState() => _ElEventState();
}

class _ElEventState extends State<ElEvent> {
  final notify = ElNotify();

  ElEventStyle get style => _style!;
  ElEventStyle? _style;

  LongPressGestureRecognizer? _longPressGestureRecognizer;

  void updateStyleAndRecognizer() {
    _style = ElEventStyle(
      tapUpDelay: widget.style?.tapUpDelay ?? 100,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onCancel: onCancel,
    );
    if (widget.style != null) _style = widget.style!.merge(style);

    if (style.onLongPress != null || style.longPressGestureRecognizer != null) {
      _longPressGestureRecognizer?.dispose();
      _longPressGestureRecognizer = (widget.style!.longPressGestureRecognizer ?? LongPressGestureRecognizer())
        ..onLongPress = onLongPress;
    }
  }

  bool _hasHover = false;

  set hasHover(bool v) {
    if (_hasHover == v) return;
    _hasHover = v;
    notify.notifyListeners();
  }

  bool _hasTap = false;

  set hasTap(bool v) {
    if (_hasTap == v) return;
    _hasTap = v;
    notify.notifyListeners();
  }

  bool _hasFocus = false;

  set hasFocus(bool v) {
    if (_hasFocus == v) return;
    _hasFocus = v;
    notify.notifyListeners();
  }

  void onEnter(PointerEnterEvent e) {
    style.onEnter?.call(e);
    hasHover = true;
  }

  void onExit(PointerExitEvent e) {
    style.onExit?.call(e);
    hasHover = false;
  }

  void onFocusChange(bool v) {
    hasFocus = v == true;
    style.onFocusChange?.call(v);
  }

  void _activateOnIntent() {
    if (style.disabled == true) return;
    hasTap = true;
    ElAsyncUtil.setTimeout(() {
      if (mounted || style.disabled != true) {
        style.onActivate?.call();
        hasTap = false;
      }
    }, 100);
  }

  /// 当聚焦时，响应 enter 回车事件
  void activateOnIntent(Intent? intent) {
    final activeThrottle = style.activeThrottle ?? 100;
    if (activeThrottle <= 0) {
      _activateOnIntent();
    } else {
      ElAsyncUtil.throttle(_activateOnIntent, activeThrottle, key: hashCode)();
    }
  }

  @override
  void initState() {
    super.initState();
    updateStyleAndRecognizer();
  }

  @override
  void didUpdateWidget(covariant ElEvent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style) updateStyleAndRecognizer();
  }

  @override
  void dispose() {
    notify.dispose();
    super.dispose();
    _longPressGestureRecognizer?.dispose();
    _longPressGestureRecognizer = null;
    _style = null;
    pointerDownEvent = null;
  }

  PointerDownEvent? pointerDownEvent;

  void onTapDown(PointerDownEvent e) {
    pointerDownEvent = e;
    hasTap = true;
    widget.style?.onTapDown?.call(e);
    _longPressGestureRecognizer?.addPointer(e);
  }

  void onTapUp(PointerUpEvent e) {
    hasTap = false;
    widget.style?.onTapUp?.call(e);
  }

  void onCancel(PointerEvent e) {
    hasTap = false;
    widget.style?.onCancel?.call(e);
  }

  void onLongPress() {
    ElTap.cancelAll(pointerDownEvent!.pointer);
    style.onLongPress?.call(pointerDownEvent!);
    if ((style.longPressFeedback ?? ElPlatform.isMobile) && mounted) {
      Feedback.forLongPress(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool disabled = style.disabled == true;
    late Widget result;

    if (disabled) {
      hasHover = false;
      hasTap = false;
    }

    if (style.ignoreStatus == true) {
      result = widget.child;
    } else {
      result = ListenableBuilder(
        listenable: notify,
        builder: (context, child) {
          return _EventStatus(_hasHover, _hasTap, _hasFocus, child: widget.child);
        },
      );
    }

    result = ElTap(style: style, child: result);

    if (ElPlatform.isDesktop) {
      result = MouseRegion(
        hitTestBehavior: disabled ? HitTestBehavior.opaque : style.hoverBehavior ?? style.behavior,
        cursor: (disabled ? (style.disabledCursor ?? SystemMouseCursors.forbidden) : style.cursor) ?? MouseCursor.defer,
        onEnter: disabled ? null : onEnter,
        onExit: disabled ? null : onExit,
        child: result,
      );
    }

    if (style.onActivate != null) {
      result = Focus(
        onFocusChange: onFocusChange,
        focusNode: style.focusNode,
        parentNode: style.parentNode,
        autofocus: style.autofocus ?? false,
        canRequestFocus: style.disabled != true,
        skipTraversal: style.skipTraversal,
        descendantsAreFocusable: style.descendantsAreFocusable,
        descendantsAreTraversable: style.descendantsAreTraversable,
        includeSemantics: style.includeFocusSemantics ?? true,
        child: result,
      );

      result = Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: activateOnIntent),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: activateOnIntent),
        },
        child: result,
      );
    }

    return result;
  }
}

enum _EventStatusAspect { hover, tap, focus }

// 将状态进行区分，仅监听使用的状态
class _EventStatus extends InheritedModel<_EventStatusAspect> {
  const _EventStatus(this.hasHover, this.hasTap, this.hasFocus, {required super.child});

  final bool hasHover;
  final bool hasTap;
  final bool hasFocus;

  @override
  bool updateShouldNotify(_EventStatus oldWidget) =>
      hasHover != oldWidget.hasHover || hasTap != oldWidget.hasTap || hasFocus != oldWidget.hasFocus;

  @override
  bool updateShouldNotifyDependent(_EventStatus oldWidget, Set<_EventStatusAspect> dependencies) {
    return dependencies.any(
      (Object dependency) =>
          dependency is _EventStatusAspect &&
          switch (dependency) {
            _EventStatusAspect.hover => hasHover != oldWidget.hasHover,
            _EventStatusAspect.tap => hasTap != oldWidget.hasTap,
            _EventStatusAspect.focus => hasFocus != oldWidget.hasFocus,
          },
    );
  }
}
