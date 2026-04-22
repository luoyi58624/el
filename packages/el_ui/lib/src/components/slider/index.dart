import 'package:flutter/material.dart';
import 'package:el_ui/el_ui.dart';

class ElSlider extends Slider implements ElFormModelValue<double> {
  const ElSlider(
    this.modelValue, {
    super.key,
    this.prop,
    super.onChanged,
    super.min,
    super.max,
    super.onChangeStart,
    super.onChangeEnd,
    super.divisions,
    super.label,
    super.activeColor,
    super.inactiveColor,
    super.secondaryActiveColor,
    super.thumbColor,
    super.overlayColor,
    super.mouseCursor,
    super.semanticFormatterCallback,
    super.focusNode,
    super.allowedInteraction,
    super.padding,
  }) : super(value: min);

  @override
  final dynamic modelValue;

  @override
  final String? prop;

  @override
  State<ElSlider> createState() => _ElSliderState();
}

class _ElSliderState extends ElFormModelValueState<ElSlider, double> {
  @override
  Widget obsBuilder(BuildContext context) {
    return Slider(
      onChanged: (v) {
        modelValue = v;
      },
      value: modelValue,
      min: widget.min,
      max: widget.max,
      onChangeStart: widget.onChangeStart,
      onChangeEnd: widget.onChangeEnd,
      divisions: widget.divisions,
      label: widget.label,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      secondaryActiveColor: widget.secondaryActiveColor,
      thumbColor: widget.thumbColor,
      overlayColor: widget.overlayColor,
      mouseCursor: widget.mouseCursor,
      semanticFormatterCallback: widget.semanticFormatterCallback,
      focusNode: widget.focusNode,
      allowedInteraction: widget.allowedInteraction,
      padding: widget.padding,
    );
  }
}
