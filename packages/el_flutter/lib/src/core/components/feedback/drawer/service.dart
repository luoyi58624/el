part of 'index.dart';

class ElDrawerService {
  static ElDrawerService? _instance;

  ElDrawerService._();

  factory ElDrawerService() {
    _instance ??= ElDrawerService._();
    return _instance!;
  }

  /// 通过路由打开抽屉，适用于无需保持状态的弹窗
  Future<T?> show<T>({
    required WidgetBuilder builder,
    AxisDirection direction = AxisDirection.left,
    double? maxPrimarySize,
    bool enabledDrag = true,
    Color modalColor = Colors.black54,
    bool ignoreModalPointer = false,
    bool enabledFade = false,
  }) async {
    final route = _ElDrawerRoute<T>(
      direction: direction,
      drawerMaxSize: _calcDrawerMaxSize(
        size: maxPrimarySize,
        overlaySize: el.overlay.context.size!,
        direction: direction,
      ),
      enabledDrag: enabledDrag,
      modalColor: modalColor,
      ignoreModalPointer: ignoreModalPointer,
      enabledFade: enabledFade,
      builder: builder,
    );

    return await el.navigatorState.push<T>(route);
  }
}
