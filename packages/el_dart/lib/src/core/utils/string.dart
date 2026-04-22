import 'package:path/path.dart' as p;

import 'util.dart';

class ElStringUtil {
  ElStringUtil._();

  /// 获取地址中的文件名
  static String? getUrlFileName(String? url) => p.basename(url ?? '');

  /// 获取地址中的文件名但不包含扩展名
  static String? getUrlFileNameNoExtension(String? url) => p.basenameWithoutExtension(url ?? '');

  /// 获取文件名后缀
  static String? getFileSuffix(String fileName, {bool keepDot = false}) {
    String suffixName = p.extension(fileName);
    if (ElDartUtil.isEmpty(suffixName)) return null;
    if (keepDot) return suffixName;
    if (suffixName.startsWith('.')) return suffixName.replaceFirst('.', '');

    return null;
  }

  /// 判断文件是否是图片
  static bool isImage(String fileName, [List<String>? ext]) =>
      (ext ?? ['jpg', 'jpeg', 'png', 'gif', 'bmp']).contains(getFileSuffix(fileName));

  /// 判断文件是否是静态图片
  static bool isStaticImage(String fileName, [List<String>? ext]) =>
      (ext ?? ['jpg', 'jpeg', 'png']).contains(getFileSuffix(fileName));

  /// 判断文件是否是视频
  static bool isVideo(String fileName, [List<String>? ext]) =>
      (ext ?? ['mkv', 'mp4', 'avi', 'mov', 'wmv', 'mpg', 'mpeg']).contains(getFileSuffix(fileName));

  /// 判断文件是否是音频
  static bool isAudio(String fileName, [List<String>? ext]) =>
      (ext ?? ['mp3', 'wav', 'wma', 'amr', 'ogg']).contains(getFileSuffix(fileName));

  /// 判断文件是否是PPT
  static bool isPPT(String fileName) => ['ppt', 'pptx'].contains(getFileSuffix(fileName));

  /// 判断文件是否是Word
  static bool isWord(String fileName) => ['doc', 'docx'].contains(getFileSuffix(fileName));

  /// 判断文件是否是Excel
  static bool isExcel(String fileName) => ['xls', 'xlsx'].contains(getFileSuffix(fileName));

  /// 判断是否是邮箱
  static bool isEmail(String s) => hasMatch(
    s,
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  /// 判断是否是手机号
  static bool isPhoneNumber(String s) {
    if (s.length > 16 || s.length < 9) return false;
    return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  }

  /// 是否是 http 地址
  static bool isHttp(String url) => url.startsWith('http');

  /// 去掉 URL 中的端口号
  static String removePortFromUrl(String url) {
    if (url.isEmpty) return url;
    return url.replaceAll(RegExp(r':\d+'), '');
  }

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  /// 拼接上级地址，返回新的path，主要过滤新地址尾部多余的/
  static String joinParentPath(String path, [String? parentPath]) {
    String $path = parentPath != null ? parentPath + path : path;
    if ($path.endsWith('/') && parentPath != null) {
      $path = $path.substring(0, $path.length - 1);
    }
    return $path;
  }
}
