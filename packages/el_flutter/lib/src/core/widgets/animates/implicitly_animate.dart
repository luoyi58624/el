import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef ElTweenVisitor = void Function(String key, dynamic targetValue, Tween tween);

/// Hook 版本的隐式动画小部件，它类似于官方提供的 [ImplicitlyAnimatedWidget] 小部件，
/// 其子类需要实现 [effects]、[forEachTween]、[buildAnimatedWidget] 三个抽象方法
abstract class ElImplicitlyAnimatedWidget extends HookWidget {
  const ElImplicitlyAnimatedWidget({
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
    this.onEnd,
    this.child,
  });

  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;
  final Widget? child;

  /// 副作用数组，当数组内的任意属性发生变化时，将会重新执行动画，注意：如果是一个对象，请务必重写 ==、hashCode 比较方法
  @protected
  List<Object?> get effects;

  /// 创建、更新 Tween 对象回调，其回调需要包含三个参数：
  /// 1. tweenMap 集合 key
  /// 2. targetValue 动画目标值
  /// 3. tween 目标值所对应的 Tween 对象
  @protected
  void forEachTween(ElTweenVisitor visitor);

  /// 构建动画小部件
  @protected
  Widget buildAnimatedWidget(BuildContext context, CurvedAnimation animation, Map<dynamic, Tween<dynamic>?> tweenMap);

  @protected
  @override
  Widget build(BuildContext context) {
    final globalAnimation = el.globalAnimation(duration, curve);
    final controller = useAnimationController(duration: globalAnimation.$1);
    final animation = useCurvedAnimation(parent: controller, curve: globalAnimation.$2);
    final tweenMap = useMemoized<Map<dynamic, Tween?>>(() => {});
    final proxy = useProxyHookWidget(this);

    useEffect(() {
      forEachTween((String key, dynamic targetValue, Tween<dynamic> tween) {
        if (targetValue != null) {
          tweenMap[key] = tween
            ..begin = targetValue
            ..end = targetValue;
        }
      });
      controller.addStatusListener((status) {
        if (status.isCompleted) {
          proxy.widget.onEnd?.call();
        }
      });
      return () => tweenMap.clear();
    }, []);

    useUpdateEffect(() {
      forEachTween((String key, dynamic targetValue, Tween<dynamic> tween) {
        if (targetValue == null) {
          tweenMap.remove(key);
        } else {
          final target = tweenMap[key];
          if (target != null && target.end != null) {
            tweenMap[key] = target
              ..begin = target.evaluate(animation)
              ..end = targetValue;
          } else {
            tweenMap[key] = tween
              ..begin = targetValue
              ..end = targetValue;
          }
        }
      });
      controller.forward(from: 0);
      return null;
    }, effects);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return buildAnimatedWidget(context, animation, tweenMap);
      },
    );
  }
}

/// 动画颜色盒子
class ElAnimatedColoredBox extends ElImplicitlyAnimatedWidget {
  const ElAnimatedColoredBox({super.key, required this.color, super.duration, super.curve, super.onEnd, super.child});

  final Color color;

  @override
  List<Object?> get effects => [color];

  @override
  void forEachTween(visitor) => visitor('color', color, ColorTween());

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return ColoredBox(color: (tweenMap['color']! as ColorTween).evaluate(animation)!, child: child);
  }
}

/// 动画装饰器盒子
class ElAnimatedDecoratedBox extends ElImplicitlyAnimatedWidget {
  const ElAnimatedDecoratedBox({
    super.key,
    this.position = .background,
    required this.decoration,
    super.duration,
    super.curve,
    super.onEnd,
    super.child,
  });

  final DecorationPosition position;
  final BoxDecoration decoration;

  @override
  List<Object?> get effects => [decoration];

  @override
  void forEachTween(visitor) => visitor('decoration', decoration, DecorationTween());

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return DecoratedBox(
      position: position,
      decoration: (tweenMap['decoration']! as DecorationTween).evaluate(animation),
      child: child,
    );
  }
}

class ElOffsetTween extends Tween<Offset?> {
  ElOffsetTween({super.begin, super.end});

  @override
  Offset? lerp(double t) => Offset.lerp(begin, end, t);
}

/// 动画 Offset 偏移
class ElAnimatedOffset extends ElImplicitlyAnimatedWidget {
  const ElAnimatedOffset({super.key, required this.offset, super.duration, super.curve, super.onEnd, super.child});

  final Offset offset;

  @override
  List<Object?> get effects => [offset];

  @override
  void forEachTween(visitor) => visitor('offset', offset, ElOffsetTween());

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return Transform.translate(offset: (tweenMap['offset']! as ElOffsetTween).evaluate(animation)!, child: child);
  }
}

class ElIconThemeTween extends Tween<IconThemeData> {
  ElIconThemeTween({super.begin, super.end});

  @override
  IconThemeData lerp(double t) => IconThemeData.lerp(begin, end, t);
}

class ElAnimatedIconTheme extends ElImplicitlyAnimatedWidget {
  const ElAnimatedIconTheme({
    super.key,
    required this.data,
    super.duration,
    super.curve,
    super.onEnd,
    required super.child,
  });

  final IconThemeData data;

  @override
  List<Object?> get effects => [data];

  @override
  void forEachTween(visitor) => visitor('data', data, ElIconThemeTween());

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return IconTheme(data: (tweenMap['data']! as ElIconThemeTween).evaluate(animation), child: child!);
  }
}

/// 动画版本 [Material] 小部件
class ElAnimatedMaterial extends ElImplicitlyAnimatedWidget {
  const ElAnimatedMaterial({
    super.key,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    super.duration,
    super.curve,
    super.onEnd,
    super.child,
  });

  final MaterialType type;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final TextStyle? textStyle;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip clipBehavior;
  final BorderRadiusGeometry? borderRadius;

  @override
  List<Object?> get effects => [elevation, color, shadowColor, surfaceTintColor, textStyle, shape];

  @override
  void forEachTween(visitor) {
    visitor('elevation', elevation, Tween<double>());
    visitor('color', color, ColorTween());
    visitor('shadowColor', shadowColor, ColorTween());
    visitor('surfaceTintColor', surfaceTintColor, ColorTween());
    visitor('textStyle', textStyle, TextStyleTween());
    visitor('shape', shape, ShapeBorderTween());
  }

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return Material(
      animationDuration: .zero,
      type: type,
      elevation: (tweenMap['elevation']! as Tween<double>).evaluate(animation),
      color: color == null ? null : (tweenMap['color']! as ColorTween).evaluate(animation)!,
      shadowColor: shadowColor == null ? null : (tweenMap['shadowColor']! as ColorTween).evaluate(animation)!,
      surfaceTintColor: surfaceTintColor == null
          ? null
          : (tweenMap['surfaceTintColor']! as ColorTween).evaluate(animation)!,
      textStyle: textStyle == null ? null : (tweenMap['textStyle']! as TextStyleTween).evaluate(animation),
      shape: shape == null ? null : (tweenMap['shape']! as ShapeBorderTween).evaluate(animation)!,
      borderOnForeground: borderOnForeground,
      clipBehavior: clipBehavior,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

/// 动画版本 [Ink] 小部件
class ElAnimatedInk extends ElImplicitlyAnimatedWidget {
  const ElAnimatedInk({
    super.key,
    this.padding,
    this.decoration,
    this.width,
    this.height,
    super.duration,
    super.curve,
    super.onEnd,
    super.child,
  });

  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final double? width;
  final double? height;

  @override
  List<Object?> get effects => [padding, decoration, width, height];

  @override
  void forEachTween(visitor) {
    visitor('padding', padding, EdgeInsetsTween());
    visitor('decoration', decoration, DecorationTween());
    visitor('width', width, Tween<double>());
    visitor('height', height, Tween<double>());
  }

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return Ink(
      padding: padding == null ? null : (tweenMap['padding']! as EdgeInsetsTween).evaluate(animation),
      decoration: decoration == null ? null : (tweenMap['decoration']! as DecorationTween).evaluate(animation),
      width: width == null ? null : (tweenMap['width']! as Tween<double>).evaluate(animation),
      height: height == null ? null : (tweenMap['height']! as Tween<double>).evaluate(animation),
      child: child,
    );
  }
}

/// 动画刷新指示器
class ElAnimatedRefreshProgressIndicator extends ImplicitlyAnimatedWidget {
  const ElAnimatedRefreshProgressIndicator({
    super.key,
    super.duration = const Duration(milliseconds: 300),
    super.curve,
    super.onEnd,
    this.value,
    this.color,
    this.backgroundColor,
    this.valueColor,
    this.strokeWidth = 2.5,
    this.strokeAlign = 0.0,
    this.strokeCap,
    this.semanticsLabel,
    this.semanticsValue,
    this.elevation = 2.0,
    this.indicatorMargin = const .all(4.0),
    this.indicatorPadding = const .all(12.0),
  });

  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  final double strokeAlign;
  final StrokeCap? strokeCap;
  final String? semanticsLabel;
  final String? semanticsValue;
  final double elevation;
  final EdgeInsetsGeometry indicatorMargin;
  final EdgeInsetsGeometry indicatorPadding;

  @override
  AnimatedWidgetBaseState<ElAnimatedRefreshProgressIndicator> createState() => _AnimatedRefreshProgressIndicatorState();
}

class _AnimatedRefreshProgressIndicatorState extends AnimatedWidgetBaseState<ElAnimatedRefreshProgressIndicator> {
  ColorTween? _color;
  ColorTween? _backgroundColor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color = visitor(_color, widget.color, (dynamic value) => ColorTween(begin: value as Color)) as ColorTween?;
    _backgroundColor =
    visitor(_backgroundColor, widget.backgroundColor, (dynamic value) => ColorTween(begin: value as Color))
    as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshProgressIndicator(
      value: widget.value,
      color: _color?.evaluate(animation),
      backgroundColor: _backgroundColor?.evaluate(animation),
      valueColor: widget.valueColor,
      strokeWidth: widget.strokeWidth,
      strokeAlign: widget.strokeAlign,
      strokeCap: widget.strokeCap,
      semanticsLabel: widget.semanticsLabel,
      semanticsValue: widget.semanticsValue,
      elevation: widget.elevation,
      indicatorMargin: widget.indicatorMargin,
      indicatorPadding: widget.indicatorPadding,
    );
  }
}
