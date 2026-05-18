import 'package:el_flutter/el_flutter.dart';

import 'package:flutter/widgets.dart';

part 'header.g.dart';

@ElModelGenerator.copy()
@immutable
class ElHeaderStyle with EquatableMixin {
  const ElHeaderStyle({this.safeArea, this.height, this.textStyle, this.iconThemeData});

  /// 是否填充顶部安全区域，默认 true
  final bool? safeArea;

  /// 头部容器高度
  final double? height;

  /// 按钮文本样式
  final TextStyle? textStyle;

  /// 按钮图标样式
  final IconThemeData? iconThemeData;

  @override
  List<Object?> get props => _props;
}
