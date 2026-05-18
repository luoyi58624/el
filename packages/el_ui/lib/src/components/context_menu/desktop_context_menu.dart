part of 'index.dart';

/// 适用于桌面端的右键菜单
class ElDesktopContextMenu extends ElRawContextMenu {
  const ElDesktopContextMenu({
    super.key,
    required super.menuId,
    required super.position,
    required super.menuList,
    super.prevMenu,
  });

  @override
  State<ElDesktopContextMenu> createState() => _ElDesktopContextMenuState();
}

class _ElDesktopContextMenuState extends ElRawContextMenuState<ElDesktopContextMenu> {
  static const _placeholderBox = SizedBox(width: 10);

  @override
  EdgeInsets get padding => .all(6);

  @override
  Color get bgColor => ElBrightness.isDark(context) ? .fromRGBO(46, 46, 46, 1) : .fromRGBO(237, 237, 237, 1);

  @override
  Color get dividerColor =>
      ElBrightness.isDark(context) ? const .fromRGBO(213, 213, 213, 1.0) : const .fromRGBO(213, 213, 213, 1.0);

  /// 构建菜单外观
  @override
  Widget buildWrapper(BuildContext context, Widget child) {
    return ElScrollbar(
      controller: scrollController,
      thickness: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: Border.all(width: 0.5, color: const .fromRGBO(155, 155, 155, 1)),
          color: bgColor,
          boxShadow: ElFlutterUtil.shadow(elevation: 4),
        ),
        child: child,
      ),
    );
  }

  /// 构建菜单子项
  @override
  Widget buildItem(BuildContext context, ElMenuEntry menu, int index) {
    final leading = buildLeading(context, menu, index);
    final trailing = buildTrailing(context, menu, index);
    final isActive = Focus.of(context).hasFocus || (expandedIndex == index && context.hasHover);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive
            ? activeColor
            : expandedIndex == index
            ? bgColor.deepen(10)
            : Colors.transparent,
        borderRadius: el.config.borderRadius,
      ),
      child: SizedBox(
        height: 24,
        child: Padding(
          padding: const .symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: .center,
            children: [
              ?leading,
              if (leading != null) Gap(6),
              if (menu.title != null)
                ElRichText(menu.title, style: TextStyle(fontSize: 13, color: isActive ? activeTextColor : textColor)),
              if (trailing != null) Spacer(),
              if (trailing != null) Gap(24),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  /// 构建前缀
  @override
  Widget? buildLeading(BuildContext context, ElMenuEntry menu, int index) {
    if (hasLeading == false) return null;

    return menu.leading ?? _placeholderBox;
  }

  /// 构建后缀
  @override
  Widget? buildTrailing(BuildContext context, ElMenuEntry menu, int index) {
    if (hasTrailing == false) return null;
    final isActive = Focus.of(context).hasFocus || (expandedIndex == index && context.hasHover);
    if (menu.trailing != null) {
      return menu.trailing;
    } else if (menu.children != null) {
      return Icon(Icons.arrow_forward_ios, size: 12, color: isActive ? activeTextColor : textColor);
    } else {
      return _placeholderBox;
    }
  }
}
