import 'package:flutter/material.dart';
import 'package:el_ui/el_ui.dart';

part 'checkbox_group.dart';

class ElCheckbox extends ElStatelessModelValue<bool?> {
  /// 多选框组件，使用该小部件时必须在祖先节点提供 [ElCheckboxGroup] 多选框组，示例：
  /// ```dart
  /// class Example extends HookWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final flag = useState([]);
  ///     return ElCheckboxGroup(
  ///       flag,
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
       valueListData = null,
       super(null);

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
  ///       flag,
  ///       child: Scaffold(
  ///         appBar: AppBar(actions: [ElCheckbox.indeterminate(data)]),
  ///         body: Row(children: data.map((e) => ElCheckbox(value: e)).toList()),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// 注意：如果复选框的数据量很大，请使用 Set 集合。
  const ElCheckbox.indeterminate(this.valueListData, {super.key, this.color, this.checkColor, this.borderColor})
    : value = null,
      label = null,
      disabled = false,
      indeterminate = true,
      assert(valueListData != null),
      super(null);

  /// 构建开关类型的复选框，这是一个独立的、支持双向绑定的复选框，
  /// 它不需要祖先提供 [ElCheckboxGroup] 复选框组，示例：
  /// ```dart
  /// class Example extends HookWidget {
  ///   const Example({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final flag = useState(false);
  ///     return ElCheckbox.toggle(flag);
  ///   }
  /// }
  /// ```
  const ElCheckbox.toggle(
    super.modelValue, {
    super.key,
    this.color,
    this.checkColor,
    this.borderColor,
    this.disabled = false,
    super.onChanged,
  }) : value = null,
       label = null,
       indeterminate = false,
       valueListData = null;

  /// 复选框的值，如果为 null，则默认使用 [label]
  final dynamic value;

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

  /// 包含全部 [value] 的数据集合，注意：若原始数据集是对象，你需要提取出 [value] 集合，
  /// 因为全选逻辑就是直接将这个集合传递给 modelValue
  final Iterable? valueListData;

  /// 是否为不确定状态多选框
  final bool indeterminate;

  dynamic get _selectedValue {
    return value ?? label;
  }

  double get disabledOpacity => 0.5;

  Color getActiveColor(BuildContext context) {
    return color ?? (context.elDefaultColor.isHighlight ? Colors.white : context.elTheme.primary);
  }

  /// 判断复选框是否被禁用，除了设置 [disabled] 属性外，当复选框组设置了 min、max 限制条件时，也会禁用剩下的复选框
  bool checkDisabled([ElCheckboxGroupState? state, bool? isSelected]) {
    if (disabled) return true;
    if (state == null) return false;
    return (state.disabledRemove && isSelected == true) || (state.disabledAdd && isSelected != true);
  }

  /// 构建复选框
  Widget buildCheckBox(BuildContext context, ElCheckboxGroupState state) {
    return _Checkbox(
      this,
      state: state,
      value: state.hasElement(_selectedValue),

      onChanged: (v) => v == true ? state.addElement(_selectedValue) : state.removeElement(_selectedValue),
    );
  }

  /// 构建中间态复选框
  Widget buildIndeterminateCheckBox(BuildContext context, ElCheckboxGroupState state) {
    assert(state.widget.max == null, 'ElCheckbox 中间态复选框不允许设置 max 限制');

    bool? value;
    if (state.modelValue.isEmpty) {
      value = false;
    } else if (state.modelValue.length == valueListData!.length) {
      value = true;
    }

    return _Checkbox(
      this,
      state: state,
      value: value,
      tristate: true,
      onChanged: (v) {
        if (state.modelValue.isEmpty || state.modelValue.length < valueListData!.length) {
          state.modelValue = valueListData!;
        } else {
          state.clear();
        }
      },
    );
  }

  /// 构建 [ElCheckbox.toggle] 开关类型的复选框
  @override
  Widget obsBuilder(BuildContext context, bool? value) {
    return _Checkbox(this, value: value, onChanged: (v) => modelValue = v);
  }

  @override
  Widget build(BuildContext context) {
    Widget result;

    if (modelValue == null) {
      final state = ElCheckboxGroup.maybeOf(context);
      assert(state != null, 'ElCheckBox 祖先没有找到 ElCheckBoxGroup，如果你要构建独立的复选框，请使用 single 构造器');

      if (indeterminate == false) {
        final isSelected = state!.hasElement(_selectedValue);
        final isDisabled = checkDisabled(state, isSelected);

        result = buildCheckBox(context, state);

        if (label != null) {
          final textColor = context.elDefaultColor.elTextColor(context);

          result = MouseRegion(
            cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isDisabled
                  ? null
                  : () {
                      state.hasElement(_selectedValue)
                          ? state.removeElement(_selectedValue)
                          : state.addElement(_selectedValue);
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  result,
                  ElRichText(
                    label,
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
        result = buildIndeterminateCheckBox(context, state!);
      }
    } else {
      result = super.build(context);
    }

    return result;
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox(this.instance, {this.state, required this.value, this.tristate = false, required this.onChanged});

  final ElCheckbox instance;
  final ElCheckboxGroupState? state;
  final bool? value;
  final bool tristate;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bgColor = context.elDefaultColor;
    final isHighlightBg = bgColor.isHighlight;
    final isDisabled = instance.checkDisabled(state, value);

    var activeColor = instance.getActiveColor(context);
    var borderColor = instance.borderColor ?? (isHighlightBg ? Colors.white : context.elTheme.regularTextColor);
    if (isDisabled) {
      borderColor = borderColor.elOpacity(instance.disabledOpacity);
    }

    return Checkbox(
      value: value,
      tristate: tristate,
      mouseCursor: isDisabled ? SystemMouseCursors.forbidden : null,
      activeColor: activeColor,
      checkColor: instance.checkColor ?? activeColor.elTextColor(context),
      side: BorderSide(width: 2, color: borderColor),
      onChanged: isDisabled ? null : onChanged,
    );
  }
}
