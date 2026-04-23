part of 'index.dart';

extension ElDialog2Ext on El {
  static final _instance = ElDialog2Service._();

  /// 走 [ElAnimatedOverlayService] 的轻量模态，可同时存在多个实例。  
  /// [show] 返回 [ElOverlayHandle]；[close] 可传同一句柄，或在子树中用 [ElOverlayHandle.of] / [ElOverlayHandle.maybeOf] 后 [remove] / [hide]。
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

  final _entries = <ElOverlayHandle, _Dialog2Entry>{};

  @override
  int get zIndex => el.config.dialogIndex;

  /// 新插入一条模态，返回 [ElOverlayHandle]（亦可由 [ElOverlayHandle.of] 在子树内取得同一句柄）。
  ///
  /// `keepAlive: true` 时 [close] 走 [ElOverlayHandle.hide] 不 remove。再次 [show(keepAlive: true)] 时，**仅当** 传入的 [child] 与某条已存在层中保存的 [Widget] 为**同一实例**（[identical]）时复用该层并保留 [State]；已显示则直接返回同一句柄。若每次 [show] 都传入**新**子组件实例会插入新层，应使用 [const] 子组件或持有并复用同一 [Widget] 引用。
  Future<ElOverlayHandle> show(Widget child, {bool keepAlive = false}) {
    return tasks.run(() async {
      if (keepAlive) {
        for (final entry in _entries.entries) {
          final handle = entry.key;
          final e = entry.value;
          if (!e.keepAlive) {
            continue;
          }
          final w = e.content.value;
          if (w == null) {
            continue;
          }
          if (!identical(w, child)) {
            continue;
          }
          if (e.isHidden) {
            await handle.show();
            e.isHidden = false;
          }
          return handle;
        }
      }

      final n = ValueNotifier<Widget?>(child);
      final h = insertOverlay(
        (handle, remove, r, hOnly, s) => _ElDialog2Widget(
          handle: handle,
          content: n,
          removeOverlay: remove,
          onRegisterRemoveHide: r,
          onRegisterHideForOverlay: hOnly,
          onRegisterShowForOverlay: s,
        ),
      );
      _entries[h] = _Dialog2Entry(keepAlive: keepAlive, content: n);
      return h;
    });
  }

  /// 关闭 [handle] 对应当前层。`dispose: true` 或该次 [show] 时 `keepAlive: false` 时走 [remove]；否则 [hide]。
  Future<void> close(ElOverlayHandle handle, {bool dispose = false}) {
    return tasks.run(() async {
      final e = _entries[handle];
      if (e == null) return;
      if (dispose || !e.keepAlive) {
        await handle.remove();
        return;
      }
      await handle.hide();
      e.isHidden = true;
    });
  }

  @override
  void onRemoved(ElOverlayHandle handle) {
    final e = _entries.remove(handle);
    e?.content.dispose();
  }
}
