import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';

import 'package:flutter/material.dart';

Widget _builderSuffixIcon(ValueNotifier<bool> expanded) {
  return AnimatedRotation(
    duration: ElCollapseAnimation.defaultDuration,
    curve: ElCollapseAnimation.defaultCurve,
    turns: expanded.value ? 0.5 : 0,
    child: Icon(ElIcons.arrowDown, size: 14),
  );
}

/// 导航菜单：https://cn.element-plus.org/zh-CN/component/menu
class ElNavMenu<T> extends StatefulWidget {
  const ElNavMenu({
    super.key,
    required this.children,
    required this.router,
    this.showBorder = true,
    this.textStyle,
    this.iconSize = 22.0,
    this.builderSuffixIcon = _builderSuffixIcon,
    this.itemHeight = 56.0,
    this.iconGap = 8.0,
    this.nestGap = 20.0,
    required this.onChanged,
  });

  /// 菜单模型集合
  final List<ElMenuModel<T>> children;

  /// 监听的声明式路由对象
  final RouterConfig router;

  /// 是否显示边框
  final bool showBorder;

  /// 自定义文本默认样式（菜单颜色是根据背景色动态计算，无法自定义）
  final TextStyle? textStyle;

  /// 默认的图表尺寸
  final double iconSize;

  /// 自定义后缀展开图标
  final Widget Function(ValueNotifier<bool> expanded) builderSuffixIcon;

  /// 每个菜单的高度
  final double itemHeight;

  /// 图标与标题的间隔
  final double iconGap;

  /// 嵌套菜单距离上一层级的距离
  final double nestGap;

  /// 监听菜单选中变化
  final ValueChanged<ElMenuModel<T>> onChanged;

  @override
  State<ElNavMenu<T>> createState() => _ElNavMenuState<T>();
}

class _ElNavMenuState<T> extends State<ElNavMenu<T>> {
  late TextStyle textStyle;
  late ElGlobalAnimation bgAnimation;
  late ElGlobalAnimation textAnimation;
  late Color bgColor;

  /// 如果设置了 router，则将路由地址作为 key 进行比较
  String? get activeKey {
    return widget.router.routerDelegate.currentConfiguration.uri.path;
  }

  /// 过滤出激活的完整嵌套 key 列表
  List<String> get activeKeyList {
    if (activeKey == null) return const [];
    return ElNestModel.findKeyPath(widget.children, activeKey!).map((e) => e.key).toList();
  }

  List<Object>? _oldActiveRouteKeyList;

  /// 路由监听地址变化，此监听会对比新旧 key 列表，若不同则重建导航菜单
  void routerListener() {
    final list = activeKeyList;
    if (_oldActiveRouteKeyList == null || _oldActiveRouteKeyList!.neq(list)) {
      setState(() {
        _oldActiveRouteKeyList = list;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(routerListener);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(routerListener);
    super.dispose();
  }

  /// 递归构建菜单子项
  Widget buildMenuItem(ElMenuModel<T> menuItem, double gap, List<Object> activeKeyList) {
    late Widget result;
    final isActive = activeKeyList.contains(menuItem.key);

    Widget buildItem({Widget? suffixIcon}) => Builder(
      builder: (context) {
        final textColor = isActive ? context.elTheme.primary : context.elTheme.sideColor.elTextColor(context);

        return ElAnimatedColoredBox(
          color: bgColor.deepen(context.hasHover ? 8 : 0),
          child: SizedBox(
            width: double.infinity,
            height: widget.itemHeight,
            child: Padding(
              padding: .only(left: widget.nestGap + gap, right: widget.nestGap),
              child: ElAnimatedIconTheme(
                duration: textAnimation.$1,
                curve: textAnimation.$2,
                data: IconThemeData(size: widget.iconSize, color: textColor),
                child: Row(
                  mainAxisAlignment: .start,
                  children: [
                    if (menuItem.icon != null) menuItem.icon!,
                    if (menuItem.icon != null) Gap(widget.iconGap),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: textAnimation.$1,
                        curve: textAnimation.$2,
                        style: textStyle.copyWith(color: textColor),
                        child: Text(
                          menuItem.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                    ?suffixIcon,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (menuItem.children.isNotEmpty) {
      result = HookBuilder(
        builder: (context) {
          final expanded = useState(isActive);

          return Column(
            children: [
              ElEvent(
                style: ElEventStyle(
                  cursor: SystemMouseCursors.click,
                  onTap: (e) {
                    expanded.value = !expanded.value;
                  },
                ),
                child: buildItem(suffixIcon: widget.builderSuffixIcon(expanded)),
              ),
              ElCollapseAnimation(
                expanded.value,
                child: Column(
                  children: menuItem.children
                      .map((e) => buildMenuItem(e, gap + widget.nestGap, activeKeyList))
                      .toList(),
                ),
              ),
            ],
          );
        },
      );
    } else {
      result = ElEvent(
        style: ElEventStyle(
          cursor: SystemMouseCursors.click,
          onTap: (e) {
            widget.onChanged(menuItem);
          },
        ),
        child: buildItem(),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final activeKeyList = this.activeKeyList;
    textStyle = context.elRegularTextStyle.copyWith(fontWeight: .w500).merge(widget.textStyle);
    bgAnimation = el.globalAnimation(50.ms, Curves.easeOut);
    textAnimation = el.globalAnimation(150.ms, Curves.easeInOut);
    bgColor = context.elTheme.sideColor;

    Widget result = ElAnimatedColoredBox(
      color: bgColor,
      child: ElDefaultColor(
        bgColor,
        child: ElScroll(children: widget.children.map((e) => buildMenuItem(e, 0.0, activeKeyList)).toList()),
      ),
    );

    if (widget.showBorder) {
      result = ElAnimatedDecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: context.elTheme.borderColor)),
        ),
        child: result,
      );
    }

    return result;
  }
}
