import 'dart:convert';
import 'dart:io';

import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';
import 'package:el_storage/el_storage.dart';

import '../el_http.dart';

part 'interceptor/cache.dart';

part 'interceptor/error.dart';

part 'interceptor/log.dart';

/// 对 Dio 进行一层简单包装，统一处理请求、响应拦截
class ElHttp {
  /// 默认的 http 实例
  static final instance = ElHttp();

  ElHttp() {
    dio = Dio(options);
    dio.interceptors.addAll(interceptors);
  }

  /// Dio 请求实例对象
  late final Dio dio;

  /// 创建初始配置
  @protected
  BaseOptions get options => BaseOptions(
    connectTimeout: Duration(seconds: El.kReleaseMode ? 30 : 5), // 连接超时
    receiveTimeout: Duration(seconds: El.kReleaseMode ? 30 : 5), // 响应超时
  );

  /// 绑定拦截器
  @protected
  List<Interceptor> get interceptors {
    return [RetryInterceptor(dio: dio, logPrint: ElLog.i), ElLogInterceptor(), ElErrorInterceptor()];
  }

  /// 统一处理请求配置
  @protected
  Options handlerReq(String method, Options? options, ElRequestExtra? extra) {
    options ??= Options();

    // 设置请求额外携带数据
    options.extra = {
      ...const ElRequestExtra(printReqLog: false, printResLog: true, printExceptionLog: true).toJson(),
      if (extra != null) ...extra.toJson(),
      if (options.extra != null) ...options.extra!,
    };

    return options;
  }

  /// get 请求
  /// * url 请求地址
  /// * data json数据
  /// * queryParameters 地址拼接的参数
  /// * options 自定义请求配置
  /// * cancelToken 取消请求 token
  /// * onReceiveProgress 监听请求进度
  /// * extra 请求额外配置选项（更多配置可直接在 options 中指定）
  Future<Response<T>> get<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    ElRequestExtra? extra,
  }) async {
    return await dio.get(
      url,
      data: data,
      queryParameters: queryParameters,
      options: handlerReq('GET', options, extra),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// post 请求
  /// * url 请求地址
  /// * data json数据
  /// * queryParameters 地址拼接的参数
  /// * options 自定义请求配置
  /// * cancelToken 取消请求 token
  /// * onSendProgress 监听上传进度
  /// * onReceiveProgress 监听请求进度
  /// * extra 请求额外配置选项（更多配置可直接在 options 中指定）
  Future<Response<T>> post<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ElRequestExtra? extra,
  }) async {
    return await dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: handlerReq('POST', options, extra),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// put 请求
  /// * url 请求地址
  /// * data json数据
  /// * queryParameters 地址拼接的参数
  /// * options 自定义请求配置
  /// * cancelToken 取消请求 token
  /// * onSendProgress 监听上传进度
  /// * onReceiveProgress 监听请求进度
  /// * extra 请求额外配置选项（更多配置可直接在 options 中指定）
  Future<Response<T>> put<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ElRequestExtra? extra,
  }) async {
    return await dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: handlerReq('PUT', options, extra),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// patch 请求
  /// * url 请求地址
  /// * data json数据
  /// * queryParameters 地址拼接的参数
  /// * options 自定义请求配置
  /// * cancelToken 取消请求 token
  /// * onSendProgress 监听上传进度
  /// * onReceiveProgress 监听请求进度
  /// * extra 请求额外配置选项（更多配置可直接在 options 中指定）
  Future<Response<T>> patch<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ElRequestExtra? extra,
  }) async {
    return await dio.patch(
      url,
      data: data,
      queryParameters: queryParameters,
      options: handlerReq('PATCH', options, extra),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// delete 请求
  /// * url 请求地址
  /// * data json数据
  /// * queryParameters 地址拼接的参数
  /// * options 自定义请求配置
  /// * cancelToken 取消请求 token
  /// * extra 请求额外配置选项（更多配置可直接在 options 中指定）
  Future<Response<T>> delete<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ElRequestExtra? extra,
  }) async {
    return await dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: handlerReq('DELETE', options, extra),
      cancelToken: cancelToken,
    );
  }
}
