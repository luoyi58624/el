import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'overlay.dart';

part 'transition.dart';

part 'theme.dart';

part 'index.g.dart';

Widget _transitionBuilder(BuildContext context, Widget child) {
  final state = ElPopup.of(context) as ElPopupMenuState;
  return ElPopupMenuTransition(
    controller: state.animationController,
    alignment: ElPopupMenu.calcScaleAlignment(state),
    child: child,
  );
}

Widget _overlayBuilder<T>(BuildContext context) {
  final state = ElPopup.of(context) as ElPopupMenuState<T>;
  return _Overlay<T>(state: state);
}

Widget _builder(BuildContext context, ElPopupState state) {
  final $state = state as ElPopupMenuState;

  final child = $state.widget.child;

  return ElEvent(
    style: ElEventStyle(behavior: HitTestBehavior.opaque, ignoreStatus: true, onTap: (e) => $state.toggle()),
    child: child,
  );
}

class ElPopupMenu<T> extends ElLinkPopup {
  /// 弹出菜单小部件
  const ElPopupMenu({
    super.key,
    super.duration,
    super.alignment = ElPopupAlignment.bottom,
    super.adjustPosition,
    super.coverTarget = false,
    super.spacing = 0,
    super.constraints,
    super.preventBack = false,
    super.transitionBuilder = _transitionBuilder,
    required super.child,
    this.minWidth,
    this.textStyle,
    required this.menuList,
    this.onMenuChanged,
  }) : super(overlayBuilder: _overlayBuilder<T>, builder: _builder);

  final double? minWidth;
  final TextStyle? textStyle;
  final List<ElMenuEntry<T>> menuList;

  /// 监听选中的菜单
  final ValueChanged<ElMenuEntry<T>>? onMenuChanged;

  @override
  State<ElPopup> createState() => ElPopupMenuState<T>();

  /// 计算 scale 缩放动画的对齐原点:
  /// 1. 如果菜单位置与 child 对齐，则直接返回固定的 Alignment 对齐原点；
  /// 2. 若没有对齐，则根据偏移坐标点 + childSize/2，除以 popupSize 得到对齐原点与弹窗尺寸的比例值，
  /// 然后将该值转换成符合 Alignment 的对齐原点，取值范围为 -1.0 ~ 1.0
  static Alignment calcScaleAlignment(ElLinkPopupState state) {
    double anchorX() => ((state.layerOffset.dx.abs() + state.childSize.width / 2) / state.popupSize.width - 0.5) * 2;
    double anchorY() => ((state.layerOffset.dy.abs() + state.childSize.height / 2) / state.popupSize.height - 0.5) * 2;

    if (state.isCenter) return Alignment(anchorX(), anchorY());

    double? x;
    double? y;

    if (state.popupAlignment!.isVertical) {
      if (state.layerOffset.dx == 0) {
        x = -1.0;
      } else if (state.layerOffset.dx + state.popupSize.width == state.childSize.width) {
        x = 1.0;
      } else {
        x = anchorX();
      }

      y = state.popupAlignment!.isTop ? 1.0 : -1.0;
    } else {
      if (state.popupAlignment!.isStart) {
        if (state.layerOffset.dy >= 0) {
          y = -1.0;
        } else {
          y = anchorY();
        }
      } else if (state.popupAlignment!.isEnd) {
        if (state.layerOffset.dy + state.popupSize.height <= state.childSize.height) {
          y = 1.0;
        } else {
          y = anchorY();
        }
      } else {
        y = anchorY();
      }
      x = state.popupAlignment!.isLeft ? 1.0 : -1.0;
    }

    return Alignment(x, y);
  }
}

class ElPopupMenuState<T> extends ElLinkPopupState<ElPopupMenu<T>> {
  @override
  Duration get animationDuration =>
      widget.duration ?? (ElPlatform.isDesktop ? el.config.fastDuration : el.config.duration);

  @override
  Widget buildPopup(BuildContext context) {
    return ListenableBuilder(
      listenable: obs,
      builder: (context, child) {
        return IgnorePointer(ignoring: modelValue != true, child: child);
      },
      child: TapRegion(groupId: groupId, onTapOutside: (e) => modelValue = false, child: super.buildPopup(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(groupId: groupId, child: super.build(context));
  }
}
