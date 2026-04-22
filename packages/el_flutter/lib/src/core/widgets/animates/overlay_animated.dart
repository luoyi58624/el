import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class _ElOverlayItem {
  _ElOverlayItem({required this.entry, required this.zIndex, required this.seq});

  final OverlayEntry entry;
  final int zIndex;
  final int seq;
  AsyncCallback? hide;
  Future<void>? removing;
}

/// 全局 overlay 基类：
/// 1. 统一维护 entry 生命周期
/// 2. 支持按 zIndex 排序
/// 3. 移除前先等待子组件执行隐藏动画
abstract class ElAnimatedOverlayService {
  static final _layers = <_ElOverlayItem>[];
  static int _seq = 0;

  final _queue = <int, _ElOverlayItem>{};
  int _id = 0;
  @protected
  final tasks = ElAsyncUtil.serialQueue();

  /// 数值越大，层级越高。
  @protected
  int get zIndex => 0;

  /// 插入一个 overlay，并返回服务层分配的 overlay id。
  ///
  /// 子类通过 [builder] 构建具体的 overlay 组件：
  /// - [remove] 用于真正移除当前 overlay
  /// - [onHide] 用于注册“隐藏动画”回调，服务层在移除前会先调用它
  @protected
  int insert(ElAnimatedOverlayWidget Function(AsyncCallback remove, ValueChanged<AsyncCallback> onHide) builder, {int? zIndex}) {
    final id = _id++;
    late final _ElOverlayItem item;
    item = _ElOverlayItem(
      entry: OverlayEntry(builder: (_) => builder(() => remove(id), (hide) => item.hide = hide)),
      zIndex: zIndex ?? this.zIndex,
      seq: _seq++,
    );
    _queue[id] = item;
    _insert(item);
    return id;
  }

  /// 同一个 entry 只会执行一次移除流程，避免重复调用打断动画。
  @protected
  Future<void> remove(int id) {
    final item = _queue[id];
    if (item == null) return Future.value();
    return item.removing ??= _remove(id, item);
  }

  Future<void> _remove(int id, _ElOverlayItem item) async {
    await item.hide?.call();
    if (_queue.remove(id) == null) return;
    _layers.remove(item);
    onRemoved(id);
    item.entry.remove();
    item.entry.dispose();
  }

  /// 当某个 overlay 已经完成隐藏并被真正移除后触发。
  ///
  /// 子类通常在这里同步自身状态，例如清理当前 id、重置引用等。
  @protected
  void onRemoved(int id) {}

  /// 统一按 zIndex 和插入顺序决定 overlay 前后关系。
  void _insert(_ElOverlayItem item) {
    _layers.add(item);
    _layers.sort((a, b) => a.zIndex != b.zIndex ? a.zIndex.compareTo(b.zIndex) : a.seq.compareTo(b.seq));
    final index = _layers.indexOf(item);
    final below = index < _layers.length - 1 ? _layers[index + 1].entry : null;
    if (below == null) {
      el.overlay.insert(item.entry);
      return;
    }
    el.overlay.insert(item.entry, below: below);
  }
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
  int insert(
    ElAnimatedOverlayWidget Function(AsyncCallback remove, ValueChanged<AsyncCallback> onHide) builder, {
    int? zIndex,
  }) {
    return _currentId = super.insert(builder, zIndex: zIndex);
  }

  /// 关闭旧 overlay 后插入新的当前 overlay。
  @protected
  Future<int> replace(
    ElAnimatedOverlayWidget Function(AsyncCallback remove, ValueChanged<AsyncCallback> onHide) builder, {
    int? zIndex,
  }) async {
    await remove();
    return insert(builder, zIndex: zIndex);
  }

  /// 关闭当前 overlay；传入 [id] 时关闭指定的当前 overlay。
  @override
  @protected
  Future<void> remove([int? id]) async {
    final target = id ?? _currentId;
    if (target == null) return;
    await super.remove(target);
    if (_currentId == target) _currentId = null;
  }

  @protected
  @override
  void onRemoved(int id) {
    if (_currentId == id) _currentId = null;
  }
}

/// 动画 overlay 组件基类。
/// remove 用于真正移除 entry，onHide 用于让服务层先触发隐藏动画。
abstract class ElAnimatedOverlayWidget extends StatefulWidget {
  const ElAnimatedOverlayWidget({super.key, required this.remove, required this.onHide});

  /// 真正移除当前 overlay entry。
  @protected
  final AsyncCallback remove;

  /// 注册隐藏动画回调，供服务层在移除前调用。
  @protected
  final ValueChanged<AsyncCallback> onHide;
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

  /// 进入动画时长。
  ///
  /// 子类必须重写它，用于父类统一创建单个 [controller]。
  @protected
  Duration get duration;

  /// 离场动画时长，默认与 [duration] 一致。
  ///
  /// 如果进入和离场节奏不同，子类可单独重写。
  @protected
  Duration get reverseDuration => duration;

  /// 主动关闭当前 overlay。
  ///
  /// 调用顺序固定为：
  /// 1. 执行 [hide]
  /// 2. 调用服务层传入的 [widget.remove]
  @protected
  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    await hide();
    await widget.remove();
  }

  /// 执行进入动画。
  ///
  /// 默认直接驱动 [controller] 正向播放，子类可以按需重写。
  @protected
  Future<void> show() => controller.forward();

  /// 执行离场动画。
  ///
  /// 默认直接驱动 [controller] 反向播放，子类可以按需重写。
  @protected
  Future<void> hide() => controller.reverse();

  /// 进入动画完成后的回调。
  ///
  /// 适合在这里启动自动关闭计时器、注册后续逻辑等。
  @protected
  void onShown() {}

  /// 服务层触发移除时，先等显示动画完成，再执行隐藏动画。
  Future<void> _hide() async {
    if (_closing) return;
    _closing = true;
    await _showFuture;
    await hide();
  }

  @override
  void initState() {
    super.initState();
    widget.onHide(_hide);
    _showFuture.then((_) {
      if (mounted && !_closing) onShown();
    });
  }

  /// 销毁父类统一创建的 [controller]。
  ///
  /// 子类若有额外资源需要释放，应先清理自身状态再调用 `super.dispose()`。
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
