part of 'index.dart';

extension ElDialog2Ext on El {
  static final _instance = ElDialog2Service._();

  /// 走 [ElAnimatedOverlayService] 的轻量模态，可同时存在多个实例；[show] 返回 id，[close] 需指定对应 id。  
  /// `keepAlive: true` 时 [close] 仅 [hideOverlay]；[close] 的 `dispose: true` 强制 [removeOverlay] 并销毁。
  ElDialog2Service get dialog2 => _instance;
}

class _Dialog2Entry {
  _Dialog2Entry({required this.keepAlive, required this.content});

  final bool keepAlive;
  final ValueNotifier<Widget?> content;
  bool isHidden = false;
}

class ElDialog2Service extends ElAnimatedOverlayService {
  ElDialog2Service._();

  final _entries = <int, _Dialog2Entry>{};

  @override
  int get zIndex => el.config.dialogIndex;

  /// 新插入一条模态，返回其 [overlayId]，[close] 时传入。
  Future<int> show(Widget child, {bool keepAlive = false}) {
    return tasks.run(() async {
      final n = ValueNotifier<Widget?>(child);
      final id = insertOverlay(
        (overlayId, remove, r, h, s) => _ElDialog2Widget(
          overlayId: overlayId,
          content: n,
          removeOverlay: remove,
          onRegisterRemoveHide: r,
          onRegisterHideForOverlay: h,
          onRegisterShowForOverlay: s,
        ),
      );
      _entries[id] = _Dialog2Entry(keepAlive: keepAlive, content: n);
      return id;
    });
  }

  /// 关闭 [id] 对应的模态。若 [dispose] 为 `true` 或该次 [show] 时 `keepAlive: false`，则 [removeOverlay] 并释放资源。
  Future<void> close(int id, {bool dispose = false}) {
    return tasks.run(() async {
      final e = _entries[id];
      if (e == null) return;
      if (dispose || !e.keepAlive) {
        await removeOverlay(id);
        return;
      }
      await hideOverlay(id);
      e.isHidden = true;
    });
  }

  @override
  void onRemoved(int id) {
    final e = _entries.remove(id);
    e?.content.dispose();
  }
}
