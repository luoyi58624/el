import 'package:el_ui/el_ui.dart';
import 'package:flutter/widgets.dart';

part 'model.dart';

part 'theme.dart';

part 'index.g.dart';

const _minWidth = 56.0;
const _height = 28.0;
const _fontSize = 12.0;
const _iconSize = 16.0;

class ElTag extends StatelessWidget {
  /// Element UI 标签小部件
  const ElTag(
    this.text, {
    super.key,
    this.duration,
    this.curve,
    this.type,
    this.icon,
    this.width,
    this.height,
    this.bgColor,
    this.textColor,
    this.textSize,
    this.iconColor,
    this.iconSize,
    this.plain,
    this.round,
    this.closable,
    this.borderRadius,
    this.padding,
    this.onClose,
  });

  /// 标签文字信息
  final String text;

  /// 动画持续时间，[ElTag] 属于隐式动画小部件
  final Duration? duration;

  /// 动画曲线
  final Curve? curve;

  /// 主题类型，默认 [.primary]
  final ElThemeType? type;

  /// 标签左图标
  final Widget? icon;

  /// 标签最小宽度
  final double? width;

  /// 标签高度，默认 28
  final double? height;

  /// 自定义标签背景颜色，此属性会替代 [type]
  final Color? bgColor;

  /// 文字颜色
  final Color? textColor;

  /// 文字大小，默认 12
  final double? textSize;

  /// 图标颜色
  final Color? iconColor;

  /// 图标大小，默认 18
  final double? iconSize;

  /// 镂空标签
  final bool? plain;

  /// 圆角标签
  final bool? round;

  /// 是否可关闭
  final bool? closable;

  /// 边框圆角
  final BorderRadius? borderRadius;

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  /// 点击关闭按钮事件
  final void Function()? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = ElTagTheme.of(context);
    final $type = type ?? theme.type ?? .primary;
    final $icon = icon ?? theme.icon;
    final $bgColor = bgColor ?? theme.bgColor ?? context.elThemeColors[$type]!;
    final $plain = plain ?? theme.plain ?? false;
    final $round = round ?? theme.round ?? false;
    final $width = width ?? theme.width ?? _minWidth;
    final $height = height ?? theme.height ?? _height;
    final $closable = closable ?? theme.closable ?? false;
    final $borderRadius = $round
        ? BorderRadius.circular($height / 2)
        : borderRadius ?? theme.borderRadius ?? el.config.borderRadius;
    final $padding =
        padding ?? theme.padding ?? .only(left: $icon == null ? 12 : 10, right: $closable == false ? 12 : 6);
    final $textStyle = TextStyle(
      color: textColor ?? theme.textColor ?? ($plain ? $bgColor : $bgColor.elTextColor(context)),
      fontSize: textSize ?? theme.textSize ?? _fontSize,
    );

    return UnconstrainedBox(
      child: AnimatedContainer(
        duration: el.globalAnimation(duration ?? theme.duration).$1,
        curve: curve ?? theme.curve ?? Curves.linear,
        constraints: BoxConstraints(minWidth: $width, minHeight: $height, maxHeight: $height),
        padding: $padding,
        decoration: BoxDecoration(
          color: $plain ? $bgColor.elLight9(context) : $bgColor,
          borderRadius: $borderRadius,
          border: Border.all(color: $bgColor, width: 1),
        ),
        child: Center(
          child: Row(
            children: [
              if ($icon != null)
                Padding(
                  padding: const .only(right: 6.0),
                  child: ElAnimatedIconTheme(
                    duration: theme.duration!,
                    data: IconThemeData(size: iconSize ?? theme.iconSize ?? _iconSize, color: $textStyle.color),
                    child: $icon,
                  ),
                ),
              AnimatedDefaultTextStyle(
                duration: el.globalAnimation(duration ?? theme.duration).$1,
                style: $textStyle,
                child: ElRichText(text),
              ),
              if ($closable)
                Padding(
                  padding: const .only(left: 6.0),
                  child: ElAnimatedIconTheme(
                    duration: theme.duration!,
                    data: IconThemeData(size: $textStyle.fontSize, color: $textStyle.color),
                    child: ElCloseButton(
                      iconHoverColor: $plain ? $bgColor.elTextColor(context) : $textStyle.color,
                      bgHoverColor: $plain ? $bgColor : $bgColor.deepen(25),
                      onTap: (e) => onClose?.call(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
