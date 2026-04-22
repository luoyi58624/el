import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [ElPositioned] 传递给 [ElStack] 的数据，它所定义的 4 个方向值，不仅支持传统的 num 类型，
/// 还支持百分比字符串，例如 top: '100%' 表示浮动元素位于子元素的底部。
///
/// 提示：虽然 [ElStack] 可以在一定程度上实现 Web 的定位样式，但有一点需要注意，
/// 浮动元素若处于 child 外部，这部分区域将无法命中事件（无法响应点击、悬停），
/// 要解决此问题，可以使用 [ElPointerTarget]、[ElPointerFollower] 小部件。
class ElStackParentData extends ContainerBoxParentData<RenderBox> {
  ElStackParentData({this.index, this.left, this.top, this.right, this.bottom});

  /// 显示权重，当小于 0 时，将不会绘制元素
  int? index;
  dynamic left;
  dynamic top;
  dynamic right;
  dynamic bottom;

  bool get isPositioned => top != null || right != null || bottom != null || left != null;
}

/// [Stack] 的变体，允许通过 index 来调整堆叠小部件的显示层级
class ElStack extends ElMultiWidget {
  const ElStack({super.key, super.sizedByParent, super.ignoreChildrenUpdate, required super.children, super.child})
    : super(debugLabel: 'ElStack');

  @override
  ElRenderStack createRenderObject(BuildContext context) {
    return ElRenderStack(debugLabel: debugLabel, sizedByParent: sizedByParent);
  }
}

class ElRenderStack extends ElRenderMultiBox {
  ElRenderStack({required super.debugLabel, super.sizedByParent});

  /// 记录 index 从大到小排序后的堆叠元素，key -> index 权重，value -> id 标识符
  final List<(int, Object)> _paintChildren = [];

  /// 按从大到小的顺序插入可绘制元素
  /// * reversed 从后面开始插入，用于希望将相同 index 权重排在后面
  void insertPaintChild(Object id, int index, {bool? reversed}) {
    assert(index >= 0, 'ElRenderStack Error: 调用 insertPaintChild 方法前请手动排除 index < 0 的数据');
    int insertIndex = 0;

    // 此循环大多数情况下只迭代一次便会中止
    if (reversed != true) {
      for (int i = 0; i < _paintChildren.length; i++) {
        if (index >= _paintChildren[i].$1) {
          break;
        } else {
          insertIndex++;
        }
      }
    } else {
      insertIndex = _paintChildren.length;
      for (int i = insertIndex - 1; i >= 0; i--) {
        if (index <= _paintChildren[i].$1) {
          break;
        } else {
          insertIndex--;
        }
      }
    }

    _paintChildren.insert(insertIndex, (index, id));
  }

  /// 移除可绘制元素
  void removePaintChild(Object id) {
    _paintChildren.removeWhere((e) => e.$2 == id);
  }

  /// 更新目标元素的 index 权重，更新成功将返回 true
  bool updateIndex(Object id, int index) {
    final target = renderBoxMap[id];

    if (target == null) return false;
    final childParentData = target.parentData as ElStackParentData;
    final oldIndex = childParentData.index ?? 0;
    if (oldIndex == index) return false;

    // 从绘制集合中移除
    if (index < 0) {
      if (oldIndex < 0) {
        childParentData.index = index;
        return false;
      } else {
        removePaintChild(id);
        childParentData.index = index;
        return true;
      }
    }

    if (_paintChildren.isEmpty) {
      childParentData.index = index;
      insertPaintChild(id, index);
      return true;
    } else {
      // 目标已经是第一位，不需要移动
      if (id == _paintChildren.first.$2 && index > _paintChildren.first.$1) {
        childParentData.index = index;
        return false;
      } else {
        removePaintChild(id);
        bool reversed = index < oldIndex; // 如果新的 index 小于旧的 index，则将其排到后面
        childParentData.index = index;
        insertPaintChild(id, index, reversed: reversed);
        return true;
      }
    }
  }

  /// 将目标显示在最前面，更新成功将返回 true（更新成功会自动执行重绘）
  /// * isEnd 将显示的目标放在最后面
  bool showTarget(Object id, {bool? isEnd}) {
    final target = renderBoxMap[id];
    if (target == null) return false;

    final childParentData = target.parentData as ElStackParentData;
    final oldIndex = childParentData.index ?? 0;

    if (_paintChildren.isEmpty) {
      if (oldIndex < 0) childParentData.index = 0;
      insertPaintChild(id, oldIndex);
      markNeedsPaint();
      return true;
    }

    if (isEnd != true) {
      final firstElement = _paintChildren.first;
      if (firstElement.$2 == id) return false;
      if (oldIndex >= 0) removePaintChild(id);
      childParentData.index = firstElement.$1 + 1;
      insertPaintChild(id, oldIndex);
    } else {
      final lastElement = _paintChildren.last;
      if (lastElement.$2 == id) return false;
      if (oldIndex >= 0) removePaintChild(id);
      childParentData.index = 0;
      insertPaintChild(id, oldIndex, reversed: true);
    }

    markNeedsPaint();
    return true;
  }

  /// 隐藏目标，更新成功将返回 true（更新成功会自动执行重绘）
  bool hideTarget(Object id) {
    final target = renderBoxMap[id];
    if (target == null) return false;

    final childParentData = target.parentData as ElStackParentData;
    final oldIndex = childParentData.index ?? 0;

    if (oldIndex < 0) return false;

    removePaintChild(id);
    childParentData.index = -1;
    markNeedsPaint();
    return true;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! ElStackParentData) {
      child.parentData = ElStackParentData();
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null) visitor(child!);
    for (final child in _paintChildren) {
      visitor(renderBoxMap[child.$2]!);
    }
  }

  BoxConstraints get defaultChildConstraints => const BoxConstraints();

  @override
  void performLayout() {
    super.performLayout();
    _paintChildren.clear();
    for (final entry in renderBoxMap.entries) {
      final child = entry.value;
      final childParentData = child.parentData as ElStackParentData;
      insertPaintChild(entry.key, childParentData.index ?? 0);

      if (childParentData.isPositioned) {
        layoutPositionChild(child, childParentData);
      } else {
        child.layout(defaultChildConstraints);
      }
    }
  }

  /// 布局 [ElPositioned] 子节点
  void layoutPositionChild(RenderBox child, ElStackParentData childParentData) {
    child.layout(defaultChildConstraints, parentUsesSize: true);

    final double x = switch (childParentData) {
      ElStackParentData(:final left?) => _parsePercent(left, size.width),
      ElStackParentData(:final right?) => size.width - _parsePercent(right, size.width) - child.size.width,
      ElStackParentData() => Alignment.topLeft.alongOffset(size - child.size as Offset).dx,
    };

    final double y = switch (childParentData) {
      ElStackParentData(:final top?) => _parsePercent(top, size.height),
      ElStackParentData(:final bottom?) => size.height - _parsePercent(bottom, size.height) - child.size.height,
      ElStackParentData() => Alignment.topLeft.alongOffset(size - child.size as Offset).dy,
    };

    childParentData.offset = Offset(x, y);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    for (int i = _paintChildren.length - 1; i >= 0; i--) {
      final target = renderBoxMap[_paintChildren[i].$2]!;
      final parentData = target.parentData as ElStackParentData;
      context.paintChild(target, offset + parentData.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (int i = 0; i < _paintChildren.length; i++) {
      final target = renderBoxMap[_paintChildren[i].$2]!;
      final parentData = target.parentData as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return target.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }
    return super.hitTestChildren(result, position: position);
  }

  @override
  void dispose() {
    _paintChildren.clear();
    super.dispose();
  }
}

/// 对 [Positioned] 进行增强，4 个方向值支持百分比字符串
class ElPositioned extends ParentDataWidget<ElStackParentData> {
  const ElPositioned({
    required super.key,
    this.index = 0,
    this.left,
    this.top,
    this.right,
    this.bottom,
    required super.child,
  }) : assert(key != null, 'ElPositioned 必须设置 key');

  final int index;
  final dynamic left;
  final dynamic top;
  final dynamic right;
  final dynamic bottom;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parent is ElRenderStack, 'ElPositioned 必须放置于 ElStack 中！');
    assert(renderObject.parentData is ElStackParentData);
    final parentData = renderObject.parentData! as ElStackParentData;
    bool needsLayout = false;
    bool needsPaint = false;

    if (parentData.index != index) {
      needsPaint = (renderObject.parent as ElRenderStack).updateIndex(key!, index);
    }

    if (parentData.left != left) {
      parentData.left = left;
      needsLayout = true;
    }

    if (parentData.top != top) {
      parentData.top = top;
      needsLayout = true;
    }

    if (parentData.right != right) {
      parentData.right = right;
      needsLayout = true;
    }

    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      needsLayout = true;
    }

    if (needsLayout) {
      renderObject.parent?.markNeedsLayout();
    } else if (needsPaint) {
      renderObject.parent?.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => ElStack;
}

/// 如果值为 num 类型，则直接返回目标值，否则将解析 % 百分比字符串：
/// * 50% -> 0.5
/// * 100% -> 1.0
/// * 150% -> 1.5
///
/// 最终返回基于 v2 的百分比相对值。
double _parsePercent(dynamic v1, double v2) {
  if (v1 is double) return v1;
  if (v1 is int) return v1.toDouble();
  assert(v1 is String && v1.endsWith('%'), 'ElPositioned 参数解析错误');
  return double.parse((v1 as String).replaceAll('%', '').trim()) / 100 * v2;
}
