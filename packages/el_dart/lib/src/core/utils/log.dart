import 'dart:convert';
import 'dart:math';

import 'package:el_dart/el_dart.dart';
import 'package:logger/logger.dart';

const _excludePaths = ['package:el_dart/src/core/utils/log.dart'];

typedef ElLogFunction = void Function(dynamic message, {dynamic title, ElLogConfig? config});

/// 日志工具类
class ElLog {
  ElLog._();

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

/// 日志配置对象
class ElLogConfig {
  // 日志级别静态常量，之所以不使用 logger 提供的 enum，是因为它不提供 success 状态
  static const all = 0;
  static const debug = 1000;
  static const info = 2000;
  static const success = 2001;
  static const warning = 3000;
  static const error = 4000;

  /// 默认日志配置对象
  static ElLogConfig defaultConfig = const ElLogConfig(
    methodCount: El.kIsWeb ? null : 2,
    lineLength: El.kIsWeb ? null : 120,
    printTitle: !El.kIsWeb,
    autoWrap: true,
    excludePaths: _excludePaths,
    levelColors: defaultLevelColors,
  );

  /// 日志过滤函数
  static bool Function(int level) filterFun = (int level) {
    if (El.kReleaseMode) {
      return level >= warning;
    } else {
      return true;
    }
  };

  const ElLogConfig({
    this.methodCount,
    this.lineLength,
    this.printTitle,
    this.color,
    this.autoWrap,
    this.excludePaths,
    this.levelColors,
  });

  /// 限制方法执行的堆栈数量
  final int? methodCount;

  /// 日志分隔线长度，如果长度为 0，则不绘制任何线条
  final int? lineLength;

  /// 是否打印标题
  final bool? printTitle;

  /// 自定义日志终端颜色
  final AnsiColor? color;

  /// 打印可迭代集合对象时是否自动换行
  final bool? autoWrap;

  /// 排除输出堆栈方法的路径
  final List<String>? excludePaths;

  /// 不同级别日志对应的颜色集合
  final Map<int, AnsiColor>? levelColors;

  static const defaultLevelColors = {
    debug: AnsiColor.none(),
    info: AnsiColor.fg(12),
    success: AnsiColor.fg(34),
    warning: AnsiColor.fg(208),
    error: AnsiColor.fg(196),
  };

  /// 克隆新的日志配置
  ElLogConfig copyWith({
    int? methodCount,
    int? lineLength,
    bool? printTitle,
    AnsiColor? color,
    bool? autoWrap,
    List<String>? excludePaths,
    Map<int, AnsiColor>? levelColors,
  }) {
    return ElLogConfig(
      methodCount: methodCount ?? this.methodCount,
      lineLength: lineLength ?? this.lineLength,
      printTitle: printTitle ?? this.printTitle,
      color: color ?? this.color,
      autoWrap: autoWrap ?? this.autoWrap,
      excludePaths: excludePaths == null ? this.excludePaths : [...this.excludePaths!, ...excludePaths],
      levelColors: levelColors == null ? this.levelColors : {...this.levelColors ?? {}, ...levelColors},
    );
  }

  /// 合并新的日志配置
  ElLogConfig merge([ElLogConfig? other]) {
    if (other == null) return this;
    return copyWith(
      methodCount: other.methodCount,
      lineLength: other.lineLength,
      printTitle: other.printTitle,
      color: other.color,
      autoWrap: other.autoWrap,
      excludePaths: other.excludePaths,
    );
  }

  String get topBorder {
    assert(lineLength != null && lineLength! > 0);
    return '${PrettyPrinter.topLeftCorner}${PrettyPrinter.doubleDivider * lineLength!}';
  }

  String get middleBorder {
    assert(lineLength != null && lineLength! > 0);
    return '${PrettyPrinter.middleCorner}${PrettyPrinter.singleDivider * lineLength!}';
  }

  String get bottomBorder {
    assert(lineLength != null && lineLength! > 0);
    return '${PrettyPrinter.bottomLeftCorner}${PrettyPrinter.doubleDivider * lineLength!}';
  }

  String get verticalLineAtLevel {
    return '${PrettyPrinter.verticalLine} ';
  }

  /// 以当前配置对象格式化打印日志
  void formatAndPrint(int level, dynamic message, {dynamic title}) {
    List<String> buffer = [];
    final stacktrace = formatStackTrace();
    final color = this.color ?? levelColors?[level] ?? const AnsiColor.none();

    if (lineLength == null || lineLength! <= 0) {
      void addBuffer(String content) {
        for (var line in content.split('\n')) {
          buffer.add(color(line));
        }
      }

      if (printTitle == true && title != null) addBuffer(title.toString());
      if (stacktrace != null) addBuffer(stacktrace);
      addBuffer(stringifyMessage(message));
    } else {
      final verticalLineAtLevel = this.verticalLineAtLevel;

      void addBuffer(String content) {
        for (var line in content.split('\n')) {
          buffer.add(color('$verticalLineAtLevel$line'));
        }
      }

      buffer.add(color(topBorder));

      if (printTitle == true && title != null) {
        addBuffer(title.toString());
        buffer.add(color(middleBorder));
      }

      if (stacktrace != null) {
        addBuffer(stacktrace);
        buffer.add(color(middleBorder));
      }

      addBuffer(stringifyMessage(message));
      buffer.add(color(bottomBorder));
    }

    buffer.forEach(print);
  }

  /// 格式化消息内容
  String stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      late JsonEncoder encoder;

      if (autoWrap == true) {
        encoder = JsonEncoder.withIndent('  ', toEncodableFallback);
      } else {
        encoder = JsonEncoder(toEncodableFallback);
      }

      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  Object toEncodableFallback(dynamic object) {
    return object.toString();
  }

  /// 格式化方法执行堆栈
  String? formatStackTrace() {
    if (methodCount == null || methodCount! <= 0) return null;

    List<String> formatted = [];
    List<String> lines = StackTrace.current
        .toString()
        .split('\n')
        .where(
          (line) =>
              !_discardDeviceStacktraceLine(line) &&
              !_discardWebStacktraceLine(line) &&
              !_discardBrowserStacktraceLine(line) &&
              line.isNotEmpty,
        )
        .toList();

    int stackTraceLength = min(lines.length, methodCount!);
    for (int count = 0; count < stackTraceLength; count++) {
      var line = lines[count];
      formatted.add('#$count   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}');
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  static final _deviceStackTraceRegex = RegExp(r'#[0-9]+\s+(.+) \((\S+)\)');
  static final _webStackTraceRegex = RegExp(r'^((packages|dart-sdk)/\S+/)');
  static final _browserStackTraceRegex = RegExp(r'^(?:package:)?(dart:\S+|\S+)');

  bool _isInExcludePaths(String segment) {
    if (excludePaths == null || excludePaths!.isEmpty) return true;

    for (var element in excludePaths!) {
      if (segment.startsWith(element)) {
        return true;
      }
    }

    return false;
  }

  bool _discardDeviceStacktraceLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(2)!;
    if (segment.startsWith('package:logger')) {
      return true;
    }
    return _isInExcludePaths(segment);
  }

  bool _discardWebStacktraceLine(String line) {
    var match = _webStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(1)!;
    if (segment.startsWith('packages/logger') || segment.startsWith('dart-sdk/lib')) {
      return true;
    }
    return _isInExcludePaths(segment);
  }

  bool _discardBrowserStacktraceLine(String line) {
    var match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    final segment = match.group(1)!;
    if (segment.startsWith('package:logger') || segment.startsWith('dart:')) {
      return true;
    }
    return _isInExcludePaths(segment);
  }

  @override
  String toString() {
    return 'ElLogConfig{methodCount: $methodCount, lineLength: $lineLength, printTitle: $printTitle, color: $color, autoWrap: $autoWrap, excludePaths: $excludePaths, levelColors: $levelColors}';
  }
}
