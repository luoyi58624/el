import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:el_flutter/el_flutter.dart';

part 'route.dart';

part 'service.dart';

part 'common.dart';

part 'transition.dart';

Widget _transitionBuilder(BuildContext context, Widget child) {
  final $state = ElPopup.of(context) as ElDrawerState;
  return _Transition(
    onModalTap: () => $state.modelValue = false,
    controller: $state.animationController,
    modalColor: $state.widget.modalColor,
    direction: $state.direction(context),
    ignoreModalPointer: $state.widget.ignoreModalPointer,
    child: child,
  );
}

Widget _builder(BuildContext context, ElPopupState state) {
  final $state = state as ElDrawerState;

  // 受控模式不需要构建默认的事件
  if ($state.widget.show != null) return $state.child;

  return Semantics(
    onTap: () => $state.toggle(),
    button: true,
    child: ElEvent(
      style: ElEventStyle(ignoreStatus: true, onTap: (e) => $state.toggle()),
      child: $state.child,
    ),
  );
}

/// Element UI 抽屉组件。
///
/// 提示：建议在每个路由页面单独设置 [ElOverlay]，否则弹窗会覆盖新跳转的页面。
class ElDrawer extends ElPopup {
  const ElDrawer({
    super.key,
    super.show,
    super.keepAlive = true,
    super.onInsert,
    super.onRemove,
    super.onChanged,
    required super.overlayBuilder,
    this.child,
    this.enabledDragFeedback,
    this.dragShowThreshold,
    this.dragHideThreshold,
    this.enabledDrag,
    this.maxPrimarySize,
    this.direction = AxisDirection.left,
    this.modalColor,
    this.ignoreModalPointer = false,
  }) : super(preventBack: true, transitionBuilder: _transitionBuilder, builder: _builder);

  final Widget? child;

  /// 是否开启拖拽抽屉触发关闭阈值震动提醒
  final bool? enabledDragFeedback;

  /// 触发拖拽显示阈值，如果小于 1.0，则以百分比计算，否则以实际像素计算，默认 0.5
  final double? dragShowThreshold;

  /// 触发拖拽隐藏阈值，默认 0.5
  final double? dragHideThreshold;

  /// 启用拖拽关闭抽屉，若为 null，移动端将默认为 true，桌面端则为 false
  final bool? enabledDrag;

  /// 抽屉展开方向的最大尺寸，如果取值范围是：0.0 ~ 1.0，则按百分比决定抽屉尺寸，否则以正常像素决定抽屉尺寸；
  /// 默认情况下，垂直展开 maxPrimarySize 将为 0.5，水平展开则为 300.0。
  ///
  /// 注意：该属性仅代表抽屉允许的最大尺寸，不代表抽屉真实尺寸，具体请参阅 [createBoxConstraints] 方法。
  final double? maxPrimarySize;

  /// 抽屉打开方向，支持上下左右 4 种方向
  final AxisDirection direction;

  /// 模态框背景颜色
  final Color? modalColor;

  /// 忽略模态框指针事件
  final bool ignoreModalPointer;

  /// 抽屉动画由 spring 驱动，此对象定义了抽屉的质量与动量，你可以在 main 方法中修改它调整抽屉的动画曲线，
  /// 官方提供的 [Drawer] 参数分别为 1.0、500.0
  static var springDescription = SpringDescription.withDampingRatio(mass: 2.0, stiffness: 600.0);

  /// 创建抽屉物理动画
  static Simulation createSimulation({required AnimationController controller, double velocity = 1.0}) {
    final double target = velocity < 0 ? 0.0 - _kFlingTolerance.distance : 1.0 + _kFlingTolerance.distance;

    final SpringSimulation simulation = SpringSimulation(ElDrawer.springDescription, controller.value, target, velocity)
      ..tolerance = _kFlingTolerance;
    return simulation;
  }

  /// 创建抽屉盒子约束
  static BoxConstraints createBoxConstraints({required bool isVertical, required Size drawerMaxSize}) {
    return BoxConstraints(
      minWidth: isVertical ? double.infinity : 0.0,
      maxWidth: isVertical ? double.infinity : drawerMaxSize.width,
      minHeight: isVertical ? 0.0 : double.infinity,
      maxHeight: isVertical ? drawerMaxSize.height : double.infinity,
    );
  }

  @override
  State<ElDrawer> createState() => ElDrawerState();
}

class ElDrawerState extends ElPopupState<ElDrawer> {
  FocusScopeNode focusScopeNode = FocusScopeNode();

  void focusListener() {
    if (modelValue == true) {
      focusScopeNode.requestFocus();
    } else {
      focusScopeNode.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    obs.addListener(focusListener);
  }

  @override
  void didUpdateWidget(covariant ElDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabledDrag != oldWidget.enabledDrag) {
      refreshOverlay?.call();
    }
  }

  @override
  void dispose() {
    obs.removeListener(focusListener);
    super.dispose();
    focusScopeNode.dispose();
  }

  /// 抽屉内容 key
  final contentKey = GlobalKey();

  late bool isVertical;

  Widget get child => widget.child ?? ElEmptyWidget.instance;

  AxisDirection direction(BuildContext context) => widget.direction.applyTextDirection(Directionality.of(context));

  void _dragEnd(double delta) {
    if (animationController.value + delta < 0.5) {
      ignoreOnceListener = true;
      modelValue = false;
      super.reverse().then((e) => reverseCallback());
    } else {
      super.forward().then((e) {
        modelValue = true;
      });
    }
  }

  @override
  Simulation? createSimulation({required bool forward}) {
    return ElDrawer.createSimulation(controller: animationController, velocity: forward ? 1.0 : -1.0);
  }

  @override
  Widget buildOverlay(BuildContext context) {
    final drawerMaxSize = _calcDrawerMaxSize(
      size: widget.maxPrimarySize,
      overlaySize: MediaQuery.sizeOf(context),
      direction: direction(context),
    );

    Widget result = MediaQuery.removePadding(
      context: context,
      removeLeft: direction(context) == AxisDirection.right,
      removeRight: direction(context) == AxisDirection.left,
      child: ConstrainedBox(
        constraints: ElDrawer.createBoxConstraints(isVertical: isVertical, drawerMaxSize: drawerMaxSize),
        child: Builder(
          key: contentKey,
          builder: (context) {
            return widget.overlayBuilder(context);
          },
        ),
      ),
    );

    result = widget.transitionBuilder(context, result);

    result = ValueListenableBuilder(
      valueListenable: obs,
      builder: (context, value, child) =>
          FocusScope(node: focusScopeNode, skipTraversal: true, descendantsAreFocusable: value == true, child: child!),
      child: result,
    );

    if (_allowedDrag(widget.enabledDrag) == false) return result;

    result = _DrawerDrag(
      behavior: HitTestBehavior.deferToChild,
      onDragUpdate: (delta) {
        animationController.value += delta;
      },
      onDragEnd: _dragEnd,
      direction: direction(context),
      getContentKey: () => contentKey,
      child: result,
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    isVertical = widget.direction.isVertical;

    return super.build(context);
  }
}
