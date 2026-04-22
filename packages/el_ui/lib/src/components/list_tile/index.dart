import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'theme.dart';

part 'index.g.dart';

class ElListTile extends StatelessWidget {
  const ElListTile({
    super.key,
    this.onTap,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.dense,
    this.page,
    this.toggle,
  });

  final VoidCallback? onTap;
  final dynamic title;
  final dynamic subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool? dense;

  /// 点击跳转页面
  final dynamic page;

  /// 开关状态，此属性会构建 Switch 后缀
  final ValueNotifier<bool>? toggle;

  @override
  Widget build(BuildContext context) {
    Widget? leading = this.leading;
    Widget? trailing = this.trailing;
    bool? dense = this.dense;

    if (page != null) {
      trailing ??= const Icon(Icons.keyboard_arrow_right);
    }
    if (toggle != null) {
      trailing ??= ElSwitch(toggle);
    }

    dense ??= subtitle == null ? false : true;

    return ListTile(
      onTap: () {
        if (page != null) {
          if (page is Widget) {
            el.router.pushPage(page);
          } else if (page is String) {
            context.push(page!);
          }
        } else if (toggle != null) {
          toggle!.value = !toggle!.value;
        }
        onTap?.call();
      },
      title: title == null
          ? null
          : title is Widget
          ? title
          : Text(title.toString(), style: TextStyle(fontSize: 16, fontWeight: .w500.elFontWeight)),
      subtitle: subtitle == null
          ? null
          : subtitle is Widget
          ? subtitle
          : Text(subtitle.toString(), style: TextStyle(fontSize: 13, fontWeight: .w400.elFontWeight)),
      leading: leading,
      trailing: trailing,
      contentPadding: EdgeInsets.only(left: leading == null ? 16.0 : 12.0, right: trailing == null ? 16.0 : 12.0),
      dense: dense,
    );
  }
}
