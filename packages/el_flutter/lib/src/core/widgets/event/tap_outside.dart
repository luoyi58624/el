import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class ElTapOutSide extends StatefulWidget {
  /// 点击外部事件小部件，这只是对 [TapRegion] 进行一个浅包装
  const ElTapOutSide({
    super.key,
    required this.child,
    this.behavior = HitTestBehavior.deferToChild,
    this.enabled = true,
    this.groupId,
    this.onPointerDown,
    this.onPointerUp,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onCancel,
  });

  final Widget child;

  /// 命中行为
  final HitTestBehavior behavior;

  /// 是否启用
  final bool enabled;

  /// 点击外部分组 id，拥有相同分组 id 的元素不会视为外部元素
  final Object? groupId;

  /// 点击外部指针落下事件
  final TapRegionCallback? onPointerDown;

  /// 点击外部指针抬起事件
  final TapRegionUpCallback? onPointerUp;

  /// 主指针点击外部落下事件
  final TapRegionCallback? onTapDown;

  /// 主指针点击外部抬起事件
  final TapRegionUpCallback? onTapUp;

  /// 点击外部事件，如果指针在抬起时发生移动，则触发 [onCancel]
  final VoidCallback? onTap;

  /// 取消事件
  final VoidCallback? onCancel;

  @override
  State<ElTapOutSide> createState() => _ElTapOutSideState();
}

class _ElTapOutSideState extends State<ElTapOutSide> {
  Offset? tapDownPosition;

  void onPointerDown(PointerDownEvent e) {
    widget.onPointerDown?.call(e);
    if (e.buttons == kPrimaryButton) {
      widget.onTapDown?.call(e);
      tapDownPosition = e.position;
    }
  }

  void onPointerUp(PointerUpEvent e) {
    widget.onPointerUp?.call(e);
    if (tapDownPosition != null) {
      widget.onTapUp?.call(e);
      if (e.position == tapDownPosition) {
        widget.onTap?.call();
      } else {
        widget.onCancel?.call();
      }
      tapDownPosition = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      behavior: widget.behavior,
      enabled: widget.enabled,
      groupId: widget.groupId,
      onTapOutside: onPointerDown,
      onTapUpOutside: onPointerUp,
      child: widget.child,
    );
  }
}
