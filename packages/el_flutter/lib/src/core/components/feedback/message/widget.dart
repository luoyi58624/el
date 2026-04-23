part of 'index.dart';

/// 消息默认高度
const double _messageHeight = 40;

/// 消息之间的间距
const double _messageGap = 8;

/// 消息小部件，只负责处理消息显示、隐藏动画
class _MessageWidget extends ElAnimatedOverlayWidget {
  const _MessageWidget({
    required super.handle,
    required this.message,
    required this.service,
  });

  final _MessageModel message;
  final ElMessageService service;

  @override
  State<_MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends ElAnimatedOverlayWidgetState<_MessageWidget> {
  late final Animation<double> offsetAnimation;
  late final Animation<double> opacityAnimation;
  Timer? _removeTimer;
  final GlobalKey messageKey = GlobalKey(debugLabel: 'el_message2');

  @override
  Duration get duration => widget.message.animationDuration;

  @override
  void initState() {
    super.initState();
    offsetAnimation = Tween<double>(
      begin: -_messageHeight,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: const Cubic(0, 0, 0.2, 1)));
    opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    widget.message._groupCount.addListener(_resetRemoveTimer);
  }

  @override
  void dispose() {
    widget.message._groupCount.removeListener(_resetRemoveTimer);
    _removeTimer?.cancel();
    super.dispose();
  }

  @override
  Future<void> hide() async {
    _removeTimer?.cancel();
    _removeTimer = null;
    await super.hide();
  }

  @override
  void onShown() {
    setRemoveTimer();
  }

  /// 计算当前消息在页面中的位置
  double get topOffset {
    return widget.service._topOffsetOf(widget.message);
  }

  /// 设置移除消息计时器
  void setRemoveTimer() {
    _removeTimer ??= ElAsyncUtil.setTimeout(() {
      close();
    }, widget.message.closeDuration.inMilliseconds);
  }

  void _resetRemoveTimer() {
    _removeTimer?.cancel();
    _removeTimer = null;
    setRemoveTimer();
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.maybeSizeOf(context);
    nextTick(() {
      final size = messageKey.currentContext?.size;
      if (size != null) {
        widget.service._updateMessageSize(widget.message, size);
      }
    });

    return Positioned.fill(
      child: overlayPointerFilter(
        Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: Listenable.merge([widget.service, widget.message._groupCount]),
            builder: (context, child) {
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: widget.message.animationDuration,
                    top: MediaQuery.paddingOf(context).top + topOffset,
                    left: 0,
                    right: 0,
                    child: ElRebuildWidget(
                      child: UnconstrainedBox(
                        child: SelectionArea(
                          child: AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, offsetAnimation.value),
                                child: Opacity(opacity: opacityAnimation.value, child: child),
                              );
                            },
                            child: ElEvent(
                              style: ElEventStyle(
                                onEnter: (e) {
                                  if (_removeTimer != null) {
                                    _removeTimer!.cancel();
                                    _removeTimer = null;
                                  }
                                },
                                onExit: (e) {
                                  setRemoveTimer();
                                },
                              ),
                              child: Builder(
                                builder: (context) => SizedBox(
                                  key: messageKey,
                                  child: ObsBuilder(
                                    builder: (context) {
                                      return ElBadge(
                                        badge: widget.message._groupCount.value,
                                        child: widget.message.builder(context),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 构建默认风格样式的消息小部件
Widget _defaultBuilder(BuildContext context, _MessageModel message) => _DefaultMessage(message);

/// Element UI 默认样式消息组件
class _DefaultMessage extends StatelessWidget {
  const _DefaultMessage(this.message);

  final _MessageModel message;

  Widget get messageIcon {
    if (message.type == .primary) return const Icon(ElIcons.platformEleme);
    if (message.type == .success) return const Icon(ElIcons.success);
    if (message.type == .warning) return const Icon(ElIcons.warning);
    if (message.type == .error) return const Icon(ElIcons.error);
    return const Icon(ElIcons.info);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.elThemeColors[message.type]!;
    double maxWidth = context.xs
        ? 250
        : context.sm
        ? 320
        : 450;
    double maxTextWidth = message.showClose ? maxWidth - 120 : maxWidth - 80;

    return ElAnimatedMaterial(
      color: themeColor.themeLightBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: el.config.cardBorderRadius,
        side: BorderSide(color: themeColor.themeLightBorder(context)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, minHeight: _messageHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(color: themeColor),
                child: message.icon ?? messageIcon,
              ),
              const Gap(10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTextWidth),
                child: ElAnimatedDefaultColor(
                  ElBrightness.isDark(context) ? el.darkTheme.textColor : themeColor,
                  child: Builder(
                    builder: (context) {
                      return ElRichText(
                        message.content,
                        style: TextStyle(color: context.elDefaultColor, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ),
              ),
              if (message.showClose) const Gap(10),
              if (message.showClose)
                ElAnimatedIconTheme(
                  data: IconThemeData(color: IconTheme.of(context).color!.withAlpha(150), size: 16),
                  child: ElCloseButton(
                    onTap: (e) => message.close(),
                    cursor: SystemMouseCursors.click,
                    iconHoverColor: themeColor,
                    bgHoverColor: themeColor.elLight7(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _MessageColorExtension on Color {
  /// 应用主题透明背景颜色
  Color themeLightBg(BuildContext context) => elLight9(context);

  /// 应用主题透明边框颜色
  Color themeLightBorder(BuildContext context) => elLight8(context);
}
