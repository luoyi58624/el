part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElSplitPaneThemeData with EquatableMixin {
  static const _defaultTheme = ElSplitPaneThemeData(axis: Axis.vertical);
  static const theme = _defaultTheme;
  static const darkTheme = _defaultTheme;

  const ElSplitPaneThemeData({this.axis});

  /// 分割器方向，默认垂直
  final Axis? axis;

  @override
  List<Object?> get props => _props;
}
