import 'util.dart';

/// 日期解析、格式化与比较
class ElDateUtil {
  ElDateUtil._();

  /// 获取当前时间的毫秒
  static int get currentMilliseconds => DateTime.now().millisecondsSinceEpoch;

  /// 获取当前时间的微秒
  static int get currentMicroseconds => DateTime.now().microsecondsSinceEpoch;

  /// 安全解析日期，支持字符串、时间戳等格式解析，如果格式不正确则返回 [defaultValue]，
  /// 若 [defaultValue] 为空，则会返回当前时间。
  static DateTime safeDate(dynamic value, [dynamic defaultValue]) {
    if (ElDartUtil.isEmpty(value)) {
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
    if (ElDartUtil.isEmpty(value)) {
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
    int nullValue1 = ElDartUtil.isEmpty(date1) ? 0 : 1;
    int nullValue2 = ElDartUtil.isEmpty(date2) ? 0 : 1;

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
}
