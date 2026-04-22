import 'package:el_dart/el_dart.dart';

extension ElDartStringExtension on String {
  /// 首字母大写
  String get firstUpperCase {
    return substring(0, 1).toUpperCase() + substring(1);
  }

  /// 首字母小写
  String get firstLowerCase {
    return substring(0, 1).toLowerCase() + substring(1);
  }

  /// 删除第一个字符
  String removeFirstChar() {
    if (isEmpty) return this;
    return substring(1, length);
  }

  /// 删除最后一个字符
  String removeLastChar() {
    if (isEmpty) return this;
    return substring(0, length - 1);
  }

  /// 将驼峰命名字符串转成下划线
  String get toUnderline {
    return replaceAllMapped(RegExp('(?<=[a-z])[A-Z]'), (m) => '_${m.group(0)}').toLowerCase();
  }

  /// 清除字符串首尾空格
  String get clearFrontBackBlank {
    return replaceAll(ElReg.removeFirstBlank, '').replaceAll(ElReg.removeEndBlank, '').trim();
  }

  /// 排除类型字符串中的泛型类型：
  /// * `List<E>` -> List
  /// * `List<E>?` -> List
  String? get excludeGeneric {
    return replaceAll(RegExp(r'(<.*>)|\?'), '');
  }

  /// 提取类型字符串的泛型类型: `List<E>` -> E
  String? get getGenericType {
    int start = indexOf('<') + 1;
    int end = lastIndexOf('>');
    if (start >= end) return null;
    return substring(indexOf('<') + 1, lastIndexOf('>'));
  }

  /// 提取 Map 类型字符串的泛型类型，返回一个 Record 类型字符串集合
  ({String key, String value})? get getMapGenericType {
    int start = indexOf('<') + 1;
    int end = lastIndexOf('>');

    if (start >= end) return null;

    List<String> typeList = substring(indexOf('<') + 1, lastIndexOf('>')).split(',');
    if (typeList.length != 2) return null;

    return (key: typeList[0].trim(), value: typeList[1].trim());
  }

  /// 判断字符串是否为 2 个连续的中文字符
  bool get isTwoChineseCharacters {
    // 获取所有 Unicode 码点（自动处理代理对）
    final codePoints = runes.toList();

    // 条件1：必须恰好包含2个码点（即2个独立汉字）
    if (codePoints.length != 2) return false;

    // 条件2：每个码点必须在汉字的 Unicode 范围内
    for (final codePoint in codePoints) {
      // 基本区（U+4E00-U+9FFF） + 扩展区（U+3400-U+4DBF, U+20000-U+2EBFF 等）
      if (!((codePoint >= 0x4E00 && codePoint <= 0x9FFF) ||
          (codePoint >= 0x3400 && codePoint <= 0x4DBF) ||
          (codePoint >= 0x20000 && codePoint <= 0x2EBFF))) {
        return false;
      }
    }

    return true;
  }

  /// 在每个字符之间插入空格
  String get insertSpaceBetweenChars {
    // 处理空字符串
    if (isEmpty) return '';

    // 获取字符串的 Unicode 码点（自动处理代理对）
    final runes = this.runes.toList();
    final buffer = StringBuffer();

    // 遍历每个码点，拼接字符和空格
    for (var i = 0; i < runes.length; i++) {
      // 写入当前字符
      buffer.write(String.fromCharCode(runes[i]));
      // 若不是最后一个字符，写入空格
      if (i != runes.length - 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  /// 对 2 个连续的中文字符之间插入空格
  String get autoInsertSpace {
    if (isTwoChineseCharacters) {
      return insertSpaceBetweenChars;
    }
    return this;
  }
}
