import 'dart:math' as math;

import 'package:el_dart/ext.dart';
import 'type.dart';

/// 通用的 Dart 工具类
class ElDartUtil {
  ElDartUtil._();

  /// 判断一个变量是否为空，例如：null、''、[]、{}
  ///
  /// checkNum - 若为true，则判断数字是否为 0
  /// checkString - 若为true，则判断字符串是否为 'null'
  static bool isEmpty(dynamic value, {bool checkNum = true, bool checkString = false}) {
    if (value == null) {
      return true;
    } else if (value is String) {
      var str = value.trim();
      if (checkString) {
        return str.isEmpty || str.toLowerCase() == 'null';
      } else {
        return str.isEmpty;
      }
    } else if (checkNum && value is num) {
      return value == 0;
    } else if (value is Iterable) {
      return value.isEmpty;
    } else if (value is Map) {
      return value.isEmpty;
    } else {
      return false;
    }
  }

  /// 判断一个变量是否不为空
  static bool isNotEmpty(dynamic value, {bool checkNum = true, bool checkString = true}) =>
      isEmpty(value, checkNum: checkNum, checkString: checkString) == false;

  /// 安全地比较两个字符
  static bool compareString(dynamic value1, dynamic value2) {
    return ElTypeUtil.safeString(value1) == ElTypeUtil.safeString(value2);
  }

  /// 安全地比较两个数字：小于、等于、大于、小于等于、大于等于。
  static bool compareNum(dynamic value1, dynamic value2, [ElCompareType compareType = ElCompareType.equal]) {
    return elCompareMatch(compareType, ElTypeUtil.safeDouble(value1) - ElTypeUtil.safeDouble(value2));
  }

  /// 检查本地版本是否需要更新，如果 localVersion < serverVersion，则返回 true，
  /// 例如：
  /// * 1.0.0 < 1.0.1
  /// * 1.0.1 < 1.1.0
  /// * 1.1.1 < 2.0.0
  static bool compareVersion(dynamic localVersion, dynamic serverVersion) {
    final local = _cleanVersion(localVersion);
    final server = _cleanVersion(serverVersion);

    final localNums = _parseVersion(local);
    final serverNums = _parseVersion(server);

    int $max(int a, int b) => a > b ? a : b;

    final maxLen = <int>[localNums.length, serverNums.length].reduce($max);

    for (int i = 0; i < maxLen; i++) {
      final l = i < localNums.length ? localNums[i] : 0;
      final s = i < serverNums.length ? serverNums[i] : 0;

      if (s > l) return true; // 服务器更新
      if (s < l) return false; // 本地更新
    }

    return false;
  }

  /// 清理掉 v/V 前缀 与 -/+ 后缀
  static String _cleanVersion(dynamic v) {
    final s = ElTypeUtil.safeString(v).trim();
    if (s.isEmpty) return '';
    if (s.toLowerCase() == 'null') return '';

    return s
        .replaceAll(RegExp(r'^[vV]'), '') // 去掉开头 v 或 V
        .split(RegExp(r'[-+]'))
        .first
        .trim();
  }

  /// 转成纯数字列表 [1,0,0]
  static List<int> _parseVersion(String v) {
    return v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// 格式化大小
  static String formatSize(dynamic size) {
    if (size == null || size == '' || size == 0) {
      return '0KB';
    }
    const unitArr = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    int index;
    var $size = ElTypeUtil.safeDouble(size);
    index = (math.log($size) / math.log(1024)).floor();
    return '${($size / math.pow(1024, index)).toStringAsFixed(2)}${unitArr[index]}';
  }

  /// 解析百分比字符串：'80%' -> 0.8
  static double parseRatio(dynamic value) {
    assert(value is String && value.endsWith('%'), 'Element Error: 非法的 % 百分比字符解析: $value');
    return double.parse((value as String).removeLastChar()) / 100;
  }
}

/// 比较两个值的条件类型（用于 [El.compareNum]、[ElDateUtil.compareDate] 等）
enum ElCompareType {
  /// 小于
  less,

  /// 小于等于
  lessEqual,

  /// 等于
  equal,

  /// 大于等于
  thanEqual,

  /// 大于
  than,
}

/// 将 `a - b` 的差值与 [compareType] 对应关系匹配。
bool elCompareMatch(ElCompareType compareType, num result) {
  switch (compareType) {
    case ElCompareType.equal:
      return result == 0;
    case ElCompareType.less:
      return result < 0;
    case ElCompareType.lessEqual:
      return result <= 0;
    case ElCompareType.than:
      return result > 0;
    case ElCompareType.thanEqual:
      return result >= 0;
  }
}
