import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Element 全局单例服务对象
const el = El._();

class El {
  const El._();

  static const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
  static const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
  static const bool kDebugMode = !kReleaseMode && !kProfileMode;
  static const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop');

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
    return safeString(value1) == safeString(value2);
  }

  /// 安全地比较两个数字：小于、等于、大于、小于等于、大于等于。
  static bool compareNum(dynamic value1, dynamic value2, [ElCompareType compareType = ElCompareType.equal]) {
    return elCompareMatch(compareType, safeDouble(value1) - safeDouble(value2));
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
    final s = safeString(v).trim();
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
    var $size = safeDouble(size);
    index = (math.log($size) / math.log(1024)).floor();
    return '${($size / math.pow(1024, index)).toStringAsFixed(2)}${unitArr[index]}';
  }

  /// 解析百分比字符串：'80%' -> 0.8
  static double parseRatio(dynamic value) {
    assert(value is String && value.endsWith('%'), 'Element Error: 非法的 % 百分比字符解析: $value');
    return double.parse((value as String).removeLastChar()) / 100;
  }

  /// 获取地址中的文件名
  static String? getUrlFileName(String? url) => p.basename(url ?? '');

  /// 获取地址中的文件名但不包含扩展名
  static String? getUrlFileNameNoExtension(String? url) => p.basenameWithoutExtension(url ?? '');

  /// 获取文件名后缀
  static String? getFileSuffix(String fileName, {bool keepDot = false}) {
    String suffixName = p.extension(fileName);
    if (isEmpty(suffixName)) return null;
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

  // =====================================================================================================
  // 类型工具方法
  // =====================================================================================================

  /// 判断变量是否是基本数据类型
  static bool isBaseType(dynamic value) => (value is num || value is String || value is bool);

  /// 检查传入的类型字符串是否是基本类型字符串
  static bool isBaseTypeString(String typeString) => ['String', 'num', 'int', 'double', 'bool'].contains(typeString);

  /// 安全解析String，如果传递的value为空，则返回一个默认值
  static String safeString(dynamic value, [String defaultValue = '']) {
    if (isEmpty(value)) {
      return defaultValue;
    } else {
      return value.toString();
    }
  }

  /// 安全解析int，如果传递的value不是num类型，则返回默认值
  static int safeInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) {
      return value.isNaN ? defaultValue : value;
    } else if (value is double) {
      if (value.isNaN) return defaultValue;
      return value.toInt();
    } else if (value is String) {
      final s = value.trim();
      final parsed = int.tryParse(s);
      return parsed ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  /// 安全解析double，如果传递的value不是num类型，则返回默认值
  static double safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value is double) {
      return value.isNaN ? defaultValue : value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      final s = value.trim();
      final parsed = double.tryParse(s);
      return parsed ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  /// 安全解析bool类型
  static bool safeBool(dynamic value, [bool defaultValue = false]) {
    if (value is String) {
      final s = value.trim().toLowerCase();
      if (s == '1') return true;
      if (s == '0') return false;
      try {
        return bool.parse(value, caseSensitive: false);
      } catch (e) {
        return defaultValue;
      }
    } else if (value is num) {
      return value != 0;
    } else if (value is bool) {
      return value;
    }
    return defaultValue;
  }

  /// 安全解析List，若解析失败则返回空List
  static List<T> safeList<T>(dynamic value, [List<T> defaultValue = const []]) {
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (e) {
        return defaultValue;
      }
    } else {
      return defaultValue;
    }
  }

  /// 将动态类型转换成实际基础类型：String、int、double、num、bool，如果
  /// * strict 如果为true，对于非基础类型将一律返回null
  static dynamic dynamicToBaseType(dynamic value, [bool? strict]) {
    String type = value.runtimeType.toString();
    if (type == 'String') {
      dynamic v = int.tryParse(value);
      if (v != null) return v;
      v = double.tryParse(value);
      if (v != null) return v;
      v = bool.tryParse(value);
      if (v != null) return v;
      return value;
    }
    if (type == 'int') return value;
    if (type == 'double') return value;
    if (type == 'bool') return value;
    if (type == 'num') return value;
    return strict == true ? null : value;
  }

  /// 将动态类型转换成指定类型的 List 集合，转换前请判断数据类型是否是 List
  static T dynamicToList<T>(dynamic value) {
    assert(value is List);
    final valueType = T.toString().getGenericType;
    if (valueType == 'dynamic') {
      return List.from(value) as T;
    } else if (valueType == 'Object') {
      return List<Object>.from(value) as T;
    } else if (valueType == 'String') {
      return List<String>.from(value) as T;
    } else if (valueType == 'int') {
      return List<int>.from(value) as T;
    } else if (valueType == 'double') {
      return List<double>.from(value) as T;
    } else if (valueType == 'num') {
      return List<num>.from(value) as T;
    } else if (valueType == 'bool') {
      return List<bool>.from(value) as T;
    } else {
      return List.from(value) as T;
    }
  }

  /// 将动态类型转换成指定类型的 Set 集合，转换前请判断数据类型是否是 Set
  static T dynamicToSet<T>(dynamic value) {
    assert(value is Set);
    final valueType = T.toString().getGenericType;
    if (valueType == 'dynamic') {
      return Set.from(value) as T;
    } else if (valueType == 'Object') {
      return Set<Object>.from(value) as T;
    } else if (valueType == 'String') {
      return Set<String>.from(value) as T;
    } else if (valueType == 'int') {
      return Set<int>.from(value) as T;
    } else if (valueType == 'double') {
      return Set<double>.from(value) as T;
    } else if (valueType == 'num') {
      return Set<num>.from(value) as T;
    } else if (valueType == 'bool') {
      return Set<bool>.from(value) as T;
    } else {
      return Set.from(value) as T;
    }
  }

  /// 将动态类型转换成指定类型的 Map 集合，转换前请判断数据类型是否是 Map
  static dynamic dynamicToMap<T>(dynamic map) {
    assert(map is Map);
    final valueType = T.toString().getMapGenericType;
    String targetKeyType = valueType!.key;
    String targetValueType = valueType.value;
    if (targetKeyType == 'dynamic') {
      if (targetValueType == 'Object') {
        return Map<Object, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<Object, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<Object, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<Object, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<Object, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<Object, bool>.from(map);
      }
      return map.cast<Object, dynamic>();
    }
    if (targetKeyType == 'String') {
      if (targetValueType == 'Object') {
        return Map<String, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<String, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<String, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<String, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<String, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<String, bool>.from(map);
      }
      return Map<String, dynamic>.from(map);
    }
    if (targetKeyType == 'int') {
      if (targetValueType == 'Object') {
        return Map<int, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<int, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<int, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<int, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<int, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<int, bool>.from(map);
      }
      return Map<int, dynamic>.from(map);
    }

    if (targetKeyType == 'double') {
      if (targetValueType == 'Object') {
        return Map<double, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<double, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<double, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<double, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<double, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<double, bool>.from(map);
      }
      return Map<double, dynamic>.from(map);
    }
    if (targetKeyType == 'bool') {
      if (targetValueType == 'Object') {
        return Map<bool, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<bool, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<bool, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<bool, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<bool, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<bool, bool>.from(map);
      }
      return Map<bool, dynamic>.from(map);
    }

    if (targetKeyType == 'num') {
      if (targetValueType == 'Object') {
        return Map<num, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<num, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<num, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<num, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<num, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<num, bool>.from(map);
      }
      return Map<num, dynamic>.from(map);
    }

    return map;
  }

  // =====================================================================================================
  // 日期工具方法
  // =====================================================================================================

  /// 获取当前时间的毫秒
  static int get currentMilliseconds => DateTime.now().millisecondsSinceEpoch;

  /// 获取当前时间的微秒
  static int get currentMicroseconds => DateTime.now().microsecondsSinceEpoch;

  /// 安全解析日期，支持字符串、时间戳等格式解析，如果格式不正确则返回 [defaultValue]，
  /// 若 [defaultValue] 为空，则会返回当前时间。
  static DateTime safeDate(dynamic value, [dynamic defaultValue]) {
    if (isEmpty(value)) {
      return _defaultDate(defaultValue);
    } else if (value is String) {
      var date = DateTime.tryParse(value);
      return date ?? _defaultDate(defaultValue);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    } else {
      return _defaultDate(defaultValue);
    }
  }

  static DateTime _defaultDate(dynamic value) {
    if (isEmpty(value)) {
      return DateTime.now();
    } else if (value is String) {
      var date = DateTime.tryParse(value);
      return date ?? DateTime.now();
    } else if (value is DateTime) {
      return value;
    } else {
      return DateTime.now();
    }
  }

  /// 安全地比较两个日期，允许传入 2 个任意类型的数据，它们都会安全地转化为 [DateTime] 进行比较
  static bool compareDate(dynamic date1, dynamic date2, [ElCompareType compareType = ElCompareType.equal]) {
    late int result;
    int nullValue1 = isEmpty(date1) ? 0 : 1;
    int nullValue2 = isEmpty(date2) ? 0 : 1;

    if (nullValue1 == 0 || nullValue2 == 0) {
      result = nullValue1 - nullValue2;
    } else {
      DateTime? dateTime1;
      DateTime? dateTime2;
      if (date1 is String) {
        dateTime1 = DateTime.tryParse(date1);
      } else if (date1 is DateTime) {
        dateTime1 = date1;
      } else {
        throw Exception('传入的date1类型错误');
      }
      if (date2 is String) {
        dateTime2 = DateTime.tryParse(date2);
      } else if (date2 is DateTime) {
        dateTime2 = date2;
      } else {
        throw Exception('传入的date2类型错误');
      }
      if (dateTime1 != null && dateTime2 != null) {
        result = dateTime1.compareTo(dateTime2);
      } else {
        result = (dateTime1 == null ? 0 : 1) - (dateTime2 == null ? 0 : 1);
      }
    }
    return elCompareMatch(compareType, result);
  }

  /// 比较两个日期，若为 true 则返回 [date1]，否则返回 [date2]。
  static DateTime getCompareDate(DateTime date1, DateTime date2, [ElCompareType compareType = ElCompareType.equal]) {
    return compareDate(date1, date2, compareType) ? date1 : date2;
  }

  /// [date1] 与 [date2] 相差的毫秒数
  static int diffDate(dynamic date1, dynamic date2) {
    return ((safeDate(date1).millisecondsSinceEpoch - safeDate(date2).millisecondsSinceEpoch)).truncate();
  }

  /// [date1] 与 [date2] 相差的天数
  static int diffDay(dynamic date1, dynamic date2) {
    return ((safeDate(date1).millisecondsSinceEpoch - safeDate(date2).millisecondsSinceEpoch) / 1000 / 60 / 60 / 24)
        .truncate();
  }

  /// 毫秒时长转倒计时文案
  static String millisecondToCountDown(int milliseconds) {
    assert(milliseconds > 0, '时间戳必须大于0');
    var duration = Duration(milliseconds: milliseconds);
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    String hourText = hours.toString().padLeft(2, '0');
    String minuteText = minutes.toString().padLeft(2, '0');
    String secondText = seconds.toString().padLeft(2, '0');
    if (days > 0) {
      return '$days天$hourText时$minuteText分$secondText秒';
    } else if (hours > 0) {
      return '$hourText时$minuteText分$secondText秒';
    } else if (minutes > 0) {
      return '$minuteText分$secondText秒';
    } else {
      return '$secondText秒';
    }
  }

  /// 按模板格式化日期（默认 `yyyy-MM-dd HH:mm:ss`）
  static String formatDate(dynamic value, [String format = 'yyyy-MM-dd HH:mm:ss']) {
    var dateTime = safeDate(value);
    if (format.contains('yy')) {
      String year = dateTime.year.toString();
      if (format.contains('yyyy')) {
        format = format.replaceAll('yyyy', year);
      } else {
        format = format.replaceAll('yy', year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(dateTime.month, format, 'M', 'MM');
    format = _comFormat(dateTime.day, format, 'd', 'dd');
    format = _comFormat(dateTime.hour, format, 'H', 'HH');
    format = _comFormat(dateTime.minute, format, 'm', 'mm');
    format = _comFormat(dateTime.second, format, 's', 'ss');
    format = _comFormat(dateTime.millisecond, format, 'S', 'SSS');

    return format;
  }

  static String _comFormat(int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format = format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }

  // =====================================================================================================
  // 异步工具方法
  // =====================================================================================================

  /// 创建一个串行任务队列。
  ///
  /// 队列中的任务会按调用顺序一个接一个执行，前一个未完成时，后一个会等待。
  static ElSerialTaskQueue serialQueue() => ElSerialTaskQueue();

  /// 延迟指定时间执行函数，单位：毫秒
  static Timer setTimeout(void Function() fun, int wait) {
    return Timer(Duration(milliseconds: wait), fun);
  }

  /// 每隔一段时间执行函数，单位：毫秒
  static Timer setInterval(void Function() fun, int wait) {
    return Timer.periodic(Duration(milliseconds: wait), (e) {
      fun();
    });
  }

  static final Set<Object> _throttleKeys = {};
  static final Map<Object, Timer?> _throttleTrailingKeys = {};

  /// 对目标函数进行包装，返回一个节流函数，此函数会忽略指定时间内的多次执行
  /// * wait 节流时间(毫秒)
  /// * key 指定函数标识符，如果 fun 是匿名函数，则需要指定它
  /// * trailing 当多次调用函数时，确保最后一次函数执行
  static void Function() throttle(Function fun, int wait, {Object? key, bool trailing = false}) {
    assert(wait > 0);
    key ??= fun.hashCode;
    return () {
      if (_throttleKeys.contains(key)) {
        if (trailing) {
          _throttleTrailingKeys[key]?.cancel();
          _throttleTrailingKeys[key!] = setTimeout(() {
            _throttleTrailingKeys.remove(key);
            fun();
          }, wait);
        }

        return;
      } else {
        if (trailing) _throttleTrailingKeys[key]?.cancel();
        _throttleKeys.add(key!);
        setTimeout(() {
          _throttleKeys.remove(key);
        }, wait);

        fun();
      }
    };
  }

  static final Map<Object, Timer> _debounceTimerMap = {};

  /// 对函数进行防抖处理，如果在指定时间内多次执行函数，那么会忽略掉它，并重置等待时间，当等待时间结束后再执行函数
  /// * wait 防抖时间(毫秒)
  /// * key 指定函数标识符，如果 fun 是匿名函数，则需要指定它
  static void Function() debounce(Function fun, int wait, {Object? key}) {
    assert(wait > 0);
    key ??= fun.hashCode;
    return () {
      if (_debounceTimerMap.containsKey(key)) {
        _debounceTimerMap[key!]!.cancel();
        _debounceTimerMap.remove(key);
      }
      _debounceTimerMap[key!] = setTimeout(() {
        fun();
        _debounceTimerMap.remove(key);
      }, wait);
    };
  }

  static final Map<Object, Future> _shareTaskQueue = {};

  /// 运行共享结果任务，当同时运行多个异步任务时，确保只处理一个任务、并排除其他任务，
  /// 当第一个任务运行结束时，其他任务会得到第一个任务的结果
  static Future<T> runShareTask<T>(Object id, Future<T> Function() task) {
    if (_shareTaskQueue.containsKey(id)) {
      return _shareTaskQueue[id]! as Future<T>;
    }

    Completer<T>? completer = Completer<T>();
    _shareTaskQueue[id] = completer.future;

    task()
        .then((result) => completer!.complete(result))
        .catchError((error) => completer!.completeError(error))
        .whenComplete(() {
          _shareTaskQueue.remove(id);
          completer = null;
        });

    return _shareTaskQueue[id] as Future<T>;
  }

  // =====================================================================================================
  // 加密工具方法
  // =====================================================================================================

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

  // =====================================================================================================
  // 日志工具方法
  // =====================================================================================================

  static void printLog(dynamic message, {int level = ElLogConfig.info, dynamic title, ElLogConfig? config}) {
    if (ElLogConfig.filterFun(level)) {
      config = ElLogConfig.defaultConfig.merge(config);
      config.formatAndPrint(level, message, title: title);
    }
  }

  /// 输出最低级别日志
  static void d(dynamic message, {dynamic title, ElLogConfig? config}) {
    printLog(message, level: ElLogConfig.debug, title: title, config: config);
  }

  /// 输出普通级别日志
  static void i(dynamic message, {dynamic title, ElLogConfig? config}) {
    printLog(message, level: ElLogConfig.info, title: title, config: config);
  }

  /// 输出成功类型日志
  static void s(dynamic message, {dynamic title, ElLogConfig? config}) {
    printLog(message, level: ElLogConfig.success, title: title, config: config);
  }

  /// 输出警告类型日志
  static void w(dynamic message, {dynamic title, ElLogConfig? config}) {
    printLog(message, level: ElLogConfig.warning, title: title, config: config);
  }

  /// 输出错误类型日志
  static void e(dynamic message, {dynamic title, ElLogConfig? config}) {
    printLog(message, level: ElLogConfig.error, title: title, config: config);
  }
}

/// 比较两个值的条件类型（用于 [El.compareNum]、[El.compareDate] 等）
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

/// 串行任务队列
class ElSerialTaskQueue {
  Future<void> _tail = Future.value();

  /// 将任务加入队列，并按顺序串行执行。
  ///
  /// 无论前一个任务成功还是失败，后续任务都仍然可以继续排队执行。
  Future<T> run<T>(FutureOr<T> Function() task) {
    final next = _tail.then((_) => Future.sync(task));
    _tail = next.then((_) {}, onError: (_) {});
    return next;
  }
}

typedef ElLogFunction = void Function(dynamic message, {dynamic title, ElLogConfig? config});
