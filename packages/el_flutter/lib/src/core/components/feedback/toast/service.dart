part of 'index.dart';

extension ElToastExt on El {
  static final _service = ElToastService();

  /// 轻提示服务，在屏幕上显示一段简单的文本提示，每次只能显示一条消息
  ElToastService get toast => _service;
}

/// Toast 服务：
/// 1. 全局单例
/// 2. 新 toast 出现前先关闭旧 toast
/// 3. 默认放在所有 feedback overlay 最上层
class ElToastService extends ElSingleAnimatedOverlayService {
  @override
  int get zIndex => el.config.toastIndex;

  Future<void> _showWidget(
    Widget child, {
    bool? tapClose,
    int? zIndex,
  }) {
    return tasks.run(() async {
      await replace(
        (handle) => _ElToastWidget(
          handle: handle,
          tapClose: tapClose,
          autoCloseDuration: Duration(milliseconds: el.config.messageDuration),
          child: child,
        ),
        zIndex: zIndex,
      );
    });
  }

  /// 默认 toast 显示在中间；
  /// 当 type 不为 null 时，使用旧版主题 toast 的底部样式。
  Future<void> show(dynamic content, {ElThemeType? type, bool? tapClose, int? zIndex}) {
    return _showWidget(
      type == null ? _Toast(content) : _ThemeToast(content, type),
      tapClose: tapClose,
      zIndex: zIndex,
    );
  }

  Future<void> primary(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .primary, tapClose: tapClose, zIndex: zIndex);

  Future<void> success(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .success, tapClose: tapClose, zIndex: zIndex);

  Future<void> info(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .info, tapClose: tapClose, zIndex: zIndex);

  Future<void> warning(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .warning, tapClose: tapClose, zIndex: zIndex);

  Future<void> error(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .error, tapClose: tapClose, zIndex: zIndex);
}

class _ElToastWidget extends ElAnimatedOverlayWidget {
  const _ElToastWidget({
    required super.handle,
    required this.child,
    required this.tapClose,
    required this.autoCloseDuration,
  });

  final Widget child;
  final bool? tapClose;
  final Duration autoCloseDuration;

  @override
  State<_ElToastWidget> createState() => _ElToastWidgetState();
}

class _ElToastWidgetState extends ElAnimatedOverlayWidgetState<_ElToastWidget> {
  Timer? _timer;

  @override
  Duration get duration => 150.ms;

  @override
  Duration get reverseDuration => 50.ms;

  @override
  Future<void> hide() async {
    _timer?.cancel();
    await super.hide();
  }

  @override
  void onShown() {
    _timer = Timer(widget.autoCloseDuration, close);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: overlayPointerFilter(
      FadeTransition(
        opacity: controller,
        child: IgnorePointer(
          // 默认不接管手势，保证不影响页面下方操作。
          ignoring: widget.tapClose != true,
          child: GestureDetector(onTap: close, child: widget.child),
        ),
      ),
    ),
  );
}
