import 'dart:async';
import 'dart:convert';

import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';
import 'package:el_storage/el_storage.dart';
import 'package:flutter/widgets.dart';

part 'builder.dart';

class _ObsCollectScope {
  _ObsCollectScope(this.markDirty);

  final VoidCallback markDirty;
  final Set<Obs> obsList = {};
}

final List<_ObsCollectScope> _obsCollectScopeStack = [];

_ObsCollectScope? get _currentObsCollectScope => _obsCollectScopeStack.isEmpty ? null : _obsCollectScopeStack.last;

/// 响应式变量对象，在 [ObsBuilder] 中使用会自动建立依赖，当变量更新时会自动重建 UI：
/// ```dart
/// const count = Obs(0);
///
/// ObsBuilder(
///   builder: (context) => Text('${count.value}'),
/// ),
/// ```
class Obs<T> extends ValueNotifier<T> {
  Obs(
    this._value, {
    this.onChanged,
    this.immediate,
    this.ignoreBuilder,
    this.cacheKey,
    this.serialize,
    this.expire,
    Duration? keepAliveTime,
    ElStorage? storage, // 为当前响应式变量指定自定义存储对象
  }) : super(_value) {
    _storage = storage;

    // 如果设置了缓存 key，则会将本地值覆盖初始值，并监听响应式变量的更改，实时同步至本地
    if (cacheKey != null) {
      _value = _getLocalValue();
      addListener(_setLocalValue);
    }

    if (immediate == true) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        notifyChanged();
      });
    }

    this.keepAliveTime = keepAliveTime;
  }

  /// 创建响应式变量时立即绑定监听函数
  final ValueChanged<T>? onChanged;

  /// 是否立刻执行一次 [onChanged] 函数，注意：在 dart 中，class 实例是延迟创建的，即使你创建了全局 Obs 对象，
  /// 如果它还未使用，那么构造函数将不会执行。
  final bool? immediate;

  /// 是否忽略 [ObsBuilder] 的自动收集，若为 true，访问 [value] 时将不会关联 ObsBuilder 依赖
  final bool? ignoreBuilder;

  /// 本地缓存 key，如果不为 null，每次更新变量时会将值缓存到本地，请保证 key 唯一
  final String? cacheKey;

  /// 对象序列化接口，本地储存只允许基本数据类型，当响应式变量类型为对象时，你需要提供一个转换器，否则持久化时会抛出异常，
  /// 不过，如果对象已经实现了 [ElSerialize]、[ElSerializeModel] 接口，那么你无需指定此参数。
  final ElSerialize? serialize;

  /// 设置本地持久化的过期时间
  final Duration? expire;

  /// 设置保活定时器，若不为 null，每隔一段时间将会刷新 [expire] 过期时间
  Duration? _keepAliveTime;

  Duration? get keepAliveTime => _keepAliveTime;

  set keepAliveTime(Duration? v) {
    if (_keepAliveTime == v) return;
    _keepAliveTime = v;
    if (v == null) {
      _closeKeepAliveTimer();
    } else {
      assert(cacheKey != null && expire != null);
      _openKeepAliveTimer();
    }
  }

  /// 指定自定义本地存储库
  late final ElStorage? _storage;

  /// 如果自定义本地存储为 null，那么将使用响应式变量默认的本地存储对象
  ElStorage get storage => _storage ?? (expire == null ? localStorage : expireLocalStorage);

  /// 响应式变量原始值
  T _value;

  /// 访问响应式变量，它会与 [ObsBuilder] 自动进行绑定
  @override
  T get value {
    if (ignoreBuilder != true) bindBuilders();
    return _value;
  }

  /// 修改响应式变量，它会自动触发所有 [ObsBuilder] 的重建
  @override
  set value(T value) {
    if (_value != value) {
      _value = value;
      notify();
    }
  }

  /// 当直接当作字符串插入时，无需指定 .value
  @override
  String toString() => value.toString();

  /// 直接访问原始 [_value] 避免触发副作用函数
  // ignore: unnecessary_getters_setters
  T get rawValue => _value;

  /// 直接更新原始 [_value] 避免触发副作用函数
  set rawValue(T value) => _value = value;

  /// 记录已绑定的 [ObsBuilder] 小部件的刷新方法
  final Set<VoidCallback> obsBuilders = {};

  /// 将响应式变量与 [ObsBuilder] 进行绑定
  @protected
  void bindBuilders() {
    final scope = _currentObsCollectScope;
    if (scope != null) {
      final fun = scope.markDirty;
      if (obsBuilders.contains(fun) == false) {
        obsBuilders.add(fun);
      }
      scope.obsList.add(this);
    }
  }

  /// 执行所有副作用监听函数、包括 UI 页面刷新
  void notify() {
    final callbacks = List<VoidCallback>.from(obsBuilders, growable: false);
    for (final fun in callbacks) {
      fun();
    }
    notifyChanged();
    notifyListeners();
  }

  /// 执行 [onChanged] 监听函数
  @protected
  void notifyChanged() {
    onChanged?.call(_value);
  }

  /// 销毁响应式变量，简单应用并不需要手动调用此方法，因为 [ObsBuilder] 在销毁时会自动移除监听
  @override
  void dispose() {
    super.dispose();
    obsBuilders.clear();
    _closeKeepAliveTimer();
  }

  /// 获取本地缓存值，这是一个默认实现，对于 [List]、[Map] 集合，其相应的 Obs 会覆写此方法
  @protected
  T? initLocalValue() {
    return storage.getItem<T>(cacheKey!);
  }

  /// 如果 [cacheKey] 不为 null，那么在创建响应式变量时会添加监听函数，每次更新变量都会将其缓存到本地
  void _setLocalValue() {
    if (_value == null) return;
    if (_value is ElSerializeModel) {
      storage.setItem(cacheKey!, jsonEncode((_value as ElSerializeModel).toJson()), expire: expire);
    } else if (_value is ElSerialize) {
      storage.setItem(cacheKey!, (_value as ElSerialize).serialize(_value), expire: expire);
    } else {
      storage.setItem(cacheKey!, _value, serialize: serialize, expire: expire);
    }
  }

  /// 如果 [cacheKey] 不为 null，创建响应式变量时会从本地配置中获取目标值
  T _getLocalValue() {
    T? result;
    try {
      if (_value is ElSerializeModel) {
        final jsonStr = storage.getItem(cacheKey!);
        if (jsonStr != null) {
          result = (_value as ElSerializeModel).fromJson(jsonDecode(jsonStr));
        }
      } else if (_value is ElSerialize) {
        final str = storage.getItem<String>(cacheKey!);
        if (str != null) {
          result = (_value as ElSerialize).deserialize(str);
        }
      } else if (serialize != null) {
        result = storage.getItem<T>(cacheKey!, serialize: serialize);
      } else {
        result = initLocalValue();
      }
      return result ?? _value;
    } catch (e) {
      ElLog.w(e, title: 'Obs 读取本地缓存的变量类型转换失败，Obs 将会删除旧数据并返回默认值 [${cacheKey!}]');
      storage.removeItem(cacheKey!);
      return _value;
    }
  }

  Timer? _keepAliveTimer;

  /// 启动一个计时器，每隔一段时间设置本地数据
  void _openKeepAliveTimer() {
    assert(keepAliveTime != null);
    _keepAliveTimer = ElAsyncUtil.setInterval(() {
      if (_value != null) storage.setExpire(cacheKey!, expire!);
    }, keepAliveTime!.inMilliseconds);
  }

  /// 关闭保活计时器
  void _closeKeepAliveTimer() {
    if (_keepAliveTimer != null) {
      _keepAliveTimer!.cancel();
      _keepAliveTimer = null;
    }
  }

  static ElStorage? _localStorage;
  static ElStorage? _expireLocalStorage;

  /// 存储 Obs 响应式变量的 Storage 对象
  static ElStorage get localStorage => _localStorage ??= ElStorage.createStorage('el_obs_storage');

  /// 存储 Obs 响应式变量的 Storage 对象（指定了 expire 过期时间的响应式变量）
  static ElStorage get expireLocalStorage {
    if (_expireLocalStorage == null) {
      _expireLocalStorage = ElStorage.createStorage('el_obs_expire_storage');
      _expireLocalStorage!.clearExpire();
    }
    return _expireLocalStorage!;
  }
}
