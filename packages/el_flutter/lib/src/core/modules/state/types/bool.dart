import '../core/obs.dart';

class BoolObs extends Obs<bool> {
  BoolObs(
    super.value, {
    super.onChanged,
    super.immediate,
    super.cacheKey,
    super.expire,
    super.keepAliveTime,
    super.storage,
  });

  /// 反转 bool 值并通知监听函数
  void reversed() {
    value = !rawValue;
  }
}
