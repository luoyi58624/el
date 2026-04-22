import 'dart:async';

import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

import 'package:el_flutter/el_flutter.dart';

part 'service.dart';

part 'widget.dart';

typedef ElMessageBuilder = Widget Function(
  BuildContext context,
  dynamic content,
);
