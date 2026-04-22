import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// 加密工具类
class ElCryptoUtil {
  ElCryptoUtil._();

  /// uuid全局实例对象
  static Uuid uuid = Uuid();

  static final Codec<String, String> _base64Codec = utf8.fuse(base64);

  /// 生成不带 '-' 符号的uuid字符串
  static String get uuidStr => uuid.v4().replaceAll('-', '');

  /// 使用 md5 单向加密加密算法生成新的字符串
  static String toMd5(String str, {String salt = ''}) => md5.convert(utf8.encode(str + salt)).toString();

  /// 字符串转 base64
  static String toBase64(String str) => _base64Codec.encode(str);

  /// base64 转字符串
  static String formBase64(String str) => _base64Codec.decode(str);

  /// 将字符串编码压缩
  static String encodeString(String str) {
    List<int> stringBytes = utf8.encode(str);
    List<int> gzipBytes = GZipEncoder().encode(stringBytes);
    return base64UrlEncode(gzipBytes);
  }

  /// 将字符串编码压缩
  static String decodeString(String str) {
    List<int> stringBytes = base64Url.decode(str);
    List<int> gzipBytes = GZipDecoder().decodeBytes(stringBytes);
    return utf8.decode(gzipBytes);
  }
}
