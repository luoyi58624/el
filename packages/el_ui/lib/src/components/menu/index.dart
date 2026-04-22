import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'menu_entry.dart';

part 'menu_item.dart';

part 'raw_menu.dart';

part 'platform/mac.dart';

class ElMenu extends StatelessWidget {
  /// Element UI 菜单列表小部件，默认样式为根据平台渲染不同外观
  const ElMenu({super.key, required this.menuList});

  final List<ElMenuEntry> menuList;

  @override
  Widget build(BuildContext context) {
    // if (ElPlatform.isDesktop) {
    //   return _MacMenu(menuList: menuList);
    // } else {
    //   return _MacMenu(
    //     menuList: menuList,
    //   );
    // }

    return Material(elevation: 2, child: Column(children: []));
  }
}
