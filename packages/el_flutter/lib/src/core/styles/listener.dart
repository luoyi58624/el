import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:el_dart/el_dart.dart';

part 'listener.g.dart';

@ElModelGenerator.copy()
// ignore: must_be_immutable
class ElListenerStyle with EquatableMixin {
  ElListenerStyle({
    this.behavior,
    this.disabled,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onHover,
    this.onPointerPanZoomStart,
    this.onPointerPanZoomUpdate,
    this.onPointerPanZoomEnd,
    this.onPointerSignal,
    this.onPointerCancel,
  });

  /// 命中测试行为，默认：[HitTestBehavior.deferToChild]，事件命中的三个行为有以下特征：
  /// * [HitTestBehavior.deferToChild] - 透明部分事件会被忽略；
  /// * [HitTestBehavior.opaque] - 透明部分事件允许触发；
  /// * [HitTestBehavior.translucent] - 透明部分事件允许触发，同时透明元素下面的目标也能命中事件；
  HitTestBehavior? behavior;

  /// 是否禁用事件，如果祖先小部件设置了 [disabled] 属性，那么后代所有小部件都将被禁用。
  bool? disabled;

  /// 原始指针按下事件，允许阻止冒泡
  PointerDownEventListener? onPointerDown;

  /// 原始指针抬起事件，允许阻止冒泡
  PointerUpEventListener? onPointerUp;

  /// 原始指针移动事件，原始指针的移动事件不允许阻止冒泡，它的具体实现为 [ElDragMixin]，
  /// 拖拽的冒泡处理具有相对合理的默认行为，但并不允许用户进一步控制它们
  PointerMoveEventListener? onPointerMove;

  /// 原始指针悬停事件
  PointerHoverEventListener? onHover;

  /// 这三个事件用于监听平移、缩放
  PointerPanZoomStartEventListener? onPointerPanZoomStart;
  PointerPanZoomUpdateEventListener? onPointerPanZoomUpdate;
  PointerPanZoomEndEventListener? onPointerPanZoomEnd;

  /// 鼠标滚轮事件
  PointerSignalEventListener? onPointerSignal;

  /// 指针取消事件，此回调只响应系统发出的指针取消事件
  PointerCancelEventListener? onPointerCancel;

  @override
  List<Object?> get props => _props;
}
