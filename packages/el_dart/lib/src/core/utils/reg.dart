/// 常用的正则表达式
class ElReg {
  ElReg._(); // coverage:ignore-line

  /// 移除字符串前面空格
  static final RegExp removeFirstBlank = RegExp(r'^\s*');

  /// 移除字符串后面空格
  static final RegExp removeEndBlank = RegExp(r'\s*$');

  /// 匹配 html 标签
  static final RegExp htmlTag = RegExp(r'<(.|\n)*?>');

  /// 匹配泛型
  static final RegExp generics = RegExp(r'(<.*>)|\?');
}
