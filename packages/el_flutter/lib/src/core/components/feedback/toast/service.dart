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

  /// 构建自定义轻提示。
  Future<int> builder(dynamic content, Widget Function(dynamic content) builder, {bool? tapClose, int? zIndex}) =>
      tasks.run(() async {
        return replace(
      (remove, r, h, s) => _ElToastWidget(
        tapClose: tapClose,
        autoCloseDuration: Duration(milliseconds: el.config.messageDuration),
        removeOverlay: remove,
        onRegisterRemoveHide: r,
        onRegisterHideForOverlay: h,
        onRegisterShowForOverlay: s,
        child: builder(content),
      ),
          zIndex: zIndex,
        );
      });

  /// 默认 toast 显示在中间；
  /// 当 type 不为 null 时，使用旧版主题 toast 的底部样式。
  Future<int> show(dynamic content, {ElThemeType? type, bool? tapClose, int? zIndex}) {
    return builder(
      content,
      (content) => type == null ? _Toast(content) : _ThemeToast(content, type),
      tapClose: tapClose,
      zIndex: zIndex,
    );
  }

  Future<int> primary(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .primary, tapClose: tapClose, zIndex: zIndex);

  Future<int> success(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .success, tapClose: tapClose, zIndex: zIndex);

  Future<int> info(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .info, tapClose: tapClose, zIndex: zIndex);

  Future<int> warning(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .warning, tapClose: tapClose, zIndex: zIndex);

  Future<int> error(dynamic content, {bool? tapClose, int? zIndex}) =>
      show(content, type: .error, tapClose: tapClose, zIndex: zIndex);

  Future<void> close([int? id]) => tasks.run(() => removeOverlay(id));
}

class _ElToastWidget extends ElAnimatedOverlayWidget {
  const _ElToastWidget({
    required this.child,
    required this.tapClose,
    required this.autoCloseDuration,
    required super.removeOverlay,
    required super.onRegisterRemoveHide,
    required super.onRegisterHideForOverlay,
    required super.onRegisterShowForOverlay,
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
    child: FadeTransition(
      opacity: controller,
      child: IgnorePointer(
        // 默认不接管手势，保证不影响页面下方操作。
        ignoring: widget.tapClose != true,
        child: GestureDetector(onTap: close, child: widget.child),
      ),
    ),
  );
}
