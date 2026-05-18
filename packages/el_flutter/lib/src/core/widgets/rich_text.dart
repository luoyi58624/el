import 'package:flutter/widgets.dart';

/// Element 富文本小部件
class ElRichText extends Text {
  const ElRichText(
    this.child, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  }) : super('');

  final dynamic child;

  /// 构建富文本片段集合
  List<InlineSpan> _buildRichText(List children) {
    List<InlineSpan> richChildren = [];
    for (final child in children) {
      richChildren.add(_buildInlineSpan(child));
    }
    return richChildren;
  }

  /// 使用递归构建富文本片段
  InlineSpan _buildInlineSpan(dynamic data) {
    // 1. 如果是文本片段则直接返回
    if (data is TextSpan || data is WidgetSpan) return data;

    // 2. 处理 Text 小部件
    if (data is Text) {
      if (data is ElRichText) {
        return TextSpan(
          children: _buildRichText([data.child]),
          style: data.style,
          semanticsLabel: data.semanticsLabel,
          locale: data.locale,
        );
      } else {
        return TextSpan(
          text: '${data.data}',
          style: data.style,
          semanticsLabel: data.semanticsLabel,
          locale: data.locale,
        );
      }
    }

    // 4. 如果是 Widget 小部件，则使用 WidgetSpan 包裹，默认使用文本对齐方案，
    // 如果你传递的 Widget 不是文本，你可以自己包裹 WidgetSpan 实现自定义对齐
    if (data is Widget) {
      return WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: data);
    }

    // 5. 如果是数组，则递归渲染
    if (data is List) return TextSpan(children: _buildRichText(data));

    // 6. 将对象当做字符串处理
    return TextSpan(text: data.toString(), semanticsLabel: semanticsLabel);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      TextSpan(children: _buildRichText(child is List ? child : [child])),
    );
  }
}

// ===========================================================================
// 模拟 Html 排版标签
// ===========================================================================

class H1 extends ElRichText {
  /// 一级标题
  H1(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold).merge(style));
}

class H2 extends ElRichText {
  /// 二级标题
  H2(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold).merge(style));
}

class H3 extends ElRichText {
  /// 三级标题
  H3(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold).merge(style));
}

class H4 extends ElRichText {
  /// 四级标题
  H4(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold).merge(style));
}

class H5 extends ElRichText {
  /// 五级标题
  H5(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold).merge(style));
}

class H6 extends ElRichText {
  /// 六级标题
  H6(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold).merge(style));
}

class P extends ElRichText {
  /// 普通段落文本
  const P(super.child, {super.key, super.style});
}

class B extends ElRichText {
  /// 加粗文本
  B(super.child, {super.key, TextStyle? style}) : super(style: TextStyle(fontWeight: FontWeight.bold).merge(style));
}

class I extends ElRichText {
  /// 斜体文本
  I(super.child, {super.key, TextStyle? style}) : super(style: TextStyle(fontStyle: FontStyle.italic).merge(style));
}

class Del extends ElRichText {
  /// 删除线文本
  Del(super.child, {super.key, TextStyle? style})
    : super(style: TextStyle(decoration: TextDecoration.lineThrough).merge(style));
}
