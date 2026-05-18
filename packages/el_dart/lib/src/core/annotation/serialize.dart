import 'package:meta/meta_meta.dart';

/// 对象序列化接口
abstract interface class ElSerialize<T> {
  /// 将对象转换成字符串
  String? serialize(T? obj);

  /// 将字符串转换成对象
  T? deserialize(String? str);
}

/// 数据模型序列化接口
abstract interface class ElSerializeModel<T> {
  /// 将 Map 转成对象
  T fromJson(Map<String, dynamic>? json);

  /// 将对象转成 Map 键值对
  Map<String, dynamic> toJson();
}

// =============================================================================
// 内置一些默认的 Dart 对象序列化
// =============================================================================

@Target({TargetKind.field})
class ElDateTimeSerialize implements ElSerialize<DateTime> {
  const ElDateTimeSerialize();

  @override
  String? serialize(DateTime? obj) => obj?.millisecondsSinceEpoch.toString();

  @override
  DateTime? deserialize(String? str) => str == null ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(str));
}

@Target({TargetKind.field})
class ElDurationSerialize implements ElSerialize<Duration> {
  const ElDurationSerialize();

  @override
  String? serialize(Duration? obj) => obj?.inMicroseconds.toString();

  @override
  Duration? deserialize(String? str) => str == null ? null : Duration(microseconds: int.parse(str));
}
