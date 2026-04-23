import 'dart:async';

import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

enum _ElOverlayPhase { hidden, visible, removing }

typedef ElAnimatedOverlayBuilder = Widget Function(ElOverlayHandle handle);

/// 与单次 [createOverlayHandle] / [insertOverlay] 一一对应。
/// 通过 [remove] / [hide] / [show] 操作该层，无需暴露整型 id。
class ElOverlayHandle extends ChangeNotifier {
  ElOverlayHandle._(this._owner);

  final ElAnimatedOverlayService _owner;

  bool _isActive = true;
  _ElOverlayPhase _phase = _ElOverlayPhase.hidden;

  bool get isActive => _isActive;

  bool get isVisible => _phase == _ElOverlayPhase.visible;

  bool get isHidden => _phase == _ElOverlayPhase.hidden;

  bool get isRemoving => _phase == _ElOverlayPhase.removing;

  void _setPhase(_ElOverlayPhase value) {
    if (_phase == value) return;
    _phase = value;
    notifyListeners();
  }

  void _deactivate() {
    _isActive = false;
    notifyListeners();
  }

  static ElOverlayHandle of(BuildContext context) {
    final handle = maybeOf(context);
    assert(handle != null, 'ElOverlayHandle.of: no overlay handle in this context');
    return handle!;
  }

  static ElOverlayHandle? maybeOf(BuildContext context) {
    return _ElOverlayScope.maybeOf(context);
  }

  Future<void> remove() {
    if (!_isActive) return Future.value();
    return _owner.removeOverlay(this);
  }

  Future<void> hide() {
    if (!_isActive) return Future.value();
    return _owner.hideOverlay(this);
  }

  Future<void> show() {
    if (!_isActive) return Future.value();
    return _owner.showOverlay(this);
  }
}

class _ElOverlayScope extends InheritedWidget {
  const _ElOverlayScope({required this.handle, required super.child});

  final ElOverlayHandle handle;

  static ElOverlayHandle? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_ElOverlayScope>()?.handle;
  }

  @override
  bool updateShouldNotify(_ElOverlayScope oldWidget) => oldWidget.handle != handle;
}

class _ElOverlayDefinition {
  const _ElOverlayDefinition({required this.builder, required this.zIndex});

  final ElAnimatedOverlayBuilder builder;
  final int zIndex;
}

class _ElOverlayItem {
  _ElOverlayItem({required this.handle, required this.entry, required this.zIndex, required this.orderKey});

  final ElOverlayHandle handle;
  final OverlayEntry entry;
  final int zIndex;
  int orderKey;
  Completer<void>? removeCompleter;
  Future<void>? removing;
}

int _sortKeyForLayer(_ElOverlayItem item) {
  return item.zIndex * 1000000 + item.orderKey;
}

/// 全局 overlay 基类，统一提供四个核心 API：
/// 1. [insertOverlay]
/// 2. [removeOverlay]
/// 3. [showOverlay]
/// 4. [hideOverlay]
abstract class ElAnimatedOverlayService {
  static final _layers = <_ElOverlayItem>[];
  static int _overlayOrder = 0;

  final _definitions = <ElOverlayHandle, _ElOverlayDefinition>{};
  final _items = <ElOverlayHandle, _ElOverlayItem>{};

  @protected
  final tasks = ElAsyncUtil.serialQueue();

  @protected
  int get zIndex => 0;

  @protected
  ElOverlayHandle createOverlayHandle(ElAnimatedOverlayBuilder builder, {int? zIndex}) {
    final handle = ElOverlayHandle._(this);
    _definitions[handle] = _ElOverlayDefinition(builder: builder, zIndex: zIndex ?? this.zIndex);
    return handle;
  }

  @protected
  ElOverlayHandle insertOverlay(ElAnimatedOverlayBuilder builder, {int? zIndex}) {
    final handle = createOverlayHandle(builder, zIndex: zIndex);
    _ensureInserted(handle);
    handle._setPhase(_ElOverlayPhase.visible);
    return handle;
  }

  @protected
  Future<void> removeOverlay(ElOverlayHandle handle) {
    if (!_isOwnedActiveHandle(handle)) return Future.value();
    final item = _items[handle];
    if (item == null) {
      _disposeHandleOnly(handle);
      return Future.value();
    }
    return item.removing ??= _beginRemove(handle, item);
  }

  @protected
  Future<void> hideOverlay(ElOverlayHandle handle) async {
    if (!_isOwnedActiveHandle(handle)) return;
    final item = _items[handle];
    if (item == null) return;
    handle._setPhase(_ElOverlayPhase.hidden);
  }

  @protected
  Future<void> showOverlay(ElOverlayHandle handle) async {
    if (!_isOwnedActiveHandle(handle)) return;
    _ensureInserted(handle);
    final item = _items[handle];
    if (item == null) return;
    item.orderKey = ++_overlayOrder;
    if (item.entry.mounted) {
      _relayerItem(item);
    }
    handle._setPhase(_ElOverlayPhase.visible);
  }

  bool _isOwnedActiveHandle(ElOverlayHandle handle) {
    if (!identical(handle._owner, this) || !handle._isActive) return false;
    return _definitions.containsKey(handle);
  }

  Future<void> _beginRemove(ElOverlayHandle handle, _ElOverlayItem item) {
    final completer = Completer<void>();
    item.removeCompleter = completer;
    handle._setPhase(_ElOverlayPhase.removing);
    if (handle.isHidden) {
      _completeRemoval(handle);
    }
    return completer.future;
  }

  void _completeRemoval(ElOverlayHandle handle) {
    final item = _items[handle];
    if (item == null) return;
    _items.remove(handle);
    _layers.remove(item);
    if (item.entry.mounted) {
      item.entry.remove();
    }
    item.entry.dispose();
    _disposeHandleOnly(handle);
    item.removeCompleter?.complete();
  }

  void _disposeHandleOnly(ElOverlayHandle handle) {
    _items.remove(handle);
    _definitions.remove(handle);
    onRemoved(handle);
    handle._deactivate();
    handle.dispose();
  }

  void _ensureInserted(ElOverlayHandle handle) {
    if (!_isOwnedActiveHandle(handle)) return;
    if (_items.containsKey(handle)) return;
    final definition = _definitions[handle];
    if (definition == null) return;
    final item = _ElOverlayItem(
      handle: handle,
      entry: OverlayEntry(
        builder: (context) {
          return _ElOverlayScope(handle: handle, child: definition.builder(handle));
        },
      ),
      zIndex: definition.zIndex,
      orderKey: ++_overlayOrder,
    );
    _items[handle] = item;
    _insertItem(item);
  }

  void _relayerItem(_ElOverlayItem item) {
    if (item.entry.mounted) {
      item.entry.remove();
    }
    _layers.sort((a, b) => _sortKeyForLayer(a).compareTo(_sortKeyForLayer(b)));
    _insertIntoNativeOverlayStack(item);
  }

  void _insertItem(_ElOverlayItem item) {
    _layers.add(item);
    _layers.sort((a, b) => _sortKeyForLayer(a).compareTo(_sortKeyForLayer(b)));
    _insertIntoNativeOverlayStack(item);
  }

  void _insertIntoNativeOverlayStack(_ElOverlayItem item) {
    final index = _layers.indexOf(item);
    if (index == -1) return;
    final below = index < _layers.length - 1 ? _layers[index + 1].entry : null;
    if (below == null) {
      el.overlay.insert(item.entry);
      return;
    }
    el.overlay.insert(item.entry, below: below);
  }

  @protected
  void onRemoved(ElOverlayHandle handle) {}
}

/// 单实例：toast、loading、prompt 等，页面同时只保留一个 overlay。
abstract class ElSingleAnimatedOverlayService extends ElAnimatedOverlayService {
  ElOverlayHandle? _current;

  @protected
  ElOverlayHandle? get currentHandle => _current;

  @protected
  set currentHandle(ElOverlayHandle? value) => _current = value;

  @protected
  @override
  ElOverlayHandle insertOverlay(ElAnimatedOverlayBuilder builder, {int? zIndex}) {
    return _current = super.insertOverlay(builder, zIndex: zIndex);
  }

  @protected
  Future<ElOverlayHandle> replace(ElAnimatedOverlayBuilder builder, {int? zIndex}) async {
    await removeOverlay();
    return insertOverlay(builder, zIndex: zIndex);
  }

  @override
  @protected
  Future<void> removeOverlay([ElOverlayHandle? handle]) async {
    final target = handle ?? _current;
    if (target == null) return;
    await super.removeOverlay(target);
    if (identical(_current, target)) _current = null;
  }

  @protected
  @override
  void onRemoved(ElOverlayHandle handle) {
    if (identical(_current, handle)) _current = null;
  }
}

/// 动画 overlay 组件基类。
abstract class ElAnimatedOverlayWidget extends StatefulWidget {
  const ElAnimatedOverlayWidget({super.key, required this.handle});

  final ElOverlayHandle handle;
}

abstract class ElAnimatedOverlayWidgetState<T extends ElAnimatedOverlayWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  Future<void> _transitionTask = Future.value();

  @protected
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: duration,
    reverseDuration: reverseDuration,
  );

  @protected
  Duration get duration;

  @protected
  Duration get reverseDuration => duration;

  @protected
  ElOverlayHandle get handle => widget.handle;

  @protected
  Future<void> close() => handle.remove();

  @protected
  Future<void> show() => _runAnimation(controller.forward);

  @protected
  Future<void> hide() => _runAnimation(controller.reverse);

  @protected
  void onShown() {}

  @protected
  Widget overlayPointerFilter(Widget child) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, handle]),
      builder: (context, _) {
        return IgnorePointer(
          ignoring: !handle.isVisible,
          child: child,
        );
      },
    );
  }

  Future<void> _runAnimation(TickerFuture Function() action) async {
    try {
      await action().orCancel;
    } on TickerCanceled {
      // Widget disposed during animation.
    }
  }

  void _scheduleSync() {
    _transitionTask = _transitionTask.then((_) => _syncToHandleState());
  }

  Future<void> _syncToHandleState() async {
    if (!mounted || !handle.isActive) return;
    if (handle.isVisible) {
      if (controller.isCompleted) return;
      await show();
      if (!mounted || !handle.isVisible) return;
      onShown();
      return;
    }
    if (handle.isHidden) {
      if (controller.isDismissed) return;
      await hide();
      return;
    }
    if (!controller.isDismissed) {
      await hide();
    }
    if (!mounted || !handle.isRemoving) return;
    handle._owner._completeRemoval(handle);
  }

  @override
  void initState() {
    super.initState();
    handle.addListener(_scheduleSync);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleSync();
    });
  }

  @override
  void dispose() {
    handle.removeListener(_scheduleSync);
    controller.dispose();
    super.dispose();
  }
}
