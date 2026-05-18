import 'dart:async';
import 'dart:math';

import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'raw_context_menu.dart';

part 'service.dart';

part 'desktop_context_menu.dart';

part 'theme.dart';

part 'index.g.dart';

class ElContextMenu extends HookWidget {
  /// 给目标小部件绑定右键菜单（桌面端右键、移动端长按）
  const ElContextMenu({
    super.key,
    required this.child,
    required this.menuList,
    this.groupId,
    this.autofocus,
    this.onChanged,
  });

  final Widget child;

  /// 菜单列表
  final List<ElMenuEntry> menuList;

  /// 分配自定义的点击外部区域的分组 id，它由 [TapRegion] 驱动，
  /// 如果你希望点击页面上的某个元素不要关闭右键菜单，请传递此属性
  final Object? groupId;

  /// 打开右键菜单时是否聚焦后代，如果后代不存在 [ElEvent]，那么将无效
  final bool? autofocus;

  /// 监听选中的菜单
  final ValueChanged<ElMenuEntry?>? onChanged;

  void showContextMenu(BuildContext context, Offset position) async {
    FocusNode? parentNode;
    // if (autofocus == true) {
    //   final result = ElEvent.getChildFocusEvent(context);
    //   if (result != null) {
    //     parentNode = result.focusNode;
    //   }
    // }

    final result = await el.contextMenu.show(
      context,
      hashCode,
      position + Offset(1.0, 0.0),
      menuList,
      parentNode: parentNode,
      groupId: groupId,
    );

    onChanged?.call(result);

    // if (autofocus == true && parentNode != null) {
    //   parentNode.requestFocus();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final position = useRef(Offset.zero);
    final style = ElEventStyle(
      behavior: HitTestBehavior.opaque,
      ignoreStatus: true,
      onPointerDown: (e) {
        position.value = e.position;
      },
    );

    if (ElPlatform.isDesktop) {
      style.onSecondaryTapDown = (e) => showContextMenu(context, e.position);
    } else {
      style.onLongPress = (e) {
        showContextMenu(context, position.value);
      };
    }

    Widget result = ElEvent(style: style, child: child);

    return result;
  }
}
