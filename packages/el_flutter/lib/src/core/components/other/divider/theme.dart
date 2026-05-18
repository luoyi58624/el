part of 'index.dart';

@ElModelGenerator.copy()
@ElThemeGenerator()
class ElDividerThemeData with EquatableMixin {
  static const theme = ElDividerThemeData.defaultData(color: .fromRGBO(193, 193, 193, 1.0));
  static const darkTheme = ElDividerThemeData.defaultData(color: .fromRGBO(125, 125, 125, 1.0));

  const ElDividerThemeData({this.size, this.thickness, this.indent, this.color});

  const ElDividerThemeData.defaultData({this.size, this.thickness = 0.5, this.indent = 0.0, this.color});

  /// 分割线实际占据的空间大小，默认跟随[thickness]
  final double? size;

  /// 分割线的线条粗细程度
  final double? thickness;

  /// 分割线从什么位置开始绘制
  final double? indent;

  /// 自定义分割线的颜色
  final Color? color;

  @override
  List<Object?> get props => _props;
}

// Widget _builderSuffixIcon(ValueNotifier<bool> expanded) {
//   return AnimatedRotation(
//     duration: ElCollapseAnimation.defaultDuration,
//     curve: ElCollapseAnimation.defaultCurve,
//     turns: expanded.value ? 0.5 : 0,
//     child: Icon(ElIcons.arrowDown, size: 14),
//   );
// }
