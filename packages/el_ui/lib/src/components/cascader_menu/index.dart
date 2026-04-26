import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';

import 'package:flutter/material.dart';

class ElCascaderMenu extends ElModelValue {
  /// Element UI 菜单小部件
  const ElCascaderMenu(super.modelValue, {super.key, required this.menuList, super.onChanged});

  final List<ElMenuEntry> menuList;

  @override
  State<ElCascaderMenu> createState() => _ElCascaderMenuState();
}

class _ElCascaderMenuState extends State<ElCascaderMenu> with ElModelValueMixin {
  /// 菜单默认最小宽度
  double get minWidth => 100.0;

  /// 构建菜单外观
  Widget buildWrapper(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: context.elTheme.cardColor,
        border: context.elBorder(),
        borderRadius: el.config.borderRadius,
      ),
      child: child,
    );
  }

  /// 构建菜单每个子项
  Widget buildItem(BuildContext context, ElMenuEntry menu) {
    final trailing = buildTrailing(context, menu);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.hasHover ? context.elTheme.primary : Colors.transparent,
        borderRadius: el.config.borderRadius,
      ),
      child: Padding(
        padding: .symmetric(horizontal: 8, vertical: 2),
        child: Row(
          crossAxisAlignment: .center,
          children: [
            if (menu.title != null)
              ElRichText(
                menu.title,
                style: TextStyle(
                  fontSize: 13,
                  color: context.hasHover ? context.elTheme.primary.elTextColor(context) : null,
                ),
              ),
            if (trailing != null) Spacer(),
            if (trailing != null) Gap(24),
            ?trailing,
          ],
        ),
      ),
    );
  }

  /// 构建菜单分割线
  Widget buildDivider(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 8, vertical: 2),
      child: ElDividerTheme(
        data: ElDividerThemeData(thickness: 1, size: 8, color: const .fromRGBO(213, 213, 213, 1.0)),
        child: ElDivider(),
      ),
    );
  }

  /// 构建菜单尾部小部件（默认实现）
  Widget? buildTrailing(BuildContext context, ElMenuEntry menu) {
    return menu.trailing;
  }

  @override
  Widget obsBuild(BuildContext context) {
    return Column(crossAxisAlignment: .start, children: []);
  }
}
