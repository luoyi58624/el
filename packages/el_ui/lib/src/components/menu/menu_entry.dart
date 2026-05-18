part of 'index.dart';

class ElMenuEntry<T> {
  /// 描述通用的菜单抽象实体类
  const ElMenuEntry({
    this.title,
    this.value,
    this.subTitle,
    this.width,
    this.leading,
    this.trailing,
    this.children,
    this.onTap,
  });

  /// 菜单标题
  final String? title;

  /// 菜单唯一标识
  final T? value;

  /// 菜单副标题（部分组件支持）
  final String? subTitle;

  /// 指定菜单的宽度
  final double? width;

  /// 菜单前缀小部件
  final Widget? leading;

  /// 菜单后缀小部件
  final Widget? trailing;

  /// 子菜单，如果 [trailingBuilder] 为 null，则会构建默认的右键图标
  final List<ElMenuEntry>? children;

  /// 菜单点击事件
  final VoidCallback? onTap;
}

/// 菜单分割线
class ElMenuSeparator extends ElMenuEntry {
  const ElMenuSeparator();
}
