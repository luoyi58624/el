part of 'index.dart';

/// 这个小部件包含 [model] 参数，方便 [_WindowElement] 访问其属性，否则我没必要单独编写这个类
class _WindowItem extends StatelessWidget {
  const _WindowItem({required this.child, required this.model});

  final Widget child;
  final ElWindowModel model;

  @override
  Widget build(BuildContext context) {
    final maxSize = ElResponsive.sizeOf(context);
    return ObsBuilder(
      builder: (context) {
        return ElWindowResizer(
          cacheKey: model.cacheKey,
          duration: Duration(milliseconds: 200),
          alignment: model.alignment,
          offset: model.offset,
          size: model.size,
          minSize: model.minSize,
          maxSize: model.maxSize == null
              ? maxSize
              : Size(min(model.maxSize!.width, maxSize.width), min(model.maxSize!.height, maxSize.height)),
          positionBuilder: (offset, child, duration) {
            return _AnimatedWindowParentDataWidget(duration: duration, offset: offset, model: model, child: child);
          },
          child: child,
        );
      },
    );
  }
}

/// 窗口小部件，它允许在页面上堆叠多个小部件，相当于特殊版本的 [Stack] 小部件，
/// 不同之处在于它支持 index 权重来控制窗口的显示层级
class _WindowWidget extends RenderObjectWidget {
  const _WindowWidget({super.key, required this.child, required this.children});

  /// 窗口下面的容器小部件，所有窗口将堆叠在此容器之上
  final Widget child;

  /// 窗口集合
  final List<_WindowItem> children;

  @override
  RenderObjectElement createElement() {
    return _WindowElement(this);
  }

  @override
  _WindowRender createRenderObject(BuildContext context) {
    return _WindowRender();
  }
}

/// 处理多个窗口元素的挂载、更新、移除逻辑
class _WindowElement extends RenderObjectElement {
  _WindowElement(super.widget);

  Element? _child;
  List<Element?>? _children;

  @override
  _WindowWidget get widget => super.widget as _WindowWidget;

  @override
  _WindowRender get renderObject => super.renderObject as _WindowRender;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child!);
    if (_children != null) {
      for (final child in _children!) {
        if (child != null) visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    _child = null;
    _children = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _child = updateChild(_child, widget.child, null)!;
    _children = [];
    for (final child in widget.children) {
      _children!.add(updateChild(null, child, child.model.id));
    }
  }

  @override
  void update(_WindowWidget newWidget) {
    super.update(newWidget);
    _child = updateChild(_child, newWidget.child, null)!;

    // 当通过 api 新增、移除窗口时，ElWindows 会更新窗口集合，通过此集合与 _children 对比来提取出需要 add、remove 的节点
    List<_WindowItem> addList = List<_WindowItem>.from(newWidget.children);

    // 每个窗口的 Element 节点位置使用 id 作为 slot 插槽，所以需要通过 id 去对比
    final ids = addList.map((e) => e.model.id).toList();

    // _children 已存在的节点，这部分节点需要从 addList 中剔除
    List<String> oldList = [];

    // addList & _children 对比过程中被移除的节点，这些节点需要从 _children 中剔除
    List<String> removeList = [];

    // 对比新旧集合，提取出已存在的元素节点、被删除的元素节点
    for (int i = 0; i < _children!.length; i++) {
      if (ids.contains(_children![i]!.slot)) {
        oldList.add(_children![i]!.slot as String);
      } else {
        removeList.add(_children![i]!.slot as String);
      }
    }

    // 把老数据剔除，保留需要新增的元素节点
    for (final id in oldList) {
      Widget? removeWidget;
      for (final child in addList) {
        if (child.model.id == id) {
          removeWidget = child;
          break;
        }
      }
      addList.remove(removeWidget);
    }

    // 移除被删除的元素节点
    for (final id in removeList) {
      Element? removeElement;
      for (final element in _children!) {
        if (element?.slot == id) {
          removeElement = element;
          updateChild(element, null, id);
          break;
        }
      }
      _children!.remove(removeElement);
    }

    // 最后将新增的元素节点挂载到树中
    for (final child in addList) {
      _children!.add(updateChild(null, child, child.model.id));
    }
  }

  @override
  void insertRenderObjectChild(RenderBox child, Object? slot) {
    if (slot == null) {
      renderObject.child = child;
    } else {
      renderObject.insert(child);
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, Object? slot) {
    if (slot == null) {
      renderObject.child = null;
    } else {
      renderObject.remove(child);
    }
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {}
}

/// 窗口绘制对象，优先绘制底部容器，再绘制创建的多个窗口，多个窗口的绘制顺序由 index 决定
class _WindowRender extends RenderBox {
  RenderBox? _child;

  /// 窗口容器
  RenderBox get child => _child!;

  set child(RenderBox? v) {
    if (_child == v) return;
    if (_child != null) {
      dropChild(_child!);
    }
    _child = v;
    if (_child != null) {
      adoptChild(_child!);
    }
  }

  /// 窗口渲染对象集合
  List<RenderBox> children = [];

  /// 记录后面新增的渲染对象，防止不必要的布局
  final List<RenderBox> _needLayoutChildren = [];

  /// 是否需要重新排序
  bool needSort = false;

  BoxConstraints? _oldConstraints;

  void insert(RenderBox child) {
    adoptChild(child);
    children.add(child);
    _needLayoutChildren.add(child);
    needSort = true;
  }

  void remove(RenderBox child) {
    dropChild(child);
    children.remove(child);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _child?.attach(owner);
    for (final child in children) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    _child?.detach();
    for (final child in children) {
      child.detach();
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_child != null) visitor(_child!);
    for (final child in children) {
      visitor(child);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _WindowParentData) {
      child.parentData = _WindowParentData();
    }
  }

  void _childLayout(RenderBox child) {
    final model = (child.parentData as _WindowParentData).model!;
    child.layout(
      BoxConstraints(
        minWidth: model.minSize.width,
        maxWidth: model.maxSize?.width ?? constraints.maxWidth,
        minHeight: model.minSize.height,
        maxHeight: model.maxSize?.height ?? constraints.maxHeight,
      ),
    );
  }

  @override
  void performLayout() {
    child.layout(constraints, parentUsesSize: true);
    size = child.size;

    if (constraints != _oldConstraints) {
      _oldConstraints = constraints;
      for (final child in children) {
        _childLayout(child);
      }
      _needLayoutChildren.clear();
    } else if (_needLayoutChildren.isNotEmpty) {
      for (final child in _needLayoutChildren) {
        _childLayout(child);
      }
      _needLayoutChildren.clear();
    }

    if (needSort) {
      children.sort(
        (a, b) =>
            ((a.parentData as _WindowParentData).model!.index) - ((b.parentData as _WindowParentData).model!.index),
      );
      needSort = false;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, offset);
    // 对排序过后的数组进行依次绘制，后绘制的元素在前一个元素之上
    for (int i = 0; i < children.length; i++) {
      context.paintChild(children[i], offset + (children[i].parentData as _WindowParentData).offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // 对排序过后的数组执行命中测试，后绘制的元素优先执行命中测试
    for (int i = children.length - 1; i >= 0; i--) {
      final bool isHit = result.addWithPaintOffset(
        offset: (children[i].parentData as _WindowParentData).offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return children[i].hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }

    return child.hitTest(result, position: position);
  }
}

class _WindowParentData extends ContainerBoxParentData<RenderBox> {
  ElWindowModel? model;

  @override
  String toString() {
    final List<String> values = <String>['model=$model'];
    values.add(super.toString());
    return values.join('; ');
  }
}

class _WindowParentDataWidget extends ParentDataWidget<_WindowParentData> {
  const _WindowParentDataWidget({required super.child, required this.offset, required this.model});

  final Offset offset;
  final ElWindowModel model;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _WindowParentData);
    final _WindowParentData parentData = renderObject.parentData as _WindowParentData;

    if (parentData.model != model) {
      parentData.model = model;
    }

    if (parentData.offset != offset) {
      parentData.offset = offset;
      renderObject.parent?.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _WindowWidget;
}

class _AnimatedWindowParentDataWidget extends ImplicitlyAnimatedWidget {
  const _AnimatedWindowParentDataWidget({
    required this.offset,
    required this.model,
    required this.child,
    required super.duration,
  });

  final Offset offset;
  final ElWindowModel model;
  final Widget child;

  @override
  AnimatedWidgetBaseState<_AnimatedWindowParentDataWidget> createState() => _AnimatedWindowParentDataWidgetState();
}

class _AnimatedWindowParentDataWidgetState extends AnimatedWidgetBaseState<_AnimatedWindowParentDataWidget> {
  ElOffsetTween? _offset;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offset =
        visitor(_offset, widget.offset, (dynamic value) => ElOffsetTween(begin: value as Offset)) as ElOffsetTween;
  }

  @override
  Widget build(BuildContext context) {
    return _WindowParentDataWidget(
      offset: _offset?.evaluate(animation) ?? Offset.zero,
      model: widget.model,
      child: widget.child,
    );
  }
}
