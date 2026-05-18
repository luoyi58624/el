import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'tab.dart';

part 'theme.dart';

part 'index.g.dart';

const _autoScrollerVelocityScalar = 100.0;

/// Element UI 标签导航，此组件适用于桌面端，移动端建议使用官方提供的 [TabBar] 小部件
class ElTabs extends ElModelValue<dynamic> {
  ElTabs({
    super.key,
    super.value,
    super.modelValue,
    required this.tabs,
    this.controller,
    this.onDragChanged,
    super.onChanged,
  });

  /// 子标签小部件集合
  final List<ElTab> tabs;

  /// 滚动控制器
  final ScrollController? controller;

  /// 拖拽触发的 change 事件，传递新的 tabs 集合
  final void Function(List<ElTab> tabs)? onDragChanged;

  static ElTabsScope of(BuildContext context) {
    final _ElTabsInheritedWidget? result = context.dependOnInheritedWidgetOfExactType<_ElTabsInheritedWidget>();
    assert(result != null, 'No _ElTabsInheritedWidget found in context');
    return result!.scope;
  }

  @override
  Widget obsBuilder(BuildContext context) {
    final scope = ElTabs.of(context);
    return Container(
      width: scope.axis == Axis.vertical ? scope.themeData.height : null,
      height: scope.axis == Axis.horizontal ? scope.themeData.height : null,
      color: scope.themeData.bgColor,
      child: buildDesktopTabs(context, scope),
    );
  }

  Widget buildDesktopTabs(BuildContext context, ElTabsScope scope) {
    final themeData = scope.themeData;
    final axis = scope.axis;
    final itemGap = themeData.itemGap ?? 0.0;
    final enabledDrag = themeData.enabledDrag ?? false;
    final effectiveController = scope.scrollController;

    // 需要插入 Overlay 实例，防止拖拽的代理标签出现 context 作用域问题
    Widget result = Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => ReorderableList(
            controller: effectiveController,
            scrollDirection: axis,
            padding: themeData.padding,
            autoScrollerVelocityScalar: themeData.autoScrollerVelocityScalar ?? _autoScrollerVelocityScalar,
            proxyDecorator: themeData.dragProxyDecorator ?? (child, index, animation) => child,
            onReorder: (int oldIndex, int newIndex) {
              if (onDragChanged != null) {
                final tempList = List<ElTab>.from(tabs);
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = tempList.removeAt(oldIndex);
                tempList.insert(newIndex, item);
                onDragChanged!(tempList);
              }
            },
            onReorderStart: (e) {
              ElCursorUtil.insertGlobalCursor();
            },
            onReorderEnd: (e) {
              ElCursorUtil.removeGlobalCursor();
            },
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              final child = tabs[index];
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
                      $obs.value = key.value;
                      list?.startItemDragReorder(
                        index: index,
                        event: e,
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
    result = builderScrollbar(context, effectiveController, result);
    return result;
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

  @override
  Widget build(BuildContext context) {
    final themeData = ElTabsTheme.of(context);
    final axis = axisDirectionToAxis(themeData.direction!);
    final effectiveController = controller ?? useMemoized(() => el.config.scrollControllerBuilder());

    final scope = ElTabsScope(
      obs: $obs,
      scrollController: effectiveController!,
      themeData: themeData,
      axis: axis,
      widget: this,
    );

    useEffect(() {
      return () {
        if (controller == null) effectiveController.dispose();
      };
    }, []);

    return _ElTabsInheritedWidget(scope: scope, child: super.build(context)).noScrollbarBehavior(context);
  }
}

class ElTabsScope {
  ElTabsScope({
    required this.obs,
    required this.scrollController,
    required this.themeData,
    required this.axis,
    required this.widget,
  });

  final Obs<dynamic> obs;
  final ScrollController scrollController;
  final ElTabsThemeData themeData;
  final Axis axis;
  final ElTabs widget;

  dynamic get modelValue => obs.value;

  set modelValue(dynamic v) => obs.value = v;
}

class _ElTabsInheritedWidget extends InheritedWidget {
  const _ElTabsInheritedWidget({required this.scope, required super.child});

  final ElTabsScope scope;

  @override
  bool updateShouldNotify(_ElTabsInheritedWidget oldWidget) {
    return true;
  }
}
