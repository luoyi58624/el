import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

/// 盒子小部件
class ElBox extends StatelessWidget {
  const ElBox({super.key, this.duration = .zero, this.curve = Curves.linear, this.style, this.child});

  final Duration duration;
  final Curve curve;
  final ElBoxStyle? style;

  /// 如果子组件不是 Widget 类型，则默认渲染为文本
  final dynamic child;

  @override
  Widget build(BuildContext context) {
    Widget? child;

    if (this.child != null) {
      child = this.child is Widget ? this.child : ElRichText(this.child.toString());
    }

    return _AnimatedBox(duration: duration, curve: curve, style: style, child: child);
  }
}

class _Box extends StatelessWidget {
  const _Box({this.style, this.child});

  final ElBoxStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget? result = child;

    if (style != null) {
      final constraints = style!.toBoxConstraints;

      if (result == null && (constraints == null || !constraints.isTight)) {
        result = LimitedBox(
          maxWidth: 0.0,
          maxHeight: 0.0,
          child: ConstrainedBox(constraints: const BoxConstraints.expand()),
        );
      } else if (style!.alignment != null) {
        result = Align(alignment: style!.alignment!, child: result);
      }

      if (style!.padding != null) {
        result = Padding(padding: style!.padding!, child: result);
      }

      if (constraints != null) {
        result = ConstrainedBox(constraints: constraints, child: result);
      }

      if (style!.decoration != null) {
        if (style!.clipBehavior != null && style!.clipBehavior != Clip.none) {
          result = ClipPath(clipper: style!.buildClipper(context), clipBehavior: style!.clipBehavior!, child: result);
        }

        result = DecoratedBox(decoration: style!.decoration!, child: result);
        if (style!.decoration!.color != null) {
          result = ElDefaultColor(style!.decoration!.color!, child: result);
        }
      }

      Matrix4? transform = style!.toMatrix4;

      if (transform != null) {
        result = Transform(transform: transform, alignment: style!.transformAlignment, child: result);
      }

      if (style!.margin != null) {
        result = Padding(padding: style!.margin!, child: result);
      }
    }

    return result ?? ElEmptyWidget.instance;
  }
}

/// 动画装饰器盒子
class _AnimatedBox extends ElImplicitlyAnimatedWidget {
  const _AnimatedBox({required super.duration, super.curve, this.style, super.child});

  final ElBoxStyle? style;

  @override
  List<Object?> get effects => [style];

  @override
  void forEachTween(visitor) {
    visitor('constraints', style?.toBoxConstraints, BoxConstraintsTween());
    visitor('margin', style?.margin, EdgeInsetsTween());
    visitor('padding', style?.padding, EdgeInsetsTween());
    visitor('alignment', style?.alignment, AlignmentTween());
    visitor('decoration', style?.decoration, DecorationTween());
    visitor('transform', style?.toMatrix4, Matrix4Tween());
    visitor('transformAlignment', style?.transformAlignment, AlignmentGeometryTween());
  }

  @override
  Widget buildAnimatedWidget(context, animation, tweenMap) {
    return _Box(
      style: ElBoxStyle(
        clipBehavior: style?.clipBehavior,
        constraints: (tweenMap['constraints'] as BoxConstraintsTween?)?.evaluate(animation),
        margin: (tweenMap['margin'] as EdgeInsetsTween?)?.evaluate(animation),
        padding: (tweenMap['padding'] as EdgeInsetsTween?)?.evaluate(animation),
        alignment: (tweenMap['alignment'] as AlignmentTween?)?.evaluate(animation),
        decoration: (tweenMap['decoration'] as DecorationTween?)?.evaluate(animation) as BoxDecoration?,
        transform: (tweenMap['transform'] as Matrix4Tween?)?.evaluate(animation),
        transformAlignment: (tweenMap['transformAlignment'] as AlignmentGeometryTween?)?.evaluate(animation),
      ),
      child: child,
    );
  }
}
