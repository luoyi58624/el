import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

/// 右键菜单构建器
typedef ElContextMenuBuilder =
    Widget Function(
      Key? key,
      Object menuId,
      Offset position,
      List<ElMenuEntry> menuList,
      ElRawContextMenuState? prevMenu,
    );
