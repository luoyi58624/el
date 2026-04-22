part of 'index.dart';

/// Element 默认滚动配置
class ElScrollBehavior extends ScrollBehavior {
  const ElScrollBehavior({this.scrollbarBuilder, this.overscrollIndicatorBuilder, this.scrollPhysicsBuilder});

  /// 构建自定义默认的滚动条
  final Widget Function(BuildContext context, Widget child, ScrollableDetails details)? scrollbarBuilder;

  /// 构建自定义默认的过度滚动动画
  final Widget Function(BuildContext context, Widget child, ScrollableDetails details)? overscrollIndicatorBuilder;

  /// 构建自定义默认的滚动行为
  final ScrollPhysics Function(BuildContext context)? scrollPhysicsBuilder;

  ElScrollBehavior merge(ElScrollBehavior? other) {
    if (other == null) return this;
    return ElScrollBehavior(
      scrollbarBuilder: other.scrollbarBuilder ?? scrollbarBuilder,
      overscrollIndicatorBuilder: other.overscrollIndicatorBuilder ?? overscrollIndicatorBuilder,
      scrollPhysicsBuilder: other.scrollPhysicsBuilder ?? scrollPhysicsBuilder,
    );
  }

  @override
  Widget buildScrollbar(context, child, details) {
    return (scrollbarBuilder ?? defaultScrollbarBuilder)(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(context, child, details) {
    return (overscrollIndicatorBuilder ?? defaultOverscrollIndicatorBuilder)(context, child, details);
  }

  @override
  ScrollPhysics getScrollPhysics(context) {
    return (scrollPhysicsBuilder ?? defaultScrollPhysicsBuilder)(context);
  }

  static Widget defaultScrollbarBuilder(BuildContext context, Widget child, ScrollableDetails details) {
    if (ElPlatform.isDesktop) {
      return ElScrollbar(controller: details.controller, child: child);
    }

    return Scrollbar(controller: details.controller, child: child);
  }

  static Widget defaultOverscrollIndicatorBuilder(BuildContext context, Widget child, ScrollableDetails details) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return StretchingOverscrollIndicator(axisDirection: details.direction, clipBehavior: .hardEdge, child: child);
    }
  }

  static ScrollPhysics defaultScrollPhysicsBuilder(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return const BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics());
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
          parent: RangeMaintainingScrollPhysics(),
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const _ClampingScrollPhysics();
    }
  }
}

class _ClampingScrollPhysics extends ClampingScrollPhysics {
  const _ClampingScrollPhysics();

  @override
  bool recommendDeferredLoading(velocity, metrics, context) => false;

  @override
  Simulation? createBallisticSimulation(position, velocity) {
    final Tolerance tolerance = toleranceFor(position);

    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return FrictionSimulation(0.135, position.pixels, velocity, constantDeceleration: 10);
    }
    return null;
  }
}
