import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:el_flutter/ext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/scheduler.dart';

/// 空 Widget 实例，通常用于在 build 条件分之中返回不可到达代码
class ElNullWidget extends Widget {
  const ElNullWidget._();

  static const ElNullWidget instance = ElNullWidget._();

  @override
  Element createElement() => throw UnimplementedError();
}

/// 空 Element 实例，通常用于初始化 Element 数组
class ElNullElement extends Element {
  ElNullElement._() : super(ElNullWidget.instance);

  static final ElNullElement instance = ElNullElement._();

  @override
  bool get debugDoingBuild => throw UnimplementedError();
}

/// 不渲染任何内容的小部件，它的作用仅充当占位符
class ElEmptyWidget extends LeafRenderObjectWidget {
  const ElEmptyWidget._();

  static const ElEmptyWidget instance = ElEmptyWidget._();

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEmpty();
}

class _RenderEmpty extends RenderBox {
  @override
  void performLayout() {
    size = constraints.smallest;
  }
}

class ElDefaultColor extends InheritedWidget {
  /// 给后代小部件提供默认颜色，你可以使用 context.elDefaultColor 访问默认颜色
  const ElDefaultColor(this.color, {super.key, required super.child});

  final Color color;

  @override
  bool updateShouldNotify(ElDefaultColor oldWidget) => color != oldWidget.color;
}

class ElAnimatedDefaultColor extends ElImplicitlyAnimatedWidget {
  /// 动画版本 [ElDefaultColor] 小部件，它可以给任意 '普通' 小部件应用颜色过渡：
  /// ```dart
  /// class _Example extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return ElAnimatedDefaultColor(
  ///       Colors.green, // 修改此颜色会应用过渡动画
  ///       child: Builder(
  ///         builder: (context) {
  ///           return Container(width: 100, height: 100, color: context.elDefaultColor);
  ///         },
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  const ElAnimatedDefaultColor(this.color, {super.key, super.duration, super.curve, super.onEnd, required super.child})
    : assert(child != null);

  final Color color;

  @override
  List<Object?> get effects => [color];

  @override
  void forEachTween(visitor) {
    visitor('color', color, ColorTween());
  }

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return ElDefaultColor((tweenMap['color']! as ColorTween).evaluate(animation)!, child: child!);
  }
}

class ElBrightness extends InheritedWidget {
  /// 指定后代小部件应用的主题模式，ElBrightness 可以充当全局主题模式，也可以在局部指定主题模式
  const ElBrightness(this.brightness, {super.key, required super.child});

  /// 对后代组件应用的主题模式，若为 null 则跟随平台
  final Brightness? brightness;

  static Brightness? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ElBrightness>()?.brightness;

  /// 访问祖先指定的主题模式，如果祖先未提供，则跟随系统
  static Brightness of(BuildContext context) => maybeOf(context) ?? MediaQuery.platformBrightnessOf(context);

  /// 当前环境是否是暗黑模式
  static bool isDark(BuildContext context) => of(context) == Brightness.dark;

  @override
  bool updateShouldNotify(ElBrightness oldWidget) => brightness != oldWidget.brightness;
}

/// 一个功能小部件，让迭代的列表子元素确认自身所在的位置
class ElChildIndex extends InheritedWidget {
  const ElChildIndex({super.key, required super.child, required this.index, this.start, this.end, this.length});

  /// 当前索引
  final int index;

  /// 迭代元素起始索引，非必需，使用前请确认是否注入
  final int? start;

  /// 迭代元素结束索引，非必需，使用前请确认是否注入
  final int? end;

  /// 迭代元素总长度，非必需，使用前请确认是否注入
  final int? length;

  static ElChildIndex? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ElChildIndex>();

  static ElChildIndex of(BuildContext context) {
    final ElChildIndex? result = maybeOf(context);
    assert(result != null, 'No ElChildIndex found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ElChildIndex oldWidget) =>
      index != oldWidget.index || start != oldWidget.start || end != oldWidget.end || length != oldWidget.length;
}

/// 响应式断点扩展
extension ElResponsiveExt on BuildContext {
  /// 当前是否处于极小布局（<=320）
  bool get xs => InheritedModel.inheritFrom<_Responsive>(this, aspect: _ResponsiveAspect.xs)?.xs ?? false;

  /// 当前是否处于移动端布局（<=640）
  bool get sm => InheritedModel.inheritFrom<_Responsive>(this, aspect: _ResponsiveAspect.sm)?.sm ?? false;

  /// 当前是否处于平板布局（<=1024）
  bool get md => InheritedModel.inheritFrom<_Responsive>(this, aspect: _ResponsiveAspect.md)?.md ?? false;

  /// 当前是否处于桌面布局（<=1920）
  bool get lg => InheritedModel.inheritFrom<_Responsive>(this, aspect: _ResponsiveAspect.lg)?.lg ?? false;

  /// 当前是否处于超大桌面布局（<=2560）
  bool get xl => InheritedModel.inheritFrom<_Responsive>(this, aspect: _ResponsiveAspect.xl)?.xl ?? false;
}

class ElResponsive extends StatelessWidget {
  /// 响应式布局小部件，相比直接监听 [MediaQuery]，使用该小部件可以减少不必要的重建，例如：
  /// ```dart
  /// class Example extends StatelessWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return ElResponsive(
  ///       child: Builder(
  ///         builder: (context) {
  ///           // 只有当布局触发阈值才会重建代码块
  ///           print('build');
  ///           return context.sm ? Text('Mobile') : Text('Desktop');
  ///         },
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  const ElResponsive({super.key, this.data = const ElResponsiveData(), required this.child});

  /// 注入自定义响应式配置对象，如果为 null，则访问祖先提供的默认配置
  final ElResponsiveData data;
  final Widget child;

  /// 访问祖先提供响应式配置
  static ElResponsiveData? maybeOf(BuildContext context) {
    return InheritedModel.inheritFrom<_Responsive>(context, aspect: _ResponsiveAspect.data)?.data;
  }

  /// 访问祖先提供响应式配置
  static ElResponsiveData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, '当前 context 未找到 ElResponsive 小部件！');
    return result!;
  }

  /// 访问祖先 ElResponsive 所在布局的尺寸，若祖先没有提供，尺寸将为应用窗口大小
  static Size sizeOf(BuildContext context) {
    return InheritedModel.inheritFrom<_Responsive>(context, aspect: _ResponsiveAspect.size)?.size ??
        MediaQuery.sizeOf(context);
  }

  /// 访问响应式布局当前对应的尺寸断点字符串类型
  static ElLevelType breakpointOf(BuildContext context) {
    final breakpoint = InheritedModel.inheritFrom<_Responsive>(
      context,
      aspect: _ResponsiveAspect.breakpoint,
    )?.breakpoint;

    if (breakpoint != null) return breakpoint;
    return _calcBreakpoint(of(context), sizeOf(context));
  }

  static ElLevelType _calcBreakpoint(ElResponsiveData data, Size size) {
    if (size.width <= data.xs) return .xs;
    if (size.width <= data.sm) return .sm;
    if (size.width <= data.md) return .md;
    if (size.width <= data.lg) return .lg;
    return .xl;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final breakpoint = _calcBreakpoint(data, size);
        return _Responsive(
          data,
          size,
          breakpoint,
          breakpoint == .xs,
          breakpoint == .xs || breakpoint == .sm,
          breakpoint == .xs || breakpoint == .sm || breakpoint == .md,
          breakpoint != .xl,
          breakpoint == .xl,
          child: child,
        );
      },
    );
  }
}

enum _ResponsiveAspect { data, size, breakpoint, xs, sm, md, lg, xl }

class _Responsive extends InheritedModel<_ResponsiveAspect> {
  const _Responsive(
    this.data,
    this.size,
    this.breakpoint,
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl, {
    required super.child,
  });

  final ElResponsiveData data;
  final Size size;
  final ElLevelType breakpoint;
  final bool xs;
  final bool sm;
  final bool md;
  final bool lg;
  final bool xl;

  @override
  bool updateShouldNotify(_Responsive oldWidget) =>
      data != oldWidget.data ||
      size != oldWidget.size ||
      breakpoint != oldWidget.breakpoint ||
      xs != oldWidget.xs ||
      sm != oldWidget.sm ||
      md != oldWidget.md ||
      lg != oldWidget.lg ||
      xl != oldWidget.xl;

  @override
  bool updateShouldNotifyDependent(_Responsive oldWidget, Set<_ResponsiveAspect> dependencies) {
    return dependencies.any(
      (Object dependency) =>
          dependency is _ResponsiveAspect &&
          switch (dependency) {
            _ResponsiveAspect.data => data != oldWidget.data,
            _ResponsiveAspect.size => size != oldWidget.size,
            _ResponsiveAspect.breakpoint => breakpoint != oldWidget.breakpoint,
            _ResponsiveAspect.xs => xs != oldWidget.xs,
            _ResponsiveAspect.sm => sm != oldWidget.sm,
            _ResponsiveAspect.md => md != oldWidget.md,
            _ResponsiveAspect.lg => lg != oldWidget.lg,
            _ResponsiveAspect.xl => xl != oldWidget.xl,
          },
    );
  }
}

class ElRebuildWidget<W extends Widget> extends Widget {
  /// 手动控制子组件重建，它会缓存旧的 Widget 实例，如果未触发重建条件，
  /// 则不会应用新的 Widget 实例，你可以将此效果理解为添加 const 修饰
  const ElRebuildWidget({super.key, this.shouldRebuild, required this.child});

  /// 指定触发重建条件，当返回 true 时将允许子组件重建，
  /// 此回调为 null 或者返回 false 则不会重建子组件，因为它会复用旧的 Widget 实例
  final ElUpdateCallback<W>? shouldRebuild;

  final W child;

  @override
  Element createElement() => _RebuildElement<W>(this);
}

class _RebuildElement<W extends Widget> extends ComponentElement {
  _RebuildElement(super.widget);

  @override
  ElRebuildWidget<W> get widget => super.widget as ElRebuildWidget<W>;

  W? _child;

  @override
  void reassemble() {
    _child = null; // 热刷新时清除缓存
    super.reassemble();
  }

  @override
  void update(covariant Widget newWidget) {
    super.update(newWidget);
    rebuild(force: true);
  }

  @override
  void unmount() {
    _child = null;
    super.unmount();
  }

  @override
  Widget build() {
    _child ??= widget.child;

    if (widget.shouldRebuild?.call(widget.child, _child!) == true) {
      _child = widget.child;
    }

    return _child!;
  }
}

class ElListenableBuilder<L extends Listenable, D> extends Widget {
  /// 类似于 ListenableBuilder 小部件，不过它支持精确更新
  const ElListenableBuilder({
    super.key,
    this.listenable,
    this.select,
    this.shouldRebuild,
    required this.builder,
    this.child,
  });

  /// 监听任何实现 [Listenable] 接口对象，例如：[ChangeNotifier]、[ValueNotifier]
  final L? listenable;

  /// 精确监听对象中的某个属性，只有当目标发生更新时才会重建 [builder] 代码块，例如：
  /// ```dart
  /// class MyController with ChangeNotifier {
  ///   int count = 0;
  ///   int count2 = 0;
  /// }
  ///
  /// ElListenableBuilder(
  ///   listenable: controller,
  ///   select: (MyController c) => c.count2, // 只监听 count2 的变化
  ///   builder: (context) {
  ///     return Text('count: ${controller.count2}');
  ///   },
  /// );
  /// ```
  final D Function(L listenable)? select;

  /// 自定义重建条件，此回调会传递 [select] 构建的最新值、上一次旧值，例如：
  /// ```dart
  /// select: (MyController c) => c.count2,
  /// shouldRebuild: (newValue, oldValue) => newValue < 10, // 超过 10 就不重建
  /// ```
  ///
  /// 你还可以监听多个属性变化，但判断 List 内容是否相同需要用 [ListEquality]：
  /// ```dart
  /// select: (MyController c) => [c.count, c.count2], // 当两个变量有一个发生变化就重建
  /// shouldRebuild: (newValue, oldValue) => newValue.neq(oldValue), // 判断 List 内容是否不同
  /// ```
  final ElUpdateCallback<D>? shouldRebuild;

  /// 当 [listenable] 发起通知时，会重建该代码块
  final TransitionBuilder builder;

  /// 如果构建函数 [builder] 包含不依赖 [listenable] 的子树，那么在此处设置它可以跳过重建
  final Widget? child;

  @override
  Element createElement() => _ListenableElement<L, D>(this);
}

class _ListenableElement<L extends Listenable, D> extends ComponentElement {
  _ListenableElement(super.widget);

  @override
  ElListenableBuilder<L, D> get widget => super.widget as ElListenableBuilder<L, D>;

  /// 缓存旧的 Widget 实例，当 [_oldValue] 与新值一样时，将不会重新执行 builder 代码块
  Widget? _oldWidget;
  dynamic _oldValue;

  @override
  void reassemble() {
    _oldWidget = null; // 热刷新时清除缓存
    _oldValue = null;
    super.reassemble();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.listenable?.addListener(_handleChange);
  }

  @override
  void update(ElListenableBuilder<L, D> newWidget) {
    if (newWidget.listenable != widget.listenable) {
      widget.listenable?.removeListener(_handleChange);
      newWidget.listenable?.addListener(_handleChange);
    }

    super.update(newWidget);
    rebuild(force: true);
  }

  @override
  void unmount() {
    widget.listenable?.removeListener(_handleChange);
    _oldWidget = null;
    _oldValue = null;
    super.unmount();
  }

  void _handleChange() {
    if (mounted) markNeedsBuild();
  }

  @override
  Widget build() {
    if (widget.listenable == null || widget.select == null) {
      return widget.builder(this, widget.child);
    }

    if (_oldWidget == null && _oldValue == null) {
      _oldWidget = widget.builder(this, widget.child);
      _oldValue = widget.select!(widget.listenable!);
      return _oldWidget!;
    }

    final newValue = widget.select!(widget.listenable!);

    bool flag;
    if (widget.shouldRebuild != null) {
      flag = widget.shouldRebuild!(newValue, _oldValue) == true;
    } else {
      flag = newValue != _oldValue;
    }

    if (flag) {
      _oldValue = newValue;
      _oldWidget = widget.builder(this, widget.child);
      return _oldWidget!;
    } else {
      _oldValue = newValue;
      return _oldWidget!;
    }
  }
}

/// 原生 [PopScope] 的变体，该小部件只执行最后一个拦截返回事件
class ElPopScope<T> extends StatefulWidget {
  const ElPopScope({
    super.key,
    required this.child,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.context,
    this.index = 0,
  });

  final Widget child;
  final bool canPop;
  final PopInvokedWithResultCallback<T>? onPopInvokedWithResult;

  /// 链接指定 context 对象
  final BuildContext? context;

  /// 当多个 PopScope 触发拦截返回事件时，其执行顺序无法确保一致，
  /// 你可以设置权重值来指定每个 PopScope 的执行优先级
  final int index;

  /// 收集触发的所有返回拦截函数，并在 1 毫秒后执行最后一条函数，然后立刻清空该集合
  static final SplayTreeMap<int, VoidCallback> _map = SplayTreeMap();

  @override
  State<ElPopScope<T>> createState() => _ElPopScopeState<T>();
}

class _ElPopScopeState<T> extends State<ElPopScope<T>> implements PopEntry<T> {
  ModalRoute<dynamic>? _route;

  BuildContext get _context => widget.context ?? context;

  @override
  void onPopInvoked(bool didPop) {
    throw UnimplementedError();
  }

  @override
  void onPopInvokedWithResult(bool didPop, T? result) {
    if (widget.canPop) return;

    void callback() {
      widget.onPopInvokedWithResult?.call(didPop, result);
    }

    ElPopScope._map[widget.index] = callback;

    ElAsyncUtil.setTimeout(() {
      if (ElPopScope._map.isNotEmpty) {
        ElPopScope._map[ElPopScope._map.lastKey()]?.call();
        ElPopScope._map.clear();
      }
    }, 1);
  }

  @override
  late final ValueNotifier<bool> canPopNotifier;

  @override
  void initState() {
    super.initState();
    canPopNotifier = ValueNotifier<bool>(widget.canPop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? nextRoute = ModalRoute.of(_context);
    if (nextRoute != _route) {
      _route?.unregisterPopEntry(this);
      _route = nextRoute;
      _route?.registerPopEntry(this);
    }
  }

  @override
  void didUpdateWidget(ElPopScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    canPopNotifier.value = widget.canPop;
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(this);
    canPopNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ElDragStartListener extends ReorderableDragStartListener {
  /// 识别长按拖拽小部件，通常用于拖拽列表
  const ElDragStartListener({super.key, required super.child, required super.index, super.enabled, this.delay});

  /// 自定义长按触发延迟，默认情况下：桌面端 100 毫秒，移动端 500 毫秒
  final Duration? delay;

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(
      debugOwner: this,
      delay: delay ?? (ElPlatform.isDesktop ? const Duration(milliseconds: 100) : kLongPressTimeout),
    );
  }
}

/// 使用 [ElApp] 所在的 context 访问 [MediaQuery] 对象填充安全边距，它与原生 [SafeArea] 的区别在于，
/// 祖先使用 SafeArea 添加安全内边距会删除使用的内边距，这会导致后代组件可能无法正确添加安全边距。
class ElSafeArea extends StatelessWidget {
  const ElSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = .zero,
    this.maintainBottomViewPadding = false,
    required this.child,
  });

  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appContext = el.context;
    EdgeInsets padding = MediaQuery.paddingOf(appContext);
    if (maintainBottomViewPadding) {
      padding = padding.copyWith(bottom: MediaQuery.viewPaddingOf(appContext).bottom);
    }

    return Padding(
      padding: .only(
        left: max(left ? padding.left : 0.0, minimum.left),
        top: max(top ? padding.top : 0.0, minimum.top),
        right: max(right ? padding.right : 0.0, minimum.right),
        bottom: max(bottom ? padding.bottom : 0.0, minimum.bottom),
      ),
      child: MediaQuery.removePadding(
        context: appContext,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: child,
      ),
    );
  }
}

/// 是否允许绘制子元素
class ElPaint extends SingleChildRenderObjectWidget {
  const ElPaint({super.key, this.disabled, super.child});

  /// 是否禁止绘制子元素
  final bool? disabled;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPaint(disabled);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderPaint).disabled = disabled;
  }
}

class _RenderPaint extends RenderProxyBox {
  _RenderPaint(this._disabled);

  bool? _disabled;

  set disabled(bool? v) {
    if (v == _disabled) {
      return;
    }
    _disabled = v;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_disabled == true) return;
    super.paint(context, offset);
  }
}

class ElFirstPaintCallback extends SingleChildRenderObjectWidget {
  /// 小部件首次触发绘制回调
  const ElFirstPaintCallback({super.key, required this.onCallback, required super.child});

  final VoidCallback onCallback;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _ElRenderFirstPaintCallback(onCallback);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _ElRenderFirstPaintCallback).onCallback = onCallback;
  }
}

class _ElRenderFirstPaintCallback extends RenderProxyBox {
  _ElRenderFirstPaintCallback(this.onCallback);

  VoidCallback onCallback;

  bool? flag = true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (flag == true) {
      flag = null;
      onCallback();
    }
    super.paint(context, offset);
  }
}

/// 创建一个代理命中测试小部件，它会收集后代 [ElPointerFollower] 的 RenderObject 对象，
/// 然后在 hitTestChildren 方法中调用它们的命中测试，用于解决 hitTestSelf 被剔除的事件命中问题：
/// https://github.com/flutter/flutter/issues/75747
///
/// 使用示例（Stack）：
/// ```dart
/// class Example extends StatelessWidget {
///   const Example({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     // 1. 在更大范围内的祖先小部件包裹 ElPointerTarget
///     return ElPointerTarget(
///       child: SizedBox(
///         width: 200,
///         height: 200,
///         child: Center(
///           child: Stack(
///             clipBehavior: Clip.none,
///             children: [
///               Container(
///                 width: 100,
///                 height: 100,
///                 color: Colors.grey,
///               ),
///               Positioned(
///                 left: -50,
///                 top: -50,
///                 // 2. 对溢出 Stack 范围的小部件包裹 ElPointerFollower
///                 child: ElPointerFollower(
///                   child: GestureDetector(
///                     onTap: () {
///                       print('tap');
///                     },
///                     child: Container(width: 100, height: 100, color: Colors.green),
///                   ),
///                 ),
///               ),
///             ],
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class ElPointerTarget extends SingleChildRenderObjectWidget {
  const ElPointerTarget({super.key, required super.child});

  @override
  RenderObject createRenderObject(context) => _RenderPointerTarget();
}

class _RenderPointerTarget extends RenderProxyBox {
  _RenderPointerTarget();

  final List<_RenderPointerFollower> followers = [];

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (int i = followers.length - 1; i >= 0; i--) {
      final hit = result.addWithPaintTransform(
        transform: followers[i].child!.getTransformTo(this),
        position: position,
        hitTest: (BoxHitTestResult result, Offset? position) {
          return followers[i].child!.hitTest(result, position: position!);
        },
      );
      if (hit) return true;
    }
    return super.hitTestChildren(result, position: position);
  }

  @override
  void dispose() {
    followers.clear();
    super.dispose();
  }
}

/// 将事件命中测试转移至 [ElPointerTarget]，应用场景：
/// * [Positioned] 定位的小部件超出 [Stack] 范围导致命中事件被剔除
/// * [Transform] 转换偏移导致命中事件被剔除
class ElPointerFollower extends SingleChildRenderObjectWidget {
  const ElPointerFollower({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    final result = context.findAncestorRenderObjectOfType<_RenderPointerTarget>();
    assert(result != null, 'ElPointerFollower Error: 当前 context 没有找到 ElPointerTarget 小部件！');

    return _RenderPointerFollower(result!.followers);
  }
}

class _RenderPointerFollower extends RenderProxyBox {
  _RenderPointerFollower(this.followers);

  final List<_RenderPointerFollower> followers;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    if (followers.contains(this) == false) followers.add(this);
  }

  @override
  void detach() {
    followers.remove(this);
    super.detach();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) => false;
}

class ElFadeTap extends StatelessWidget {
  const ElFadeTap({
    super.key,
    this.onTap,
    this.style,
    required this.child,
    this.opacity,
    this.hoverOpacity,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOut,
  });

  final PointerUpEventListener? onTap;
  final ElEventStyle? style;
  final Widget child;
  final double? opacity;
  final double? hoverOpacity;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    double hoverOpacity = this.hoverOpacity ?? (ElPlatform.isDesktop ? 0.56 : 1.0);

    double opacity = this.opacity ?? (ElPlatform.isDesktop ? hoverOpacity : 0.2);

    return ElEvent(
      style: ElEventStyle(onTap: onTap, behavior: HitTestBehavior.opaque).merge(style),
      child: Builder(
        builder: (context) {
          return AnimatedOpacity(
            duration: duration,
            curve: curve,
            opacity: context.hasTap
                ? opacity
                : context.hasHover
                ? hoverOpacity
                : 1.0,
            child: child,
          );
        },
      ),
    );
  }
}

class ElScaleTap extends StatelessWidget {
  const ElScaleTap({
    super.key,
    this.onTap,
    this.style,
    required this.child,
    this.duration = const Duration(milliseconds: 120),
    this.scale,
    this.hoverScale,
  });

  final PointerUpEventListener? onTap;
  final ElEventStyle? style;
  final Widget child;
  final Duration duration;
  final double? scale;
  final double? hoverScale;

  @override
  Widget build(BuildContext context) {
    double hoverScale = this.hoverScale ?? 1.0;
    double scale = this.scale ?? 0.96;

    return ElEvent(
      style: ElEventStyle(onTap: onTap, tapUpDelay: 100, behavior: HitTestBehavior.opaque).merge(style),
      child: Builder(
        builder: (context) {
          return AnimatedScale(
            duration: duration,
            curve: Curves.easeOut,
            scale: context.hasTap
                ? scale
                : context.hasHover
                ? hoverScale
                : 1.0,
            child: child,
          );
        },
      ),
    );
  }
}

/// 调试小部件
class ElDebugWidget extends SingleChildRenderObjectWidget {
  const ElDebugWidget({
    super.key,
    this.debugLabel,
    this.checkElementMount = false,
    this.checkElementUpdate = false,
    this.checkElementUnmount = false,
    this.checkRenderLayout = false,
    this.checkRenderPaint = false,
    this.filterTime,
    required super.child,
  });

  /// 调试标签
  final String? debugLabel;

  /// 检查 Element 挂载
  final bool checkElementMount;

  /// 检查 Element 更新
  final bool checkElementUpdate;

  /// 检查 Element 卸载
  final bool checkElementUnmount;

  /// 检查重排
  final bool checkRenderLayout;

  /// 检查重绘
  final bool checkRenderPaint;

  /// 过滤时间打印最低阈值
  final Duration? filterTime;

  @override
  SingleChildRenderObjectElement createElement() {
    return _DebugElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDebug(debugLabel, checkRenderLayout, checkRenderPaint, filterTime);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    renderObject as _RenderDebug
      ..debugLabel = debugLabel
      ..checkRenderLayout = checkRenderLayout
      ..checkRenderPaint = checkRenderPaint
      ..filterTime = filterTime;
  }
}

class _DebugElement extends SingleChildRenderObjectElement {
  _DebugElement(super.widget);

  @override
  ElDebugWidget get widget => super.widget as ElDebugWidget;

  @override
  void mount(Element? parent, Object? newSlot) {
    () {
      super.mount(parent, newSlot);
    }.time(
      enabled: widget.checkElementMount,
      debugLabel: widget.debugLabel,
      logPrefix: 'Element mount: ',
      filterTime: widget.filterTime,
      log: ElLog.d,
    );
  }

  @override
  void update(ElDebugWidget newWidget) {
    () {
      super.update(newWidget);
    }.time(
      enabled: newWidget.checkElementUpdate,
      debugLabel: newWidget.debugLabel,
      logPrefix: 'Element update: ',
      filterTime: newWidget.filterTime,
      log: ElLog.i,
    );
  }

  @override
  void unmount() {
    () {
      super.unmount();
    }.time(
      enabled: widget.checkElementUnmount,
      debugLabel: widget.debugLabel,
      logPrefix: 'Element unmount: ',
      filterTime: widget.filterTime,
      log: ElLog.e,
    );
  }
}

class _RenderDebug extends RenderProxyBox {
  _RenderDebug(this._debugLabel, this._checkRenderLayout, this._checkRenderPaint, this._filterTime);

  String? _debugLabel;

  set debugLabel(String? v) {
    if (_debugLabel == v) return;
    _debugLabel = v;
    markNeedsLayout();
  }

  bool _checkRenderLayout;

  set checkRenderLayout(bool v) {
    if (_checkRenderLayout == v) return;
    _checkRenderLayout = v;
    markNeedsLayout();
  }

  bool _checkRenderPaint;

  set checkRenderPaint(bool v) {
    if (_checkRenderPaint == v) return;
    _checkRenderPaint = v;
    markNeedsPaint();
  }

  Duration? _filterTime;

  set filterTime(Duration? v) {
    if (_filterTime == v) return;
    _filterTime = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    () {
      super.performLayout();
    }.time(
      enabled: _checkRenderLayout,
      debugLabel: _debugLabel,
      logPrefix: 'RenderObject performLayout: ',
      filterTime: _filterTime,
      log: ElLog.e,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    () {
      super.paint(context, offset);
    }.time(
      enabled: _checkRenderPaint,
      debugLabel: _debugLabel,
      logPrefix: 'RenderObject paint: ',
      filterTime: _filterTime,
      log: ElLog.w,
    );
  }
}

/// 显示当前帧率小部件
class ElFps extends StatelessWidget {
  const ElFps({super.key, this.show = true, this.color = Colors.green, required this.child, this.positionedBuilder});

  final Widget child;

  /// 是否显示帧率
  final bool show;

  /// 帧率文本颜色
  final Color color;

  /// 自定义构建帧率显示位置，你需要通过 [Positioned] 小部件设置定位
  final ElWidgetBuilder? positionedBuilder;

  TextStyle get textStyle => TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final fpsBuilder =
        positionedBuilder ??
        (context, child) => Positioned(top: MediaQuery.of(context).viewPadding.top + 64, right: 20, child: child);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          RepaintBoundary(child: child),
          fpsBuilder(
            context,
            ObsBuilder(
              builder: (context) {
                return IgnorePointer(child: show ? _ElFpsText(textStyle) : ElEmptyWidget.instance);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ElFpsText extends StatefulWidget {
  const _ElFpsText(this.style);

  final TextStyle style;

  @override
  State<_ElFpsText> createState() => _ElFpsTextState();
}

class _ElFpsTextState extends State<_ElFpsText> {
  /// 初始 fps 帧率，除了 ios、mac 等平台，其他平台的初始帧率需要设置为 -1，因为 [Ticker] 似乎会多执行一帧
  static final _initialFps = ElPlatform.isApple ? 0 : -1;

  /// 帧率显示值
  int fps = 0;

  /// 记录 1 秒内 [_ticker] 的回调次数
  int fpsTime = _initialFps;

  /// 帧率监控计时时间（微秒），每过 1 秒将刷新一次
  late int currentTime;

  /// Ticker 计时器，它内部会根据屏幕刷新信号触发帧回调
  late final Ticker _ticker = Ticker(_timerHandler);

  void _timerHandler(Duration timestamp) {
    if (timestamp.inMicroseconds - currentTime >= 1000000) {
      setState(() {
        fps = fpsTime;
      });
      fpsTime = _initialFps;
      currentTime = timestamp.inMicroseconds;
    }
    fpsTime++;
  }

  void _startTicker() {
    if (_ticker.isActive == false) {
      currentTime = 0;
      fpsTime = _initialFps;
      _ticker.start();
    }
  }

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$fps', style: widget.style);
  }
}

class ElDoubleQuit extends StatefulWidget {
  const ElDoubleQuit({super.key, required this.child, this.msg = '请再按一次退出 App', this.canPop}) : isRouter = false;

  const ElDoubleQuit.router({super.key, required this.child, this.msg = '请再按一次退出 App', this.canPop}) : isRouter = true;

  final bool isRouter;
  final Widget child;
  final String msg;

  /// 判断当前导航器是否允许退出路由，如果你没有使用原生 [Navigator] 进行导航，
  /// 那么你必须自定义此逻辑。
  ///
  /// 例如，当你使用 [go_router] 时，你必须使用它内置的 api，因为它在原生导航基础上判断了 ShellRouter 嵌套导航，
  /// 示例代码：
  /// ```dart
  /// GoRouter.of(context).canPop()
  /// ```
  final bool Function()? canPop;

  @override
  State<ElDoubleQuit> createState() => _ElDoubleQuitState();
}

class _ElDoubleQuitState extends State<ElDoubleQuit> {
  bool _flag = false;

  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRouter) {
      return BackButtonListener(
        onBackButtonPressed: () async {
          if ((widget.canPop ?? Navigator.of(context).canPop)()) {
            return false;
          } else {
            if (_flag) return false;
            el.toast.show(widget.msg);
            _flag = true;
            _timer = ElAsyncUtil.setTimeout(() {
              _timer = null;
              _flag = false;
            }, el.config.messageDuration);
            return true;
          }
        },
        child: widget.child,
      );
    } else {
      return ElPopScope(
        index: -9999,
        canPop: _flag,
        onPopInvokedWithResult: (didPop, result) {
          if ((widget.canPop ?? Navigator.of(context).canPop)() == false) {
            el.toast.show(widget.msg);
            setState(() {
              _flag = true;
            });
            _timer = ElAsyncUtil.setTimeout(() {
              _timer = null;
              setState(() {
                _flag = false;
              });
            }, el.config.messageDuration);
          }
        },
        child: widget.child,
      );
    }
  }
}

class ElChildSizeBuilder extends RenderObjectWidget {
  /// 在 build 过程中直接访问 child 尺寸的小部件，无需帧后回调，
  /// 其核心原理便是在进行实际布局前探测 [tempChild] 的尺寸，
  /// 然后将 size 传递给 [builder] 方法。
  ///
  /// 提示：使用该小部件需要注意性能问题，因为布局成本可能翻倍，创建该小部件的灵感来自此评论：
  /// https://github.com/flutter/flutter/issues/14488#issuecomment-675837800
  const ElChildSizeBuilder({super.key, this.constraints, required this.tempChild, required this.builder});

  /// 对 [tempChild] 添加尺寸约束，默认情况下 [tempChild] 使用的是 [ElChildSizeBuilder] 父级的尺寸约束，
  /// 但如果你实际构建的组件间接引用了新的约束，那么你应当将此约束应用给 [tempChild]
  final BoxConstraints? constraints;

  /// 需要计算尺寸的临时小部件，它参与布局但不进行渲染，布局完成后会拿到 size 并传递给 [builder] 回调
  final Widget tempChild;

  /// 实际构建的小部件，其回调参数便是 [tempChild] 的尺寸
  final Widget Function(Size size) builder;

  /// 判断组件是否处于临时布局中
  static bool isTempLayout(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ElChildSizeInheritedWidget>() != null;

  @override
  RenderObjectElement createElement() => _ElChildSizeElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => _ElRenderChildSizeBox(constraints);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _ElRenderChildSizeBox).builderConstraints = constraints;
  }
}

class _ElChildSizeElement extends RenderObjectElement {
  _ElChildSizeElement(super.widget);

  @override
  ElChildSizeBuilder get widget => super.widget as ElChildSizeBuilder;

  @override
  _ElRenderChildSizeBox get renderObject => super.renderObject as _ElRenderChildSizeBox;

  bool _needsBuild = true;
  Element? _tempChild;
  Element? _child;

  /// 探测尺寸的临时小部件需要排除焦点、语义，尤其是焦点，如果不排除将会破坏正常布局的聚焦，
  /// 你还可以通过 [ElChildSizeBuilder.isTempLayout] 方法判断组件是否处于临时布局中
  Widget get tempChildWidget => ExcludeSemantics(
    child: ExcludeFocus(child: _ElChildSizeInheritedWidget(child: widget.tempChild)),
  );

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child!);
    if (_tempChild != null) visitor(_tempChild!);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _tempChild = updateChild(_tempChild, tempChildWidget, #tempChild);
    renderObject._rebuild = _rebuild;
  }

  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    _tempChild = updateChild(_tempChild, tempChildWidget, #tempChild);
    renderObject.markNeedsLayout();
    _needsBuild = true;
  }

  @override
  void markNeedsBuild() {
    renderObject.markNeedsLayout();
    _needsBuild = true;
  }

  @override
  void performRebuild() {
    renderObject.markNeedsLayout();
    _needsBuild = true;
    super.performRebuild();
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant Object? slot) {
    if (slot == #tempChild) {
      renderObject.tempChild = child as RenderBox;
    } else if (slot == #child) {
      renderObject.child = child as RenderBox;
    }
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant Object? slot) {
    if (slot == #tempChild) {
      renderObject.tempChild = null;
    } else if (slot == #child) {
      renderObject.child = null;
    }
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {
    assert(false);
  }

  /// 当 [_tempChild] 的尺寸发生变化时，需要重新构建 builder 代码块
  Size? _oldTempChildSize;

  void _rebuild(Constraints constraints) {
    void updateChildCallback() {
      Widget result = widget.builder(renderObject.tempChildSize);
      _child = updateChild(_child, result, #child);
      _needsBuild = false;
      _oldTempChildSize = renderObject.tempChildSize;
    }

    owner!.buildScope(
      this,
      _needsBuild || _oldTempChildSize != renderObject.tempChildSize ? updateChildCallback : null,
    );
  }
}

class _ElRenderChildSizeBox extends RenderShiftedBox {
  _ElRenderChildSizeBox(this._builderConstraints) : super(null);

  LayoutCallback? _rebuild;

  Size get tempChildSize => _tempChildSize!;
  Size? _tempChildSize;

  RenderBox? _tempChild;

  set tempChild(RenderBox? v) {
    if (_tempChild == v) return;
    if (_tempChild != null) {
      dropChild(_tempChild!);
    }
    _tempChild = v;
    if (_tempChild != null) {
      adoptChild(_tempChild!);
    }
  }

  BoxConstraints? _builderConstraints;

  set builderConstraints(BoxConstraints? v) {
    if (_builderConstraints != v) {
      _builderConstraints = v;
      markNeedsLayout();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _tempChild?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _tempChild?.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    if (_tempChild != null) visitor(_tempChild!);
  }

  @override
  void performLayout() {
    // 对临时子组件进行布局，它的作用只用于探测尺寸，不做渲染
    _tempChild!.layout(_builderConstraints ?? constraints.loosen(), parentUsesSize: true);

    _tempChildSize = _tempChild!.size;

    // 调用 builder 代码块，将返回的 Widget 插入到 Element 树中
    if (_rebuild != null) invokeLayoutCallback(_rebuild!);

    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void dispose() {
    _tempChildSize = null;
    _rebuild = null;
    super.dispose();
  }
}

/// 子组件可以通过 [ElChildSizeBuilder.isTempLayout] 判断当前构建是否处于临时布局中，
/// 这样可以规避一些错误，例如：排除 [Focus] 焦点
class _ElChildSizeInheritedWidget extends InheritedWidget {
  const _ElChildSizeInheritedWidget({required super.child});

  @override
  bool updateShouldNotify(_ElChildSizeInheritedWidget oldWidget) => false;
}

class ElSecondChildWidget extends RenderObjectWidget {
  /// 允许在 [child] 上方、下方构建第二个小部件，它们的约束尺寸强制跟随 [child] 大小
  const ElSecondChildWidget({
    super.key,
    this.sizedByParent,
    this.secondChild,
    this.foregroundSecondChild,
    required this.child,
  });

  /// 强制布局尺寸跟随父元素，默认情况下布局尺寸会跟随 [child]
  final bool? sizedByParent;

  /// 渲染在 child 上方的子组件
  final Widget? secondChild;

  /// 渲染在 child 下方的子组件
  final Widget? foregroundSecondChild;

  /// 代理子组件
  final Widget child;

  @override
  RenderObjectElement createElement() => ElSecondChildElement(this);

  @override
  ElRenderSecondChildBox createRenderObject(BuildContext context) =>
      ElRenderSecondChildBox(sizedByParent: sizedByParent);

  @override
  void updateRenderObject(BuildContext context, ElRenderSecondChildBox renderObject) {
    renderObject.updateSizedByParent(sizedByParent);
  }
}

class ElSecondChildElement extends RenderObjectElement {
  ElSecondChildElement(super.widget);

  Element? childElement;
  Element? secondChildElement;
  Element? foregroundSecondChildElement;

  @override
  ElSecondChildWidget get widget => super.widget as ElSecondChildWidget;

  @override
  ElRenderSecondChildBox get renderObject => super.renderObject as ElRenderSecondChildBox;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (childElement != null) visitor(childElement!);
    if (secondChildElement != null) visitor(secondChildElement!);
    if (foregroundSecondChildElement != null) visitor(foregroundSecondChildElement!);
  }

  @override
  void forgetChild(Element child) {
    if (childElement == child) {
      childElement = null;
    } else if (secondChildElement == child) {
      secondChildElement = null;
    } else if (foregroundSecondChildElement == child) {
      foregroundSecondChildElement = null;
    }
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    childElement = updateChild(childElement, widget.child, #child);
    secondChildElement = updateChild(secondChildElement, widget.secondChild, #secondChild);
    foregroundSecondChildElement = updateChild(
      foregroundSecondChildElement,
      widget.foregroundSecondChild,
      #foregroundSecondChild,
    );
  }

  @override
  void update(ElSecondChildWidget newWidget) {
    super.update(newWidget);
    childElement = updateChild(childElement, widget.child, #child);
    secondChildElement = updateChild(secondChildElement, widget.secondChild, #secondChild);
    foregroundSecondChildElement = updateChild(
      foregroundSecondChildElement,
      widget.foregroundSecondChild,
      #foregroundSecondChild,
    );
  }

  @override
  void insertRenderObjectChild(RenderBox child, Object? slot) {
    if (slot == #child) {
      renderObject.child = child;
    } else if (slot == #secondChild) {
      renderObject.secondChild = child;
    } else if (slot == #foregroundSecondChild) {
      renderObject.foregroundSecondChild = child;
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, Object? slot) {
    if (slot == #child) {
      renderObject.child = null;
    } else if (slot == #secondChild) {
      renderObject.secondChild = null;
    } else if (slot == #foregroundSecondChild) {
      renderObject.foregroundSecondChild = child;
    }
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {}
}

class ElRenderSecondChildBox extends RenderProxyBox {
  ElRenderSecondChildBox({bool? sizedByParent}) {
    _sizedByParent = sizedByParent;
  }

  bool? _sizedByParent;

  void updateSizedByParent(bool? v) {
    if (_sizedByParent != v) {
      _sizedByParent = v;
      markNeedsLayout();
    }
  }

  RenderBox? _secondChild;

  RenderBox? get secondChild => _secondChild;

  set secondChild(RenderBox? value) {
    if (_secondChild != null) {
      dropChild(_secondChild!);
    }
    _secondChild = value;
    if (_secondChild != null) {
      adoptChild(_secondChild!);
    }
  }

  RenderBox? _foregroundSecondChild;

  RenderBox? get foregroundSecondChild => _foregroundSecondChild;

  set foregroundSecondChild(RenderBox? value) {
    if (_foregroundSecondChild != null) {
      dropChild(_foregroundSecondChild!);
    }
    _foregroundSecondChild = value;
    if (_foregroundSecondChild != null) {
      adoptChild(_foregroundSecondChild!);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _secondChild?.attach(owner);
    _foregroundSecondChild?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _secondChild?.detach();
    _foregroundSecondChild?.detach();
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    if (_secondChild != null) redepthChild(_secondChild!);
    if (_foregroundSecondChild != null) redepthChild(_foregroundSecondChild!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    if (_secondChild != null) visitor(_secondChild!);
    if (_foregroundSecondChild != null) visitor(_foregroundSecondChild!);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  bool get sizedByParent => _sizedByParent ?? child == null;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    assert(
      constraints.biggest.isInfinite == false,
      'ElSecondChildWidget 没有指定 child 小部件，它的尺寸将跟随父元素，但是 parent 传递的约束为 infinity 无限大小: \n$constraints\n\n'
      '要修复此错误，请将 ElSecondChildWidget 包裹在有限尺寸的容器内，或者指定 child 小部件！',
    );
    return constraints.biggest;
  }

  @override
  void performLayout() {
    if (child != null) {
      if (sizedByParent) {
        child!.layout(constraints.loosen());
      } else {
        child!.layout(constraints.loosen(), parentUsesSize: true);
        size = constraints.constrain(child!.size);
      }
    }

    secondChild?.layout(BoxConstraints.tight(size));
    foregroundSecondChild?.layout(BoxConstraints.tight(size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (foregroundSecondChild != null) context.paintChild(foregroundSecondChild!, offset);
    context.paintChild(child!, offset);
    if (secondChild != null) context.paintChild(secondChild!, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (secondChild?.hitTest(result, position: position) == true) return true;
    if (child?.hitTest(result, position: position) == true) return true;
    if (foregroundSecondChild?.hitTest(result, position: position) == true) return true;
    return false;
  }
}

/// 布局、渲染多个子节点的小部件，该小部件是 [MultiChildRenderObjectWidget] 的简化版本，
/// 它只使用 [Key] 来放置 [children] 插槽，在 [ElRenderMultiBox] 中，允许用户使用 key
/// 来访问 [children] 实例化的 RenderObject 对象。
///
/// 注意：该小部件所创建的 [ElMultiElement]、[ElRenderMultiBox] 不会处理 children 的顺序，
/// 你不能将其用在动态 [children] 的场景中。
abstract class ElMultiWidget extends RenderObjectWidget {
  const ElMultiWidget({
    super.key,
    this.debugLabel = _debugLabel,
    this.sizedByParent,
    this.ignoreChildrenUpdate,
    required this.children,
    this.child,
  });

  static const _debugLabel = 'ElMultiWidget';

  /// 打印 assert 错误断言名称
  final String debugLabel;

  /// 强制布局尺寸跟随父元素
  final bool? sizedByParent;

  /// 是否忽略 [children] diff 更新
  final bool? ignoreChildrenUpdate;

  /// 子节点集合，注意：每个子节点必须设置 key 作为唯一标识，
  /// 因为 [ElMultiElement] 只使用 key 来作为元素 slot 插槽
  final Iterable<Widget> children;

  /// 代理子类，所有的子节点将绘制在目标小部件之上，如果为 null，布局大小将跟随父元素
  final Widget? child;

  @override
  ElMultiElement createElement() => ElMultiElement(this);

  @override
  void updateRenderObject(BuildContext context, covariant ElRenderMultiBox renderObject) {
    renderObject.updateSizedByParent(sizedByParent);
  }
}

class ElMultiElement extends RenderObjectElement {
  ElMultiElement(super.widget);

  Element? child;

  final Map<Key, Element?> children = {};

  @override
  ElMultiWidget get widget => super.widget as ElMultiWidget;

  @override
  ElRenderMultiBox get renderObject => super.renderObject as ElRenderMultiBox;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) visitor(child!);
    for (final child in children.values) {
      if (child != null) visitor(child);
    }
  }

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    if (child.slot == null) {
      this.child = null;
    } else {
      children.remove(child.slot);
    }
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    child = updateChild(null, widget.child, null);
    for (final child in widget.children) {
      assert(child.key != null, '${widget.debugLabel} mount 出现错误，children 子元素必须全部设置 key：$child');
      assert(
        children.containsKey(child.key) == false,
        '${widget.debugLabel} mount 出现错误，children 列表出现重复的 key 元素：${child.key}',
      );
      children[child.key!] = updateChild(null, child, child.key);
    }
  }

  @override
  void update(ElMultiWidget newWidget) {
    super.update(newWidget);
    child = updateChild(child, widget.child, null);

    if (newWidget.ignoreChildrenUpdate == true) return;

    updateMultiChildren(newWidget);
  }

  /// 默认的更新 children 元素方法
  @protected
  void updateMultiChildren(ElMultiWidget newWidget) {
    // 将 List -> Map 结构
    final newMap = {};
    for (final child in widget.children) {
      assert(child.key != null, '${widget.debugLabel} update 出现错误，children 子元素必须全部设置 key：$child');
      newMap[child.key!] = child;
    }

    // 记录需要更新的节点 key、需要移除的节点 key
    final List<Key> updateKeys = [], removeKeys = [];

    // 对比新旧集合，提取出已存在、需要移除的元素节点
    for (final key in children.keys) {
      newMap.containsKey(key) ? updateKeys.add(key) : removeKeys.add(key);
    }

    // 移除被删除的元素节点
    for (final key in removeKeys) {
      updateChild(children[key], null, key);
      children.remove(key);
    }

    // 更新旧数据，并且从新的集合中移除它们，保留需要新增的元素节点
    for (final key in updateKeys) {
      children[key] = updateChild(children[key], newMap[key], key);
      newMap.remove(key);
    }

    // 将新增的元素节点挂载到 Element 树中
    for (final item in newMap.entries) {
      children[item.key!] = updateChild(null, item.value, item.key);
    }
  }

  @override
  void unmount() {
    super.unmount();
    child = null;
    children.clear();
  }

  @override
  void insertRenderObjectChild(RenderBox child, Object? slot) {
    if (slot == null) {
      renderObject.child = child;
    } else {
      renderObject.insert(slot as Key, child);
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, Object? slot) {
    if (slot == null) {
      renderObject.child = null;
    } else {
      renderObject.remove(slot as Key, child);
    }
  }

  @override
  void moveRenderObjectChild(child, oldSlot, newSlot) {
    assert(false, '${widget.debugLabel} 禁止动态增删子元素，因为这会导致显示可能和预期不符！');
  }
}

/// 多节点渲染对象，children 实例化的 RenderObject 对象会存放在 [renderBoxMap] 集合，
/// 你可以通过 [Key] 访问目标渲染对象，然后需要自行实现 [performLayout]、[paint]、[hitTestChildren] 方法
abstract class ElRenderMultiBox extends RenderProxyBox with ElMapRenderObjectMixin {
  ElRenderMultiBox({this.debugLabel = ElMultiWidget._debugLabel, bool? sizedByParent}) : _sizedByParent = sizedByParent;

  String debugLabel;
  bool? _sizedByParent;

  void updateSizedByParent(bool? v) {
    if (_sizedByParent != v) {
      _sizedByParent = v;
      markNeedsLayout();
    }
  }

  @protected
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  /// 若没有指定 child，那么大小将跟随父元素
  @override
  bool get sizedByParent => _sizedByParent ?? child == null;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    assert(
      constraints.biggest.isInfinite == false,
      '$debugLabel 没有指定 child 小部件，它的尺寸将跟随父元素，但是 parent 传递的约束为 infinity 无限大小: \n$constraints\n\n'
      '要修复此错误，请将 $debugLabel 包裹在有限尺寸的容器内，或者指定 child 小部件！',
    );
    return constraints.biggest;
  }

  @override
  void performLayout() {
    // 仅布局 child 代理小部件，你需要自行处理 children 布局逻辑
    if (child != null) {
      if (sizedByParent) {
        child!.layout(constraints);
      } else {
        child!.layout(constraints, parentUsesSize: true);
        size = constraints.constrain(child!.size);
      }
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = (child.parentData as BoxParentData).offset;
    transform.translateByDouble(offset.dx, offset.dy, 0.0, 1.0);
  }

  @override
  void dispose() {
    _sizedByParent = null;
    super.dispose();
  }
}

/// 使用 Map 集合保存 RenderObject 对象
mixin ElMapRenderObjectMixin on RenderObject {
  final Map<Key, RenderBox> renderBoxMap = {};

  void insert(Key key, RenderBox child) {
    adoptChild(child);
    renderBoxMap[key] = child;
  }

  void remove(Key key, RenderBox child) {
    dropChild(child);
    renderBoxMap.remove(key);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final child in renderBoxMap.values) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    for (final child in renderBoxMap.values) {
      child.detach();
    }
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    for (final child in renderBoxMap.values) {
      redepthChild(child);
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    for (final child in renderBoxMap.values) {
      visitor(child);
    }
  }

  @override
  void dispose() {
    renderBoxMap.clear();
    super.dispose();
  }
}

/// 切换多个子组件时会缓存旧的实例
class ElKeepAlive extends RenderObjectWidget {
  const ElKeepAlive({super.key, required this.child});

  /// 动态子组件，当每次更新子组件时，旧的组件依然会保留在 Element 树中（组件必须设置 key）
  final Widget child;

  @override
  RenderObjectElement createElement() => ElKeepAliveElement(this);

  @override
  ElRenderKeepAlive createRenderObject(BuildContext context) {
    assert(child.key != null, 'ElKeepAlive Error: child 需要设置 key');
    return ElRenderKeepAlive(key: child.key!);
  }

  @override
  void updateRenderObject(BuildContext context, covariant ElRenderKeepAlive renderObject) {
    assert(child.key != null, 'ElKeepAlive Error: child 需要设置 key');
    renderObject.key = child.key!;
  }
}

class ElKeepAliveElement extends RenderObjectElement {
  ElKeepAliveElement(super.widget);

  final Map<Key, Element?> children = {};

  @override
  ElKeepAlive get widget => super.widget as ElKeepAlive;

  @override
  ElRenderKeepAlive get renderObject => super.renderObject as ElRenderKeepAlive;

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final child in children.values) {
      if (child != null) visitor(child);
    }
  }

  @protected
  @override
  void forgetChild(Element child) {
    super.forgetChild(child);
    children.remove(child.slot);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    children[widget.child.key!] = updateChild(null, widget.child, widget.child.key);
  }

  @override
  void update(ElKeepAlive newWidget) {
    super.update(newWidget);
    assert(newWidget.child.key != null, 'ElKeepAliveElement update 出现错误，child 必须设置 key');
    children[newWidget.child.key!] = updateChild(children[newWidget.child.key!], newWidget.child, newWidget.child.key);
  }

  @override
  void unmount() {
    super.unmount();
    children.clear();
  }

  @override
  void insertRenderObjectChild(RenderBox child, Object? slot) {
    renderObject.insert(slot as Key, child);
  }

  @override
  void removeRenderObjectChild(RenderBox child, Object? slot) {
    renderObject.remove(slot as Key, child);
  }

  @override
  void moveRenderObjectChild(child, oldSlot, newSlot) {
    assert(false);
  }
}

class ElRenderKeepAlive extends RenderBox with ElMapRenderObjectMixin {
  ElRenderKeepAlive({required Key key}) : _key = key;

  Key? _key;

  Key get key => _key!;

  set key(Key key) {
    if (_key == key) return;
    _key = key;
    markNeedsLayout();
  }

  RenderBox get child => renderBoxMap[key]!;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void performLayout() {
    for (final child in renderBoxMap.values) {
      child.layout(constraints, parentUsesSize: true);
    }
    size = child.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child.hitTest(result, position: position);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = (child.parentData as BoxParentData).offset;
    transform.translateByDouble(offset.dx, offset.dy, 0.0, 1.0);
  }
}

/// 对局部组件应用触控重采样，此组件可以解决高刷安卓触控抖动问题（仅限安卓）
class ElLocalResampling extends StatelessWidget {
  const ElLocalResampling({super.key, required this.child});

  final Widget child;

  /// 对不同帧率的手机应用不同的采样间隔，如果手机刷新率为 60hz，那么没必要开启重采样，
  /// 对于高刷、以及更高刷新率的手机，指定更短的间隔时间可以尽可能减少触控延迟。
  ///
  /// 如果此逻辑存在任何问题，你可以在 main 方法中覆写此函数。
  static var samplingBuilder = (double fps) {
    if (fps < 65) return null;
    if (65 <= fps && fps < 95) return Duration(milliseconds: -14);
    if (95 <= fps && fps < 125) return Duration(milliseconds: -10);
    return Duration(milliseconds: -8);
  };

  @override
  Widget build(BuildContext context) {
    if (kIsWeb == false && ElPlatform.isAndroid) {
      return _LocalResampling(child: child);
    }
    return child;
  }
}

class _LocalResampling extends StatefulWidget {
  const _LocalResampling({required this.child});

  final Widget child;

  @override
  State<_LocalResampling> createState() => _LocalResamplingState();
}

class _LocalResamplingState extends State<_LocalResampling> {
  /// 当前重采样间隔，由 [ElLocalResampling.samplingBuilder] 提供，若为 null 则不会监听触摸事件
  Duration? samplingOffset;

  /// 记录当前移动次数
  int moveCount = 0;

  /// 延迟关闭重采样，当重采样已经启用时，手指抬起、短时间内又快速滑动（包括轻触），
  /// 会继续保持重采样状态
  Timer? delayCancelTimer;

  void onPointerMove(PointerMoveEvent e) {
    if (GestureBinding.instance.resamplingEnabled) {
      if (delayCancelTimer != null) {
        delayCancelTimer!.cancel();
        delayCancelTimer = null;
      }
    } else {
      moveCount++;
      // 当手指在屏幕上连续移动 60 次才开启重采样，该值不应当太小，否则页面可能会出现停顿感
      if (moveCount >= 60) {
        GestureBinding.instance.resamplingEnabled = true;
      }
    }
  }

  void closeResampling() {
    if (GestureBinding.instance.resamplingEnabled) {
      GestureBinding.instance.resamplingEnabled = false;
    }
    moveCount = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fps = ElFlutterUtil.getFps();
    if (fps != null) {
      samplingOffset = ElLocalResampling.samplingBuilder(fps);
      if (samplingOffset != null) {
        GestureBinding.instance.samplingOffset = samplingOffset!;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (delayCancelTimer != null) {
      delayCancelTimer!.cancel();
      delayCancelTimer = null;
    }
    closeResampling();
  }

  @override
  Widget build(BuildContext context) {
    if (samplingOffset == null) return widget.child;
    return Listener(
      onPointerMove: onPointerMove,
      onPointerUp: (e) {
        delayCancelTimer = ElAsyncUtil.setTimeout(() {
          closeResampling();
        }, 3000);
      },
      onPointerCancel: (e) {
        closeResampling();
      },
      child: widget.child,
    );
  }
}
