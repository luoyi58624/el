import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ElAndroidPageTransitionsBuilder extends PageTransitionsBuilder {
  const ElAndroidPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ElAndroidPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// 安卓页面过渡动画
class ElAndroidPageTransition extends HookWidget {
  const ElAndroidPageTransition({
    super.key,
    required this.child,
    required this.primaryRouteAnimation,
    required this.secondaryRouteAnimation,
  });

  final Widget child;
  final Animation<double> primaryRouteAnimation;
  final Animation<double> secondaryRouteAnimation;

  @override
  Widget build(BuildContext context) {
    final primaryAnimation = useCurvedAnimation(
      parent: primaryRouteAnimation,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
    ).drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero));

    final secondaryAnimation = useCurvedAnimation(
      parent: secondaryRouteAnimation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeInToLinear,
    ).drive(Tween(begin: Offset.zero, end: const Offset(-1.0 / 3.0, 0.0)));

    final boxAnimation =
        useCurvedAnimation(
          parent: secondaryRouteAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic.flipped,
        ).drive(
          DecorationTween(
            begin: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0)),
            end: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.64)),
          ),
        );

    return SlideTransition(
      position: secondaryAnimation,
      child: SlideTransition(
        position: primaryAnimation,
        child: DecoratedBoxTransition(decoration: boxAnimation, position: DecorationPosition.foreground, child: child),
      ),
    );
  }
}
