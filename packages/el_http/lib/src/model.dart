import 'package:el_dart/el_dart.dart';

/// 默认的 Http 响应模型
class ElHttpModel implements ElSerializeModel, EquatableMixin {
  static ElHttpModel instance = ElHttpModel(code: 200, message: '');

  ElHttpModel({required this.code, required this.message, this.data});

  final int code;
  final String message;
  final dynamic data;

  factory ElHttpModel.fromJson(Map<String, dynamic>? json) {
    return ElHttpModel(
      code: ElJsonUtil.$int(json, 'code') ?? 0,
      message: ElJsonUtil.$string(json, 'message') ?? '',
      data: json?['data'],
    );
  }

  @override
  fromJson(Map<String, dynamic>? json) => ElHttpModel.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {'code': code, 'message': message, 'data': data};

  @override
  List<Object?> get props => [code, message, data];

  @override
  bool? get stringify => true;
}

/// 请求携带的配置数据
class ElRequestExtra implements ElSerializeModel {
  const ElRequestExtra({this.printReqLog, this.printResLog, this.printExceptionLog});

  /// 打印请求日志
  final bool? printReqLog;

  /// 打印响应日志
  final bool? printResLog;

  /// 打印异常日志
  final bool? printExceptionLog;

  factory ElRequestExtra.fromJson(Map<String, dynamic>? json) => ElRequestExtra(
    printReqLog: json?['printReqLog'],
    printResLog: json?['printResLog'],
    printExceptionLog: json?['printExceptionLog'],
  );

  @override
  ElRequestExtra fromJson(Map<String, dynamic>? json) => ElRequestExtra.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    if (printReqLog != null) 'printReqLog': printReqLog,
    if (printResLog != null) 'printResLog': printResLog,
    if (printExceptionLog != null) 'printExceptionLog': printExceptionLog,
  };

  @override
  String toString() => toJson().toString();
}
