part of 'index.dart';

/// 日期选择器的 modelValue 支持以下类型：
/// 1. [String] - 日期字符串，通用性强，支持直接解析 [DateTime]、[TimeOfDay]
/// 2. [int] - 日期时间戳（毫秒），如果绑定此类型数据你不能设置 [onlyTime]
/// 3. [DateTime] - 日期对象，如果绑定此类型数据你不能设置 [onlyTime]
class ElDateRangePicker extends ElModelValue {
  /// Element UI 日期范围选择器
  const ElDateRangePicker(
    super.modelValue, {
    super.key,
    required this.child,
    this.firstDate,
    this.lastDate,
    this.onlyDate,
    this.onlyTime,
    this.primaryColor,
    this.format,
    super.onChanged,
  }) : assert(
         (onlyDate != true && onlyTime != true) ||
             (onlyDate == true && onlyTime != true) ||
             onlyDate != true && onlyTime == true,
         'onlyDate 与 onlyTime 不能同时设置 true',
       );

  final Widget child;

  /// 限制起始时间，可以是数字
  final dynamic firstDate;

  /// 限制结束时间
  final dynamic lastDate;

  /// 仅显示日期选择器
  final bool? onlyDate;

  /// 仅显示时间选择器
  final bool? onlyTime;

  /// 颜色选择器主题色
  final Color? primaryColor;

  /// 日期字符串格式化，默认的完整格式为 yyyy-MM-dd HH:mm:ss
  final String? format;

  static ElDateRangePickerState of(BuildContext context) => _ElDateRangePickerInheritedWidget.of(context);

  @override
  State<ElDateRangePicker> createState() => ElDateRangePickerState();
}

class ElDateRangePickerState extends State<ElDateRangePicker> with ElModelValueMixin {
  late ElDatePickerThemeData _themeData;

  ElDatePickerThemeData get themeData => _themeData;

  /// 构建主题数据
  ElDatePickerThemeData buildThemeData(BuildContext context) {
    return ElDatePickerTheme.of(context).copyWith(primaryColor: widget.primaryColor, format: widget.format);
  }

  /// 显示选择器
  Future<void> showPicker() async {
    if (widget.onlyDate != true && widget.onlyTime != true) {
      DateTime? result = await showDatePicker();
      if (result == null) return;

      result = DateTime(result.year, result.month, result.day);

      final time = await showTimePicker();
      if (time == null) return;

      result = result.copyWith(hour: time.hour, minute: time.minute);

      if (modelValue is String) {
        modelValue = ElDateUtil.formatDate(result, themeData.format ?? 'yyyy-MM-dd HH:mm:ss');
      } else if (modelValue is int) {
        modelValue == result.millisecondsSinceEpoch;
      } else if (modelValue is DateTime) {
        modelValue = result;
      } else {
        throw 'ElDatePicker 绑定的 modelValue 不能是 TimeOfDay 类型，如果你非要指定为 TimeOfDay 类型，那么请将 onlyTime 设置为 true';
      }
    } else {
      if (widget.onlyDate == true) {
        final v = await showDatePicker();
        if (v != null) {
          final result = v.copyWith(year: v.year, month: v.month, day: v.day);
          if (modelValue is String) {
            modelValue = ElDateUtil.formatDate(result, themeData.format ?? 'yyyy-MM-dd');
          } else if (modelValue is int) {
            modelValue == result.millisecondsSinceEpoch;
          } else if (modelValue is DateTime) {
            modelValue = result;
          } else {
            throw 'ElDatePicker 设置了 onlyDate 属性，绑定的 modelValue 不能是 TimeOfDay 类型，因为日期选择器无法获取当天时间';
          }
        }
      } else if (widget.onlyTime == true) {
        final v = await showTimePicker();
        if (v != null) {
          if (modelValue is String) {
            modelValue = ElDateUtil.formatDate(
              DateTime.now().copyWith(hour: v.hour, minute: v.minute),
              themeData.format ?? 'HH:mm',
            );
          } else if (modelValue is m.TimeOfDay) {
            modelValue == v;
          } else {
            throw 'ElDatePicker 设置了 onlyTime 属性，绑定的 modelValue 只能是 String、TimeOfDay 类型';
          }
        }
      }
    }
  }

  /// 显示日期选择器
  Future<DateTime?> showDatePicker() async {
    return await m.showDatePicker(
      context: context,
      initialDate: ElDateUtil.safeDate(modelValue),
      firstDate: ElDateUtil.safeDate(widget.firstDate, DateTime(1970)),
      lastDate: ElDateUtil.safeDate(widget.lastDate, DateTime(2050)),
      builder: (context, child) => buildPickerThemeWidget(context, child!),
    );
  }

  /// 显示时间选择器
  Future<m.TimeOfDay?> showTimePicker() async {
    late m.TimeOfDay time;
    try {
      if (modelValue is String) {
        if (ElDartUtil.isEmpty(modelValue)) {
          time = m.TimeOfDay.now();
        } else if ((modelValue as String).length <= 5) {
          // 将非数字字符作为分隔符，得到 hour、minute 数组
          final result = (modelValue as String).split(RegExp(r'\D'));
          time = m.TimeOfDay(hour: int.parse(result[0]), minute: int.parse(result[1]));
        } else {
          time = m.TimeOfDay.fromDateTime(DateTime.parse(modelValue));
        }
      } else if (modelValue is int) {
        time = m.TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(modelValue));
      } else if (modelValue is DateTime) {
        time = m.TimeOfDay.fromDateTime(modelValue);
      } else if (modelValue is m.TimeOfDay) {
        time = modelValue;
      } else {
        throw '';
      }
    } catch (e) {
      assert(false, 'showTimePicker 方法解析 TimeOfDay 失败，当前 modelValue 值为：$modelValue');
    }

    return await m.showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) => buildPickerThemeWidget(context, child!),
    );
  }

  /// 构建选择器主题小部件
  Widget buildPickerThemeWidget(BuildContext context, Widget child) {
    final materialThemeData = m.Theme.of(context);
    return m.Theme(
      data: m.ThemeData(
        // 我不喜欢 material3 风格的日期选择器
        useMaterial3: false,
        brightness: materialThemeData.brightness,
        primarySwatch: (themeData.primaryColor ?? context.elTheme.primary).toMaterialColor(),
        visualDensity: materialThemeData.visualDensity,
        textTheme: materialThemeData.textTheme,
        textButtonTheme: materialThemeData.textButtonTheme,
        datePickerTheme: materialThemeData.datePickerTheme,
        timePickerTheme: materialThemeData.timePickerTheme,
      ),
      child: child,
    );
  }

  @override
  Widget obsBuilder(BuildContext context) {
    _themeData = buildThemeData(context);
    return ElEvent(
      style: ElEventStyle(onTap: (e) => showPicker()),
      child: _ElDateRangePickerInheritedWidget(this, child: widget.child),
    );
  }
}

class _ElDateRangePickerInheritedWidget extends InheritedWidget {
  const _ElDateRangePickerInheritedWidget(this.state, {required super.child});

  final ElDateRangePickerState state;

  static ElDateRangePickerState of(BuildContext context) {
    final _ElDateRangePickerInheritedWidget? result = context
        .dependOnInheritedWidgetOfExactType<_ElDateRangePickerInheritedWidget>();
    assert(result != null, 'No _ElDateRangePickerInheritedWidget found in context');
    return result!.state;
  }

  @override
  bool updateShouldNotify(_ElDateRangePickerInheritedWidget oldWidget) {
    return true;
  }
}
