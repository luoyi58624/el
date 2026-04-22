part of 'obs.dart';

class ObsBuilder extends Widget {
  /// 响应式变量构建器，当任何一个响应式变量发生变化时，都会自动重建小部件
  const ObsBuilder({
    super.key,
    this.debugLabel,
    this.ignoreObs,
    this.listenables,
    required this.builder,
  });

  /// 打印 [ObsBuilder] 自动收集的 [Obs] 列表，当发现 ObsBuilder 意外地重建时，
  /// 设置该属性可以观察到内部引用了哪些 Obs 依赖
  final String? debugLabel;

  /// 忽略 [builder] 内部的 Obs，若为 true，将不会自动收集依赖
  final bool? ignoreObs;

  /// 手动绑定监听的响应式变量，此数组通常用于监听实现 [Listenable] 接口的对象，
  /// 但如果你要监听 [Obs] 变量，建议设置 [ignoreObs] 避免重复绑定监听函数。
  final List<Listenable>? listenables;

  /// 构建小部件函数，它会自动收集内部的响应式变量
  final WidgetBuilder builder;

  @override
  Element createElement() => _ObsElement(this);
}

class _ObsElement extends ComponentElement {
  _ObsElement(super.widget);

  /// 保存绑定的响应式变量集合，[Obs] 和 [ObsBuilder] 是多对多关系，
  /// [Obs] 保存的是多个 [ObsBuilder] 的刷新方法，而 [ObsBuilder] 可以引用多个 [Obs] 变量，
  /// 当组件被销毁时，需要通知所有引用此 [ObsBuilder] 的 [Obs] 变量移除它的刷新方法
  Set<Obs> _obsList = {};

  @override
  ObsBuilder get widget => super.widget as ObsBuilder;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    if (widget.listenables != null) {
      for (final item in widget.listenables!) {
        item.addListener(markNeedsBuild);
      }
    }
  }

  @override
  void update(ObsBuilder newWidget) {
    bool needBuild = false;

    // 更改 ignoreObs 属性需要移除当前自动绑定的所有 Obs
    if (newWidget.ignoreObs != widget.ignoreObs) {
      if (newWidget.ignoreObs == true) {
        for (var item in _obsList) {
          item.obsBuilders.remove(markNeedsBuild);
        }
        _obsList = {};
      }
      needBuild = true;
    }

    // 当用户更新了关联列表，移除旧的监听数据，绑定新的监听
    if (newWidget.listenables != null || widget.listenables != null) {
      if (newWidget.listenables != null && widget.listenables != null) {
        if (newWidget.listenables!.neq(widget.listenables!)) {
          for (final item in widget.listenables!) {
            item.removeListener(markNeedsBuild);
          }
          for (final item in newWidget.listenables!) {
            item.addListener(markNeedsBuild);
          }
          needBuild = true;
        }
      } else if (newWidget.listenables != null && widget.listenables == null) {
        for (final item in newWidget.listenables!) {
          item.addListener(markNeedsBuild);
        }
        needBuild = true;
      } else {
        for (final item in widget.listenables!) {
          item.removeListener(markNeedsBuild);
        }
        needBuild = true;
      }
    }

    if (newWidget.builder != widget.builder) {
      needBuild = true;
    }

    super.update(newWidget);

    // 行为与 StatelessElement 一致：builder/依赖来源变化后需要强制重建
    if (needBuild) rebuild(force: true);
  }

  @override
  void unmount() {
    for (var item in _obsList) {
      item.obsBuilders.remove(markNeedsBuild);
    }
    if (widget.listenables != null) {
      for (var item in widget.listenables!) {
        item.removeListener(markNeedsBuild);
      }
    }
    _obsList = {};
    super.unmount();
  }

  @override
  Widget build() {
    if (widget.ignoreObs == true) {
      return widget.builder(this);
    }

    // 每次 build 都重新收集依赖，并对比新旧依赖做增量解绑，避免动态依赖造成的泄漏/误重建
    final scope = _ObsCollectScope(markNeedsBuild);
    _obsCollectScopeStack.add(scope);
    final result = widget.builder(this);
    _obsCollectScopeStack.removeLast();

    final newObsList = scope.obsList;
    if (_obsList.isNotEmpty) {
      for (final oldObs in _obsList) {
        if (!newObsList.contains(oldObs)) {
          oldObs.obsBuilders.remove(markNeedsBuild);
        }
      }
    }
    _obsList = newObsList;

    assert(() {
      if (widget.debugLabel != null) {
        ElLog.i(_obsList, title: '${widget.debugLabel}');
      }
      return true;
    }());

    return result;
  }
}
