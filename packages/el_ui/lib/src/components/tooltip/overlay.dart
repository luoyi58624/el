part of 'index.dart';

class ElTooltipOverlay extends StatefulWidget {
  const ElTooltipOverlay({
    super.key,
    required this.state,
    this.height,
    this.fontSize,
    this.bgColor,
    this.showArrow,
    this.enabledSelected,
    this.padding,
  });

  final ElPopupState state;

  /// tooltip 高度
  final double? height;

  /// tooltip 字体大小
  final double? fontSize;

  /// 自定义提示框背景色
  final Color? bgColor;

  /// 是否显示箭头，默认 false
  final bool? showArrow;

  /// tooltip 文字是否可选中
  final bool? enabledSelected;

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  @override
  State<ElTooltipOverlay> createState() => _ElTooltipOverlayState();
}

class _ElTooltipOverlayState extends State<ElTooltipOverlay> {
  ElTooltipState get state {
    assert(widget.state is ElTooltipState);
    return widget.state as ElTooltipState;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.bgColor ?? context.elTheme.tooltipColor;
    final message = state.widget.message;
    final child = message == null
        ? null
        : message is Widget
        ? message
        : ElRichText(
            message,
            style: TextStyle(fontSize: (ElPlatform.isDesktop ? 12 : 13), color: bgColor.elTextColor(context)),
            // selectionColor: bgColor.elSelectionColor(context),
          );

    if (child == null) return ElEmptyWidget.instance;

    Widget result = Container(
      constraints: BoxConstraints(minHeight: widget.height ?? (ElPlatform.isDesktop ? 28 : 32)),
      padding:
          widget.padding ??
          (ElPlatform.isDesktop
              ? const .symmetric(horizontal: 8, vertical: 4)
              : .symmetric(horizontal: 10, vertical: 6)),
      decoration: BoxDecoration(color: bgColor, borderRadius: el.config.borderRadius),
      child: ClipRect(
        clipBehavior: .hardEdge,
        child: LayoutBuilder(
          builder: (_, c) {
            return UnconstrainedBox(
              child: Center(
                child: ConstrainedBox(constraints: c.loosen(), child: child),
              ),
            );
          },
        ),
      ),
    );

    if (widget.enabledSelected == true) {
      result = SelectionArea(
        onSelectionChanged: (e) {
          if (context.mounted) {
            // if (ElDartUtil.isEmpty(e?.plainText)) {
            //   state.hoverHasActive = false;
            // } else {
            //   state.hoverHasActive = true;
            // }
          }
        },
        child: result,
      );
    }

    return result;
  }
}
