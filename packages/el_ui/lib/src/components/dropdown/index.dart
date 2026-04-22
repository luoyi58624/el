import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'transition.dart';

Widget _transitionBuilder(BuildContext context, Widget child) {
  final state = ElPopup.of(context) as ElDropdownState;

  return _Transition(
    controller: state.animationController,
    axisDirection: state.popupAlignment!.toAxisDirection.flipped,
    child: child,
  );
}

Widget _builder(BuildContext context, ElPopupState state) {
  final $state = state as ElDropdownState;

  final child = $state.widget.child;

  // 受控模式不需要构建默认的事件
  if ($state.widget.show != null) return child;

  return ElTapOutSide(
    groupId: $state.groupId,
    onTapDown: (e) => $state.modelValue = false,
    child: ElEvent(
      style: ElEventStyle(onTap: (e) => $state.modelValue = !($state.modelValue ?? false)),
      child: child,
    ),
  );
}

/// 下拉菜单
class ElDropdown extends ElLinkPopup {
  const ElDropdown({
    super.key,
    super.show,
    super.alignment,
    super.spacing = 4,
    required super.overlayBuilder,
    required super.child,
  }) : super(keepAlive: true, transitionBuilder: _transitionBuilder, builder: _builder);

  static Duration defaultDuration = Duration(milliseconds: 300);

  @override
  State<ElPopup> createState() => ElDropdownState();
}

class ElDropdownState extends ElLinkPopupState<ElDropdown> {
  @override
  Duration get animationDuration => widget.duration ?? ElDropdown.defaultDuration;
}
