import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class _ElOverlayItem {
  _ElOverlayItem({required this.entry, required this.zIndex, required this.seq});

  final OverlayEntry entry;
  final int zIndex;
  final int seq;

  /// 调用 [showOverlay] 时写入：等于 [el.config.dialogIndex] + 全局自增，用于在同类弹层中排序。
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

/// 构建由 [ElAnimatedOverlayService.insertOverlay] 插入的弹层小部件，并注册 [remove]、各阶段动画等回调。
typedef ElAnimatedOverlayInsertBuilder = ElAnimatedOverlayWidget Function(
  AsyncCallback removeOverlay,
  void Function(AsyncCallback) onRegisterRemoveHide,
  void Function(AsyncCallback) onRegisterHideForOverlay,
  void Function(AsyncCallback) onRegisterShowForOverlay,
);

/// 全局 overlay 基类：
/// 1. 统一维护 entry 生命周期
/// 2. 支持按 zIndex 排序
/// 3. 移除前先等待子组件执行隐藏动画
/// 4. 支持 [hideOverlay] 仅播隐藏动画不移除，以及 [showOverlay] 重排并再次显示
abstract class ElAnimatedOverlayService {
  static final _layers = <_ElOverlayItem>[];
  static int _seq = 0;

  /// 与 [el.config.dialogIndex] 相加，[showOverlay] 每调用一次自增 1，用于在 dialog/drawer 等之间确定先后层级。
  static int _showOrder = 0;

  final _queue = <int, _ElOverlayItem>{};
  int _id = 0;
  @protected
  final tasks = ElAsyncUtil.serialQueue();

  /// 数值越大，层级越高；未设置 [zIndex] 时子类可覆写为默认基准。
  @protected
  int get zIndex => 0;

  /// 插入一个 overlay，并返回服务层分配的 overlay id。
  @protected
  int insertOverlay(ElAnimatedOverlayInsertBuilder builder, {int? zIndex}) {
    final id = _id++;
    late final _ElOverlayItem item;
    item = _ElOverlayItem(
      entry: OverlayEntry(
        builder: (context) => builder(
          () => removeOverlay(id),
          (c) => item.hideForRemove = c,
          (c) => item.hideForOverlay = c,
          (c) => item.showForOverlay = c,
        ),
      ),
      zIndex: zIndex ?? this.zIndex,
      seq: _seq++,
    );
    _queue[id] = item;
    _insertItem(item);
    return id;
  }

  /// 同一个 entry 只会执行一次移除流程，避免重复调用打断动画。
  @protected
  Future<void> removeOverlay(int id) {
    final item = _queue[id];
    if (item == null) return Future.value();
    return item.removing ??= _remove(id, item);
  }

  Future<void> _remove(int id, _ElOverlayItem item) async {
    final hide = item.hideForRemove;
    if (hide != null) {
      await hide();
    }
    if (_queue.remove(id) == null) return;
    _layers.remove(item);
    onRemoved(id);
    item.entry.remove();
    item.entry.dispose();
  }

  /// 仅播隐藏动画，不移除 [OverlayEntry]、不 [dispose]。
  ///
  /// 依赖子类 [ElAnimatedOverlayWidget] 在 [onRegisterHideForOverlay] 中注册动画，否则为 no-op。
  @protected
  Future<void> hideOverlay(int id) {
    return tasks.run(() async {
      final item = _queue[id];
      if (item == null) return;
      final hide = item.hideForOverlay;
      if (hide == null) return;
      await hide();
    });
  }

  /// 为已存在且仍挂载的 entry 提升层级并再次显示；写入 [zShowKey] 后自增全局计数，并重新 [Overlay.insert]。
  ///
  /// 为调整顺序会从 Overlay 中 [OverlayEntry.remove] 再插回，可能触发子树重新挂载；有状态需求时请外提状态或参考文档。
  @protected
  Future<void> showOverlay(int id) {
    return tasks.run(() async {
      final item = _queue[id];
      if (item == null) return;
      item.zShowKey = el.config.dialogIndex + ++_showOrder;
      if (item.entry.mounted) {
        _relayerItem(item);
      }
      final show = item.showForOverlay;
      if (show != null) {
        await show();
      }
    });
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

  /// 当某个 overlay 已经完成隐藏并被真正移除后触发。
  @protected
  void onRemoved(int id) {}
}

/// 单实例 overlay 服务基类。
///
/// 同一时间只维护一个当前 overlay，适合 toast、loading、prompt 这类
/// “ 新内容出现前先替换掉旧内容 ” 的场景。
abstract class ElSingleAnimatedOverlayService extends ElAnimatedOverlayService {
  int? _currentId;

  /// 当前仍由该 service 管理的 overlay id。
  @protected
  int? get currentId => _currentId;

  @protected
  set currentId(int? value) => _currentId = value;

  /// 插入并记录当前 overlay。
  @override
  @protected
  int insertOverlay(ElAnimatedOverlayInsertBuilder builder, {int? zIndex}) {
    return _currentId = super.insertOverlay(builder, zIndex: zIndex);
  }

  /// 关闭旧 overlay 后插入新的当前 overlay。
  @protected
  Future<int> replace(ElAnimatedOverlayInsertBuilder builder, {int? zIndex}) async {
    await removeOverlay();
    return insertOverlay(builder, zIndex: zIndex);
  }

  /// 关闭当前 overlay；传入 [id] 时关闭指定的当前 overlay。
  @override
  @protected
  Future<void> removeOverlay([int? id]) async {
    final target = id ?? _currentId;
    if (target == null) return;
    await super.removeOverlay(target);
    if (_currentId == target) _currentId = null;
  }

  @protected
  @override
  void onRemoved(int id) {
    if (_currentId == id) _currentId = null;
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

  /// 从 overlay 中真正 [OverlayEntry.remove] 并 [dispose] 的回调。
  @protected
  final AsyncCallback removeOverlay;

  /// 在 [ElAnimatedOverlayService.removeOverlay] 前调用的「隐藏 + 可衔接移除」注册。
  @protected
  final ValueChanged<AsyncCallback> onRegisterRemoveHide;

  /// 在 [ElAnimatedOverlayService.hideOverlay] 中仅做隐藏、不移除的动画注册。
  @protected
  final ValueChanged<AsyncCallback> onRegisterHideForOverlay;

  /// 在 [ElAnimatedOverlayService.showOverlay] 中再次 [forward] 的动画注册。
  @protected
  final ValueChanged<AsyncCallback> onRegisterShowForOverlay;
}

/// 约定 overlay 只使用一个 controller，子类通过重写时长和基于 controller 派生动画。
abstract class ElAnimatedOverlayWidgetState<T extends ElAnimatedOverlayWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  bool _closing = false;
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

  /// 主动关闭当前 overlay：隐藏动画后调用服务层 [removeOverlay]。
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

  /// 在真正移除前：先等进入动画，再 [hide]（与 [ElAnimatedOverlayService.removeOverlay] 配合同路径）。
  Future<void> _removeAnimationBeforeServiceRemove() async {
    if (_closing) return;
    _closing = true;
    await _showFuture;
    await hide();
  }

  /// 仅隐藏：不置 [_closing] 为「进入移除流」，不调用 [removeOverlay]。
  Future<void> _hideForOverlayServiceOnly() async {
    await _showFuture;
    await hide();
  }

  /// [showOverlay] 再次显示时恢复动画；若子类有额外逻辑可重写 [onShowForOverlay]。
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
      if (mounted && !_closing) onShown();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
