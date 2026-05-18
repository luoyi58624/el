import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

class ElColorTransition extends AnimatedWidget {
  const ElColorTransition({super.key, required this.color, this.child}) : super(listenable: color);

  final Animation<Color?> color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: color.value ?? Colors.transparent, child: child);
  }
}

class ElOffsetTransition extends AnimatedWidget {
  const ElOffsetTransition({super.key, required this.offset, this.child}) : super(listenable: offset);

  final Animation<Offset> offset;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(offset: offset.value, child: child);
  }
}

class ElModalTransition2 extends AnimatedWidget {
  const ElModalTransition2({super.key, required this.color, required this.child}) : super(listenable: color);

  final Animation<Color?> color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElSecondChildWidget(
      foregroundSecondChild: ColoredBox(color: color.value ?? Colors.transparent),
      child: child,
    );
  }
}
