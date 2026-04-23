part of 'index.dart';

class _ElDialog2Widget extends ElAnimatedOverlayWidget {
  // ignore: prefer_const_constructors_in_immutables
  _ElDialog2Widget({
    required this.handle,
    required this.body,
    required super.removeOverlay,
    required super.onRegisterRemoveHide,
    required super.onRegisterHideForOverlay,
    required super.onRegisterShowForOverlay,
  });

  final ElOverlayHandle handle;
  final Widget body;

  @override
  State<_ElDialog2Widget> createState() => _ElDialog2WidgetState();
}

class _ElDialog2WidgetState extends ElAnimatedOverlayWidgetState<_ElDialog2Widget> {
  @override
  Duration get duration => el.config.duration;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: overlayPointerFilter(
        FadeTransition(
          opacity: controller,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => unawaited(el.dialog2._onBackdropTap(widget.handle)),
                  child: ColoredBox(color: Colors.black54),
                ),
              ),
              Center(child: widget.body),
            ],
          ),
        ),
      ),
    );
  }
}
