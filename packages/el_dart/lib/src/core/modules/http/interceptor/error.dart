part of '../index.dart';

/// 默认错误文案映射
String _defaultElErrorMessageMapper(DioException err) {
  switch (err.type) {
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionTimeout:
      return '服务器连接超时，请稍后重试！';
    case DioExceptionType.receiveTimeout:
      return '服务器响应超时，请稍后重试！';
    case DioExceptionType.badResponse:
      if (err.message != null && err.message!.contains('404')) {
        return '请求接口404';
      }
      return '无效请求';
    case DioExceptionType.connectionError:
      return '服务器连接错误';
    case DioExceptionType.badCertificate:
      return '服务证书错误';
    case DioExceptionType.cancel:
      return '';
    case DioExceptionType.unknown:
      if (err.error is SocketException) {
        return '网络连接错误，请检查网络连接！';
      }
      return '网络连接出现未知错误！';
  }
}

/// 错误拦截器，通常情况下此拦截器应当放在最后
class ElErrorInterceptor extends Interceptor {
  ElErrorInterceptor({this.messageMapper = _defaultElErrorMessageMapper});

  /// 自定义错误文案映射（建议用于业务侧国际化/自定义提示）
  final String? Function(DioException err) messageMapper;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final errorMsg = (messageMapper(err) ?? '').trim();
    if (err.requestOptions.extra['errorMessageFun'] != null) {
      if (errorMsg.isNotEmpty) err.requestOptions.extra['errorMessageFun'](errorMsg);
    }
    handler.reject(err);
  }
}
