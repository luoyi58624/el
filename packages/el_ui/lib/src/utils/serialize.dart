import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';

import 'package:flutter/material.dart';

@Target({TargetKind.field})
class ElThemeModeSerialize implements ElSerialize<ThemeMode> {
  const ElThemeModeSerialize();

  @override
  String? serialize(ThemeMode? obj) => obj?.name;

  @override
  ThemeMode? deserialize(String? str) {
    if (str == 'system') return ThemeMode.system;
    if (str == 'dark') return ThemeMode.dark;
    if (str == 'light') return ThemeMode.light;
    return null;
  }
}
