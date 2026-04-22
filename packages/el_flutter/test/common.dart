import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: el.navigatorKey,
      home: Scaffold(body: child),
    );
  }
}
