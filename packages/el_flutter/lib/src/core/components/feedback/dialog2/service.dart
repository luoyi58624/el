part of 'index.dart';

extension ElDialog2Ext on El {
  static final _instance = ElDialog2Service._();

  /// dialog2 弹窗服务：支持 [show] 与 [showForHandle]。
  ElDialog2Service get dialog2 => _instance;
}

typedef _Dialog2Record = ({Widget body, bool hideOnClose});

class ElDialog2Service extends ElAnimatedOverlayService {
  ElDialog2Service._();

  /// 仅 dialog2 使用，与基类句柄生命周期保持一致（在 [onRemoved] 中清理）。
  final _dialogs = <ElOverlayHandle, _Dialog2Record>{};

  @override
  int get zIndex => el.config.dialogIndex;

  /// 创建可复用的 dialog 句柄。默认遮罩点击只隐藏（保留状态）。
  ElOverlayHandle createHandle(Widget child, {bool hideOnClose = true}) {
    final handle = createOverlayHandle(
      (overlayHandle) => _ElDialog2Widget(
        handle: overlayHandle,
        body: child,
      ),
    );
    _dialogs[handle] = (body: child, hideOnClose: hideOnClose);
    return handle;
  }

  /// 显示一个新弹窗，遮罩点击后会销毁该弹窗（remove）。
  Future<ElOverlayHandle> show(Widget child) async {
    final handle = createHandle(child, hideOnClose: false);
    await tasks.run(() => showOverlay(handle));
    return handle;
  }

  /// 使用已存在句柄再次显示弹窗，遮罩点击后会隐藏（hide）以保留状态。
  Future<void> showForHandle(ElOverlayHandle handle) {
    return tasks.run(() async {
      final record = _dialogs[handle];
      if (record == null) return;
      _dialogs[handle] = (body: record.body, hideOnClose: true);
      await showOverlay(handle);
    });
  }

  Future<void> _onBackdropTap(ElOverlayHandle handle) {
    return tasks.run(() async {
      final record = _dialogs[handle];
      if (record == null) return;
      if (record.hideOnClose) {
        await hideOverlay(handle);
        return;
      }
      await removeOverlay(handle);
    });
  }

  @override
  void onRemoved(ElOverlayHandle handle) {
    _dialogs.remove(handle);
    super.onRemoved(handle);
  }
}
