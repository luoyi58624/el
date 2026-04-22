import 'package:el_dart/ext.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

part 'controller.dart';

part 'element.dart';

part 'render.dart';

part 'node.dart';

/// 虚拟滚动小部件，该小部件可以高效地渲染大量数据
class ElVirtualScroll<D> extends RenderObjectWidget {
  const ElVirtualScroll({
    super.key,
    // required this.controller,
    this.fixedItemHeight,
    required this.items,
    required this.itemBuilder,
  });

  /// 滚动控制器
  // final ElVirtualScrollController controller;

  /// 固定每个子项的高度，若为 true，构建第一条数据时将会以它的尺寸约束后面每个子项，
  /// 如果不指定，将不会渲染滚动条
  final bool? fixedItemHeight;

  /// 原始数据集合
  final List<D> items;

  /// 按需构建小部件
  final Widget Function(D item) itemBuilder;

  @override
  RenderObjectElement createElement() {
    return ElVirtualScrollElement<D>(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ElRenderVirtualScroll(context as ElVirtualScrollElement);
  }
}
