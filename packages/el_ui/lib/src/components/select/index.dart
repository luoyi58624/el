import 'package:flutter/material.dart';
import 'package:el_ui/el_ui.dart';

class ElSelect<T> extends DropdownMenu<T> implements ElInputModelValue<T> {
  ElSelect(
    this.modelValue, {
    super.key,
    this.prop,
    this.onChanged,
    required this.children,
    super.enabled,
    super.width,
    super.menuHeight,
    super.leadingIcon,
    super.trailingIcon,
    super.showTrailingIcon,
    super.label,
    super.hintText,
    super.helperText,
    super.errorText,
    super.selectedTrailingIcon,
    super.enableFilter,
    super.enableSearch,
    super.keyboardType,
    super.textStyle,
    super.textAlign,
    super.inputDecorationTheme,
    super.menuStyle,
    super.controller,
    super.initialSelection,
    super.onSelected,
    super.focusNode,
    super.requestFocusOnTap,
    super.expandedInsets,
    super.filterCallback,
    super.searchCallback,
    super.alignmentOffset,
    super.inputFormatters,
    super.closeBehavior,
    super.maxLines,
    super.textInputAction,
    super.restorationId,
  }) : super(
         dropdownMenuEntries: children
             .map((e) => DropdownMenuEntry<T>(label: e.label!, value: (e.value ?? e.label) as T))
             .toList(),
       );

  @override
  final dynamic modelValue;

  @override
  final String? prop;

  @override
  final ValueChanged<T>? onChanged;

  @override
  ScrollController? get scrollController => null;

  final List<ElLabelModel<T>> children;

  @override
  State<ElSelect<T>> createState() => _ElSelectState<T>();
}

class _ElSelectState<T> extends ElInputModelValueState<ElSelect<T>, T> {
  @override
  Widget buildInput(BuildContext context) {
    return DropdownMenu(
      controller: controller,
      onSelected: (v) {
        modelValue = v as T;
      },
      dropdownMenuEntries: widget.dropdownMenuEntries,
      enabled: widget.enabled,
      width: widget.width,
      menuHeight: widget.menuHeight,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
      showTrailingIcon: widget.showTrailingIcon,
      label: widget.label,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      selectedTrailingIcon: widget.selectedTrailingIcon,
      enableFilter: widget.enableFilter,
      enableSearch: widget.enableSearch,
      keyboardType: widget.keyboardType,
      textStyle: widget.textStyle,
      textAlign: widget.textAlign,
      inputDecorationTheme: widget.inputDecorationTheme,
      menuStyle: widget.menuStyle,
      initialSelection: widget.initialSelection,
      focusNode: widget.focusNode,
      requestFocusOnTap: widget.requestFocusOnTap,
      expandedInsets: widget.expandedInsets,
      filterCallback: widget.filterCallback,
      searchCallback: widget.searchCallback,
      alignmentOffset: widget.alignmentOffset,
      inputFormatters: widget.inputFormatters,
      closeBehavior: widget.closeBehavior,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      restorationId: widget.restorationId,
    );
  }
}
