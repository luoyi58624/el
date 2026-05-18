part of 'index.dart';

const _groupId = 'el_menu_bar';

class ElMenuBarItem extends StatefulWidget {
  /// 菜单子项小部件
  const ElMenuBarItem({super.key, required this.title, required this.menuList});

  final String title;
  final List<ElMenuEntry> menuList;

  @override
  State<ElMenuBarItem> createState() => ElMenuBarItemState();
}

class ElMenuBarItemState extends State<ElMenuBarItem> {
  late final FocusNode focusNode;

  late FocusScopeNode focusScopeNode;

  bool hasFocus = false;

  /// 展示菜单面板在 Y 轴的偏移位置
  double get menuOffset => 0.0;

  /// 构建菜单栏子项外观，你可以覆写此方法自定义主题
  Widget buildWrapper(BuildContext context) {
    late Color color;

    if (hasFocus) {
      color = context.elTheme.primary;
    } else {
      if (focusScopeNode.hasFocus == false && context.hasHover) {
        color = context.elDefaultColor.deepen(5);
      } else {
        color = context.elDefaultColor;
      }
    }
    return AnimatedContainer(
      duration: el.globalAnimation(200.ms).$1,
      curve: Curves.easeOut,
      padding: .symmetric(vertical: 3, horizontal: 10),
      decoration: BoxDecoration(color: color),
      child: ElRichText(
        widget.title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color.elTextColor(context)),
      ),
    );
  }

  void _showMenu() async {
    final result = await el.contextMenu.show(
      context,
      hashCode,
      ElFlutterUtil.getPosition(context) + Offset(0, context.size!.height + menuOffset),
      widget.menuList,
      parentNode: focusNode,
      groupId: _groupId,
      isMenuAnchor: true,
    );
    if (result != null) focusScopeNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        if (el.contextMenu.menuId != hashCode) _showMenu();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    focusScopeNode = FocusScope.of(context);
    return ElTapOutSide(
      groupId: _groupId,
      onPointerDown: (e) {
        if (hasFocus) focusScopeNode.unfocus();
      },
      child: Focus(
        focusNode: focusNode,
        child: ElEvent(
          style: ElEventStyle(
            onPointerDown: (e) {
              if (hasFocus) {
                focusScopeNode.unfocus();
                el.contextMenu.remove(hashCode);
              } else {
                focusNode.requestFocus();
              }
            },
            onSecondaryTapDown: (e) {
              focusNode.requestFocus();
            },
            onEnter: (e) {
              if (focusScopeNode.hasFocus) focusNode.requestFocus();
            },
          ),
          child: Builder(
            builder: (context) {
              hasFocus = Focus.of(context).hasFocus;
              return buildWrapper(context);
            },
          ),
        ),
      ),
    );
  }
}
