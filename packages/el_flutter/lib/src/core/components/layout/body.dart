import 'package:flutter/widgets.dart';

class ElBody extends StatelessWidget {
  const ElBody({super.key, required this.child});

  final dynamic child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      removeTop: true,
      removeRight: true,
      removeBottom: true,
      child: child is Widget ? child : Text(child.toString()),
    );
  }
}
