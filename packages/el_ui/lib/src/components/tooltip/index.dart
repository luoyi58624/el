import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'overlay.dart';

part 'theme.dart';

part 'index.g.dart';

Widget _overlayBuilder(BuildContext context) {
  return ElTooltipOverlay(state: ElPopup.of(context));
}

class ElTooltip extends ElPopover {
  const ElTooltip({
    super.key,
    super.show,
    super.duration,
    super.alignment = ElPopupAlignment.bottom,
    super.spacing,
    super.edgeSpacing,
    super.hoverDelayShow,
    super.hoverDelayHide,
    super.staticHover,
    super.showArrow,
    required this.message,
    required super.child,
  }) : super(overlayBuilder: _overlayBuilder);

  /// 提示框文本内容，你可以直接传递 [Widget] 渲染任意内容
  final dynamic message;

  @override
  State<ElPopup> createState() => ElTooltipState();
}

class ElTooltipState<T extends ElTooltip> extends ElPopoverState<T> {
  late ElTooltipThemeData themeData;

  @override
  double get spacing => widget.spacing ?? themeData.spacing!;

  @override
  double get edgeSpacing => widget.edgeSpacing ?? themeData.edgeSpacing!;

  @override
  int get hoverDelayShow => widget.hoverDelayShow ?? themeData.hoverDelayShow!;

  @override
  int get hoverDelayHide => widget.hoverDelayHide ?? themeData.hoverDelayHide!;

  @override
  bool get staticHover => widget.staticHover ?? themeData.staticHover!;

  @override
  bool get showArrow => widget.showArrow ?? themeData.showArrow!;

  @override
  Widget build(BuildContext context) {
    themeData = ElTooltipTheme.of(context);
    return super.build(context);
  }
}
