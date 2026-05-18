import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:el_flutter/el_flutter.dart';

class ElRing extends StatelessWidget {
  /// 在小部件周围绘制轮廓环，轮廓环不会占据小部件的空间，通常情况下它用于聚焦外观，其效果类似于 CSS 中的 outline
  const ElRing({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.show = true,
    this.width,
    this.offset,
    this.color,
    this.strokeAlign,
    this.border,
    this.borderRadius,
    this.gradient,
  });

  final Widget child;

  /// Ring 是隐式动画小部件，修改任意属性会自动应用过渡动画
  final Duration? duration;

  /// 动画曲线
  final Curve? curve;

  /// 是否显示轮廓环，默认 true
  final bool show;

  /// 轮廓环宽度，若 width == 0 时则不进行任何绘制
  final double? width;

  /// 轮廓环距离子元素间隔，默认 0
  final double? offset;

  /// 轮廓环颜色
  final Color? color;

  /// 轮廓环绘制位置，默认向外进行延伸 [BorderSide.strokeAlignOutside]
  final double? strokeAlign;

  /// 此属性允许你绘制部分边框，但是请注意：你只能通过 [width]、[color] 属性统一定义边框颜色、宽度，
  /// 在 [BorderSide] 中定义 width、color 是无效的
  final Border? border;

  /// 边框圆角，如果边框不相连，那么会忽略圆角
  final BorderRadius? borderRadius;

  /// 填充渐变色
  final Gradient? gradient;

  /// 获取 [ElRing] 嵌入到 [child] 的内边距，防止内容被覆盖
  static EdgeInsets paddingOf(BuildContext context) => _ElRingInheritedWidget.maybeOf(context)?.padding ?? .zero;

  @override
  Widget build(BuildContext context) {
    CustomPaint;
    return _AnimatedRing(
      duration: duration ?? Duration.zero,
      curve: curve ?? Curves.linear,
      width: show == true ? max(width ?? 2.0, 0.0) : 0.0,
      offset: show == true ? (offset ?? 0.0) : 0.0,
      color: color ?? Colors.blue,
      strokeAlign: strokeAlign ?? BorderSide.strokeAlignOutside,
      border: border ?? const Border.fromBorderSide(BorderSide()),
      borderRadius: borderRadius ?? .circular(4),
      gradient: gradient,
      child: child,
    );
  }
}

class _AnimatedRing extends ImplicitlyAnimatedWidget {
  const _AnimatedRing({
    required super.duration,
    required super.curve,
    required this.child,
    required this.width,
    required this.offset,
    required this.color,
    required this.strokeAlign,
    required this.border,
    required this.borderRadius,
    this.gradient,
  });

  final Widget child;
  final double width;
  final double offset;
  final Color color;
  final double strokeAlign;
  final Border border;
  final BorderRadius borderRadius;
  final Gradient? gradient;

  @override
  AnimatedWidgetBaseState<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends AnimatedWidgetBaseState<_AnimatedRing> {
  Tween<double>? _width;
  Tween<double>? _offset;
  ColorTween? _color;
  BorderRadiusTween? _borderRadius;

  @override
  Widget build(BuildContext context) {
    final width = _width!.evaluate(animation);
    final offset = _offset!.evaluate(animation);
    final color = _color!.evaluate(animation);
    final borderRadius = _borderRadius!.evaluate(animation);

    EdgeInsets? $padding;

    switch (widget.strokeAlign) {
      case BorderSide.strokeAlignCenter:
        if (offset - width / 2 < 0) {
          $padding = .all(-(offset - width / 2));
        }
      case BorderSide.strokeAlignInside:
        if (offset - width < 0) {
          $padding = .all(-(offset - width));
        }
      default:
        if (offset < 0) {
          $padding = .all(-offset);
        }
    }

    return _ElRingInheritedWidget(
      $padding,
      child: _Ring(
        width: width,
        offset: offset,
        color: color!,
        strokeAlign: widget.strokeAlign,
        border: widget.border,
        borderRadius: borderRadius!,
        gradient: widget.gradient,
        child: widget.child,
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _width = visitor(_width, widget.width, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>;
    _offset =
        visitor(_offset, widget.offset, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>;
    _color =
        visitor(
              _color,
              widget.width == 0.0 ? widget.color.elOpacity(0.0) : widget.color,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween;
    _borderRadius =
        visitor(
              _borderRadius,
              _caleNatureRadius(widget.borderRadius),
              (dynamic value) => BorderRadiusTween(begin: value as BorderRadius),
            )
            as BorderRadiusTween;
  }

  /// 计算自然圆角
  BorderRadius _caleNatureRadius(BorderRadius radius) {
    switch (widget.strokeAlign) {
      case BorderSide.strokeAlignCenter:
        return BorderRadius.only(
          topLeft: Radius.elliptical(_calcAutoRadius(radius.topLeft.x), _calcAutoRadius(radius.topLeft.y)),
          topRight: Radius.elliptical(_calcAutoRadius(radius.topRight.x), _calcAutoRadius(radius.topRight.y)),
          bottomLeft: Radius.elliptical(_calcAutoRadius(radius.bottomLeft.x), _calcAutoRadius(radius.bottomLeft.y)),
          bottomRight: Radius.elliptical(_calcAutoRadius(radius.bottomRight.x), _calcAutoRadius(radius.bottomRight.y)),
        );
      case BorderSide.strokeAlignInside:
        return BorderRadius.only(
          topLeft: Radius.elliptical(_calcInsetRadius(radius.topLeft.x), _calcInsetRadius(radius.topLeft.y)),
          topRight: Radius.elliptical(_calcInsetRadius(radius.topRight.x), _calcInsetRadius(radius.topRight.y)),
          bottomLeft: Radius.elliptical(_calcInsetRadius(radius.bottomLeft.x), _calcInsetRadius(radius.bottomLeft.y)),
          bottomRight: Radius.elliptical(
            _calcInsetRadius(radius.bottomRight.x),
            _calcInsetRadius(radius.bottomRight.y),
          ),
        );
      default:
        return BorderRadius.only(
          topLeft: Radius.elliptical(_calcOutsetRadius(radius.topLeft.x), _calcOutsetRadius(radius.topLeft.y)),
          topRight: Radius.elliptical(_calcOutsetRadius(radius.topRight.x), _calcOutsetRadius(radius.topRight.y)),
          bottomLeft: Radius.elliptical(_calcOutsetRadius(radius.bottomLeft.x), _calcOutsetRadius(radius.bottomLeft.y)),
          bottomRight: Radius.elliptical(
            _calcOutsetRadius(radius.bottomRight.x),
            _calcOutsetRadius(radius.bottomRight.y),
          ),
        );
    }
  }

  /// 计算向外延伸的圆角值
  double _calcOutsetRadius(double rawRadius) {
    if (rawRadius <= 0.0) return rawRadius;

    // 此公式能让 ring 完全贴合子组件，widget.offset + widget.width / 2 是 canvas 画布范围定义，
    // 详情你可以参考 _RenderRing 中的 setRingRect 方法描述
    if (widget.offset <= 0.0) {
      return rawRadius + widget.offset + widget.width / 2;
    }

    // 不要太早应用完全贴合子组件的圆角公式，当子组件圆角很低时，offset 间距会导致 ring 的圆角过于巨大，
    // 所以需要在这中间插入一个中和算法让 ring 圆角更自然
    return rawRadius + min((rawRadius / (widget.offset + widget.width / 2)), widget.offset + widget.width / 2);
  }

  /// 计算向两边延伸的圆角值
  double _calcAutoRadius(double rawRadius) {
    if (rawRadius <= 0.0) return rawRadius;

    if (widget.offset <= 0.0) return rawRadius + widget.offset;

    return rawRadius + min((rawRadius / (widget.offset)), widget.offset);
  }

  /// 计算向内延伸的圆角值
  double _calcInsetRadius(double rawRadius) {
    if (rawRadius <= 0.0) return rawRadius;

    if (widget.offset <= 0.0) {
      return rawRadius + widget.offset - widget.width / 2;
    }

    return rawRadius +
        min((rawRadius / max((widget.offset - widget.width / 2), 1.0)), widget.offset - widget.width / 2);
  }
}

class _Ring extends SingleChildRenderObjectWidget {
  const _Ring({
    super.child,
    required this.width,
    required this.offset,
    required this.color,
    required this.strokeAlign,
    required this.border,
    required this.borderRadius,
    required this.gradient,
  });

  final double width;
  final double offset;
  final Color color;
  final double strokeAlign;
  final Border border;
  final BorderRadius borderRadius;
  final Gradient? gradient;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderRing(width, offset, color, strokeAlign, border, borderRadius, gradient);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderRing renderObject) {
    renderObject
      ..width = width
      ..offset = offset
      ..color = color
      ..strokeAlign = strokeAlign
      ..border = border
      ..borderRadius = borderRadius
      ..gradient = gradient;
  }
}

class _RenderRing extends RenderProxyBox {
  _RenderRing(
    this._width,
    this._offset,
    this._color,
    this._strokeAlign,
    this._border,
    this._borderRadius,
    this._gradient,
  );

  double? _width;

  double get width => _width!;

  set width(double v) {
    if (_width == v) return;
    _width = v;
    markNeedsPaint();
  }

  double? _offset;

  double get offset => _offset!;

  set offset(double v) {
    if (_offset == v) return;
    _offset = v;
    markNeedsPaint();
  }

  Color? _color;

  Color get color => _color!;

  set color(Color v) {
    if (_color == v) return;
    _color = v;
    markNeedsPaint();
  }

  double? _strokeAlign;

  double get strokeAlign => _strokeAlign!;

  set strokeAlign(double v) {
    if (_strokeAlign == v) return;
    _strokeAlign = v;
    markNeedsPaint();
  }

  Border? _border;

  Border get border => _border!;

  set border(Border v) {
    if (_border == v) return;
    _border = v;
    markNeedsPaint();
  }

  BorderRadius? _borderRadius;

  BorderRadius get borderRadius => _borderRadius!;

  set borderRadius(BorderRadius v) {
    if (_borderRadius == v) return;
    _borderRadius = v;
    markNeedsPaint();
  }

  Gradient? _gradient;

  Gradient? get gradient => _gradient;

  set gradient(Gradient? v) {
    if (_gradient == v) return;
    _gradient = v;
    markNeedsPaint();
  }

  /// ring 的绘制范围矩形对象
  late Rect ringRect;

  /// 根据 [borderRadius] 绘制出的 path 路径对象，此对象允许用户进行裁剪
  late Path ringPath;

  /// 这些是经过 [ringRect] 约束过后的圆角值
  late Radius topLeft;
  late Radius topRight;
  late Radius bottomLeft;
  late Radius bottomRight;

  /// 约束圆角最大值
  Radius constraintsRadius(Radius v) =>
      Radius.elliptical(max(min(v.x, ringRect.width / 2), 0.1), max(min(v.y, ringRect.height / 2), 0.1));

  /// 在 [paint] 绘制时设置 [ringRect] 画布范围
  void setRingRect() {
    switch (strokeAlign) {
      case BorderSide.strokeAlignCenter:
        ringRect = Rect.fromLTWH(-offset, -offset, (size.width + offset * 2), (size.height + offset * 2));
      case BorderSide.strokeAlignInside:
        ringRect = Rect.fromLTWH(
          -offset + width / 2,
          -offset + width / 2,
          (size.width + offset * 2 - width),
          (size.height + offset * 2 - width),
        );
      default:
        // 如果 ring 是朝外绘制，那么画布范围将是 offset + width / 2，
        // 之所以是 width / 2，是因为 width 被用于 Paint 画笔 strokeWidth 属性，
        // 以绘制的坐标点为基准，根据 strokeWidth 宽度向两边进行绘画，所以需要 width / 2
        ringRect = Rect.fromLTWH(
          -offset - width / 2,
          -offset - width / 2,
          (size.width + offset * 2 + width),
          (size.height + offset * 2 + width),
        );
    }
  }

  /// 构建完整封闭路径的 [Path] 对象
  Path buildFullPath() {
    final path = Path();
    double left = ringRect.left;
    double top = ringRect.top;
    double right = ringRect.right;
    double bottom = ringRect.bottom;

    path.moveTo(ringRect.left + topLeft.x, ringRect.top);
    path.lineTo(right - topRight.x, top);
    addTopRightArc(path);
    path.lineTo(right, bottom - bottomRight.y);
    addBottomRightArc(path);
    path.lineTo(left + bottomLeft.x, bottom);
    addBottomLeftArc(path);
    path.lineTo(left, top + topLeft.y);
    addTopLeftArc(path);
    path.close();
    return path;
  }

  /// 添加右上角的圆弧路径
  void addTopRightArc(Path path) {
    path.arcTo(
      Rect.fromLTWH(ringRect.right - topRight.x * 2, ringRect.top, topRight.x * 2, topRight.y * 2),
      pi + pi / 2,
      pi / 2,
      false,
    );
  }

  /// 添加右下角的圆弧路径
  void addBottomRightArc(Path path) {
    path.arcTo(
      Rect.fromLTWH(
        ringRect.right - bottomRight.x * 2,
        ringRect.bottom - bottomRight.y * 2,
        bottomRight.x * 2,
        bottomRight.y * 2,
      ),
      0,
      pi / 2,
      false,
    );
  }

  /// 添加左下角的圆弧路径
  void addBottomLeftArc(Path path) {
    path.arcTo(
      Rect.fromLTWH(ringRect.left, ringRect.bottom - bottomLeft.y * 2, bottomLeft.x * 2, bottomLeft.y * 2),
      pi / 2,
      pi / 2,
      false,
    );
  }

  /// 添加左上角的圆弧路径
  void addTopLeftArc(Path path) {
    path.arcTo(Rect.fromLTWH(ringRect.left, ringRect.top, topLeft.x * 2, topLeft.y * 2), pi, pi / 2, false);
  }

  /// 修复抗锯齿带来的细微间隙
  static const double antiAliasGap = 0.15;

  /// 绘制独立边框
  void paintIndependentBorder(Canvas canvas, Paint paint) {
    final path = Path();

    double left = ringRect.left;
    double top = ringRect.top;
    double right = ringRect.right;
    double bottom = ringRect.bottom;

    // 单独绘制顶部边框
    if (border.top != BorderSide.none) {
      path.reset();
      late double x1, x2, y1 = top, y2 = top;

      // 起始 x 轴坐标点
      x1 = border.left == BorderSide.none ? left : left + topLeft.x - antiAliasGap;
      path.moveTo(x1, y1);

      // 如果存在右边框，则绘制上右圆角
      if (border.right != BorderSide.none) {
        x2 = right - topRight.x;
        addTopRightArc(path);
      } else {
        x2 = right;
        path.lineTo(x2, y2);
      }

      canvas.drawPath(path, paint);
    }

    // 右边框
    if (border.right != BorderSide.none) {
      path.reset();

      late double x1 = right, x2 = right, y1, y2;
      y1 = border.top == BorderSide.none ? top : top + topRight.y - antiAliasGap;

      path.moveTo(x1, y1);
      if (border.bottom != BorderSide.none) {
        y2 = bottom - bottomRight.y;
        addBottomRightArc(path);
      } else {
        y2 = bottom;
        path.lineTo(x2, y2);
      }

      canvas.drawPath(path, paint);
    }

    // 下边框
    if (border.bottom != BorderSide.none) {
      path.reset();
      late double x1, x2, y1 = bottom, y2 = bottom;
      x1 = border.right == BorderSide.none ? right : right - bottomRight.x + antiAliasGap;

      path.moveTo(x1, y1);
      if (border.left != BorderSide.none) {
        x2 = left + bottomLeft.x;
        addBottomLeftArc(path);
      } else {
        x2 = left;
        path.lineTo(x2, y2);
      }

      canvas.drawPath(path, paint);
    }

    // 左边框
    if (border.left != BorderSide.none) {
      path.reset();

      late double x1 = left, x2 = left, y1, y2;
      y1 = border.bottom == BorderSide.none ? bottom : bottom - bottomLeft.y + antiAliasGap;

      path.moveTo(x1, y1);
      if (border.top != BorderSide.none) {
        y2 = top + topLeft.y;
        addTopLeftArc(path);
      } else {
        y2 = top;
        path.lineTo(x2, y2);
      }

      canvas.drawPath(path, paint);
    }
  }

  /// 绘制轮廓环
  void paintRing(Canvas canvas, Offset offset) {
    // 若 ring 的宽度小于等于 0，那么没必要绘制 ring
    if (width <= 0) return;

    // 保存当前绘图，移动绘制 ring 画布的基点位置，以子元素位置为相对点
    canvas.save();
    if (offset != Offset.zero) {
      canvas.translate(offset.dx, offset.dy);
    }

    // 创建画笔
    var paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // 应用渐变色
    if (gradient != null) {
      paint = paint..shader = gradient!.createShader(Offset.zero & size);
    }

    // 如果是完整边框，那么直接应用计算好的 path 路径对象，否则需要进行细致化处理
    if (border.isFull) {
      canvas.drawPath(ringPath, paint);
    } else {
      paintIndependentBorder(canvas, paint);
    }

    canvas.restore();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (width <= 0.0) return;

    setRingRect();
    topLeft = constraintsRadius(borderRadius.topLeft);
    topRight = constraintsRadius(borderRadius.topRight);
    bottomLeft = constraintsRadius(borderRadius.bottomLeft);
    bottomRight = constraintsRadius(borderRadius.bottomRight);
    ringPath = buildFullPath();

    paintRing(context.canvas, offset);
  }
}

class _ElRingInheritedWidget extends InheritedWidget {
  const _ElRingInheritedWidget(this.padding, {required super.child});

  final EdgeInsets? padding;

  static _ElRingInheritedWidget? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ElRingInheritedWidget>();

  @override
  bool updateShouldNotify(_ElRingInheritedWidget oldWidget) => padding != oldWidget.padding;
}
