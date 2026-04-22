import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

part 'theme.dart';

part 'index.g.dart';

/// 卡片组件，此组件通常配置 [ElListTile] 共同使用
class ElCard extends StatelessWidget {
  const ElCard({super.key, this.onTap, this.title, this.showBorder = false, required this.child});

  final Widget child;
  final dynamic title;
  final bool showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = ElCardTheme.of(context);
    final elTheme = context.elTheme;

    Widget result = ElDefaultColor(elTheme.cardColor, child: child);

    if (onTap != null) {
      result = InkWell(onTap: onTap, child: result);
    }

    result = ElAnimatedMaterial(
      clipBehavior: .hardEdge,
      elevation: themeData.elevation!,
      color: elTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: el.config.cardBorderRadius,
        side: showBorder ? BorderSide(color: context.elTheme.borderColor) : BorderSide.none,
      ),
      child: result,
    );

    if (title != null) {
      result = Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: themeData.titlePadding!,
            child: title is Widget ? title : Text(title.toString(), style: themeData.titleStyle),
          ),
          result,
        ],
      );
    }

    return result;
  }
}
