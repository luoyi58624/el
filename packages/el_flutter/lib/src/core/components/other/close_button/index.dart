import 'package:flutter/widgets.dart';

import 'package:el_flutter/el_flutter.dart';

class ElCloseButton extends StatelessWidget {
  const ElCloseButton({super.key, this.iconHoverColor, this.bgHoverColor, this.cursor, this.onTap});

  /// 图标悬停颜色
  final Color? iconHoverColor;

  /// 按钮悬停背景颜色
  final Color? bgHoverColor;

  /// 鼠标悬停光标样式
  final MouseCursor? cursor;

  /// 点击事件
  final PointerUpEventListener? onTap;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final $iconSize = iconTheme.size!;
    final $iconHoverColor = iconHoverColor;
    final $bgHoverColor = bgHoverColor;

    final $size = $iconSize + 4;

    return ElStopPropagation(
      child: ElEvent(
        style: ElEventStyle(cursor: cursor, onTap: onTap),
        child: Builder(
          builder: (context) {
            return Container(
              width: $size,
              height: $size,
              decoration: BoxDecoration(
                color: context.hasHover ? $bgHoverColor : null,
                borderRadius: .circular($size / 2),
              ),
              child: Icon(ElIcons.close, color: context.hasHover ? $iconHoverColor : null, size: $iconSize),
            );
          },
        ),
      ),
    );
  }
}
