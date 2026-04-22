import 'dart:async';

import 'package:el_dart/el_dart.dart';

/// 对可能为 null 元素进行扩展
extension ElDartOptionalExt<T> on T? {
  /// 非空回调，如果变量不为 null，则执行传递的回调函数
  R? notBlankCallback<R>(R? Function(T v) callback) {
    if (this != null) return callback(this as T);

    return null;
  }
}

extension ElDartDurationExt on Duration {
  Future delay([FutureOr Function()? callback]) async => Future.delayed(this, callback);

  Duration operator *(int num) {
    return Duration(milliseconds: inMilliseconds * num);
  }
}

extension ElDartIntExt on int {
  /// 返回时间对象: 毫秒
  Duration get ms => Duration(milliseconds: this);

  /// 返回时间对象: 秒
  Duration get ss => Duration(seconds: this);

  /// 返回时间对象: 分钟
  Duration get mm => Duration(minutes: this);

  /// 返回时间对象: 小时
  Duration get hh => Duration(hours: this);

  /// 返回时间对象: 天
  Duration get dd => Duration(days: this);

  /// 延迟多少毫秒再执行回调函数
  Future delay([FutureOr Function()? callback]) async => ms.delay(callback);
}

extension ElDartDoubleExt on double {
  /// 将浮点数转成 0 ~ 255 的整数（用于颜色处理）
  int get floatToInt8 => (this * 255.0).round().clamp(0, 255);
}

extension ElDartFuntionExt on Function {
  static final _logConfig = ElLogConfig(excludePaths: ['package:el/src/utils/extension.dart']);

  /// 统计函数的执行时间
  void time({
    String? debugLabel,
    String logPrefix = '',
    bool enabled = true,
    Duration? filterTime,
    ElLogFunction? log,
  }) {
    if (El.kReleaseMode) {
      // coverage:ignore-line
      this(); // coverage:ignore-line
    } else {
      if (!enabled) {
        this();
      } else {
        final stopwatch = Stopwatch()..start();
        this();
        stopwatch.stop();
        final end = stopwatch.elapsedMicroseconds;
        if (filterTime != null && filterTime.inMilliseconds > end / 1000) {
          return;
        }
        if (end >= 1000) {
          // coverage:ignore-line
          (log ?? ElLog.d)(
            '$logPrefix耗时 ${(end / 1000).toStringAsFixed(2)} 毫秒',
            title: debugLabel,
            config: _logConfig,
          ); // coverage:ignore-line
        } else {
          (log ?? ElLog.d)('$logPrefix耗时 $end 微秒', title: debugLabel, config: _logConfig);
        }
      }
    }
  }
}
