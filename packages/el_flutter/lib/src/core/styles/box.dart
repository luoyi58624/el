import 'package:flutter/widgets.dart';
import 'package:el_flutter/el_flutter.dart';

part 'box.g.dart';

@ElModelGenerator.copy()
@immutable
class ElBoxStyle with EquatableMixin {
  const ElBoxStyle({
    this.clipBehavior,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.padding,
    this.alignment,
    this.decoration,
    this.transform,
    this.transformAlignment,
    this.scale,
    this.translate,
  });

  /// 对盒子应用裁剪
  final Clip? clipBehavior;

  /// 强制盒子最大、最小宽度
  final double? width;

  /// 强制盒子最大、最小高度
  final double? height;

  /// 设置盒子最大、最小宽高
  final BoxConstraints? constraints;

  /// 盒子外边距
  final EdgeInsets? margin;

  /// 盒子内边距
  final EdgeInsets? padding;

  /// 盒子元素的对齐方式
  final Alignment? alignment;

  /// 盒子装饰样式
  @ElFieldGenerator(useMerge: true)
  final BoxDecoration? decoration;

  /// 对盒子应用变换矩阵
  final Matrix4? transform;

  /// 如果指定了 [transform]，则原点相对于容器大小的对齐方式
  final AlignmentGeometry? transformAlignment;

  /// 应用缩放效果，这是 [transform] 的语法糖，支持以下写法：
  /// * 0.8 - 整体缩小 0.8 倍
  /// * [0.8, null] - 对 x 轴缩小 0.8 倍
  /// * [null, 0.8] - 对 y 轴缩小 0.8 倍
  final dynamic scale;

  /// 应用平移效果，这也是 [transform] 的语法糖
  final Offset? translate;

  /// 生成目标 BoxConstraints 约束对象
  BoxConstraints? get toBoxConstraints {
    return (width != null || height != null)
        ? constraints?.tighten(width: width, height: height) ?? BoxConstraints.tightFor(width: width, height: height)
        : constraints;
  }

  /// 生成目标 Matrix4 对象，执行优先顺序为：[transform]、[scale]、[translate]
  Matrix4? get toMatrix4 {
    if (transform != null) {
      return transform;
    } else if (scale != null) {
      double x, y;
      if (scale is Iterable) {
        assert(
          scale.first is double? && scale.last is double?,
          'ElBoxStyle Error: scale List 参数写法必须为 double 或者 null 类型',
        );
        x = scale.first ?? 1.0;
        y = scale.last ?? 1.0;
      } else {
        assert(scale is double, 'ElBoxStyle Error: scale 参数必须为 double 类型');
        x = scale;
        y = x;
      }
      return Matrix4.diagonal3Values(x, y, 1.0);
    } else if (translate != null) {
      return Matrix4.translationValues(translate!.dx, translate!.dy, 0.0);
    }

    return null;
  }

  /// 构建 [decoration] 绘制的裁剪路径对象
  CustomClipper<Path> buildClipper(BuildContext context) {
    assert(clipBehavior != null && clipBehavior != Clip.none && decoration != null);
    return _DecorationClipper(textDirection: Directionality.maybeOf(context), decoration: decoration!);
  }

  @override
  List<Object?> get props => _props;
}

class _DecorationClipper extends CustomClipper<Path> {
  _DecorationClipper({TextDirection? textDirection, required this.decoration})
    : textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size) {
    return decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(_DecorationClipper oldClipper) {
    return oldClipper.decoration != decoration || oldClipper.textDirection != textDirection;
  }
}
