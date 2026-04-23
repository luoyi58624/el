import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 与单次 [insertOverlay] 一一对应。通过 [remove] / [hide] / [show] 操作该层，无需使用整型 id。  
/// 在弹层子树中可使用 [of] 取得当前句柄并关闭本层，例如 `ElOverlayHandle.of(context).remove()`。
class ElOverlayHandle {
  ElOverlayHandle._(this._owner);

  final ElAnimatedOverlayService _owner;
  var _isActive = true;

  bool get isActive => _isActive;

  void _deactivate() {
    _isActive = false;
  }

  /// 调用 [maybeOf]；为 [null] 时 debug 下 [assert] 失败。不建立对 inherited 的依赖，与 [maybeOf] 相同。
  static ElOverlayHandle of(BuildContext context) {
    final handle = maybeOf(context);
    assert(handle != null, 'ElOverlayHandle.of: no overlay handle in this context');
    return handle!;
  }

  /// 不建立与弹层注入的依赖，未找到时返回 [null]。
  static ElOverlayHandle? maybeOf(BuildContext context) {
    return _ElOverlayScope.maybeOf(context);
  }

  /// 与 [ElAnimatedOverlayService.removeOverlay] 等效：先播注册过的移除前隐藏动画，再 [OverlayEntry.remove] + [dispose]。
  Future<void> remove() {
    if (!_isActive) return Future.value();
    return _owner._removeEntry(this);
  }

  /// 与 [ElAnimatedOverlayService] 的 [hideForOverlay] 等效，仅播隐藏动画，不移除 entry。
  Future<void> hide() {
    if (!_isActive) return Future.value();
    return _owner._hideForOverlayByHandle(this);
  }

  /// 与 [showOverlayAgain] 等效，更新层级并再播 overlay 内注册的 [show] 动画。
  Future<void> show() {
    if (!_isActive) return Future.value();
    return _owner._showAgainByHandle(this);
  }
}

/// 将 [ElOverlayHandle] 注入弹层子树，供 [ElOverlayHandle.of] / [maybeOf] 解析。
class _ElOverlayScope extends InheritedWidget {
  const _ElOverlayScope({required this.handle, required super.child});

  final ElOverlayHandle handle;

  static ElOverlayHandle? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_ElOverlayScope>()?.handle;
  }

  @override
  bool updateShouldNotify(_ElOverlayScope oldWidget) => oldWidget.handle != handle;
}

class _ElOverlayItem {
  _ElOverlayItem({required this.handle, required this.entry, required this.zIndex, required this.seq});

  final ElOverlayHandle handle;
  final OverlayEntry entry;
  final int zIndex;
  final int seq;

  int? zShowKey;

  AsyncCallback? hideForRemove;
  AsyncCallback? hideForOverlay;
  AsyncCallback? showForOverlay;
  Future<void>? removing;
}

int _sortKeyForLayer(_ElOverlayItem a) {
  if (a.zShowKey != null) return a.zShowKey!;
  return a.zIndex * 1000000 + a.seq;
}

/// 第一个参数为 [insertOverlay] 返回的 [ElOverlayHandle]（子树中可通过 [ElOverlayHandle.of] 取得同一句柄）；  
/// [removeOverlay] 一般传 `() => handle.remove()` 即可，与 [handle.remove] 等价。
typedef ElAnimatedOverlayInsertBuilder = ElAnimatedOverlayWidget Function(
  ElOverlayHandle handle,
  AsyncCallback removeOverlay,
  void Function(AsyncCallback) onRegisterRemoveHide,
  void Function(AsyncCallback) onRegisterHideForOverlay,
  void Function(AsyncCallback) onRegisterShowForOverlay,
);

/// 全局 overlay 基类。内部用 [ElOverlayHandle] 作为 [Map] 的键，语义上等价于在活跃集合中按对象引用去重、查找。
abstract class ElAnimatedOverlayService {
  static final _layers = <_ElOverlayItem>[];
  static int _seq = 0;

  static int _showOrder = 0;

  final _byHandle = <ElOverlayHandle, _ElOverlayItem>{};

  @protected
  final tasks = ElAsyncUtil.serialQueue();

  @protected
  int get zIndex => 0;

  @protected
  ElOverlayHandle insertOverlay(ElAnimatedOverlayInsertBuilder builder, {int? zIndex}) {
    final h = ElOverlayHandle._(this);
    late final _ElOverlayItem item;
    item = _ElOverlayItem(
      handle: h,
      entry: OverlayEntry(
        builder: (context) {
          return _ElOverlayScope(
            handle: h,
            child: builder(
              h,
              h.remove,
              (c) => item.hideForRemove = c,
              (c) => item.hideForOverlay = c,
              (c) => item.showForOverlay = c,
            ),
          );
        },
      ),
      zIndex: zIndex ?? this.zIndex,
      seq: _seq++,
    );
    _byHandle[h] = item;
    _insertItem(item);
    return h;
  }

  @protected
  Future<void> removeOverlay(ElOverlayHandle handle) {
    if (!handle._isActive) return Future.value();
    return _removeEntry(handle);
  }

  Future<void> _removeEntry(ElOverlayHandle handle) {
    if (!handle._isActive) return Future.value();
    final item = _byHandle[handle];
    if (item == null) return Future.value();
    return item.removing ??= _removeByHandleAndDisposeItem(handle, item);
  }

  Future<void> _removeByHandleAndDisposeItem(ElOverlayHandle handle, _ElOverlayItem item) async {
    final hide = item.hideForRemove;
    if (hide != null) {
      await hide();
    }
    if (_byHandle.remove(handle) == null) return;
    _layers.remove(item);
    onRemoved(handle);
    handle._deactivate();
    item.entry.remove();
    item.entry.dispose();
  }

  /// 不再包 [tasks.run]，避免与 [tasks] 外层嵌套时死锁（例如 [ElOverlayHandle.hide] 在已排队的 [close] 内调用）。
  @protected
  Future<void> _hideForOverlayByHandle(ElOverlayHandle handle) async {
    final item = _byHandle[handle];
    if (item == null) return;
    final hide = item.hideForOverlay;
    if (hide == null) return;
    await hide();
  }

  /// 同 [_hideForOverlayByHandle]。
  @protected
  Future<void> _showAgainByHandle(ElOverlayHandle handle) async {
    final item = _byHandle[handle];
    if (item == null) return;
    item.zShowKey = el.config.dialogIndex + ++_showOrder;
    if (item.entry.mounted) {
      _relayerItem(item);
    }
    final show = item.showForOverlay;
    if (show != null) {
      await show();
    }
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
  set currentHandle(ElOverlayHandle? v) => _current = v;

  @protected
  @override
  ElOverlayHandle insertOverlay(ElAnimatedOverlayInsertBuilder builder, {int? zIndex}) {
    return _current = super.insertOverlay(builder, zIndex: zIndex);
  }

  @protected
  Future<ElOverlayHandle> replace(ElAnimatedOverlayInsertBuilder builder, {int? zIndex}) async {
    await removeOverlay();
    return insertOverlay(builder, zIndex: zIndex);
  }

  @override
  @protected
  Future<void> removeOverlay([ElOverlayHandle? handle]) async {
    final h = handle ?? _current;
    if (h == null) return;
    await super.removeOverlay(h);
    if (identical(_current, h)) _current = null;
  }

  @protected
  @override
  void onRemoved(ElOverlayHandle handle) {
    if (identical(_current, handle)) _current = null;
  }
}

/// 动画 overlay 组件基类。
abstract class ElAnimatedOverlayWidget extends StatefulWidget {
  const ElAnimatedOverlayWidget({
    super.key,
    required this.removeOverlay,
    required this.onRegisterRemoveHide,
    required this.onRegisterHideForOverlay,
    required this.onRegisterShowForOverlay,
  });

  @protected
  final AsyncCallback removeOverlay;

  @protected
  final ValueChanged<AsyncCallback> onRegisterRemoveHide;

  @protected
  final ValueChanged<AsyncCallback> onRegisterHideForOverlay;

  @protected
  final ValueChanged<AsyncCallback> onRegisterShowForOverlay;
}

abstract class ElAnimatedOverlayWidgetState<T extends ElAnimatedOverlayWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  bool _closing = false;
  /// 是否至少完成过首次 [show]（[controller] 到可见），用于与「首帧 [dismissed]」区分。
  bool _seenVisibleAfterInsert = false;
  late final Future<void> _showFuture = show();
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
  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    await hide();
    await widget.removeOverlay();
  }

  @protected
  Future<void> show() => controller.forward();

  @protected
  Future<void> hide() => controller.reverse();

  @protected
  void onShown() {}

  /// 包裹在 [Positioned.fill] 的 **child** 上（[Positioned] 须为 [Overlay] 里 [Stack] 的直接子，不可包在本方法外侧）。
  /// [handle.hide] 仅播隐藏、不移除 [OverlayEntry] 时，[AnimationStatus.dismissed] 后让指针穿透到下层。
  @protected
  Widget overlayPointerFilter(Widget child) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return IgnorePointer(
          ignoring: _seenVisibleAfterInsert && controller.status == AnimationStatus.dismissed,
          child: child,
        );
      },
    );
  }

  Future<void> _removeAnimationBeforeServiceRemove() async {
    if (_closing) return;
    _closing = true;
    await _showFuture;
    await hide();
  }

  Future<void> _hideForOverlayServiceOnly() async {
    await _showFuture;
    await hide();
  }

  Future<void> _showForOverlayServiceOnly() async {
    _closing = false;
    await onShowForOverlay();
  }

  @protected
  Future<void> onShowForOverlay() => show();

  @override
  void initState() {
    super.initState();
    widget.onRegisterRemoveHide(_removeAnimationBeforeServiceRemove);
    widget.onRegisterHideForOverlay(_hideForOverlayServiceOnly);
    widget.onRegisterShowForOverlay(_showForOverlayServiceOnly);
    _showFuture.then((_) {
      if (!mounted) return;
      _seenVisibleAfterInsert = true;
      if (!_closing) onShown();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
