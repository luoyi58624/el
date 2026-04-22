import 'package:flutter/material.dart';

import 'package:el_flutter/el_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'route.dart';

part 'service.dart';

part 'transition.dart';

Widget _transitionBuilder(BuildContext context, Widget child) {
  final $state = ElPopup.of(context) as ElDialogState;
  return _Transition(
    onModalTap: () => $state.modelValue = false,
    controller: $state.animationController,
    modalColor: $state.widget.modalColor,
    ignoreModalPointer: $state.widget.ignoreModalPointer,
    child: child,
  );
}

Widget _builder(BuildContext context, ElPopupState state) {
  final $state = state as ElDialogState;

  // 受控模式不需要构建默认的事件
  if ($state.widget.show != null) return $state.child;

  return Semantics(
    onTap: () => $state.toggle(),
    button: true,
    child: ElEvent(
      style: ElEventStyle(ignoreStatus: true, onTap: (e) => $state.toggle()),
      child: $state.child,
    ),
  );
}

/// Element UI 对话框组件。
///
/// 注意：组件弹窗需要在每个路由页面设置 [ElOverlay]，否则弹窗会覆盖新跳转的页面。
class ElDialog extends ElPopup {
  const ElDialog({
    super.key,
    super.show,
    super.duration,
    super.keepAlive = true,
    required super.overlayBuilder,
    this.child,
    this.size,
    this.modalColor,
    this.ignoreModalPointer = false,
  }) : super(preventBack: true, transitionBuilder: _transitionBuilder, builder: _builder);

  final Widget? child;

  /// 抽屉尺寸，如果取值范围是：0.0 ~ 1.0，则按百分比决定抽屉尺寸，否则以正常像素决定抽屉尺寸
  final double? size;

  /// 模态框背景颜色
  final Color? modalColor;

  /// 忽略模态框指针事件
  final bool ignoreModalPointer;

  static Duration defaultDuration = const Duration(milliseconds: 250);

  @override
  State<ElDialog> createState() => ElDialogState();
}

class ElDialogState extends ElPopupState<ElDialog> {
  @override
  Duration get animationDuration => widget.duration ?? ElDialog.defaultDuration;

  Widget get child => widget.child ?? ElEmptyWidget.instance;

  @override
  Widget buildOverlay(BuildContext context) {
    return widget.transitionBuilder(context, widget.overlayBuilder(context));
  }
}
