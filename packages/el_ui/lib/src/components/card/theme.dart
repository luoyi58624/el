part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElCardThemeData with EquatableMixin {
  static const theme = ElCardThemeData.defaultData(
    elevation: 0.0,
    titleStyle: TextStyle(fontSize: 15, fontWeight: .bold, color: .fromRGBO(88, 88, 88, 1.0)),
  );
  static const darkTheme = ElCardThemeData.defaultData(
    elevation: 2.0,
    titleStyle: TextStyle(fontSize: 15, fontWeight: .bold, color: .fromRGBO(88, 88, 88, 1.0)),
  );

  const ElCardThemeData({this.elevation, this.titleStyle, this.titlePadding});

  const ElCardThemeData.defaultData({
    this.elevation,
    this.titleStyle,
    this.titlePadding = const .only(left: 16.0, bottom: 8.0),
  });

  final double? elevation;
  final TextStyle? titleStyle;
  final EdgeInsets? titlePadding;

  @override
  List<Object?> get props => _props;
}
