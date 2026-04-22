// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElBoxStyleExt on ElBoxStyle {
  ElBoxStyle copyWith({
    Clip? clipBehavior,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Alignment? alignment,
    BoxDecoration? decoration,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    dynamic scale,
    Offset? translate,
  }) {
    return ElBoxStyle(
      clipBehavior: clipBehavior ?? this.clipBehavior,
      width: width ?? this.width,
      height: height ?? this.height,
      constraints: constraints ?? this.constraints,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      decoration: this.decoration == null ? decoration : this.decoration!.merge(decoration),
      transform: transform ?? this.transform,
      transformAlignment: transformAlignment ?? this.transformAlignment,
      scale: scale ?? this.scale,
      translate: translate ?? this.translate,
    );
  }

  ElBoxStyle merge([ElBoxStyle? other]) {
    if (other == null) return this;
    return copyWith(
      clipBehavior: other.clipBehavior,
      width: other.width,
      height: other.height,
      constraints: other.constraints,
      margin: other.margin,
      padding: other.padding,
      alignment: other.alignment,
      decoration: other.decoration,
      transform: other.transform,
      transformAlignment: other.transformAlignment,
      scale: other.scale,
      translate: other.translate,
    );
  }

  List<Object?> get _props => [
    clipBehavior,
    width,
    height,
    constraints,
    margin,
    padding,
    alignment,
    decoration,
    transform,
    transformAlignment,
    scale,
    translate,
  ];
}
