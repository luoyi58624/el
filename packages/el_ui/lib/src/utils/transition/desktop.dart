import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

/// 桌面端组件切换动画
class ElDesktopTransition extends StatefulWidget {
  const ElDesktopTransition({super.key, this.duration = const Duration(milliseconds: 300), required this.child});

  final Duration duration;
  final Widget child;

  @override
  State<ElDesktopTransition> createState() => _ElDesktopTransitionState();
}

class _ElDesktopTransitionState extends State<ElDesktopTransition> {
  Widget? currentChild;
  bool? isLeave;
  bool? isEnter;

  late final enterController = AnimationController(vsync: vsync, value: 1.0, duration: widget.duration);

  late final leaveController = AnimationController(vsync: vsync, duration: widget.duration);

  late final enterCurve = CurvedAnimation(parent: enterController, curve: Curves.ease);

  late final leaveCurve = CurvedAnimation(parent: leaveController, curve: Curves.ease);

  @override
  void initState() {
    super.initState();
    currentChild = widget.child;
    leaveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            currentChild = widget.child;
            isLeave = false;
            isEnter = true;
            enterController.forward(from: 0).then((v) {
              isLeave = null;
              isEnter = null;
            });
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(ElDesktopTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      enterController.duration = widget.duration;
      leaveController.duration = widget.duration;
    }

    if (Widget.canUpdate(currentChild!, widget.child) == false) {
      if (isLeave == null) {
        isLeave = true;
        leaveController.forward(from: 0);
      } else if (isEnter != null) {
        enterController.stop();
        currentChild = widget.child;
        enterController.forward(from: 0).then((v) {
          isLeave = null;
          isEnter = null;
        });
      }
    } else {
      if (isLeave == null) {
        currentChild = widget.child;
      }
    }
  }

  @override
  void dispose() {
    enterCurve.dispose();
    leaveCurve.dispose();
    enterController.dispose();
    leaveController.dispose();
    currentChild = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> fade;
    Animation<Offset> offset;

    if (Widget.canUpdate(currentChild!, widget.child) && isLeave != true) {
      fade = Tween(begin: 0.0, end: 1.0).animate(enterCurve);
      offset = Tween(begin: Offset(-50, 0.0), end: Offset.zero).animate(enterCurve);
    } else {
      fade = Tween(begin: 1.0, end: 0.0).animate(leaveCurve);
      offset = Tween(begin: Offset.zero, end: Offset(50, 0.0)).animate(leaveCurve);
    }
    return FadeTransition(
      opacity: fade,
      child: ElOffsetTransition(offset: offset, child: currentChild),
    );
  }
}
