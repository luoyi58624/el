part of '../index.dart';

const _config = ElLogConfig(methodCount: 0);

/// 日志拦截器
class ElLogInterceptor extends Interceptor {
  ElLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final extra = ElRequestExtra.fromJson(options.extra);
    if (extra.printReqLog == true) {
      ElLog.i(
        {'Headers': options.headers, "Data": options.data ?? {}},
        title: '[${options.method}] Req: ${options.uri}',
        config: _config,
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final extra = ElRequestExtra.fromJson(options.extra);
    if (extra.printResLog == true) {
      ElLog.s(response.data, title: '[${options.method}] Res: ${options.uri}', config: _config);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = ElRequestExtra.fromJson(err.requestOptions.extra);
    if (extra.printExceptionLog == true) {
      ElLog.e(err, title: '请求异常：${err.requestOptions.uri}', config: _config);
    }

    super.onError(err, handler);
  }
}
