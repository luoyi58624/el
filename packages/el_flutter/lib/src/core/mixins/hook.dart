import 'package:el_flutter/ext.dart';

/// 保留 HookWidget 临时数据的引用，避免在多个方法中不断进行传参
mixin ElHookWidgetModelMixin on HookWidget {
  final Map<String, dynamic> _map = {};

  /// 访问临时数据
  @protected
  T $get<T>(String key) {
    assert(_map.containsKey(key), 'ElHookWidgetModelMixin Error: No model with key = $key was found.');
    return _map[key] as T;
  }

  /// 添加临时数据，如果已存在，则直接返回已存在的对象
  @protected
  T $add<T>(String key, T value) {
    if (_map.containsKey(key)) return _map[key] as T;
    return _map[key] = value;
  }
}
