import 'dart:math';

import 'package:el_flutter/el_flutter.dart';
import 'package:el_dart/ext.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'render.dart';

/// 滚动小部件，它会一次性布局所有子项，但不会渲染可视窗口外的元素
class ElScroll extends HookWidget {
  const ElScroll({
    super.key,
    required this.children,
    this.controller,
    this.physics,
    this.clipBehavior = .hardEdge,
    this.keyboardDismissBehavior,
    this.padding,
    this.spacing,
    this.spacingWidget,
    this.center = false,
    this.excludeSemantics = false,
    this.debugLabel,
    this.cacheKey,
  });

  final List<Widget> children;

  final ScrollController? controller;

  final ScrollPhysics? physics;

  final EdgeInsets? padding;

  final Clip clipBehavior;

  /// 如果想要在滚动时隐藏键盘，可以设置 onDrag 参数
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// 设置滚动元素之间的间隔，它相当于给 [spacingWidget] 设置 [SizedBox]
  final double? spacing;

  /// 自定义元素之间的小部件
  final Widget? spacingWidget;

  /// 滚动内容是否居中
  final bool center;

  /// 是否忽略滚动区域的语义
  final bool excludeSemantics;

  /// 显示打印 ElScroll 布局耗时日志
  final String? debugLabel;

  /// 记录滚动位置缓存，注意：初始化定位时需要将位置传递给控制器，若你使用自定义控制器只能自己处理缓存
  final String? cacheKey;

  Widget buildViewport(BuildContext context, ViewportOffset offset) {
    List<Widget> $children = children;
    final spacingWidget = this.spacingWidget ?? (spacing != null ? SizedBox(height: spacing) : null);

    if (spacingWidget != null) {
      final List<Widget> newList = [];
      for (int i = 0; i < $children.length; i++) {
        newList.add($children[i]);
        newList.add(spacingWidget);
      }
      if (newList.isNotEmpty) newList.removeLast();
      $children = newList;
    }

    return _ViewportWidget(
      offset: offset,
      clipBehavior: clipBehavior,
      center: center,
      padding: padding == null ? .zero : padding as EdgeInsets,
      excludeSemantics: excludeSemantics,
      debugLabel: debugLabel,
      children: $children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = useGlobalScrollController(controller: this.controller, cacheKey: cacheKey);

    Widget result = Scrollable(controller: controller, physics: physics, viewportBuilder: buildViewport);

    if (keyboardDismissBehavior == ScrollViewKeyboardDismissBehavior.onDrag) {
      result = NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification e) {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (e.dragDetails != null && !currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          return false;
        },
        child: result,
      );
    }

    return result;
  }
}

class _ViewportWidget extends MultiChildRenderObjectWidget {
  const _ViewportWidget({
    required super.children,
    required this.offset,
    required this.clipBehavior,
    required this.padding,
    required this.center,
    required this.excludeSemantics,
    required this.debugLabel,
  });

  final ViewportOffset offset;
  final Clip clipBehavior;
  final EdgeInsets padding;
  final bool center;
  final bool excludeSemantics;
  final String? debugLabel;

  @override
  MultiChildRenderObjectElement createElement() {
    return _ViewportElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderViewport(offset, clipBehavior, padding, center, excludeSemantics, debugLabel);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderViewport renderObject) {
    renderObject
      ..offset = offset
      ..clipBehavior = clipBehavior
      ..padding = padding
      ..center = center
      ..excludeSemantics = excludeSemantics
      ..debugLabel = debugLabel;
  }
}

class _ViewportElement extends MultiChildRenderObjectElement with NotifiableElementMixin, ViewportElementMixin {
  _ViewportElement(_ViewportWidget super.widget);

  // 这是用来充当滚动容器中的锚点，滚动列表有一项辅助功能，让目标元素显示在可视窗口中，例如：
  // 1. 弹出键盘需要让表单自动滚动到键盘上面；
  // 2. 焦点导航需要让激活的目标元素自动滚动到可视窗口中；
  Element? emptyChild;

  @override
  void visitChildren(ElementVisitor visitor) {
    super.visitChildren(visitor);
    if (emptyChild != null) visitor(emptyChild!);
  }

  @override
  void forgetChild(Element child) {
    emptyChild = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    emptyChild = updateChild(emptyChild, ElEmptyWidget.instance, #emptyChild);
  }

  @override
  void update(MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    emptyChild = updateChild(emptyChild, ElEmptyWidget.instance, #emptyChild);
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, Object? slot) {
    if (slot is IndexedSlot<Element?>) {
      super.insertRenderObjectChild(child, slot);
    } else if (slot == #emptyChild) {
      (renderObject as _RenderViewport).emptyChild = child as RenderBox;
    }
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, Object? slot) {
    if (slot is IndexedSlot<Element?>) {
      super.removeRenderObjectChild(child, slot);
    } else if (slot == #emptyChild) {
      (renderObject as _RenderViewport).emptyChild = null;
    }
  }
}
