import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'input_number.dart';

part 'theme.dart';

part 'index.g.dart';

// ignore_for_file: deprecated_member_use

/// Element 响应式输入框，它继承官方提供的 [TextField]，所有行为都与 [TextField] 无异。
/// 你无需声明 [TextEditingController] 控制器，也无需监听 [onChanged] 手动更新内容：
/// * 当输入框内部发生变化时，会自动同步 input 变量；
/// * 当更新 input 变量时，也会自动同步输入框的内部状态；
///
/// 例如：
/// ```dart
/// class _Example extends HookWidget {
///   const _Example();
///
///   @override
///   Widget build(BuildContext context) {
///     final input = useState('');
///     return ElInput(input);
///   }
/// }
/// ```
///
/// 如果你想集成其他设计语言的输入框，可以选择继承 [ElInputModelValue] 基础小部件。
class ElInput extends TextField implements ElInputModelValue<String> {
  const ElInput(
    this.modelValue, {
    super.key,
    this.prop,
    this.cleanIcon = const Icon(Icons.clear, size: 18),
    this.clearable = false,
    this.showPasswordIcon = false,
    this.onClean,
    super.controller,
    super.focusNode,
    super.undoController,
    super.decoration,
    super.keyboardType,
    super.textInputAction,
    super.textCapitalization,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textAlignVertical,
    super.textDirection,
    super.readOnly,
    super.toolbarOptions,
    super.showCursor,
    super.autofocus,
    super.statesController,
    super.obscuringCharacter,
    super.obscureText,
    super.autocorrect,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions,
    super.maxLines,
    super.minLines,
    super.expands,
    super.maxLength,
    super.maxLengthEnforcement,
    super.onChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.onAppPrivateCommand,
    super.inputFormatters,
    super.enabled,
    super.ignorePointers,
    super.cursorWidth,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorOpacityAnimates,
    super.cursorColor,
    super.cursorErrorColor,
    super.selectionHeightStyle,
    super.selectionWidthStyle,
    super.keyboardAppearance,
    super.scrollPadding,
    super.dragStartBehavior,
    super.enableInteractiveSelection,
    super.selectAllOnFocus,
    super.selectionControls,
    super.onTap,
    super.onTapAlwaysCalled,
    super.onTapOutside,
    super.onTapUpOutside,
    super.mouseCursor,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
    super.autofillHints,
    super.contentInsertionConfiguration,
    super.clipBehavior,
    super.restorationId,
    super.scribbleEnabled,
    super.stylusHandwritingEnabled,
    super.enableIMEPersonalizedLearning,
    super.contextMenuBuilder,
    super.canRequestFocus,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
    super.hintLocales,
  });

  @override
  final dynamic modelValue;

  @override
  final String? prop;

  /// 自定义清除图标
  final Widget cleanIcon;

  /// 显示清除图标
  final bool clearable;

  /// 构建显示、隐藏密码图标，要默认隐藏请设置 [obscureText] 为 true
  final bool showPasswordIcon;

  /// 点击清除回调
  final GestureTapCallback? onClean;

  @override
  State<ElInput> createState() => _ElInputState();
}

class _ElInputState extends ElInputModelValueState<ElInput, String> {
  /// 显示、隐藏密码状态
  bool? _obscureText;

  void _togglePassword() {
    setState(() {
      if (_obscureText == true) {
        _obscureText = false;
      } else {
        _obscureText = true;
      }
    });
  }

  @override
  Widget buildInput(BuildContext context) {
    InputDecoration? decoration = widget.decoration;

    // 重新构建前缀、后缀图标
    Widget? prefixIcon = decoration?.prefixIcon;
    Widget? suffixIcon = decoration?.suffixIcon;

    if (widget.showPasswordIcon) {
      _obscureText ??= widget.obscureText;
      suffixIcon = ElButton.icon(
        block: true,
        onPressed: _togglePassword,
        child: _obscureText == true ? Icons.visibility_off : Icons.visibility,
      );
    } else if (widget.clearable && modelValue.isNotEmpty) {
      suffixIcon = ElButton.icon(
        block: true,
        onPressed: () {
          widget.onClean?.call();
          modelValue = '';
        },
        child: widget.cleanIcon,
      );
    }

    // 由于清除了默认的图标约束，所以需要使用 AspectRatio 重新固定图标的尺寸
    if (prefixIcon != null) {
      prefixIcon = AspectRatio(
        aspectRatio: 1.0,
        child: Padding(padding: .all(2), child: prefixIcon),
      );
    }

    if (suffixIcon != null) {
      suffixIcon = AspectRatio(
        aspectRatio: 1.0,
        child: Padding(padding: .all(2), child: suffixIcon),
      );
    }

    if (prefixIcon != null || suffixIcon != null) {
      if (decoration == null) {
        decoration = InputDecoration(prefixIcon: prefixIcon, suffixIcon: suffixIcon);
      } else {
        decoration = decoration.copyWith(prefixIcon: prefixIcon, suffixIcon: suffixIcon);
      }
    }

    return TextField(
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      scrollController: scrollController,
      decoration: decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      toolbarOptions: widget.toolbarOptions,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      obscureText: _obscureText ?? widget.obscureText,
      obscuringCharacter: widget.obscuringCharacter,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      ignorePointers: widget.ignorePointers,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorColor: widget.cursorColor,
      cursorErrorColor: widget.cursorErrorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectAllOnFocus: widget.selectAllOnFocus,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      onTapUpOutside: widget.onTapUpOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      scribbleEnabled: widget.scribbleEnabled,
      stylusHandwritingEnabled: widget.stylusHandwritingEnabled,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      contextMenuBuilder: widget.contextMenuBuilder,
      canRequestFocus: widget.canRequestFocus,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
      hintLocales: widget.hintLocales,
    );
  }
}
