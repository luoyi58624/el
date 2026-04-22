import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

extension ElSelectionExtension on BuildContext {
  /// 小部件是否被选中
  bool get hasSelected => _SelectionListenerData.of(this);
}

class ElSelectionListener extends StatefulWidget {
  /// 选中监听小部件
  const ElSelectionListener({super.key, required this.child});

  final Widget child;

  @override
  State<ElSelectionListener> createState() => _ElSelectionListenerState();
}

class _ElSelectionListenerState extends State<ElSelectionListener> {
  final hasSelected = Obs(false);

  @override
  Widget build(BuildContext context) {
    final rect = ElSelectionArea.getRect(context);
    nextTick(() {
      final childRect = (ElFlutterUtil.getPosition(context) & context.size!);

      hasSelected.value = childRect.overlaps(rect);
    });
    // i(rect);
    return ObsBuilder(
      builder: (context) {
        return _SelectionListenerData(hasSelected.value, child: widget.child);
      },
    );
  }
}

class _SelectionListenerData extends InheritedWidget {
  const _SelectionListenerData(this.hasSelected, {required super.child});

  final bool hasSelected;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SelectionListenerData>()?.hasSelected ?? false;

  @override
  bool updateShouldNotify(_SelectionListenerData oldWidget) => hasSelected != oldWidget.hasSelected;
}
