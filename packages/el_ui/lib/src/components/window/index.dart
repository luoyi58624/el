import 'dart:async';
import 'dart:math';

import 'package:el_flutter/ext.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'package:el_ui/el_ui.dart';

part 'controller.dart';

part 'model.dart';

part 'render.dart';

part 'resizer.dart';

part 'windows.dart';

part 'platform_button.dart';

part 'index.g.dart';

/// 在 Flutter 应用层模拟多窗口，允许你在页面上创建、管理多个分离的窗口。
///
/// 注意：创建它的初衷并非对标客户端级别的多窗口，它更多的是对 Dialog、Drawer 等简单浮层的补充。
class ElWindow extends StatefulWidget {
  const ElWindow({super.key, required this.child, required this.controller});

  final Widget child;

  /// 窗口控制器
  final ElWindowController controller;

  /// 窗口子组件可以通过此方法获取当前窗口对象
  static ElWindowModel of(BuildContext context) => _WindowModelWidget.of(context);

  @override
  State<ElWindow> createState() => _ElWindowState();
}

class _ElWindowState extends State<ElWindow> {
  final GlobalKey _windowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_notify);
    widget.controller.context = context;
    nextTick(() {
      widget.controller._renderObject = _windowKey.currentContext!.findRenderObject() as _WindowRender;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_notify);
  }

  void _notify() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _WindowWidget(
      key: _windowKey,
      child: widget.child,
      children:
          [
                ...widget.controller.windows.values,
                ...widget.controller.groupWindows.values.toList().expand((e) => e.values),
              ]
              .map(
                (model) => _WindowItem(
                  model: model,
                  child: ElListener(
                    style: ElListenerStyle(
                      onPointerDown: (e) {
                        widget.controller.moveTop(model.id, model.groupKey);
                      },
                    ),
                    child: _WindowModelWidget(
                      model,
                      child: RepaintBoundary(child: model.child ?? ElEmptyWidget.instance),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
