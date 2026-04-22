part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElTooltipThemeData with EquatableMixin {
  static const theme = ElTooltipThemeData.defaultData();
  static const darkTheme = theme;

  const ElTooltipThemeData({
    this.spacing,
    this.edgeSpacing,
    this.hoverDelayShow,
    this.hoverDelayHide,
    this.staticHover,
    this.showArrow,
  });

  const ElTooltipThemeData.defaultData({
    this.spacing = 0.0,
    this.edgeSpacing = 8.0,
    this.hoverDelayShow = 0,
    this.hoverDelayHide = 0,
    this.staticHover = false,
    this.showArrow = false,
  });

  final double? spacing;
  final double? edgeSpacing;
  final int? hoverDelayShow;
  final int? hoverDelayHide;
  final bool? staticHover;
  final bool? showArrow;

  @override
  List<Object?> get props => _props;
}
