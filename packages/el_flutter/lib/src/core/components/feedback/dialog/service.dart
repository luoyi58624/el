part of 'index.dart';

extension ElDialogServiceExt on El {
  static final _instance = ElDialogService();

  /// 弹窗服务，它是基于 [Navigator] 推送弹窗
  ElDialogService get dialog => _instance;
}

class ElDialogService {
  /// 通过路由 Api 打开对话框
  Future<T?> show<T>({
    required WidgetBuilder builder,
    double? size,
    Color modalColor = Colors.black54,
    bool ignoreModalPointer = false,
  }) async {
    return await el.navigatorState.push<T>(
      _ElDialogRoute<T>(modalColor: modalColor, ignoreModalPointer: ignoreModalPointer, builder: builder),
    );
  }

  void close<T>([T? result]) {
    el.navigatorState.pop(result);
  }
}
