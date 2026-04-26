import 'package:el_model_value/el_model_value.dart';
import 'package:el_ui/el_ui.dart' hide ElModelValue, ElModelValueMixin;
import 'package:flutter/material.dart';

part 'checkbox_group.dart';

bool _toggleCheckDisabledUnused(ElCheckboxGroupScope? scope, bool? selected) => false;

class ElCheckbox extends StatelessWidget {
  /// 多选框组件，使用该小部件时必须在祖先节点提供 [ElCheckboxGroup] 多选框组，示例：
  /// ```dart
  /// class Example extends HookWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final flag = useState([]);
  ///     return ElCheckboxGroup(
  ///       modelValue: flag,
  ///       child: Row(
  ///         children: [
  ///           ElCheckbox(value: 1),
  ///           ElCheckbox(value: 2),
  ///           ElCheckbox(value: 3),
  ///         ],
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  const ElCheckbox({
    super.key,
    this.value,
    this.label,
    this.color,
    this.checkColor,
    this.borderColor,
    this.disabled = false,
  }) : indeterminate = false,
       valueListData = null;

  /// 构建带有不确定状态的多选框，你只需要传递原始列表数据集合，内部已经自动处理了全选逻辑，示例：
  /// ```dart
  /// class Example extends HookWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final data = [1, 2, 3];
  ///     final flag = useState([]);
  ///     return ElCheckboxGroup(
  ///       modelValue: flag,
  ///       child: Scaffold(
  ///         appBar: AppBar(actions: [ElCheckbox.indeterminate(data)]),
  ///         body: Row(children: data.map((e) => ElCheckbox(value: e)).toList()),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  const ElCheckbox.indeterminate(Iterable<Object?> this.valueListData, {super.key, this.color, this.checkColor, this.borderColor})
    : value = null,
      label = null,
      disabled = false,
      indeterminate = true;

  /// 复选框的值，如果为 null，则默认使用 [label]
  final Object? value;

  /// 复选框标签，如果为 null 则只渲染 [Checkbox] 小部件
  final String? label;

  /// 复选框激活的背景颜色
  final Color? color;

  /// 复选框钩子颜色
  final Color? checkColor;

  /// 复选框边框颜色
  final Color? borderColor;

  /// 是否禁用
  final bool disabled;

  /// 包含全部 [value] 的数据集合（仅 [ElCheckbox.indeterminate] 使用）。
  final Iterable<Object?>? valueListData;

  /// 是否为不确定状态多选框
  final bool indeterminate;

  Object? get _selectedValue => value ?? label;

  double get disabledOpacity => 0.5;

  Color getActiveColor(BuildContext context) {
    return color ?? (context.elDefaultColor.isHighlight ? Colors.white : context.elTheme.primary);
  }

  /// 判断复选框是否被禁用，除了设置 [disabled] 属性外，当复选框组设置了 min、max 限制条件时，也会禁用剩下的复选框
  bool checkDisabled([ElCheckboxGroupScope? scope, bool? isSelected]) {
    if (disabled) return true;
    if (scope == null) return false;
    return (scope.disabledRemove && isSelected == true) || (scope.disabledAdd && isSelected != true);
  }

  /// 构建复选框
  Widget buildCheckBox(BuildContext context, ElCheckboxGroupScope scope) {
    return _Checkbox(
      color: color,
      checkColor: checkColor,
      borderColor: borderColor,
      disabledOpacity: disabledOpacity,
      getActiveColor: getActiveColor,
      checkDisabled: checkDisabled,
      forceDisabled: null,
      scope: scope,
      value: scope.hasElement(_selectedValue),
      onChanged: (v) => v == true ? scope.addElement(_selectedValue) : scope.removeElement(_selectedValue),
    );
  }

  /// 构建中间态复选框
  Widget buildIndeterminateCheckBox(BuildContext context, ElCheckboxGroupScope scope) {
    assert(scope.widget.max == null, 'ElCheckbox 中间态复选框不允许设置 max 限制');
    final data = valueListData!;

    bool? triValue;
    if (scope.modelValue.isEmpty) {
      triValue = false;
    } else if (scope.modelValue.length == data.length) {
      triValue = true;
    }

    return _Checkbox(
      color: color,
      checkColor: checkColor,
      borderColor: borderColor,
      disabledOpacity: disabledOpacity,
      getActiveColor: getActiveColor,
      checkDisabled: checkDisabled,
      forceDisabled: null,
      scope: scope,
      value: triValue,
      tristate: true,
      onChanged: (v) {
        if (scope.modelValue.isEmpty || scope.modelValue.length < data.length) {
          scope.modelValue = List<Object?>.from(data);
        } else {
          scope.clear();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = ElCheckboxGroup.maybeOf(context);
    assert(scope != null, 'ElCheckBox 祖先没有找到 ElCheckBoxGroup，如果你要构建独立的复选框，请使用 ElCheckboxToggle');

    Widget result;

    if (indeterminate == false) {
      final isSelected = scope!.hasElement(_selectedValue);
      final isDisabled = checkDisabled(scope, isSelected);

      result = buildCheckBox(context, scope);

      if (label != null) {
        final textColor = context.elDefaultColor.elTextColor(context);

        result = MouseRegion(
          cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isDisabled
                ? null
                : () {
                    scope.hasElement(_selectedValue) ? scope.removeElement(_selectedValue) : scope.addElement(_selectedValue);
                  },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                result,
                ElRichText(
                  label!,
                  style: context.elTextStyle.copyWith(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isDisabled
                        ? textColor.elOpacity(disabledOpacity)
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
    } else {
      result = buildIndeterminateCheckBox(context, scope!);
    }

    return result;
  }
}

/// 独立开关型复选框（双向绑定），无需 [ElCheckboxGroup] 祖先。
class ElCheckboxToggle extends ElModelValue<bool?> {
  ElCheckboxToggle({
    super.key,
    super.value,
    super.modelValue,
    super.onChanged,
    this.color,
    this.checkColor,
    this.borderColor,
    this.disabled = false,
  });

  final Color? color;
  final Color? checkColor;
  final Color? borderColor;
  final bool disabled;

  double get disabledOpacity => 0.5;

  Color getActiveColor(BuildContext context) {
    return color ?? (context.elDefaultColor.isHighlight ? Colors.white : context.elTheme.primary);
  }

  @override
  Widget obsBuild(BuildContext context) {
    return _Checkbox(
      color: color,
      checkColor: checkColor,
      borderColor: borderColor,
      disabledOpacity: disabledOpacity,
      getActiveColor: getActiveColor,
      checkDisabled: _toggleCheckDisabledUnused,
      forceDisabled: disabled,
      scope: null,
      value: $obs.value,
      onChanged: disabled ? null : (v) => $obs.value = v,
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({
    required this.color,
    required this.checkColor,
    required this.borderColor,
    required this.disabledOpacity,
    required this.getActiveColor,
    required this.checkDisabled,
    this.forceDisabled,
    required this.scope,
    required this.value,
    this.tristate = false,
    required this.onChanged,
  });

  final Color? color;
  final Color? checkColor;
  final Color? borderColor;
  final double disabledOpacity;
  final Color Function(BuildContext) getActiveColor;
  final bool Function(ElCheckboxGroupScope?, bool?) checkDisabled;
  final bool? forceDisabled;
  final ElCheckboxGroupScope? scope;
  final bool? value;
  final bool tristate;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bgColor = context.elDefaultColor;
    final isHighlightBg = bgColor.isHighlight;
    final isDisabled = forceDisabled ?? checkDisabled(scope, value);

    var activeColor = getActiveColor(context);
    var effectiveBorderColor = borderColor ?? (isHighlightBg ? Colors.white : context.elTheme.regularTextColor);
    if (isDisabled) {
      effectiveBorderColor = effectiveBorderColor.elOpacity(disabledOpacity);
    }

    return Checkbox(
      value: value,
      tristate: tristate,
      mouseCursor: isDisabled ? SystemMouseCursors.forbidden : null,
      activeColor: activeColor,
      checkColor: checkColor ?? activeColor.elTextColor(context),
      side: BorderSide(width: 2, color: effectiveBorderColor),
      onChanged: onChanged,
    );
  }
}
