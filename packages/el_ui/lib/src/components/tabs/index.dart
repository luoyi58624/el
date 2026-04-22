import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'tab.dart';

part 'theme.dart';

part 'index.g.dart';

const _autoScrollerVelocityScalar = 100.0;

/// Element UI 标签导航，此组件适用于桌面端，移动端建议使用官方提供的 [TabBar] 小部件
class ElTabs extends ElModelValue {
  const ElTabs(super.modelValue, {super.key, required this.tabs, this.controller, this.onDragChanged, super.onChanged});

  /// 子标签小部件集合
  final List<ElTab> tabs;

  /// 滚动控制器
  final ScrollController? controller;

  /// 拖拽触发的 change 事件，传递新的 tabs 集合
  final void Function(List<ElTab> tabs)? onDragChanged;

  static ElTabsState of(BuildContext context) {
    final _ElTabsInheritedWidget? result = context.dependOnInheritedWidgetOfExactType<_ElTabsInheritedWidget>();
    assert(result != null, 'No _ElTabsInheritedWidget found in context');
    return result!.state;
  }

  @override
  State<ElTabs> createState() => ElTabsState();
}

class ElTabsState extends State<ElTabs> with ElModelValueMixin<ElTabs, dynamic> {
  late ScrollController scrollController;
  late ElTabsThemeData themeData;
  late Axis axis;
  PointerDownEvent? pointerDownEvent;

  void onChanged(int index) {
    modelValue = index;
  }

  void _setScrollController() {
    scrollController = widget.controller ?? el.config.scrollControllerBuilder();
  }

  @override
  void initState() {
    super.initState();
    _setScrollController();
  }

  @override
  void didUpdateWidget(covariant ElTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) _setScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) scrollController.dispose();
  }

  Widget builderScrollbar(BuildContext context, ScrollController controller, Widget child) => ElScrollbar(
    showMode: ElScrollbarShowMode.onlyScrolling,
    controller: controller,
    thickness: 3,
    crossAxisMargin: 0.0,
    ignorePointer: true,
    ignoreTrackPointer: true,
    timeToFade: const Duration(milliseconds: 200),
    child: child,
  );

  Widget buildDesktopTabs() {
    final itemGap = themeData.itemGap ?? 0.0;
    final enabledDrag = themeData.enabledDrag ?? false;

    // 需要插入 Overlay 实例，防止拖拽的代理标签出现 context 作用域问题
    Widget result = Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => ReorderableList(
            controller: scrollController,
            scrollDirection: axis,
            padding: themeData.padding,
            autoScrollerVelocityScalar: themeData.autoScrollerVelocityScalar ?? _autoScrollerVelocityScalar,
            proxyDecorator: themeData.dragProxyDecorator ?? (child, index, animation) => child,
            onReorder: (int oldIndex, int newIndex) {
              if (widget.onDragChanged != null) {
                final tempList = List<ElTab>.from(widget.tabs);
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = tempList.removeAt(oldIndex);
                tempList.insert(newIndex, item);
                widget.onDragChanged!(tempList);
              }
            },
            onReorderStart: (e) {
              ElCursorUtil.insertGlobalCursor();
            },
            onReorderEnd: (e) {
              ElCursorUtil.removeGlobalCursor();
            },
            itemCount: widget.tabs.length,
            itemBuilder: (context, index) {
              final child = widget.tabs[index];
              assert(child.key is ValueKey<int>, 'ElTab 必须设置 key，而且必须是 ValueKey<int> 类型，请检查是否正确设置它们');
              final key = child.key as ValueKey<int>;
              Widget result = child;
              if (enabledDrag) {
                if (itemGap > 0.0) {
                  result = Padding(
                    padding: .only(left: index == 0.0 ? 0.0 : itemGap),
                    child: result,
                  );
                }

                final DeviceGestureSettings? gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
                final SliverReorderableListState? list = SliverReorderableList.maybeOf(context);

                return ElEvent(
                  key: key,
                  style: ElEventStyle(
                    onPointerDown: (e) {
                      onChanged(key.value);
                      pointerDownEvent = e;
                      list?.startItemDragReorder(
                        index: index,
                        event: pointerDownEvent!,
                        recognizer: ElMultiDragGestureRecognizer(
                          triggerOffset: 10,
                          delay: const Duration(milliseconds: 250),
                        )..gestureSettings = gestureSettings,
                      );
                    },
                  ),
                  child: result,
                );
              }
              return Builder(key: key, builder: (context) => result);
            },
          ).elHorizontalScroll,
        ),
      ],
    );
    result = builderScrollbar(context, scrollController, result);
    return result;
  }

  @override
  Widget obsBuilder(BuildContext context) {
    return Container(
      width: axis == Axis.vertical ? themeData.height : null,
      height: axis == Axis.horizontal ? themeData.height : null,
      color: themeData.bgColor,
      child: buildDesktopTabs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    themeData = ElTabsTheme.of(context);
    axis = axisDirectionToAxis(themeData.direction!);
    return _ElTabsInheritedWidget(this, child: super.build(context)).noScrollbarBehavior(context);
  }
}

class _ElTabsInheritedWidget extends InheritedWidget {
  const _ElTabsInheritedWidget(this.state, {required super.child});

  final ElTabsState state;

  @override
  bool updateShouldNotify(_ElTabsInheritedWidget oldWidget) {
    return true;
  }
}
