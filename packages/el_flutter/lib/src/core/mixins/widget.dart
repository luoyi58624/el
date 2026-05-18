import 'package:flutter/widgets.dart';

/// 创建一个 [Map] 集合保存 [StatelessWidget] 无状态小部件 [build] 方法声明的局部变量
mixin ElStatelessMapMixin on StatelessWidget {
  final Map<Object, dynamic> _map = {};

  @protected
  T $set<T>(Object key, T value) {
    return _map[key] = value;
  }

  @protected
  T $get<T>(Object key) {
    assert(_map.containsKey(key), 'No key = $key was found.');
    return _map[key] as T;
  }
}
