import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'group.dart';

class ElRadio extends StatelessWidget {
  /// 单选框组件，此构造必须在祖先提供 [ElRadioGroup] 单选框组
  const ElRadio({super.key, this.value, this.label, this.color, this.disabled = false});

  /// 单选框的值，如果为 null，则默认使用 [label]
  final dynamic value;

  /// 单选框标签，如果为 null 则只渲染 [Radio] 小部件
  final String? label;

  /// 选择框主题颜色
  final Color? color;

  /// 是否禁用
  final bool disabled;

  dynamic get _selectedValue => value ?? label;

  double get disabledOpacity => 0.5;

  MouseCursor get cursor => disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click;

  Color getActiveColor(BuildContext context) {
    return color ?? (context.elDefaultColor.isHighlight ? Colors.white : context.elTheme.primary);
  }

  /// 构建单选框小部件
  Widget buildRadio(BuildContext context, ElRadioGroupState state) {
    return Radio<dynamic>(
      value: _selectedValue,
      mouseCursor: cursor,
      enabled: !disabled,
      activeColor: getActiveColor(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ElRadioGroup.of(context);
    Widget result = buildRadio(context, state);

    if (label != null) {
      final isSelected = _selectedValue == state.modelValue;
      final textColor = context.elDefaultColor.elTextColor(context);
      result = MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: disabled ? null : () => state.modelValue = _selectedValue,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              result,
              ElRichText(
                label,
                style: context.elTextStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: disabled
                      ? textColor.elOpacity(0.6)
                      : isSelected
                      ? getActiveColor(context)
                      : textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return result;
  }
}
