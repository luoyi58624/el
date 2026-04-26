import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';

part 'route.dart';

/// 基于 [ElOverlay] 实现的弹出层小部件，构建的浮层由 ElOverlay 绘制，显示、隐藏弹窗支持状态保留
class ElPopup extends ElModelValue<bool?> {
  const ElPopup({
    super.key,
    super.onChanged,
    this.show,
    this.duration,
    this.keepAlive = false,
    this.preventBack = false,
    this.onInsert,
    this.onRemove,
    required this.transitionBuilder,
    required this.overlayBuilder,
    required this.builder,
  }) : assert(show == null || show is bool || show is ValueNotifier<bool>, '弹出层 show 参数必须为 bool 类型'),
       super(show);

  /// 手动控制弹出层的显示隐藏（支持双向绑定）
  final dynamic show;

  /// 弹出层的过渡时间，默认 [El.duration]
  final Duration? duration;

  /// 关闭弹出层时是否保留状态
  final bool keepAlive;

  /// 是否拦截物理返回（仅限安卓）
  final bool preventBack;

  /// 插入弹出层回调
  final VoidCallback? onInsert;

  /// 移除弹出层回调
  final VoidCallback? onRemove;

  /// 构建弹出层动画
  final Widget Function(BuildContext context, Widget child) transitionBuilder;

  /// 构建弹出层小部件
  final Widget Function(BuildContext context) overlayBuilder;

  /// 构建代理子组件
  final Widget Function(BuildContext context, ElPopupState state) builder;

  /// 访问弹出层实例对象，只能在 [transitionBuilder]、[overlayBuilder] 中访问
  static ElPopupState of(BuildContext context) {
    final result = context.getInheritedWidgetOfExactType<_PopupOverlayScope>()?.state;
    assert(result != null, '当前 context 祖先不存在 ElPopup 小部件');
    return result!;
  }

  @override
  State<ElPopup> createState() => ElPopupState();
}

class ElPopupState<T extends ElPopup> extends State<T>
    with SingleTickerProviderStateMixin, ElModelValueMixin<T, bool?> {
  final overlayController = OverlayPortalController();

  /// 显示、隐藏弹窗动画控制器
  late final AnimationController animationController;

  /// 声明默认的动画持续时间
  Duration get animationDuration => widget.duration ?? Duration.zero;

  /// 弹出层实例对象
  OverlayEntry? overlayEntry;

  Size? _overlaySize;

  /// 弹出层容器尺寸
  Size get overlaySize {
    assert(_overlaySize != null, '请在 Overlay 初始化后再访问 overlaySize');
    return _overlaySize!;
  }

  /// 刷新弹窗内容，此方法会触发 [buildOverlay] 重建
  VoidCallback? refreshOverlay;

  /// 忽略一次响应式变量监听方法，有时候更新响应式变量不希望触发监听函数（需要手动控制动画），
  /// 你可以将此变量设置为 true，监听拦截后会自动重置它
  @protected
  bool? ignoreOnceListener;

  /// 使用弹簧动画来驱动 [animationController]
  @protected
  Simulation? createSimulation({required bool forward}) => null;

  /// 切换显示、隐藏弹窗
  void toggle() => modelValue == true ? modelValue = false : modelValue = true;

  /// 执行 [initState] 初始化时绑定响应式监听，通过 [modelValue] 来驱动弹窗的显示、隐藏
  @protected
  void bindingListener() {
    // 忽略一次监听执行
    if (ignoreOnceListener == true) {
      ignoreOnceListener = null;
      return;
    }

    if (modelValue == true) {
      // 先插入弹窗，再执行显示动画
      overlayEntry == null ? insertOverlay() : showOverlay();
      forward();
    } else {
      // 先执行隐藏动画，结束后再移除弹窗，若隐藏动画还未执行完毕，
      // 重新显示弹窗将不会移除弹窗，而是会直接执行 showOverlay 更新显示状态
      reverse().then((e) => reverseCallback());
    }
  }

  /// 返回动画回调
  @protected
  void reverseCallback() {
    if (widget.keepAlive != true) removeOverlay();
  }

  /// 前进动画
  @protected
  TickerFuture forward() {
    final simulation = createSimulation(forward: true);

    if (simulation == null) {
      return animationController.forward();
    } else {
      return animationController.animateWith(simulation);
    }
  }

  /// 返回动画
  @protected
  TickerFuture reverse() {
    final simulation = createSimulation(forward: false);

    if (simulation == null) {
      return animationController.reverse();
    } else {
      return animationController.animateBackWith(simulation);
    }
  }

  /// 插入弹出层
  @protected
  @mustCallSuper
  void insertOverlay() {
    assert(overlayEntry == null, 'Overlay 已存在，请不要重复执行 insertOverlay 方法!');
    onInsert();
    final child = _PopupOverlayScope(
      this,
      child: StatefulBuilder(
        builder: (context, setState) {
          refreshOverlay = () {
            if (context.mounted) safeCallback(() => setState(() {}));
          };
          return buildOverlay(context);
        },
      ),
    );

    Widget result = ValueListenableBuilder(
      valueListenable: obs,
      builder: (context, value, child) {
        Widget result = ExcludeSemantics(
          excluding: value != true,
          child: IgnorePointer(ignoring: value != true, child: child!),
        );
        if (ElPlatform.isAndroid && widget.preventBack) {
          result = result;
        }
        return result;
      },
      child: child,
    );

    overlayEntry = OverlayEntry(
      builder: (context) {
        _overlaySize = MediaQuery.sizeOf(context);
        return RepaintBoundary(child: result);
      },
    );

    el.overlay.insert(overlayEntry!);
  }

  /// 移除弹出层
  @protected
  void removeOverlay() {
    if (overlayEntry != null) {
      onRemove();
      overlayEntry!.remove();
      overlayEntry!.dispose();
      overlayEntry = null;
      _overlaySize = null;
    }
  }

  /// 当 [overlayEntry] 还存在时，可以调用此方法直接显示弹出层，通常有 2 种情况会调用它：
  /// 1. 开启 keepAlive 保持弹窗状态
  /// 2. 执行隐藏动画还未结束时又立即显示
  @protected
  @mustCallSuper
  void showOverlay() {
    assert(overlayEntry != null, 'Overlay 还未插入，执行 showOverlay 方法前请执行 insertOverlay 方法!');
    // 若是手动调用此方法，还需要同步 modelValue 状态
    if (modelValue != true) {
      ignoreOnceListener = true;
      modelValue = true;
    }
  }

  @protected
  @mustCallSuper
  void onInsert() {
    widget.onInsert?.call();
  }

  @protected
  @mustCallSuper
  void onRemove() {
    widget.onRemove?.call();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: animationDuration);
    obs.addListener(bindingListener);
    if (obs.rawValue == true) nextTick(bindingListener);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      animationController.duration = animationDuration;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    obs.removeListener(bindingListener);
    super.dispose();
    removeOverlay();
  }

  /// 构建 overlay 内容小部件
  @protected
  Widget buildOverlay(BuildContext context) {
    return widget.transitionBuilder(context, widget.overlayBuilder(context));
  }

  // Widget overlayBuilder(BuildContext context) {
  //   return widget.overlayBuilder(context);
  // }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    // return OverlayPortal(
    //   controller: overlayController,
    //   overlayChildBuilder: (context){
    //
    //   },
    //   child: widget.builder(context, this),
    // );
    return widget.builder(context, this);
  }

  @override
  Widget obsBuild(BuildContext context) {
    throw UnimplementedError();
  }
}

class _PopupOverlayScope extends InheritedWidget {
  const _PopupOverlayScope(this.state, {required super.child});

  final ElPopupState state;

  @override
  bool updateShouldNotify(_PopupOverlayScope oldWidget) => false;
}
