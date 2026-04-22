import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'group_button.dart';

part 'segmented_button.dart';

part 'theme.dart';

part 'index.g.dart';

enum ElButtonType { basic, flat, outline, text, link, icon }

class ElButton extends StatefulWidget {
  /// 普通按钮
  const ElButton({
    super.key,
    required this.child,
    this.buttonType = .basic,
    this.type,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.textStyle,
    this.iconThemeData,
    this.leftIcon,
    this.rightIcon,
    this.borderRadius,
    this.round,
    this.block,
    this.loading = false,
    this.disabled = false,
    this.autofocus = false,
    this.focusNode,
    this.loadingBuilder,
    this.onPressed,
  });

  /// 没有海拔的普通按钮
  const ElButton.flat({
    super.key,
    required this.child,
    this.type,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.textStyle,
    this.iconThemeData,
    this.leftIcon,
    this.rightIcon,
    this.borderRadius,
    this.round,
    this.block,
    this.loading = false,
    this.disabled = false,
    this.autofocus = false,
    this.focusNode,
    this.loadingBuilder,
    this.onPressed,
  }) : buttonType = .flat;

  /// 边框按钮，背景透明，周围绘制边框
  const ElButton.outline({
    super.key,
    required this.child,
    this.type,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.textStyle,
    this.iconThemeData,
    this.borderRadius,
    this.round,
    this.block,
    this.loading = false,
    this.disabled = false,
    this.autofocus = false,
    this.focusNode,
    this.onPressed,
  }) : buttonType = .outline,
       leftIcon = null,
       rightIcon = null,
       loadingBuilder = null;

  /// 文本按钮，背景透明
  const ElButton.text({
    super.key,
    required this.child,
    this.type,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.textStyle,
    this.iconThemeData,
    this.borderRadius,
    this.round,
    this.loading = false,
    this.disabled = false,
    this.autofocus = false,
    this.focusNode,
    this.onPressed,
  }) : buttonType = .text,
       leftIcon = null,
       rightIcon = null,
       block = null,
       loadingBuilder = null;

  /// 链接文字按钮，不包含任何装饰，按下时有一个透明效果
  const ElButton.link({
    super.key,
    required this.child,
    this.type = .primary,
    this.color,
    this.margin,
    this.textStyle,
    this.iconThemeData,
    this.loading = false,
    this.disabled = false,
    this.autofocus = false,
    this.focusNode,
    this.onPressed,
  }) : buttonType = .link,
       width = null,
       height = null,
       padding = null,
       leftIcon = null,
       rightIcon = null,
       borderRadius = null,
       round = null,
       block = null,
       loadingBuilder = null;

  /// 圆形图标按钮
  const ElButton.icon({
    super.key,
    required this.child,
    this.type,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.textStyle,
    this.iconThemeData,
    this.loading = false,
    this.disabled = false,
    this.autofocus = false,
    this.block,
    this.focusNode,
    this.onPressed,
  }) : buttonType = .icon,
       leftIcon = null,
       rightIcon = null,
       borderRadius = null,
       round = null,
       loadingBuilder = null;

  final ElButtonType buttonType;

  /// 子组件，如果是[Widget]，则直接渲染，否则自动渲染为文字
  final dynamic child;

  /// 主题类型
  final ElThemeType? type;

  /// 自定义按钮颜色，它会覆盖 [type] 类型颜色
  final Color? color;

  /// 自定义按钮宽度，它的应用策略如下：
  /// 1. 优先应用组件定义的 width
  /// 2. 当按钮类型为 icon 时，width = height
  /// 3. 当 child 为图标时，width = height * iconChildFactor
  /// 4. 最后应用 buttonTheme 的 width
  final double? width;

  /// 自定义按钮高度，若要仅以 [padding] 撑开按钮，直接将其设置为 0 即可
  final double? height;

  /// 自定义按钮内边距
  final EdgeInsets? padding;

  /// 自定义按钮外边距
  final EdgeInsets? margin;

  /// 文本样式
  final TextStyle? textStyle;

  /// 图标样式
  final IconThemeData? iconThemeData;

  /// 按钮左图标
  final Widget? leftIcon;

  /// 按钮右图标
  final Widget? rightIcon;

  /// 边框圆角
  final BorderRadius? borderRadius;

  /// 圆角按钮
  final bool? round;

  /// 是否为块级按钮，若为 true 按钮宽度将会充满容器，
  /// 其原理只是移除 [UnconstrainedBox] 小部件。
  ///
  /// 提示：如果你遇到像素溢出问题，将此属性设置为 true 即可解决，原理很简单，
  /// 因为移除 [UnconstrainedBox] 后，按钮尺寸将受祖先影响。
  final bool? block;

  /// 是否处于加载状态
  final bool loading;

  /// 是否禁用按钮
  final bool disabled;

  /// 是否自动聚焦
  final bool autofocus;

  /// 焦点控制器
  final FocusNode? focusNode;

  /// 自定义 loading 构建器
  final WidgetBuilder? loadingBuilder;

  /// 点击事件
  final VoidCallback? onPressed;

  /// 默认风格的加载器
  static Widget defaultLoadingBuilder(BuildContext context) {
    final themeData = IconTheme.of(context);
    return SizedBox(
      width: themeData.size,
      height: themeData.size,
      child: CircularProgressIndicator(
        strokeWidth: 2.applyTextScale(MediaQuery.textScalerOf(context)),
        color: themeData.color,
      ),
    );
  }

  @override
  State<ElButton> createState() => _ElButtonState();
}

class _ElButtonState<T extends ElButton> extends State<T> {
  late ElButtonThemeData themeData;
  late TextScaler textScaler;
  late TextDirection textDirection;

  Color? get color => widget.color ?? context.elThemeColors[widget.type];

  /// 将 widget.child 进行转换，根据条件渲染不同的默认小部件
  Widget buildChild(dynamic child) {
    if (child is IconData) {
      _isIconChild = true;
      return Icon(child);
    } else if (child is Icon) {
      _isIconChild = true;
      return child;
    } else if (child is Image) {
      _isIconChild = true;
      final iconSize = this.iconSize.applyTextScale(textScaler);
      return Center(
        child: widget.child is Widget
            ? SizedBox(width: iconSize, height: iconSize, child: widget.child)
            : Placeholder(fallbackWidth: iconSize, fallbackHeight: iconSize),
      );
    } else {
      if (child is Widget) {
        if (widget.buttonType == .icon) {
          _isIconChild = true;
          final size = iconSize;
          return SizedBox(width: size, height: size, child: child);
        } else {
          _isIconChild = false;
        }
        return child;
      } else {
        _isIconChild = false;
        return buildTextWidget(child.toString());
      }
    }
  }

  /// 构建默认文本小部件
  Widget buildTextWidget(String text) {
    if (themeData.autoInsertSpace == true) {
      if (widget.leftIcon == null && widget.rightIcon == null) {
        return ElRichText(text.autoInsertSpace);
      }
    }
    return ElRichText(text);
  }

  late bool _isIconChild;

  /// 是否为图标按钮
  bool get isIconChild => _isIconChild;

  double get width {
    if (widget.width != null) return widget.width!.applyTextScale(textScaler);
    if (widget.buttonType == .icon) return height;
    if (isIconChild) return height * themeData.iconChildFactor!;
    return themeData.width!.applyTextScale(textScaler);
  }

  double get height {
    return (widget.height ??
            (widget.buttonType == .icon ? themeData.height! * themeData.iconChildFactor! : themeData.height!))
        .applyTextScale(textScaler);
  }

  double get iconSize {
    if (widget.iconThemeData?.size != null) return widget.iconThemeData!.size!;
    if ((widget.buttonType == .text || widget.buttonType == .icon) && isIconChild) {
      return themeData.iconSize! * themeData.iconChildFactor!;
    } else {
      return themeData.iconSize!;
    }
  }

  EdgeInsets get padding => (widget.padding ?? (isIconChild ? .zero : themeData.padding!)).applyTextScale(textScaler);

  EdgeInsets get margin => (widget.margin ?? themeData.margin!).applyTextScale(textScaler);

  BorderRadius get borderRadius =>
      (widget.round == true || widget.buttonType == .icon
              ? const BorderRadius.all(Radius.circular(1000))
              : widget.borderRadius ?? el.config.borderRadius)
          .applyTextScale(textScaler);

  bool get disabled => widget.disabled || widget.loading;

  MouseCursor get cursor => widget.disabled
      ? themeData.disabledCursor!
      : widget.loading == true
      ? themeData.loadingCursor!
      : themeData.cursor!;

  WidgetBuilder get loadingBuilder => widget.loadingBuilder ?? ElButton.defaultLoadingBuilder;

  /// 构建按钮默认文本样式
  TextStyle buildTextStyle(Color textColor) {
    return context.elTextStyle
        .copyWith(fontSize: themeData.fontSize!, fontWeight: FontWeight.w500, color: textColor)
        .merge(widget.textStyle);
  }

  /// 构建按钮默认图标样式
  IconThemeData buildIconData(Color textColor) {
    return IconThemeData(color: textColor, size: iconSize).merge(widget.iconThemeData);
  }

  /// 构建波纹交互组件
  Widget buildInkWell({
    Duration hoverDuration = const Duration(milliseconds: 200),
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Color? focusColor,
    required BorderRadius borderRadius,
    required Widget child,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      mouseCursor: cursor,
      splashFactory: InkRipple.splashFactory,
      borderRadius: borderRadius,
      hoverDuration: hoverDuration,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      focusColor: focusColor,
      canRequestFocus: widget.disabled == false,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      child: child,
    );
  }

  /// 构建聚焦环
  Widget buildRing(
    BuildContext context, {
    double width = 2.0,
    double offset = 2.0,
    double? strokeAlign,
    required Widget child,
  }) {
    return ElRing(
      duration: Duration(milliseconds: 100),
      show: Focus.of(context).hasFocus,
      borderRadius: borderRadius,
      color: color ?? context.elTheme.primary,
      width: width,
      offset: offset,
      strokeAlign: strokeAlign,
      child: child,
    );
  }

  /// 构建按钮基本骨架
  Widget buildBox(BuildContext context, Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: width, minHeight: height),
      child: Padding(padding: padding, child: child),
    );
  }

  /// 构建按钮内容
  Widget buildContent(BuildContext context, Widget child, [Widget? leftIcon, Widget? rightIcon]) {
    if (leftIcon == null && rightIcon == null) {
      return Center(child: child);
    }

    Widget? $leftIcon = leftIcon;
    Widget? $rightIcon = rightIcon;

    final gap = 6.0.applyTextScale(textScaler);
    Widget result = Padding(
      padding: .only(left: $leftIcon != null ? gap : 0.0, right: $rightIcon != null ? gap : 0.0),
      child: child,
    );

    result = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [?$leftIcon, result, ?$rightIcon],
    );

    return result;
  }

  /// 默认的 loading 加载器背景颜色
  Color get loadingBgColor =>
      ElBrightness.isDark(context) ? const .fromRGBO(57, 57, 57, 1.0) : const .fromRGBO(224, 224, 224, 1.0);

  /// 默认的 loading 加载器颜色
  Color get loadingColor =>
      ElBrightness.isDark(context) ? const .fromRGBO(118, 118, 118, 1.0) : const .fromRGBO(166, 166, 166, 1.0);

  /// 构建 loading 加载器，它会隐藏传递的 child 并将 loading 覆盖在按钮之上
  Widget buildLoadingWidget(BuildContext context, Color loadingColor, Widget child) {
    if (widget.loading) {
      return Stack(
        children: [
          Opacity(opacity: 0, child: child),
          Positioned.fill(
            child: AnimatedDefaultTextStyle(
              duration: el.globalAnimation().$1,
              curve: el.globalAnimation().$2,
              style: buildTextStyle(loadingColor),
              child: IconTheme(
                data: buildIconData(loadingColor).copyWith(size: height / 2),
                child: Center(
                  child: Builder(
                    builder: (context) {
                      return loadingBuilder(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }

  Widget get buttonWidget {
    switch (widget.buttonType) {
      case .basic:
        return _BasicButton(this);
      case .flat:
        return _FlatButton(this);
      case .outline:
        return _OutlineButton(this);
      case .text:
        return _TextButton(this);
      case .link:
        return _LinkButton(this);
      case .icon:
        return _IconButton(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    themeData = ElButtonTheme.of(context);
    textScaler = MediaQuery.textScalerOf(context);
    Widget result = buttonWidget;

    if (widget.block != true) result = UnconstrainedBox(child: result);
    if (margin != .zero) {
      result = Padding(padding: margin, child: result);
    }

    return Semantics(button: true, enabled: widget.disabled == false, onTap: widget.onPressed, child: result);
  }
}

typedef _InkWellColors = (Color? hoverColor, Color? highlightColor, Color? splashColor);

class _BasicButton extends StatelessWidget {
  const _BasicButton(this.state);

  final _ElButtonState state;

  static Color buildBgColor(BuildContext context, Color? color) {
    return color ?? context.elDefaultColor.deepen(5, darkScale: 8);
  }

  static _InkWellColors buildInkWellColors(BuildContext context, Color bgColor) {
    final isHighlightBg = bgColor.isHighlight;
    return (
      isHighlightBg
          ? ElBrightness.isDark(context)
                ? Colors.black12
                : Colors.black12
          : bgColor.isDark
          ? Colors.white12
          : Colors.black12,
      isHighlightBg
          ? Colors.white24
          : bgColor.isDark
          ? Colors.white12
          : Colors.black12,
      isHighlightBg
          ? Colors.white30
          : bgColor.isDark
          ? Colors.white30
          : Colors.black12,
    );
  }

  double buildElevation(BuildContext context) => state.disabled
      ? 0
      : context.hasTap
      ? 6
      : context.hasHover
      ? 4
      : ElBrightness.isDark(context)
      ? 4
      : 2;

  void onPressed() {
    state.widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final child = state.buildChild(state.widget.child);
    final bgColor = buildBgColor(context, state.color);
    final textColor = state.disabled ? state.loadingColor : bgColor.elRegularTextColor(context);
    final (hoverColor, highlightColor, splashColor) = buildInkWellColors(context, bgColor);
    final globalAnimation = el.globalAnimation();

    Widget result = state.buildBox(
      context,
      state.buildLoadingWidget(
        context,
        state.loadingColor,
        AnimatedDefaultTextStyle(
          duration: globalAnimation.$1,
          curve: globalAnimation.$2,
          style: state.buildTextStyle(textColor),
          child: ElAnimatedIconTheme(
            data: state.buildIconData(textColor),
            child: state.buildContent(context, child, state.widget.leftIcon, state.widget.rightIcon),
          ),
        ),
      ),
    );

    return ElEvent(
      child: Focus(
        skipTraversal: true,
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return ElAnimatedMaterial(
              color: state.disabled ? state.loadingBgColor : bgColor,
              borderRadius: state.borderRadius,
              elevation: hasFocus ? 0 : buildElevation(context),
              child: state.buildRing(
                context,
                child: state.buildInkWell(
                  onPressed: state.disabled ? null : onPressed,
                  hoverColor: hoverColor,
                  highlightColor: highlightColor,
                  splashColor: splashColor,
                  focusColor: Colors.transparent,
                  borderRadius: state.borderRadius,
                  child: result,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FlatButton extends _BasicButton {
  const _FlatButton(super.state);

  @override
  double buildElevation(BuildContext context) => 0;
}

class _OutlineButton extends _BasicButton {
  const _OutlineButton(super.state);

  static Color buildTextColor(BuildContext context, Color? color) {
    return color ?? context.elDefaultColor.elSecondaryTextColor(context);
  }

  static _InkWellColors buildInkWellColors(BuildContext context, Color textColor) {
    return (Colors.transparent, textColor.elOpacity(0.10), textColor.elOpacity(0.16));
  }

  @override
  Widget build(BuildContext context) {
    final child = state.buildChild(state.widget.child);
    final textColor = state.disabled ? state.loadingColor : buildTextColor(context, state.color);
    final (hoverColor, highlightColor, splashColor) = buildInkWellColors(context, textColor);
    final borderWidth = el.config.borderWidth.applyTextScale(state.textScaler);
    final globalAnimation = el.globalAnimation();

    Widget result = ElAnimatedDecoratedBox(
      decoration: BoxDecoration(
        color: state.widget.disabled ? state.loadingBgColor : null,
        borderRadius: state.borderRadius,
        border: Border.all(color: state.disabled ? state.loadingBgColor : textColor, width: borderWidth),
      ),
      child: AnimatedDefaultTextStyle(
        duration: globalAnimation.$1,
        curve: globalAnimation.$2,
        style: state.buildTextStyle(textColor),
        child: IconTheme(
          data: state.buildIconData(textColor),
          child: state.buildBox(
            context,
            state.buildLoadingWidget(context, state.loadingColor, state.buildContent(context, child)),
          ),
        ),
      ),
    );

    return Focus(
      skipTraversal: true,
      child: Builder(
        builder: (context) {
          return ElAnimatedMaterial(
            type: MaterialType.transparency,
            child: state.buildRing(
              context,
              width: borderWidth * 2,
              offset: -borderWidth,
              child: state.buildInkWell(
                onPressed: state.disabled ? null : onPressed,
                hoverDuration: Duration.zero,
                hoverColor: hoverColor,
                highlightColor: highlightColor,
                splashColor: splashColor,
                focusColor: Colors.transparent,
                borderRadius: state.borderRadius,
                child: result,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TextButton extends _OutlineButton {
  const _TextButton(super.state);

  static _InkWellColors buildInkWellColors(BuildContext context, Color textColor) {
    return (textColor.elOpacity(0.08), textColor.elOpacity(0.10), textColor.elOpacity(0.16));
  }

  @override
  Widget build(BuildContext context) {
    final child = state.buildChild(state.widget.child);
    final textColor = state.widget.disabled
        ? state.loadingColor.elOpacity(0.5)
        : _OutlineButton.buildTextColor(context, state.color);
    final (hoverColor, highlightColor, splashColor) = buildInkWellColors(context, textColor);
    final globalAnimation = el.globalAnimation();

    Widget result = state.buildBox(
      context,
      state.buildLoadingWidget(
        context,
        textColor,
        AnimatedDefaultTextStyle(
          duration: globalAnimation.$1,
          curve: globalAnimation.$2,
          style: state.buildTextStyle(textColor),
          child: ElAnimatedIconTheme(data: state.buildIconData(textColor), child: state.buildContent(context, child)),
        ),
      ),
    );

    return ElAnimatedMaterial(
      type: MaterialType.transparency,
      borderRadius: state.borderRadius,
      child: state.buildInkWell(
        onPressed: state.disabled ? null : onPressed,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        borderRadius: state.borderRadius,
        child: result,
      ),
    );
  }
}

class _IconButton extends _TextButton {
  const _IconButton(super.state);

  @override
  Widget build(BuildContext context) {
    final child = state.buildChild(state.widget.child);
    final textColor = state.widget.disabled
        ? state.loadingColor.elOpacity(0.5)
        : state.color ?? context.elDefaultColor.elSecondaryTextColor(context);

    Widget result = state.buildBox(
      context,
      state.buildLoadingWidget(
        context,
        textColor,
        ElAnimatedIconTheme(data: state.buildIconData(textColor), child: state.buildContent(context, child)),
      ),
    );

    return ElAnimatedMaterial(
      type: MaterialType.transparency,
      borderRadius: state.borderRadius,
      child: state.buildInkWell(
        onPressed: state.disabled ? null : onPressed,
        hoverColor: textColor.elOpacity(0.12),
        highlightColor: textColor.elOpacity(0.12),
        splashColor: textColor.elOpacity(0.2),
        borderRadius: state.borderRadius,
        child: result,
      ),
    );
  }
}

class _LinkButton extends _TextButton {
  const _LinkButton(super.state);

  @override
  Widget build(BuildContext context) {
    final child = state.buildChild(state.widget.child);
    final textColor = state.widget.disabled
        ? state.loadingColor.elOpacity(0.5)
        : state.color ?? context.elDefaultColor.elSecondaryTextColor(context);
    final globalAnimation = el.globalAnimation();

    return Actions(
      actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (i) => onPressed())},
      child: Focus(
        canRequestFocus: !state.disabled,
        autofocus: state.widget.autofocus,
        focusNode: state.widget.focusNode,
        child: Builder(
          builder: (context) {
            return state.buildRing(
              context,
              child: ElFadeTap(
                onTap: state.disabled ? null : (e) => onPressed(),
                style: ElEventStyle(
                  disabled: state.disabled,
                  cursor: state.themeData.cursor,
                  disabledCursor: state.widget.loading ? state.themeData.loadingCursor : state.themeData.disabledCursor,
                ),
                opacity: ElPlatform.isDesktop ? 0.4 : 0.28,
                hoverOpacity: 0.4,
                child: Builder(
                  builder: (context) {
                    return state.buildLoadingWidget(
                      context,
                      textColor,
                      AnimatedDefaultTextStyle(
                        duration: globalAnimation.$1,
                        curve: globalAnimation.$2,
                        style: state.buildTextStyle(textColor),
                        child: ElAnimatedIconTheme(data: state.buildIconData(textColor), child: child),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
