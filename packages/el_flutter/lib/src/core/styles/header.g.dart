// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'header.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElHeaderStyleExt on ElHeaderStyle {
  ElHeaderStyle copyWith({bool? safeArea, double? height, TextStyle? textStyle, IconThemeData? iconThemeData}) {
    return ElHeaderStyle(
      safeArea: safeArea ?? this.safeArea,
      height: height ?? this.height,
      textStyle: this.textStyle == null ? textStyle : this.textStyle!.merge(textStyle),
      iconThemeData: this.iconThemeData == null ? iconThemeData : this.iconThemeData!.merge(iconThemeData),
    );
  }

  ElHeaderStyle merge([ElHeaderStyle? other]) {
    if (other == null) return this;
    return copyWith(
      safeArea: other.safeArea,
      height: other.height,
      textStyle: other.textStyle,
      iconThemeData: other.iconThemeData,
    );
  }

  List<Object?> get _props => [safeArea, height, textStyle, iconThemeData];
}
