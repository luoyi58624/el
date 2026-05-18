import 'package:el_dart/ext.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

part 'style.dart';

part 'index.g.dart';

class ElRawButton extends StatelessWidget with ElStatelessMapMixin {
  ElRawButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type,
    this.leftIcon,
    this.rightIcon,
    this.autofocus,
    this.focusNode,
    this.round,
    this.block,
    this.loading,
    this.disabled,
    this.eventStyle,
    this.styleBuilder,
  });

  /// 点击事件
  final VoidCallback? onPressed;

  /// 子组件，如果是 [Widget]，则直接渲染，否则自动渲染为文字
  final dynamic child;

  /// 主题类型
  final ElThemeType? type;

  /// 按钮左图标
  final Widget? leftIcon;

  /// 按钮右图标
  final Widget? rightIcon;

  /// 是否自动聚焦
  final bool? autofocus;

  /// 焦点控制器
  final FocusNode? focusNode;

  /// 圆角按钮
  final bool? round;

  /// 是否为块级按钮，若为 true 按钮宽度将会充满容器，
  /// 其原理只是移除 [UnconstrainedBox] 小部件。
  ///
  /// 提示：如果你遇到像素溢出问题，将此属性设置为 true 即可解决，原理很简单，
  /// 因为移除 [UnconstrainedBox] 后，按钮尺寸将受祖先影响。
  final bool? block;

  /// 是否处于加载状态
  final bool? loading;

  /// 是否禁用按钮
  final bool? disabled;

  /// 事件样式
  final ElEventStyle? eventStyle;

  /// 按钮样式
  final ElRawButtonStyle Function()? styleBuilder;

  @protected
  Widget get $child => switch (child) {
    Widget _ => child,
    _ => Text(child.toString()),
  };

  bool get $block => block ?? false;

  bool get $disabled => disabled ?? false;

  @override
  Widget build(BuildContext context) {
    Widget result = ElEvent(
      style: ElEventStyle(onTap: (e) => onPressed?.call()),
      child: Builder(
        builder: (context) {
          return AnimatedScale(
            duration: 120.ms,
            curve: Curves.easeOut,
            scale: context.hasTap ? 0.96 : 1.0,
            child: ElBox(
              duration: 120.ms,
              style: ElBoxStyle(
                constraints: BoxConstraints(minWidth: 64),
                padding: .symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.blue.darken(context.hasTap ? 20 : 0),
                  borderRadius: .circular(8),
                ),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  style: TextStyle(fontWeight: .w500, fontSize: 15),
                  duration: 120.ms,
                  child: $child,
                ),
              ),
            ),
          );
        },
      ),
    );

    if ($block) result = UnconstrainedBox(child: result);

    return Semantics(button: true, enabled: !$disabled, onTap: onPressed, child: result);
  }
}
