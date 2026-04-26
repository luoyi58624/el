import 'package:el_model_value/el_model_value.dart';
import 'package:el_ui/el_ui.dart' hide ElModelValue, ElModelValueMixin, ElStatelessModelValue;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ElSelect<T> extends ElInputModelValue<T> {
  ElSelect({
    super.key,
    super.value,
    super.modelValue,
    super.prop,
    super.onChanged,
    super.controller,
    super.focusNode,
    super.scrollController,
    required this.children,
    this.enabled = true,
    this.width,
    this.menuHeight,
    this.leadingIcon,
    this.trailingIcon,
    this.showTrailingIcon = true,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedTrailingIcon,
    this.enableFilter = false,
    this.enableSearch = false,
    this.keyboardType,
    this.textStyle,
    this.textAlign,
    this.inputDecorationTheme,
    this.menuStyle,
    this.initialSelection,
    this.onSelected,
    this.requestFocusOnTap = true,
    this.expandedInsets,
    this.filterCallback,
    this.searchCallback,
    this.alignmentOffset,
    this.inputFormatters,
    this.closeBehavior = DropdownMenuCloseBehavior.all,
    this.maxLines,
    this.textInputAction,
    this.restorationId,
  });

  final List<ElLabelModel<T>> children;

  final bool enabled;
  final double? width;
  final double? menuHeight;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool showTrailingIcon;
  final Widget? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? selectedTrailingIcon;
  final bool enableFilter;
  final bool enableSearch;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final InputDecorationTheme? inputDecorationTheme;
  final MenuStyle? menuStyle;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final bool requestFocusOnTap;
  final EdgeInsets? expandedInsets;
  final FilterCallback<T>? filterCallback;
  final SearchCallback<T>? searchCallback;
  final Offset? alignmentOffset;
  final List<TextInputFormatter>? inputFormatters;
  final DropdownMenuCloseBehavior closeBehavior;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final String? restorationId;

  List<DropdownMenuEntry<T>> get _entries => children
      .map((e) => DropdownMenuEntry<T>(label: e.label!, value: (e.value ?? e.label) as T))
      .toList();

  @override
  String toTextEditing(T value) {
    for (final e in children) {
      final entryValue = (e.value ?? e.label) as T;
      if (entryValue == value) {
        return e.label!;
      }
    }
    return value.toString();
  }

  @override
  T toModelValue(String text) {
    for (final e in children) {
      if (e.label == text) {
        return (e.value ?? e.label) as T;
      }
    }
    return text as T;
  }

  @override
  Widget obsBuild(BuildContext context) {
    super.obsBuild(context);
    return buildInput(context);
  }

  Widget buildInput(BuildContext context) {
    final textController = controller ?? $textEditingController;
    final effectiveFocusNode = focusNode ?? $focusNode;

    return DropdownMenu<T>(
      controller: textController,
      onSelected: (v) {
        if (v != null) {
          $obs.value = v;
        }
        onSelected?.call(v);
      },
      dropdownMenuEntries: _entries,
      enabled: enabled,
      width: width,
      menuHeight: menuHeight,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      showTrailingIcon: showTrailingIcon,
      label: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      selectedTrailingIcon: selectedTrailingIcon,
      enableFilter: enableFilter,
      enableSearch: enableSearch,
      keyboardType: keyboardType,
      textStyle: textStyle,
      textAlign: textAlign ?? TextAlign.start,
      inputDecorationTheme: inputDecorationTheme,
      menuStyle: menuStyle,
      initialSelection: initialSelection,
      focusNode: effectiveFocusNode,
      requestFocusOnTap: requestFocusOnTap,
      expandedInsets: expandedInsets,
      filterCallback: filterCallback,
      searchCallback: searchCallback,
      alignmentOffset: alignmentOffset,
      inputFormatters: inputFormatters,
      closeBehavior: closeBehavior,
      maxLines: maxLines,
      textInputAction: textInputAction,
      restorationId: restorationId,
    );
  }
}
