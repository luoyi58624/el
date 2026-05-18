part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElListTileThemeData with EquatableMixin {
  static const theme = ElListTileThemeData.defaultData(
    elevation: 0.0,
    color: .fromRGBO(255, 255, 255, 1.0),
    titleStyle: TextStyle(fontSize: 15, fontWeight: .bold, color: .fromRGBO(88, 88, 88, 1.0)),
  );
  static const darkTheme = ElListTileThemeData.defaultData(
    elevation: 2.0,
    color: .fromRGBO(43, 43, 43, 1.0),
    titleStyle: TextStyle(fontSize: 15, fontWeight: .bold, color: .fromRGBO(88, 88, 88, 1.0)),
  );

  const ElListTileThemeData({this.color, this.elevation, this.radius, this.titleStyle, this.contentPadding});

  const ElListTileThemeData.defaultData({
    this.color,
    this.elevation,
    this.radius = 8.0,
    this.titleStyle,
    this.contentPadding,
  });

  final Color? color;
  final double? elevation;
  final double? radius;
  final TextStyle? titleStyle;
  final EdgeInsets? contentPadding;

  @override
  List<Object?> get props => _props;
}
