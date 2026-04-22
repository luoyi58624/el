import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:el_flutter/el_flutter.dart';

part 'scroll_behavior.dart';

part 'mixin.dart';

part 'raw_mixin.dart';

part 'scrollbar_painter.dart';

/// Element UI 滚动条显示模式
enum ElScrollbarShowMode {
  /// 不显示滚动条
  hidden,

  /// 当鼠标进入滚动区域立即显示滚动条，离开则立即隐藏，
  /// 由于移动端没有 hover 事件，所以此模式在移动端将自动应用 [onlyScrolling]
  hover,

  /// 一直显示滚动条
  always,

  /// 只有当滚动时才显示滚动条
  onlyScrolling,
}

class ElScrollbar extends StatefulWidget {
  /// Element UI 滚动条，由于可以通过 [ScrollConfiguration] 配置默认滚动条，所以并未提供 ThemeData 配置
  const ElScrollbar({
    super.key,
    required this.child,
    this.showMode = ElScrollbarShowMode.hover,
    this.controller,
    this.thickness = 8.0,
    this.shape,
    this.radius = const Radius.circular(4.0),
    this.trackRadius,
    this.mainAxisMargin = 0.0,
    this.crossAxisMargin = 1.0,
    this.padding,
    this.minThumbLength = 36.0,
    this.trackColor = Colors.transparent,
    this.trackBorderColor = Colors.transparent,
    this.paintSecondTrackBorder = false,
    this.trackBorderWidth = 1.0,
    this.thumbColor = const .fromRGBO(144, 147, 153, .45),
    this.thumbActiveColor = const .fromRGBO(144, 147, 153, .9),
    this.ignorePointer = false,
    this.ignoreTrackPointer = false,
    this.fadeDuration = const Duration(milliseconds: 200),
    this.timeToFade = const Duration(milliseconds: 1000),
    this.trackScrollDuration = const Duration(milliseconds: 350),
    this.scrollbarOrientation,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  });

  final Widget child;

  /// 滚动条显示模式，默认 [ElScrollbarShowMode.hover]
  final ElScrollbarShowMode showMode;

  /// 滚动控制器
  final ScrollController? controller;

  /// 滚动条粗细值
  final double thickness;

  /// 自定义滚动条形状，只能在 [radius] 之间二选一
  final OutlinedBorder? shape;

  /// 滚动条圆角
  final Radius radius;

  /// 滚动轨道圆角
  final Radius? trackRadius;

  /// 滚动条离顶部、尾部之间的间距，默认 0.0
  final double mainAxisMargin;

  /// 滚动条离轨道之间的间距，默认 1.0
  final double crossAxisMargin;

  /// 滚动条和轨道内边距
  final EdgeInsets? padding;

  /// 滚动条最小长度
  final double minThumbLength;

  /// 轨道颜色，默认透明
  final Color trackColor;

  /// 轨道边框颜色，默认透明
  final Color trackBorderColor;

  /// 轨道边框宽度
  final double trackBorderWidth;

  /// 是否绘制第二条轨道边框，默认情况下，ScrollbarPainter 只会绘制一条轨道，
  /// 如果你的布局没有使用 Border 分割页面，那么局部滚动条的轨道将会显得非常突兀。
  ///
  /// 注意：绘制第二条轨道边框是我自己魔改的代码，目前只支持垂直右侧滚动条。
  final bool paintSecondTrackBorder;

  /// 滚动条颜色
  final Color thumbColor;

  /// 滚动条激活颜色
  final Color thumbActiveColor;

  /// 是否忽略滚动条指针事件，若为 true，将不允许拖拽滚动条
  final bool ignorePointer;

  /// 否忽略轨道指针事件
  final bool ignoreTrackPointer;

  /// 滚动条淡入、淡出过渡动画持续时间
  final Duration fadeDuration;

  /// 当交互停止时，滚动条多久才会隐藏，仅限 [mode] = [ElScrollbarShowMode.onlyScrolling]
  final Duration timeToFade;

  /// 点击轨道滚动跳转动画持续时间
  final Duration trackScrollDuration;

  /// 滚动条在滚动容器中的位置，默认情况下，如果是垂直滚动，滚动条放置在右边，水平滚动滚动条放置在底部
  final ScrollbarOrientation? scrollbarOrientation;

  /// 根据滚动通知响应的 depth 来决定滚动条是否触发滚动，默认 [defaultScrollNotificationPredicate]，
  /// 它返回的条件是 notification.depth == 0，假如你嵌套了多个滚动容器，要让滚动条响应第二滚动容器只需要返回 notification.depth == 1，
  /// 应用场景：同时显示垂直、水平滚动条，详细信息请参阅 element_ui/lib 滚动条示例。
  final ScrollNotificationPredicate notificationPredicate;

  @override
  State<ElScrollbar> createState() => _ElScrollbarState();
}

class _ElScrollbarState extends State<ElScrollbar>
    with SingleTickerProviderStateMixin, _ElScrollbarMixin, _RawScrollbarMixin {
  void handleHoverEnter(PointerEnterEvent event) {
    if (hasHover == false) {
      hasHover = true;
      // 如果是在拖拽状态下鼠标重新进入滚动区域，需要重新判断是否处于滚动条上
      if (isDragScroll) {
        if (isPointerOverThumb(event.position, event.kind)) {
          changeColor(widget.thumbActiveColor, widget.thumbColor);
        }
      } else {
        changeColor(defaultThumbColor, widget.thumbColor);
      }
    }
  }

  void handleHover(PointerHoverEvent event) {
    // if (isPointerOverScrollbar(event.position, event.kind, forHover: true)) {
    //   i('xx');
    //   ElCursorUtil.insertGlobalCursor(SystemMouseCursors.click);
    // } else {
    //   ElCursorUtil.removeGlobalCursor();
    // }
  }

  void handleHoverExit(PointerExitEvent event) {
    hasHover = false;
    if (isDragScroll) return;
    changeColor(widget.thumbColor, defaultThumbColor);
  }

  /// 开始拖动滚动条
  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);

    isDragScroll = true;
    changeColor(widget.thumbColor, widget.thumbActiveColor);
  }

  /// 结束拖动滚动条
  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);

    if (showMode == ElScrollbarShowMode.onlyScrolling) {
      changeColor(widget.thumbActiveColor, widget.thumbColor);
    } else {
      // 短暂延迟一段时间执行结束逻辑，因为需要依赖 hasHover 判断鼠标是否还在当前滚动区域
      ElAsyncUtil.setTimeout(() {
        isDragScroll = false;
        if (hasHover) {
          changeColor(widget.thumbActiveColor, widget.thumbColor);
        } else {
          changeColor(widget.thumbActiveColor, defaultThumbColor);
        }
      }, 16);
    }
  }

  /// 隐藏滚动中的滚动条，如果滚动停止超过一段时间，将隐藏它
  Timer? _hideScrollingTimer;

  void _cancelHideScrollingTimer() {
    if (_hideScrollingTimer != null) {
      _hideScrollingTimer!.cancel();
      _hideScrollingTimer = null;
    }
  }

  /// 延迟清除 [color1]、[color2]
  Timer? _delayCleanColor;

  void _cancelDelayCleanColor() {
    if (_delayCleanColor != null) {
      _delayCleanColor!.cancel();
      _delayCleanColor = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ElPlatform.isMobile && showMode == ElScrollbarShowMode.hover) {
      showMode = ElScrollbarShowMode.onlyScrolling;
    }

    Widget result = widget.child;
    if (showMode == ElScrollbarShowMode.hidden) return result;

    updateScrollbarPainter();

    result = RepaintBoundary(
      child: CustomPaint(key: _scrollbarPainterKey, foregroundPainter: scrollbarPainter, child: result),
    );

    if (showMode == ElScrollbarShowMode.hover) {
      result = MouseRegion(onEnter: handleHoverEnter, onHover: handleHover, onExit: handleHoverExit, child: result);
    } else if (showMode == ElScrollbarShowMode.onlyScrolling) {
      result = NotificationListener<ScrollUpdateNotification>(
        onNotification: (e) {
          _cancelHideScrollingTimer();
          _cancelDelayCleanColor();
          _hideScrollingTimer = ElAsyncUtil.setTimeout(() {
            _hideScrollingTimer = null;
            changeColor(widget.thumbColor, defaultThumbColor);
            _delayCleanColor = ElAsyncUtil.setTimeout(() {
              _delayCleanColor = null;
              color1 = null;
              color2 = null;
            }, widget.fadeDuration.inMilliseconds);
          }, widget.timeToFade.inMilliseconds);
          if (color1 != color2 || (color1 == null && color2 == null)) {
            changeColor(defaultThumbColor, widget.thumbColor);
          }

          return false;
        },
        child: result,
      );
    }

    if (widget.ignorePointer != true) {
      result = RawGestureDetector(key: _gestureDetectorKey, gestures: _gestures, child: result);
    }
    result = NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetricsNotification,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Listener(onPointerSignal: _receivedPointerSignal, child: result),
      ),
    );

    return result;
  }
}
