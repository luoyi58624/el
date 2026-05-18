import 'dart:async';
import 'dart:math';

import 'package:el_dart/ext.dart' hide reverse;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

extension ElObjectExt<T extends Object> on T {
  /// 批量生成重复的对象
  List<T> operator *(int other) => List.generate(other, (index) => this);
}

extension ElIntExt on int {
  /// 应用系统全局文本缩放
  double applyTextScale(TextScaler textScaler, {double? minValue, double? maxValue}) {
    if (textScaler == TextScaler.noScaling) return toDouble();

    double result = textScaler.scale(toDouble());

    if (minValue != null) result = max(result, minValue);
    if (maxValue != null) result = min(result, maxValue);
    return result;
  }

  /// int 转 [FontWeight]
  FontWeight toFontWeight([FontWeight? defaultFontWeight]) {
    switch (this) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return defaultFontWeight ?? FontWeight.normal;
    }
  }
}

extension ElDoubleExt on double {
  /// 应用系统全局文本缩放
  double applyTextScale(TextScaler textScaler, {double? minValue, double? maxValue}) {
    if (textScaler == TextScaler.noScaling) return this;

    double result = textScaler.scale(this);

    if (minValue != null) result = max(result, minValue);
    if (maxValue != null) result = min(result, maxValue);
    return result;
  }

  Offset get toOffset => Offset(this, this);

  Size get toSize => Size(this, this);
}

extension ElListIntExt on List<int> {
  EdgeInsets? get toEdgeInsets => map((e) => e.toDouble()).toList().toEdgeInsets;
}

extension ElListDoubleExt on List<double> {
  /// 将数组转为内边距对象，其数组结构与 CSS 一致：
  /// * [10] - 所有
  /// * [10, 20] - 上下 | 左右
  /// * [10, 20, 10] - 上 | 左右 | 下
  /// * [10, 20, 10, 20] - 上 | 右 | 下 | 左
  EdgeInsets? get toEdgeInsets {
    if (isEmpty) return null;

    if (length == 1) {
      return .all(first);
    } else if (length == 2) {
      return .symmetric(vertical: first, horizontal: last);
    } else {
      if (length == 3) {
        return .only(top: this[0], left: this[1], right: this[1], bottom: this[2]);
      } else {
        return .only(top: this[0], right: this[1], bottom: this[2], left: this[3]);
      }
    }
  }
}

extension ElBoolExt on bool {
  Brightness get brightness => this == true ? Brightness.dark : Brightness.light;
}

extension ElStringExt on String {
  /// 将16进制字符串颜色转成Color对象
  Color toColor() {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ElFontWeightExt on FontWeight {
  /// 应用 Element 全局字重逻辑
  FontWeight get elFontWeight => el.config.fontWeightBuilder(this);
}

extension ElPointerDownEventExt on PointerDownEvent {
  TapDownDetails get toTapDownDetails =>
      TapDownDetails(globalPosition: position, localPosition: localPosition, kind: kind);

  DragDownDetails get toDragDownDetails => DragDownDetails(globalPosition: position, localPosition: localPosition);

  DragStartDetails get toDragStartDetails =>
      DragStartDetails(sourceTimeStamp: timeStamp, globalPosition: position, localPosition: localPosition, kind: kind);
}

extension ElPointerUpEventExt on PointerUpEvent {
  TapUpDetails get toTapUpDetails => TapUpDetails(globalPosition: position, localPosition: localPosition, kind: kind);
}

extension ElPointerMoveEventExt on PointerMoveEvent {
  DragUpdateDetails get toDragUpdateDetails => DragUpdateDetails(
    sourceTimeStamp: timeStamp,
    delta: delta,
    globalPosition: position,
    localPosition: localPosition,
  );
}

extension ElAxisExt on Axis {
  bool get isHorizontal => this == Axis.horizontal;

  bool get isVertical => this == Axis.vertical;
}

extension ElAxisDirectionExt on AxisDirection {
  bool get isHorizontal => this == AxisDirection.left || this == AxisDirection.right;

  bool get isVertical => this == AxisDirection.up || this == AxisDirection.down;

  /// 判断拖拽的滚动方向是否为前进
  bool get isForwardScroll => this == AxisDirection.up || this == AxisDirection.left;

  /// 将方向转成 Alignment 对象
  Alignment get toAlignment {
    switch (this) {
      case AxisDirection.up:
        return Alignment.topCenter;
      case AxisDirection.down:
        return Alignment.bottomCenter;
      case AxisDirection.left:
        return Alignment.centerLeft;
      case AxisDirection.right:
        return Alignment.centerRight;
    }
  }

  /// 反转方向
  AxisDirection get flipped {
    switch (this) {
      case AxisDirection.up:
        return AxisDirection.down;
      case AxisDirection.down:
        return AxisDirection.up;
      case AxisDirection.left:
        return AxisDirection.right;
      case AxisDirection.right:
        return AxisDirection.left;
    }
  }

  /// 根据文本方向返回新的方向
  AxisDirection applyTextDirection(TextDirection textDirection) {
    if (isVertical) return this;
    return textDirection == TextDirection.ltr ? this : flipped;
  }
}

extension ElEdgeInsetsExt on EdgeInsets {
  EdgeInsets applyTextScale(TextScaler textScaler) {
    if (textScaler == TextScaler.noScaling) return this;
    return copyWith(
      left: textScaler.scale(left),
      right: textScaler.scale(right),
      top: textScaler.scale(top),
      bottom: textScaler.scale(bottom),
    );
  }

  EdgeInsets merge(EdgeInsets? v) {
    if (v == null) return this;
    return copyWith(
      left: v.left == 0.0 ? null : v.left,
      right: v.right == 0.0 ? null : v.right,
      top: v.top == 0.0 ? null : v.top,
      bottom: v.bottom == 0.0 ? null : v.bottom,
    );
  }
}

extension ElBorderRadiusExt on BorderRadius {
  BorderRadius applyTextScale(TextScaler textScaler) {
    if (textScaler == TextScaler.noScaling) return this;
    return copyWith(
      topLeft: Radius.elliptical(textScaler.scale(topLeft.x), textScaler.scale(topLeft.y)),
      topRight: Radius.elliptical(textScaler.scale(topRight.x), textScaler.scale(topRight.y)),
      bottomLeft: Radius.elliptical(textScaler.scale(bottomLeft.x), textScaler.scale(bottomLeft.y)),
      bottomRight: Radius.elliptical(textScaler.scale(bottomRight.x), textScaler.scale(bottomRight.y)),
    );
  }
}

extension ElBorderExt on Border {
  /// 获取 Border 最大的宽度
  double get maxWidth {
    final list = [top.width, right.width, bottom.width, left.width];
    list.sort();
    return list.last;
  }

  /// 判断是否为完整边框，边框的 4 条边均不为 null
  bool get isFull =>
      top != BorderSide.none && right != BorderSide.none && bottom != BorderSide.none && left != BorderSide.none;

  /// 将自定义属性应用到当前边框对象中，添加 el 前缀防止冲突，虽然目前 Border 没有这个方法
  Border copyWith({double? width, Color? color, BorderStyle? style, double? strokeAlign}) => Border(
    top: top.copyWith(width: width, color: color, style: style, strokeAlign: strokeAlign),
    right: right.copyWith(width: width, color: color, style: style, strokeAlign: strokeAlign),
    bottom: bottom.copyWith(width: width, color: color, style: style, strokeAlign: strokeAlign),
    left: left.copyWith(width: width, color: color, style: style, strokeAlign: strokeAlign),
  );
}

extension ElBoxDecorationExt on BoxDecoration {
  BoxDecoration merge(BoxDecoration? other) {
    if (other == null) return this;
    return copyWith(
      color: other.color,
      image: other.image,
      border: other.border,
      borderRadius: other.borderRadius,
      boxShadow: other.boxShadow,
      gradient: other.gradient,
      backgroundBlendMode: other.backgroundBlendMode,
      shape: other.shape,
    );
  }
}

extension ElBrightnessExt on Brightness {
  bool get isDark => this == Brightness.dark;

  Brightness get reverse => this == Brightness.dark ? Brightness.light : Brightness.dark;
}

extension ElAnimationControllerExt on AnimationController {
  /// 继续运行动画，默认情况下会根据当前状态继续朝相同方向运行动画，将参数设置为 true 则朝反方向运行动画
  void start([bool? $reverse]) {
    if (status == AnimationStatus.dismissed || status == AnimationStatus.forward) {
      $reverse == true ? reverse() : forward();
    } else {
      $reverse == true ? forward() : reverse();
    }
  }
}

extension ElSizeExt on Size {
  /// 将 Size 转成 Offset 对象
  Offset get toOffset => Offset(width, height);
}

extension ElOffsetExt on Offset {
  /// 将 Offset 转成 Size 对象
  Size get toSize => Size(dx, dy);

  /// 将 offset 限制在 [BoxConstraints] 约束中，返回新的 Offset 对象
  Offset clampConstraints(BoxConstraints constraints) {
    double x = 0.0;
    double y = 0.0;
    if (dx < 0) {
      x = 0;
    } else if (dx > constraints.maxWidth) {
      x = constraints.maxWidth;
    } else {
      x = dx;
    }
    if (dy < 0) {
      y = 0;
    } else if (dy > constraints.maxHeight) {
      y = constraints.maxHeight;
    } else {
      y = dy;
    }
    return Offset(x, y);
  }

  /// 根据 [Axis] 轴计算拖拽方向
  AxisDirection fromAxis(Axis axis) => switch (axis) {
    Axis.vertical => dy < 0 ? AxisDirection.up : AxisDirection.down,
    Axis.horizontal => dx < 0 ? AxisDirection.left : AxisDirection.right,
  };

  /// 根据水平角度计算拖拽方向
  AxisDirection toAxisDirection(double horizontalAngle) {
    final direction = this.direction;
    if ((-horizontalAngle <= direction && direction <= horizontalAngle) ||
        (direction <= -pi + horizontalAngle || direction >= pi - horizontalAngle)) {
      return dx < 0 ? AxisDirection.left : AxisDirection.right;
    } else {
      return dy < 0 ? AxisDirection.up : AxisDirection.down;
    }
  }
}

extension ElColorExt on Color {
  /// 代替被弃用的方法 withOpacity
  Color elOpacity(double opacity) {
    return withValues(alpha: opacity);
  }

  /// 判断一个颜色是否是暗色，171 表示 [.warning] 的感知亮度，这个值可以覆盖 Element UI 默认的主题系统
  bool get isDark => hsp <= 171;

  /// 返回一个颜色的感知亮度：0 - 255，0 表示纯黑色，255 表示纯白色，
  /// 参考链接：http://www.w3.org/TR/AERT#color-contrast
  int get hsp => ((r.floatToInt8 * 299 + g.floatToInt8 * 587 + b.floatToInt8 * 114) / 1000).ceilToDouble().toInt();

  /// 检查一个颜色是否为强调色，如果颜色越接近白色、黑色，它将返回 false
  bool get isHighlight {
    final hsp = this.hsp;
    return 78 <= hsp && hsp <= 178;
  }

  /// 根据明亮度获取一个新的颜色，lightness以1为基准，小于1则颜色变暗，大于1则颜色变亮
  Color getLightnessColor(double lightness) {
    final originalColor = HSLColor.fromColor(this);
    final newLightness = originalColor.lightness * lightness;
    final newColor = originalColor.withLightness(newLightness.clamp(0.0, 1.0));
    return newColor.toColor();
  }

  /// 将颜色转成 int
  int get toInt => a.floatToInt8 << 24 | r.floatToInt8 << 16 | g.floatToInt8 << 8 | b.floatToInt8 << 0;

  /// Color对象转16进制字符串格式颜色
  /// * hasLeading 是否添加 # 前缀，默认true
  /// * hasAlpha 是否添加透明度，默认false
  String toHex({bool hasLeading = true, bool hasAlpha = false}) =>
      '${hasLeading == true ? '#' : ''}'
      '${hasAlpha == true ? a.floatToInt8.toRadixString(16).padLeft(2, '0') : ''}'
      '${r.floatToInt8.toRadixString(16).padLeft(2, '0')}'
      '${g.floatToInt8.toRadixString(16).padLeft(2, '0')}'
      '${b.floatToInt8.toRadixString(16).padLeft(2, '0')}';

  /// 将当前颜色转换成 Material 颜色。
  ///
  /// 注意：[MaterialColor] 中所有颜色都是手动预设值，此函数只是简单根据预设梯度创建不同级别颜色，
  /// 所以返回的 MaterialColor 对象并不相同。
  MaterialColor toMaterialColor() {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = .fromRGBO(
        r.floatToInt8 + ((ds < 0 ? r.floatToInt8 : (255 - r.floatToInt8)) * ds).round(),
        g.floatToInt8 + ((ds < 0 ? g.floatToInt8 : (255 - g.floatToInt8)) * ds).round(),
        b.floatToInt8 + ((ds < 0 ? b.floatToInt8 : (255 - b.floatToInt8)) * ds).round(),
        1,
      );
    }
    return MaterialColor(toInt, swatch);
  }

  /// 设置颜色亮度，取值范围 -100 ~ 100，正数变亮，负数变暗
  Color setBrightness(int scale) {
    assert(scale >= -100 && scale <= 100, 'setBrightness 颜色函数 scale 取值范围必须在 -100 ~ 100 之间：$scale');
    if (scale == 0) return this;
    final p = scale / 100;

    return Color.fromARGB(
      a.floatToInt8,
      _applyScale(r.floatToInt8, p),
      _applyScale(g.floatToInt8, p),
      _applyScale(b.floatToInt8, p),
    );
  }

  /// 对颜色的 r、g、b 应用 scale 调整明亮度
  int _applyScale(int v, double p) => p > 0 ? (v + (255 - v) * p).round() : (v * (1 + p)).round();

  /// 将颜色变得更亮
  /// * scale 值越大，颜色越亮，当为负数时，值越小，颜色越暗
  Color brighten(int scale) => setBrightness(scale);

  /// 将颜色变得更暗
  /// * scale 值越大，颜色越深，当为负数时，值越小，颜色越亮
  Color darken(int scale) => setBrightness(-scale);

  /// 将颜色变得深，如果当前颜色是亮色，颜色会变暗，但如果当前颜色是暗色，则颜色会变亮
  /// * scale -100-100，值越大，颜色越深
  /// * reversal 是否反转，如果颜色是亮色，则颜色更亮，否则更暗
  /// * lightScale 0 ~ 100，当颜色是亮色时，应用的 scale 值
  /// * darkScale 0 ~ 100，当颜色是暗色时，应用的 scale 值
  Color deepen(int scale, {bool reversal = false, int? lightScale, int? darkScale}) {
    return reversal
        ? (isDark ? darken(darkScale ?? scale) : brighten(lightScale ?? scale))
        : (isDark ? brighten(darkScale ?? scale) : darken(lightScale ?? scale));
  }

  /// 将当前颜色和另一种颜色按一定比例进行混合
  /// * other 与之混合的颜色
  /// * scale 0 ~ 100，比值越小就越接近color1，比值越大就接近color2
  Color mix(Color other, int scale) {
    assert(scale >= 0 && scale <= 100, 'mix 颜色函数 scale 取值范围必须在 0 ~ 100 之间：$scale');
    final p = scale / 100;
    final a = this.a.floatToInt8;
    final r = this.r.floatToInt8;
    final g = this.g.floatToInt8;
    final b = this.b.floatToInt8;

    return Color.fromARGB(
      ((other.a.floatToInt8 - a) * p + a).round(),
      ((other.r.floatToInt8 - r) * p + r).round(),
      ((other.g.floatToInt8 - g) * p + g).round(),
      ((other.b.floatToInt8 - b) * p + b).round(),
    );
  }
}

extension ElImageProviderExt on ImageProvider {
  /// 获取图片信息
  Future<ImageInfo?> getImageInfo({ImageStream? imageStream}) async {
    imageStream ??= resolve(ImageConfiguration.empty);
    final completer = Completer<ImageInfo?>();

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(imageInfo);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          imageStream!.removeListener(listener);
        });
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        imageStream!.removeListener(listener);
      },
    );
    imageStream.addListener(listener);
    return completer.future;
  }
}

extension ElWidgetExt on Widget {
  /// 不使用祖先提供的默认滚动条，当使用自定义滚动条时请设置此扩展，可以防止与祖先提供的默认滚动条重叠
  Widget noScrollbarBehavior(
    BuildContext context, {
    Key? key,
    bool? overscroll,
    Set<PointerDeviceKind>? dragDevices,
    MultitouchDragStrategy? multitouchDragStrategy,
    Set<LogicalKeyboardKey>? pointerAxisModifiers,
    ScrollPhysics? physics,
    TargetPlatform? platform,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
    bool enabled = true,
  }) => enabled
      ? ScrollConfiguration(
          key: key,
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: overscroll,
            dragDevices: dragDevices,
            multitouchDragStrategy: multitouchDragStrategy,
            pointerAxisModifiers: pointerAxisModifiers,
            physics: physics,
            platform: platform,
            keyboardDismissBehavior: keyboardDismissBehavior,
          ),
          child: this,
        )
      : this;

  /// 合并祖先 ElScrollBehavior 的默认配置，如果不需要尊重祖先配置，
  /// 请直接使用 [ScrollConfiguration] 覆盖即可
  Widget elScrollbarBehavior(BuildContext context, ElScrollBehavior behavior) {
    final parent = ScrollConfiguration.of(context);
    if (parent is ElScrollBehavior) {
      return ScrollConfiguration(behavior: parent.merge(behavior), child: this);
    } else {
      return this;
    }
  }

  /// 监听鼠标水平滚动（仅限桌面端生效），其后代滚动小部件必须在 widget 层指定 ScrollController
  Widget get elHorizontalScroll {
    if (ElPlatform.isMobile) return this;
    return _HorizontalScroll(child: this);
  }
}

class _HorizontalScroll extends HookWidget {
  const _HorizontalScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = useRef<ScrollController?>(null);
    useEffect(() {
      nextTick(() {
        final scroll = ElFlutterUtil.findDescendantStateOfType<ScrollableState>(context);
        assert(scroll != null, 'ElHorizontalScroll Error: 后代不存在可滚动小部件！');
        assert(scroll?.widget.controller != null, 'ElHorizontalScroll Error: 后代滚动小部件必须手动设置 ScrollController！');
        controller.value = scroll!.widget.controller!;
      });

      return () => controller.value = null;
    }, []);

    return ElPlatform.isDesktop
        ? Listener(
            onPointerSignal: (e) {
              if (e is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(e, (event) {
                  controller.value?.position.pointerScroll(e.scrollDelta.dy);
                });
              }
            },
            child: child,
          )
        : child;
  }
}
