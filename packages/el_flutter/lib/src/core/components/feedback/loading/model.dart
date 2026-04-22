part of 'index.dart';

/// 关闭 loading 文本描述对象
class ElLoadingCloseModel {
  static var instance = ElLoadingCloseModel(
    title: 'Close Loading',
    content: 'Are you sure you want to close it?',
    cancel: 'Cancel',
    confirm: 'Confirm',
  );

  ElLoadingCloseModel({this.title, this.content, this.cancel, this.confirm, this.cancelToken});

  final String? title;
  final String? content;
  final String? cancel;
  final String? confirm;

  /// 取消请求 token，当 loading 被关闭时，此 token 会被执行
  final CancelToken? cancelToken;

  ElLoadingCloseModel copyWith({
    String? title,
    String? content,
    String? cancel,
    String? confirm,
    CancelToken? cancelToken,
  }) {
    return ElLoadingCloseModel(
      title: title ?? this.title,
      content: content ?? this.content,
      cancel: cancel ?? this.cancel,
      confirm: confirm ?? this.confirm,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  ElLoadingCloseModel merge([ElLoadingCloseModel? other]) {
    if (other == null) return this;
    return copyWith(
      title: other.title,
      content: other.content,
      cancel: other.cancel,
      confirm: other.confirm,
      cancelToken: other.cancelToken,
    );
  }
}
