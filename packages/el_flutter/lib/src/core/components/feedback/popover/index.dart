import 'dart:async';

import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

part 'builder.dart';

Widget _transitionBuilder(BuildContext context, Widget child) {
  return FadeTransition(opacity: ElPopup.of(context).animationController, child: child);
}

Widget _builder(BuildContext context, ElPopupState state) {
  return ElPopoverBuilder(state: state as ElPopoverState);
}

/// Popover 弹出框，用于展示轻量级内容，该小部件在 [ElLinkPopup] 的基础上添加了默认事件代理，
/// 通常适合展示类似于 tooltip 之类的提示面板
class ElPopover extends ElLinkPopup {
  const ElPopover({
    super.key,
    super.show,
    super.duration,
    super.keepAlive,
    super.onChanged,
    super.onInsert,
    super.onRemove,
    super.transitionBuilder = _transitionBuilder,
    super.builder = _builder,
    required super.overlayBuilder,
    required super.child,
    super.alignment,
    super.removeBehavior,
    super.spacing = 8.0,
    super.edgeSpacing,
    this.hoverDelayShow,
    this.hoverDelayHide,
    this.staticHover,
    this.showArrow,
    this.disabledEvent,
  });

  /// 悬停延迟显示弹出层（毫秒），如果不为 null 则默认对齐为 [ElPopupAlignment.float]
  final int? hoverDelayShow;

  /// 悬停延迟隐藏弹出层（毫秒）
  ///
  /// 注意：如果要与弹窗进行交互，就一定要设置延迟隐藏，
  /// 否则鼠标离开 child 范围就会立即移除弹窗（不需要交互则可以设置为 null）。
  final int? hoverDelayHide;

  /// 是否启用静止悬停，若为 true，当悬停在目标元素上时，移动时会重置 [hoverDelayShow] 时间，
  /// 只有当鼠标静止时，悬停一段时间后才会显示弹窗
  final bool? staticHover;

  /// 是否显示箭头
  final bool? showArrow;

  /// 是否禁止构建默认事件
  final bool? disabledEvent;

  @override
  State<ElPopup> createState() => ElPopoverState();
}

class ElPopoverState<T extends ElPopover> extends ElLinkPopupState<T> {
  @override
  Duration get animationDuration => widget.duration ?? const Duration(milliseconds: 100);

  int get hoverDelayShow => widget.hoverDelayShow ?? 0;

  int get hoverDelayHide => widget.hoverDelayHide ?? 0;

  bool get staticHover => widget.staticHover ?? false;

  bool get showArrow => widget.showArrow ?? false;

  /// 如果设置了延迟显示，那么默认弹出层对齐为浮动
  @override
  ElPopupAlignment get alignment =>
      widget.alignment ?? (widget.hoverDelayShow != null ? ElPopupAlignment.float : ElPopupAlignment.bottom);

  Timer? delayShowTimer;
  Timer? delayHideTimer;

  void cancelDelayShowTimer() {
    if (delayShowTimer != null) {
      delayShowTimer!.cancel();
      delayShowTimer = null;
    }
  }

  void cancelDelayHideTimer() {
    if (delayHideTimer != null) {
      delayHideTimer!.cancel();
      delayHideTimer = null;
    }
  }

  /// 延迟悬停显示弹窗
  void delayHoverShow() {
    cancelDelayHideTimer();
    if (hoverDelayShow <= 0) {
      modelValue = true;
    } else {
      delayShowTimer = ElAsyncUtil.setTimeout(() {
        modelValue = true;
      }, hoverDelayShow);
    }
  }

  /// 延迟隐藏
  void delayHoverHide() {
    cancelDelayShowTimer();
    if (hoverDelayHide <= 0) {
      modelValue = false;
    } else {
      delayHideTimer = ElAsyncUtil.setTimeout(() {
        modelValue = false;
      }, hoverDelayHide);
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelDelayShowTimer();
    cancelDelayHideTimer();
  }

  @override
  Widget buildPopup(BuildContext context) {
    return MouseRegion(
      onEnter: (e) {
        cancelDelayHideTimer();
      },
      onExit: (e) {
        delayHoverHide();
      },
      child: super.buildPopup(context),
    );
  }
}
