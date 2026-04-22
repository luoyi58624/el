import 'package:el_dart/el_dart.dart';

class ElLabelModel<T> with EquatableMixin {
  final String? label;
  final T? value;

  ElLabelModel(this.label, [this.value]);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [label, value];
}

/// 嵌套数据模型
abstract base class ElNestModel<T extends ElNestModel<T>> with EquatableMixin {
  const ElNestModel({required this.key, required this.children});

  /// 唯一 key
  final String key;

  /// 嵌套模型
  final List<T> children;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [key, children];

  /// 计算目标 key 在嵌套模型的完整路径
  /// * list 嵌套数据集合
  /// * targetKey 寻找的目标 key
  /// * inherit 子级 key 是否要继承父级 key
  /// * splitChar 自定义拼接字符
  static List<T> findKeyPath<T extends ElNestModel<T>>(
    List<T> list,
    String targetKey, {
    bool inherit = false,
    String splitChar = '',
  }) {
    if (list.isEmpty) return [];

    // 用于记录每个节点的父节点，以及收集所有节点
    final parentMap = <T, T?>{};
    final allNodes = <T>[];

    // 递归遍历：收集所有节点，并建立 parent 关系
    void traverse(T node, T? parent) {
      allNodes.add(node);
      parentMap[node] = parent;
      for (final child in node.children) {
        traverse(child, node);
      }
    }

    // 从每个根节点开始遍历
    for (final rootNode in list) {
      traverse(rootNode, null);
    }

    // 遍历所有节点，查找匹配的 key
    for (final node in allNodes) {
      String keyToMatch;

      if (inherit) {
        // 构造从根到当前节点的完整 key，例如 "A/B/C"
        final keys = <String>[];
        T? current = node;

        while (current != null) {
          keys.add(current.key);
          current = parentMap[current];
        }

        keyToMatch = keys.reversed.toList().join(splitChar);
      } else {
        keyToMatch = node.key;
      }

      // 判断是否匹配目标 key
      if (keyToMatch == targetKey) {
        final path = <T>[];
        T? current = node;

        while (current != null) {
          path.add(current);
          current = parentMap[current];
        }

        // 反转路径：从根 -> ... -> 目标节点
        return path.reversed.toList();
      }
    }

    // 没找到匹配的 key
    return [];
  }
}
