import 'package:el_flutter/ext.dart';
import 'package:el_model_value/el_model_value.dart';
import 'package:el_ui/el_ui.dart' hide ElModelValue, ElModelValueMixin;
import 'dart:ui' show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'input_number.dart';

part 'theme.dart';

part 'index.g.dart';

// ignore_for_file: deprecated_member_use

/// Element 响应式输入框，行为与 [TextField] 对齐。
///
/// 使用命名参数 [value] / [modelValue] 绑定；可选 [controller] / [focusNode] 覆盖内部 hook 实例。
///
/// ```dart
/// final input = useState('');
/// return ElInput(modelValue: input);
/// ```
///
/// 自定义输入外观可继承 [ElInputModelValue]。
class ElInput extends ElInputModelValue<String> {
  ElInput({
    super.key,
    super.value,
    super.modelValue,
    super.prop,
    super.onChanged,
    super.controller,
    super.focusNode,
    super.scrollController,
    this.cleanIcon = const Icon(Icons.clear, size: 18),
    this.clearable = false,
    this.showPasswordIcon = false,
    this.onClean,
    this.undoController,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.toolbarOptions,
    this.showCursor = true,
    this.autofocus = false,
    this.statesController,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled = true,
    this.ignorePointers = false,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.selectAllOnFocus = false,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.stylusHandwritingEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.hintLocales,
  });

  final Widget cleanIcon;
  final bool clearable;
  final bool showPasswordIcon;
  final GestureTapCallback? onClean;

  final UndoHistoryController? undoController;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final ToolbarOptions? toolbarOptions;
  final bool showCursor;
  final bool autofocus;
  final WidgetStatesController? statesController;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool ignorePointers;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final BoxHeightStyle? selectionHeightStyle;
  final BoxWidthStyle? selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final bool enableInteractiveSelection;
  final bool selectAllOnFocus;
  final TextSelectionControls? selectionControls;
  final GestureTapCallback? onTap;
  final bool onTapAlwaysCalled;
  final TapRegionCallback? onTapOutside;
  final TapRegionUpCallback? onTapUpOutside;
  final MouseCursor? mouseCursor;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final Clip clipBehavior;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool stylusHandwritingEnabled;
  final bool enableIMEPersonalizedLearning;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final bool canRequestFocus;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final List<Locale>? hintLocales;

  static const String _obscureOverrideKey = 'el_input._obscureOverride';

  @override
  Widget build(BuildContext context) {
    $add(_obscureOverrideKey, useState<bool?>(null));
    return super.build(context);
  }

  @override
  Widget obsBuild(BuildContext context) {
    super.obsBuild(context);
    return buildInput(context);
  }

  Widget buildInput(BuildContext context) {
    final obscureOverride = $get<ValueNotifier<bool?>>(_obscureOverrideKey);
    final effectiveObscure = obscureOverride.value ?? obscureText;

    InputDecoration? effectiveDecoration = decoration;

    Widget? prefixIcon = effectiveDecoration?.prefixIcon;
    Widget? suffixIcon = effectiveDecoration?.suffixIcon;

    if (showPasswordIcon) {
      suffixIcon = ElButton.icon(
        block: true,
        onPressed: () {
          obscureOverride.value = !effectiveObscure;
        },
        child: effectiveObscure ? Icons.visibility_off : Icons.visibility,
      );
    } else if (clearable && $obs.value.isNotEmpty) {
      suffixIcon = ElButton.icon(
        block: true,
        onPressed: () {
          onClean?.call();
          $obs.value = '';
        },
        child: cleanIcon,
      );
    }

    if (prefixIcon != null) {
      prefixIcon = AspectRatio(
        aspectRatio: 1.0,
        child: Padding(padding: const EdgeInsets.all(2), child: prefixIcon),
      );
    }

    if (suffixIcon != null) {
      suffixIcon = AspectRatio(
        aspectRatio: 1.0,
        child: Padding(padding: const EdgeInsets.all(2), child: suffixIcon),
      );
    }

    if (prefixIcon != null || suffixIcon != null) {
      if (effectiveDecoration == null) {
        effectiveDecoration = InputDecoration(prefixIcon: prefixIcon, suffixIcon: suffixIcon);
      } else {
        effectiveDecoration = effectiveDecoration.copyWith(prefixIcon: prefixIcon, suffixIcon: suffixIcon);
      }
    }

    final tc = controller ?? $textEditingController;
    final fn = focusNode ?? $focusNode;
    final sc = scrollController ?? $scrollController;

    return TextField(
      controller: tc,
      onChanged: (s) => $obs.value = s,
      focusNode: fn,
      undoController: undoController,
      decoration: effectiveDecoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      textDirection: textDirection,
      readOnly: readOnly,
      toolbarOptions: toolbarOptions,
      showCursor: showCursor,
      autofocus: autofocus,
      statesController: statesController,
      obscuringCharacter: obscuringCharacter,
      obscureText: effectiveObscure,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      onAppPrivateCommand: onAppPrivateCommand,
      inputFormatters: inputFormatters,
      enabled: enabled,
      ignorePointers: ignorePointers,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorOpacityAnimates: cursorOpacityAnimates,
      cursorColor: cursorColor,
      cursorErrorColor: cursorErrorColor,
      selectionHeightStyle: selectionHeightStyle ?? BoxHeightStyle.tight,
      selectionWidthStyle: selectionWidthStyle ?? BoxWidthStyle.tight,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      selectAllOnFocus: selectAllOnFocus,
      selectionControls: selectionControls,
      onTap: onTap,
      onTapOutside: onTapOutside,
      onTapUpOutside: onTapUpOutside,
      mouseCursor: mouseCursor,
      buildCounter: buildCounter,
      scrollController: sc,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      contentInsertionConfiguration: contentInsertionConfiguration,
      clipBehavior: clipBehavior,
      restorationId: restorationId,
      scribbleEnabled: scribbleEnabled,
      stylusHandwritingEnabled: stylusHandwritingEnabled,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      contextMenuBuilder: contextMenuBuilder,
      canRequestFocus: canRequestFocus,
      spellCheckConfiguration: spellCheckConfiguration,
      magnifierConfiguration: magnifierConfiguration,
      hintLocales: hintLocales,
    );
  }
}
