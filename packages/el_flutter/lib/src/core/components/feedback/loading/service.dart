part of 'index.dart';

extension ElLoadingServiceExt on El {
  static final _instance = ElLoadingService();

  /// 全局 loading 服务
  ElLoadingService get loading => _instance;
}

class ElLoadingService extends ElSingleAnimatedOverlayService {
  @override
  int get zIndex => el.config.loadingIndex;

  /// 打开一个 loading，每次打开新的都会关闭当前 loading；全局只保留一个实例。
  Future<void> open(String text, {ElLoadingCloseModel? closeModel, int? zIndex}) {
    return tasks.run(() async {
      await replace(
        (_, remove, r, h, s) => _ElLoadingWidget(
          text: text,
          closeModel: closeModel,
          onConfirmClose: close,
          removeOverlay: remove,
          onRegisterRemoveHide: r,
          onRegisterHideForOverlay: h,
          onRegisterShowForOverlay: s,
        ),
        zIndex: zIndex,
      );
    });
  }

  /// 关闭当前 loading
  Future<void> close() => tasks.run(() => removeOverlay());
}

class _ElLoadingWidget extends ElAnimatedOverlayWidget {
  const _ElLoadingWidget({
    required this.text,
    this.closeModel,
    required this.onConfirmClose,
    required super.removeOverlay,
    required super.onRegisterRemoveHide,
    required super.onRegisterHideForOverlay,
    required super.onRegisterShowForOverlay,
  });

  final String text;
  final ElLoadingCloseModel? closeModel;
  final Future<void> Function() onConfirmClose;

  @override
  State<_ElLoadingWidget> createState() => _ElLoadingWidgetState();
}

enum _LoadingInteractionState { idle, confirming, closing }

class _ElLoadingWidgetState extends ElAnimatedOverlayWidgetState<_ElLoadingWidget> {
  _LoadingInteractionState _interactionState = _LoadingInteractionState.idle;

  @override
  Duration get duration => 200.ms;

  @override
  Duration get reverseDuration => 100.ms;

  @override
  Future<void> hide() async {
    final shouldClosePrompt = _interactionState == _LoadingInteractionState.confirming;
    _interactionState = _LoadingInteractionState.closing;
    if (!shouldClosePrompt) {
      await controller.reverse();
      return;
    }
    // 如果 loading 在确认框弹出期间被外部关闭，确认框也一起关闭。
    await Future.wait([controller.reverse(), el.prompt.close()]);
  }

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: PopScope(
      // loading 存在期间禁止物理返回，避免用户误退页面。
      canPop: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => ColoredBox(
            // 遮罩颜色与中间内容共用同一个 controller 过渡。
            color: Color.lerp(Colors.transparent, Colors.black.withAlpha(90), controller.value)!,
            child: child!,
          ),
          child: Center(
            child: FadeTransition(
              opacity: controller,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                decoration: BoxDecoration(color: Colors.black.withAlpha(200), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(widget.text, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _handleTap() async {
    if (_interactionState != _LoadingInteractionState.idle) return;
    _interactionState = _LoadingInteractionState.confirming;
    final closeModel = ElLoadingCloseModel.instance.merge(widget.closeModel);
    try {
      final result = await _showClosePrompt(closeModel);
      final promptClose = el.prompt.close(result);
      if (!mounted || _interactionState == _LoadingInteractionState.closing) {
        await promptClose;
        return;
      }
      if (!result) {
        await promptClose;
        return;
      }
      final token = closeModel.cancelToken;
      if (token != null && token.isCancelled == false) {
        token.cancel();
      }
      await Future.wait([promptClose, widget.onConfirmClose()]);
    } finally {
      if (_interactionState == _LoadingInteractionState.confirming) {
        _interactionState = _LoadingInteractionState.idle;
      }
    }
  }

  Future<bool> _showClosePrompt(ElLoadingCloseModel closeModel) {
    // 点击 loading 任意位置，都通过 prompt 二次确认是否关闭。
    return el.prompt.alert(
      title: closeModel.title,
      content: closeModel.content ?? '',
      cancel: closeModel.cancel ?? '',
      confirm: closeModel.confirm ?? '',
    );
  }
}
