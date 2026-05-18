import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Element UI 主窗口
class ElBody extends StatefulWidget {
  const ElBody({super.key, this.child, this.minWidth = 10, this.minHeight = 10.0, this.bgColor})
    : assert(minWidth >= 0.0),
      assert(minHeight >= 0.0);

  final Widget? child;

  /// 主窗口最小宽度
  final double minWidth;

  /// 主窗口最小高度
  final double minHeight;

  /// 主窗口背景颜色
  final Color? bgColor;

  @override
  State<ElBody> createState() => _ElBodyState();
}

class _ElBodyState extends State<ElBody> {
  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}
