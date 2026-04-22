import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

enum ElAdaptive { element, android, ios, windows, macos, custom }

/// 全局主题动画
typedef ElGlobalAnimation = (Duration, Curve);

/// 新、旧值回调
typedef ElUpdateCallback<T> = bool? Function(T newValue, T oldValue);

/// 小部件构建器
typedef ElWidgetBuilder = Widget Function(BuildContext context, Widget child);

/// 颜色构建
typedef ElColorBuilder = Color Function(BuildContext context);

/// 默认的字重构建器
typedef ElFontWeightBuilder = FontWeight Function([FontWeight weight]);

/// 默认的滚动控制器构建器
typedef ElScrollControllerBuilder = ScrollController Function([ElScrollControllerAttrModel model]);

/// 默认的滚动条小部件构建器
typedef ElScrollbarBuilder = Widget Function(BuildContext context, ScrollController controller, Widget child);
