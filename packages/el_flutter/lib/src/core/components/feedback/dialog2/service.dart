part of 'index.dart';

extension ElDialog2Ext on El {
  static final _instance = ElDialog2Service._();

  /// 仅 [show] 与 [persist]；遮罩走 [_backdrop]。
  ElDialog2Service get dialog2 => _instance;
}

typedef _D2R = ({Widget body, bool persistent, bool isHidden});

class ElDialog2Service extends ElAnimatedOverlayService {
  ElDialog2Service._();

  /// 仅 dialog2 使用，与基类 [_byHandle] 同步增删（在 [onRemoved] 里清）。
  final _d2 = <ElOverlayHandle, _D2R>{};

  @override
  int get zIndex => el.config.dialogIndex;

  /// 若 [child] 与已记录 [body] [identical] 则复用；[isHidden] 时 [ElOverlayHandle.show] 再显。否则新插。
  Future<ElOverlayHandle> show(Widget child) {
    return tasks.run(() async {
      for (final e in _d2.entries) {
        final h = e.key;
        final o = e.value;
        if (!identical(o.body, child)) {
          continue;
        }
        if (o.isHidden) {
          await h.show();
          _d2[h] = (body: o.body, persistent: o.persistent, isHidden: false);
        }
        return h;
      }

      final h = insertOverlay(
        (handle, remove, r, hOnly, s) => _ElDialog2Widget(
          handle: handle,
          body: child,
          removeOverlay: remove,
          onRegisterRemoveHide: r,
          onRegisterHideForOverlay: hOnly,
          onRegisterShowForOverlay: s,
        ),
      );
      _d2[h] = (body: child, persistent: false, isHidden: false);
      return h;
    });
  }

  /// 持久化后遮罩 [_backdrop] 只 [hide]；否则 [remove]。
  Future<void> persist(ElOverlayHandle handle) {
    return tasks.run(() {
      final o = _d2[handle];
      if (o == null) {
        return;
      }
      _d2[handle] = (body: o.body, persistent: true, isHidden: o.isHidden);
    });
  }

  Future<void> _backdrop(ElOverlayHandle h) {
    return tasks.run(() async {
      final o = _d2[h];
      if (o == null) {
        return;
      }
      if (o.persistent) {
        await h.hide();
        _d2[h] = (body: o.body, persistent: o.persistent, isHidden: true);
        return;
      }
      await h.remove();
    });
  }

  @override
  void onRemoved(ElOverlayHandle handle) {
    _d2.remove(handle);
    super.onRemoved(handle);
  }
}
