part of 'index.dart';

extension ElPromptExt on El {
  static final _service = ElPromptService();

  /// 轻提示服务
  ElPromptService get prompt => _service;
}

class ElPromptService extends ElSingleAnimatedOverlayService {
  Completer<Object?>? _currentCompleter;
  Object? _dismissResult;

  @override
  int get zIndex => el.config.promptIndex;

  /// alert 返回 true/false，对应确认/取消。
  /// 新 alert 打开前会先关闭上一个。
  Future<bool> alert({
    String? title,
    required String content,
    String? cancel,
    required String confirm,
    int? zIndex,
    ElPromptAction? onCancel,
    ElPromptAction? onConfirm,
  }) {
    return _showPrompt<bool>(
      dismissResult: false,
      zIndex: zIndex,
      builder: (handle) => _ElPromptWidget(
        handle: handle,
        title: title,
        cancel: cancel,
        confirm: confirm,
        content: _ElPromptAlertContent(content: content),
        onCancel: cancel == null
            ? null
            : _buildAction(result: () => false, beforeClose: () => onCancel?.call() ?? true),
        onConfirm: _buildAction(result: () => true, beforeClose: () => onConfirm?.call() ?? true),
      ),
    );
  }

  /// input 返回输入结果；取消或被外部关闭时返回 null。
  Future<String> input({
    String? title,
    String value = '',
    String? placeholder,
    String? cancel,
    required String confirm,
    int? zIndex,
    ElPromptInputAction? onCancel,
    ElPromptInputAction? onConfirm,
  }) async {
    final text = Obs('');

    return await _showPrompt<String>(
      dismissResult: '',
      zIndex: zIndex,
      builder: (handle) => _ElPromptWidget(
        handle: handle,
        title: title,
        cancel: cancel,
        confirm: confirm,
        content: ObsBuilder(
          builder: (context) {
            return _ElPromptInputContent(placeholder: placeholder);
          },
        ),
        onCancel: cancel == null
            ? null
            : _buildAction(result: () => null, beforeClose: () => onCancel?.call(text.value) ?? true),
        onConfirm: _buildAction(result: () => text.value, beforeClose: () => onConfirm?.call(text.value) ?? true),
      ),
    );
  }

  Future<void> close([Object? result = false]) => tasks.run(() => _close(result: result));

  Future<T> _showPrompt<T>({
    required T dismissResult,
    required ElAnimatedOverlayWidget Function(ElOverlayHandle handle) builder,
    int? zIndex,
  }) async {
    late final Completer<Object?> completer;
    await tasks.run(() async {
      await removeOverlay();
      completer = Completer<Object?>();
      _currentCompleter = completer;
      _dismissResult = dismissResult;
      insertOverlay(builder, zIndex: zIndex);
    });
    return await completer.future as T;
  }

  FutureOr<void> Function() _buildAction<T>({
    required T Function() result,
    required FutureOr<bool> Function() beforeClose,
  }) {
    return () {
      final actionResult = beforeClose();
      if (actionResult is Future<bool>) {
        return actionResult.then((shouldClose) {
          if (shouldClose) unawaited(_finish(result()));
        });
      }
      if (actionResult) {
        unawaited(_finish(result()));
      }
    };
  }

  /// 点击按钮后先完成结果，再走关闭动画。
  Future<void> _finish(Object? result) async {
    if (_currentCompleter?.isCompleted == false) {
      _currentCompleter?.complete(result);
    }
    await _close(result: result);
  }

  Future<void> _close({required Object? result}) async {
    final h = currentHandle;
    final completer = _currentCompleter;
    if (h == null) return;
    if (completer?.isCompleted == false) completer?.complete(result);
    await removeOverlay(h);
    if (identical(_currentCompleter, completer)) _currentCompleter = null;
    _dismissResult = null;
  }

  @override
  void onRemoved(ElOverlayHandle handle) {
    super.onRemoved(handle);
    if (_currentCompleter?.isCompleted == false) _currentCompleter?.complete(_dismissResult);
    _currentCompleter = null;
    _dismissResult = null;
  }
}

class _ElPromptWidget extends ElAnimatedOverlayWidget {
  const _ElPromptWidget({
    required super.handle,
    this.title,
    required this.content,
    this.cancel,
    required this.confirm,
    required this.onCancel,
    required this.onConfirm,
  });

  final String? title;
  final Widget content;
  final String? cancel;
  final String confirm;
  final FutureOr<void> Function()? onCancel;
  final FutureOr<void> Function() onConfirm;

  @override
  State<_ElPromptWidget> createState() => _ElPromptWidgetState();
}

enum _ElPromptActionType { cancel, confirm }

class _ElPromptWidgetState extends ElAnimatedOverlayWidgetState<_ElPromptWidget> {
  bool _cancelLoading = false;
  bool _confirmLoading = false;

  @override
  Duration get duration => 250.ms;

  @override
  Duration get reverseDuration => 200.ms;

  bool get _loading => _cancelLoading || _confirmLoading;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: overlayPointerFilter(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onCancel == null ? null : _handleCancel,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => ColoredBox(
            color: Color.lerp(Colors.transparent, Colors.black.withAlpha(90), controller.value)!,
            child: child!,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final progress = (controller.value / .8).clamp(0.0, 1.0);
                // 只在显示阶段做轻微缩放，隐藏阶段保持原尺寸直接淡出。
                final scale = controller.status == AnimationStatus.reverse
                    ? 1.0
                    : Tween(begin: 1.1, end: 1.0).transform(Curves.easeIn.transform(progress));
                return FadeTransition(
                  opacity: controller,
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: GestureDetector(
                onTap: () {},
                child: Builder(
                  builder: (context) {
                    // 面板颜色、分隔线和文案颜色都按明暗主题做一层适配。
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final background = isDark ? const Color(0xCC2C2C2E) : const Color(0xCCF2F2F7);
                    final titleColor = isDark ? Colors.white : const Color(0xFF111111);
                    final contentColor = isDark ? Colors.white.withAlpha(220) : const Color(0xFF3C3C43).withAlpha(215);
                    final cancelColor = isDark ? Colors.white.withAlpha(235) : const Color(0xFF111111);
                    final dividerColor = isDark ? Colors.white.withAlpha(28) : const Color(0xFF3C3C43).withAlpha(36);
                    final confirmColor = const Color(0xFF007AFF);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        // 用毛玻璃模拟 iOS alert 的磨砂质感。
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          width: 270,
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withAlpha(isDark ? 20 : 120)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (widget.title != null) ...[
                                      Text(
                                        widget.title!,
                                        textAlign: .center,
                                        style: TextStyle(color: titleColor, fontSize: 18, fontWeight: .bold),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    DefaultTextStyle(
                                      style: TextStyle(
                                        color: contentColor,
                                        fontSize: 14,
                                        height: 1.35,
                                        fontWeight: .w500,
                                      ),
                                      child: widget.content,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, thickness: 1, color: dividerColor),
                              SizedBox(
                                height: 44,
                                child: Row(
                                  children: [
                                    if (widget.cancel != null) ...[
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: _handleCancel,
                                          child: Center(
                                            child: _ElPromptActionLabel(
                                              text: widget.cancel!,
                                              color: cancelColor,
                                              loading: _cancelLoading,
                                            ),
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(width: 1, thickness: 1, color: dividerColor),
                                    ],
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: _handleConfirm,
                                        child: Center(
                                          child: _ElPromptActionLabel(
                                            text: widget.confirm,
                                            color: confirmColor,
                                            loading: _confirmLoading,
                                            bold: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _handleCancel() => _runAction(widget.onCancel, _ElPromptActionType.cancel);

  Future<void> _handleConfirm() => _runAction(widget.onConfirm, _ElPromptActionType.confirm);

  Future<void> _runAction(FutureOr<void> Function()? action, _ElPromptActionType type) async {
    if (action == null || _loading) return;
    final result = action();
    if (result is! Future) return;
    setState(() {
      if (type == _ElPromptActionType.cancel) {
        _cancelLoading = true;
      } else {
        _confirmLoading = true;
      }
    });
    try {
      await result;
    } finally {
      setState(() {
        if (type == _ElPromptActionType.cancel) {
          _cancelLoading = false;
        } else {
          _confirmLoading = false;
        }
      });
    }
  }
}

class _ElPromptAlertContent extends StatelessWidget {
  const _ElPromptAlertContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Text(content, textAlign: .center);
  }
}

class _ElPromptInputContent extends StatelessWidget {
  const _ElPromptInputContent({this.placeholder});

  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withAlpha(20) : const Color(0xFF3C3C43).withAlpha(36);
    final fillColor = isDark ? Colors.black.withAlpha(45) : Colors.white.withAlpha(180);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextField(
        autofocus: true,
        textAlign: TextAlign.center,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111111), fontSize: 15),
        decoration: InputDecoration(
          isDense: true,
          hintText: placeholder,
          hintStyle: TextStyle(color: isDark ? Colors.white.withAlpha(100) : const Color(0xFF8E8E93)),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF007AFF)),
          ),
        ),
      ),
    );
  }
}

class _ElPromptActionLabel extends StatelessWidget {
  const _ElPromptActionLabel({required this.text, required this.color, required this.loading, this.bold = false});

  final String text;
  final Color color;
  final bool loading;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: ElLoading(child: Icon(ElIcons.loading, size: 14, color: color)),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(color: color, fontSize: 16, fontWeight: bold ? FontWeight.w600 : null),
        ),
      ],
    );
  }
}
