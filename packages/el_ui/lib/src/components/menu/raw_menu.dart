part of 'index.dart';

abstract class ElRawMenu extends StatefulWidget {
  const ElRawMenu({super.key, required this.menuList});

  final List<ElMenuEntry> menuList;

  @override
  State<ElRawMenu> createState();
}

abstract class ElRawMenuState<T extends ElRawMenu> extends State<T> {
  /// 菜单默认最小宽度
  double get minWidth => 150.0;

  /// 构建右键菜单外观
  Widget buildWrapper(BuildContext context, Widget child);

  /// 构建右键菜单每个子项
  Widget buildItem(BuildContext context, ElMenuEntry menu);

  /// 构建右键菜单分割线
  Widget buildDivider(BuildContext context);

  /// 构建菜单尾部小部件（默认实现）
  Widget? buildTrailing(BuildContext context, ElMenuEntry menu) {
    return menu.trailing;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
