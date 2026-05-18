part of 'index.dart';

@ElModelGenerator.copy()
class ElRawButtonStyle with EquatableMixin {
  ElRawButtonStyle({
    this.boxStyle,
    this.textStyle,
    this.iconThemeData,
  });

  /// 盒子样式
  final ElBoxStyle? boxStyle;

  /// 文本样式
  final TextStyle? textStyle;

  /// 图标样式
  final IconThemeData? iconThemeData;

  @override
  List<Object?> get props => _props;
}
