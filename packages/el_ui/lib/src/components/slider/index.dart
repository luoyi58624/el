import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';

class ElSlider extends ElFormModelValue<double> {
  ElSlider({
    super.key,
    super.value,
    super.modelValue,
    super.prop,
    super.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.allowedInteraction,
    this.padding,
  });

  final double min;
  final double max;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? secondaryActiveColor;
  final Color? thumbColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final MouseCursor? mouseCursor;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final FocusNode? focusNode;
  final SliderInteraction? allowedInteraction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget obsBuilder(BuildContext context) {
    return Slider(
      value: $obs.value.clamp(min, max),
      onChanged: (v) => $obs.value = v,
      min: min,
      max: max,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      secondaryActiveColor: secondaryActiveColor,
      thumbColor: thumbColor,
      overlayColor: overlayColor,
      mouseCursor: mouseCursor,
      semanticFormatterCallback: semanticFormatterCallback,
      focusNode: focusNode,
      allowedInteraction: allowedInteraction,
      padding: padding,
    );
  }
}
