import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

class ElSelectionArea extends StatefulWidget {
  /// 拖拽范围选中，它适用于选中小部件，你还需要搭配 [ElSelectionListener] 来监听选中
  const ElSelectionArea({
    super.key,
    required this.child,
    this.selectionBgColor = Colors.white24,
    this.selectionBorderColor = Colors.white60,
  });

  final Widget child;

  /// 选中区域背景颜色
  final Color selectionBgColor;

  /// 选中区域边框颜色
  final Color selectionBorderColor;

  /// 获取选中范围
  static Rect getRect(BuildContext context) => _SelectionAreaData.of(context);

  @override
  State<ElSelectionArea> createState() => _ElSelectionAreaState();
}

class _ElSelectionAreaState extends State<ElSelectionArea> {
  final size = Obs(Size.zero);
  final position = Obs(Offset.zero);
  final selectionRect = Obs(Rect.zero);

  Offset? pointDownPosition;
  OverlayEntry? overlayEntry;

  void insertOverlay(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(
        builder: (context) => ObsBuilder(
          builder: (context) {
            return Positioned(
              left: position.value.dx,
              top: position.value.dy,
              child: Container(
                width: size.value.width,
                height: size.value.height,
                decoration: BoxDecoration(
                  color: widget.selectionBgColor,
                  border: Border.all(color: widget.selectionBorderColor),
                ),
              ),
            );
          },
        ),
      );
      Overlay.of(context).insert(overlayEntry!);
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      size.value = Size.zero;
      position.value = Offset.zero;
      selectionRect.value = Rect.zero;
      overlayEntry!.remove();
      overlayEntry!.dispose();
      overlayEntry = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return ElEvent(
      style: ElEventStyle(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          pointDownPosition = e.position;
          position.value = e.position;
          insertOverlay(context);
          ElCursorUtil.insertGlobalCursor();
        },
        onPointerMove: (e) {
          final delta = e.position - pointDownPosition!;
          size.value = Size(delta.dx.abs(), delta.dy.abs());
          double dx = pointDownPosition!.dx;
          double dy = pointDownPosition!.dy;
          if (delta.dx < 0) dx += delta.dx;
          if (delta.dy < 0) dy += delta.dy;
          position.value = Offset(dx, dy);
          selectionRect.value = position.value & size.value;
        },
        onPointerUp: (e) {
          removeOverlay();
          ElCursorUtil.removeGlobalCursor();
        },
      ),
      child: ObsBuilder(
        builder: (context) {
          return _SelectionAreaData(selectionRect.value, child: widget.child);
        },
      ),
    );
  }
}

class _SelectionAreaData extends InheritedWidget {
  const _SelectionAreaData(this.selectionRect, {required super.child});

  final Rect selectionRect;

  static Rect of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SelectionAreaData>()?.selectionRect ?? Rect.zero;

  @override
  bool updateShouldNotify(_SelectionAreaData oldWidget) => selectionRect != oldWidget.selectionRect;
}
