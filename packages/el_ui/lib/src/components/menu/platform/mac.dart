part of '../index.dart';

/// Mac 平台下的菜单
class _MacMenu extends ElRawMenu {
  const _MacMenu({required super.menuList});

  @override
  State<_MacMenu> createState() => _MacMenuState();
}

class _MacMenuState extends ElRawMenuState<_MacMenu> {
  @override
  Widget buildWrapper(BuildContext context, Widget child) {
    return Container(
      padding: .all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        border: Border.all(width: 0.5, color: const .fromRGBO(155, 155, 155, 1)),
        color: ElBrightness.isDark(context) ? const .fromRGBO(43, 43, 43, 1) : const .fromRGBO(237, 237, 237, 1),
        boxShadow: ElFlutterUtil.shadow(elevation: 6),
      ),
      child: child,
    );
  }

  @override
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

  @override
  Widget buildDivider(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 8, vertical: 2),
      child: ElDividerTheme(
        data: ElDividerThemeData(thickness: 1, size: 8, color: const .fromRGBO(213, 213, 213, 1.0)),
        child: ElDivider(),
      ),
    );
  }

  @override
  Widget? buildTrailing(BuildContext context, ElMenuEntry menu) {
    var result = super.buildTrailing(context, menu);
    if (result == null && menu.children != null) {
      result = Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: context.hasHover ? context.elTheme.primary.elTextColor(context) : null,
      );
    }
    return result;
  }
}
