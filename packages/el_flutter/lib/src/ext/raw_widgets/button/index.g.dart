// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElRawButtonStyleExt on ElRawButtonStyle {
  ElRawButtonStyle copyWith({
    ElBoxStyle? boxStyle,
    TextStyle? textStyle,
    IconThemeData? iconThemeData,
  }) {
    return ElRawButtonStyle(
      boxStyle: this.boxStyle == null
          ? boxStyle
          : this.boxStyle!.merge(boxStyle),
      textStyle: this.textStyle == null
          ? textStyle
          : this.textStyle!.merge(textStyle),
      iconThemeData: this.iconThemeData == null
          ? iconThemeData
          : this.iconThemeData!.merge(iconThemeData),
    );
  }

  ElRawButtonStyle merge([ElRawButtonStyle? other]) {
    if (other == null) return this;
    return copyWith(
      boxStyle: other.boxStyle,
      textStyle: other.textStyle,
      iconThemeData: other.iconThemeData,
    );
  }

  List<Object?> get _props => [boxStyle, textStyle, iconThemeData];
}
