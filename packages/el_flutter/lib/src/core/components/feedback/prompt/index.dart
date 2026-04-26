import 'dart:async';
import 'dart:ui';

import 'package:el_flutter/el_flutter.dart';
import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

part 'service.dart';

typedef ElPromptAction = FutureOr<bool> Function();
typedef ElPromptInputAction = FutureOr<bool> Function(String value);
