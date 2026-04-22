import 'dart:math';

import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

part 'mixin.dart';

/// 指定弹窗如何触发重新定位
enum ElPopupAdjustPosition {
  /// 以容器中间为基准，调整弹窗的位置
  center,

  /// 以容器边缘为基准，调整弹窗位置（默认）
  boundary,
}

/// 触摸 popup 弹窗外部时的移除策略
enum ElPopupRemoveBehavior {
  /// 不移除弹窗
  none,

  /// 指针按下时移除
  tapDown,

  /// 指针抬起时移除
  tapUp,

  /// 点击外部时移除
  tap,
}

/// 弹出层的对齐方式
enum ElPopupAlignment {
  left,
  leftStart,
  leftEnd,
  top,
  topStart,
  topEnd,
  right,
  rightStart,
  rightEnd,
  bottom,
  bottomStart,
  bottomEnd,

  /// 以目标子组件中心为基点，显示弹窗
  center,

  /// 跟随指针的触摸位置
  float;

  bool get isVertical =>
      this == top || this == topStart || this == topEnd || this == bottom || this == bottomStart || this == bottomEnd;

  bool get isHorizontal =>
      this == left || this == leftStart || this == leftEnd || this == right || this == rightStart || this == rightEnd;

  bool get isStart => this == topStart || this == bottomStart || this == leftStart || this == rightStart;

  bool get isCenter => this == left || this == top || this == right || this == bottom;

  bool get isEnd => this == topEnd || this == bottomEnd || this == leftEnd || this == rightEnd;

  bool get isTop => this == top || this == topStart || this == topEnd;

  bool get isBottom => this == bottom || this == bottomStart || this == bottomEnd;

  bool get isLeft => this == left || this == leftStart || this == leftEnd;

  bool get isRight => this == right || this == rightStart || this == rightEnd;

  AxisDirection get toAxisDirection {
    if (isTop) return AxisDirection.up;
    if (isBottom) return AxisDirection.down;
    if (isLeft) return AxisDirection.left;
    if (isRight) return AxisDirection.right;

    throw 'ElPopupAlignment Error: $name 类型不可调用 toAxisDirection 方法';
  }
}

Widget _builder(BuildContext context, ElPopupState state) {
  return (state as ElLinkPopupState).widget.child;
}

/// 使用 [LayerLink] 链接 child 与 popup 的位置，在目标小部件周围显示弹出层
abstract class ElLinkPopup extends ElPopup {
  const ElLinkPopup({
    super.key,
    super.show,
    super.duration,
    super.keepAlive,
    super.preventBack,
    super.onChanged,
    super.onInsert,
    super.onRemove,
    required super.transitionBuilder,
    required super.overlayBuilder,
    super.builder = _builder,
    required this.child,
    this.groupId,
    this.alignment,
    this.removeBehavior,
    this.adjustPosition = ElPopupAdjustPosition.boundary,
    this.coverTarget,
    this.spacing,
    this.edgeSpacing,
    this.constraints,
  });

  /// 链接的目标子组件，弹窗会在该小部件周围显示
  final Widget child;

  /// 点击外部分组 id，默认以当前 State 的 hashCode 作为分组 id
  final Object? groupId;

  /// 弹出层的对齐位置，如果设置了 [hoverDelayShow] 延迟显示，
  /// 那么默认对齐为 [ElPopupAlignment.float]，否则默认为 [ElPopupAlignment.bottom]
  final ElPopupAlignment? alignment;

  /// 点击弹窗外部所应用的移除策略，默认为 [ElPopupRemoveBehavior.tapDown]，但有些弹窗可能是其他策略
  final ElPopupRemoveBehavior? removeBehavior;

  /// 弹出层如何触发重新定位，默认 [ElPopupAdjustPosition.boundary]，
  /// 当目标方向放不下弹窗内容时，才会调整方向
  final ElPopupAdjustPosition adjustPosition;

  /// 弹窗是否覆盖目标组件
  final bool? coverTarget;

  /// 弹出层与目标小部件之间的间隔
  final double? spacing;

  /// 弹出层与 Overlay 画布之间的间隔
  final double? edgeSpacing;

  /// 设置弹出层尺寸范围，如果最大最小宽高相等，则弹窗布局性能将会提高一倍
  final BoxConstraints? constraints;

  @override
  State<ElPopup> createState();
}

abstract class ElLinkPopupState<T extends ElLinkPopup> extends ElPopupState<T> with _LayerMixin<T> {
  /// 感知滚动通知，当发生滚动时可能需要调整弹出层位置
  late Listenable scrollNotify;

  /// 点击外部分组 id
  Object get groupId => widget.groupId ?? hashCode;

  /// 点击弹窗外部应用的移除策略，不同弹窗应用的策略可能并不相同
  ElPopupRemoveBehavior get removeBehavior {
    if (widget.removeBehavior != null) return widget.removeBehavior!;

    return ElPopupRemoveBehavior.tapDown;
  }

  /// 弹出层默认的尺寸约束，如果用户没有指定约束条件，则 [overlaySize] 将直接作为弹出层默认最大尺寸，
  /// 若用户指定了约束条件，则将 widget.constraints 与 overlaySize 进行联合取值。
  @protected
  BoxConstraints get popupConstraints {
    final maxSize = overlaySize;
    if (widget.constraints == null) return BoxConstraints.loose(maxSize);

    final maxWidth = min(widget.constraints!.maxWidth, maxSize.width);
    final maxHeight = min(widget.constraints!.maxHeight, maxSize.height);

    return BoxConstraints(
      minWidth: min(widget.constraints!.minWidth, maxWidth),
      maxWidth: maxWidth,
      minHeight: min(widget.constraints!.minHeight, maxHeight),
      maxHeight: maxHeight,
    );
  }

  /// 插入弹窗前初始化一些属性
  void _updateAttr() {
    _childSize = childKey.currentContext!.size;
    _childPosition = ElFlutterUtil.getPosition(childKey.currentContext!, el.context);
  }

  /// 触发滚动、弹出层尺寸发生变化监听
  void _installAttrListener() {
    nextTick(() {
      _updateAttr();
      refreshOverlay?.call();
    });
  }

  void _obsListener() {
    if (modelValue == true) {
      scrollNotify.addListener(_installAttrListener);
    } else {
      scrollNotify.removeListener(_installAttrListener);
    }
  }

  @override
  void initState() {
    super.initState();
    obs.addListener(_obsListener);
  }

  @override
  void dispose() {
    obs.removeListener(_obsListener);
    super.dispose();
  }

  @protected
  @mustCallSuper
  @override
  void onInsert() {
    super.onInsert();
    _updateAttr();
  }

  @protected
  @mustCallSuper
  @override
  void onRemove() {
    super.onRemove();
    _childSize = null;
    _childPosition = null;
    _popupSize = null;
    _layerOffset = null;
    _popupAlignment = null;
    _isTight = null;
    _positionType = null;
  }

  /// 继承 [ElLinkPopup] 的子类若要自定义内容，应当重写此方法，而不是 [buildOverlay] 方法
  @protected
  Widget buildPopup(BuildContext context) {
    return super.buildOverlay(context);
  }

  @protected
  @mustCallSuper
  @override
  Widget buildOverlay(BuildContext context) {
    // 阻止 popup 的滚动事件向外部传递，因为 ElApp 注册了监听子类滚动，
    // 由于 popup 弹窗与子组件是分离的，所以没有必要让 popup 滚动事件冒泡到 ElApp 中
    final result = NotificationListener<ScrollNotification>(
      onNotification: (v) => true,
      child: Builder(
        builder: (context) {
          _layerOffset = Offset.zero;
          _calcPopupAlignment();
          _setPositionType();
          _calcLayerOffset();
          return CompositedTransformFollower(
            link: layerLink,
            offset: layerOffset,
            showWhenUnlinked: false,
            child: SizedBox.fromSize(
              size: popupSize,
              child: ElTapOutSide(
                groupId: groupId,
                onTapDown: (e) {
                  if (removeBehavior == ElPopupRemoveBehavior.tapDown) {
                    modelValue = false;
                  }
                },
                onTapUp: (e) {
                  if (removeBehavior == ElPopupRemoveBehavior.tapUp) {
                    modelValue = false;
                  }
                },
                onTap: () {
                  if (removeBehavior == ElPopupRemoveBehavior.tap) {
                    modelValue = false;
                  }
                },
                child: buildPopup(context),
              ),
            ),
          );
        },
      ),
    );

    final popupConstraints = this.popupConstraints;

    // 计算 Popup 尺寸，若 popupConstraints 满足 tight 条件，那么无需对 Popup 的尺寸进行探测
    if (popupConstraints.isTight) {
      _isTight = true;
      _popupSize = Size(popupConstraints.maxWidth, popupConstraints.maxHeight);
      return UnconstrainedBox(child: result);
    } else {
      _isTight = false;
      return ElChildSizeBuilder(
        constraints: popupConstraints,
        tempChild: widget.overlayBuilder(context),
        builder: (size) {
          _popupSize = size;
          return result;
        },
      );
    }
  }

  /// 若是浮动对齐，则需要包裹一层事件小部件来访问指针位置
  Widget buildFloatEvent(BuildContext context, Widget child) {
    return ElEvent(
      style: ElEventStyle(
        onHover: (e) => localPosition = e.localPosition,
        onPointerDown: (e) => localPosition = e.localPosition,
        ignoreStatus: true,
      ),
      child: child,
    );
  }

  @protected
  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    scrollNotify = ElApp.scrollNotifyOf(context);
    _safePadding = MediaQuery.paddingOf(el.context);
    Widget result = CompositedTransformTarget(key: childKey, link: layerLink, child: super.build(context));

    if (isFloat) result = buildFloatEvent(context, result);

    return result;
  }
}
