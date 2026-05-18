// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElWindowModelExt on ElWindowModel {
  ElWindowModel copyWith({
    Widget? child,
    String? title,
    String? icon,
    Size? size,
    Size? minSize,
    Size? maxSize,
    Alignment? alignment,
    Offset? offset,
    bool? fullscreen,
    bool? hidden,
    String? cacheKey,
  }) {
    return ElWindowModel(
      child: child ?? this.child,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      size: size ?? this.size,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      fullscreen: fullscreen ?? this.fullscreen,
      hidden: hidden ?? this.hidden,
      cacheKey: cacheKey ?? this.cacheKey,
    );
  }

  ElWindowModel merge([ElWindowModel? other]) {
    if (other == null) return this;
    return copyWith(
      child: other.child,
      title: other.title,
      icon: other.icon,
      size: other.size,
      minSize: other.minSize,
      maxSize: other.maxSize,
      alignment: other.alignment,
      offset: other.offset,
      fullscreen: other.fullscreen,
      hidden: other.hidden,
      cacheKey: other.cacheKey,
    );
  }

  List<Object?> get _props => [
    child,
    title,
    icon,
    size,
    minSize,
    maxSize,
    alignment,
    offset,
    fullscreen,
    hidden,
    cacheKey,
  ];
}
