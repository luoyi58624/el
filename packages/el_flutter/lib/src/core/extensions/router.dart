import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ElRouterServiceExt on El {
  static final _instance = ElRouterService();

  /// 路由服务，无需 context 进行导航，代价是只能通过顶级 [Navigator] 推送路由，
  /// 对于嵌套导航，请不要使用此 api 进行路由控制
  ElRouterService get router => _instance;
}

class ElRouterService {
  /// 推送一个路由
  Future<T?> push<T>(Route<T> route) async {
    var state = el.navigatorState;
    return state.push<T>(route);
  }

  /// 弹出一个路由
  void pop<T>([T? result]) {
    var state = el.navigatorState;
    if (state.canPop()) state.pop<T>(result);
  }

  /// 弹出所有路由
  void popAll() {
    var state = el.navigatorState;
    while (state.canPop()) {
      state.pop();
    }
  }

  /// 是否还能弹出（栈上是否还有可 pop 的路由）
  bool canPop() => el.navigatorState.canPop();

  /// 尝试弹出当前路由；若当前路由为 [Route.willHandlePopInternally] 等导致无法直接 pop，则返回 false
  Future<bool> maybePop<T>([T? result]) => el.navigatorState.maybePop<T>(result);

  /// 连续弹出直到 [predicate] 对某一剩余路由返回 true（该路由本身不会被弹出）
  void popUntil(RoutePredicate predicate) {
    el.navigatorState.popUntil(predicate);
  }

  /// 用新路由替换当前栈顶路由
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(Route<T> newRoute, {TO? result}) {
    return el.navigatorState.pushReplacement<T, TO>(newRoute, result: result);
  }

  /// 推送新路由并移除栈中直到 [predicate] 为 true 的路由之上的所有路由
  Future<T?> pushAndRemoveUntil<T extends Object?>(Route<T> newRoute, RoutePredicate predicate) {
    return el.navigatorState.pushAndRemoveUntil<T>(newRoute, predicate);
  }

  /// 从栈中移除指定路由（不会触发该路由的 completer，除非该路由是当前路由）
  void removeRoute(Route<dynamic> route) {
    el.navigatorState.removeRoute(route);
  }

  /// 用 [newRoute] 替换栈中的 [oldRoute]
  void replace<T extends Object?>({required Route<dynamic> oldRoute, required Route<T> newRoute}) {
    el.navigatorState.replace<T>(oldRoute: oldRoute, newRoute: newRoute);
  }

  /// 推送一个页面，如果使用 CupertinoApp，则使用 [CupertinoPageRoute] 路由推送页面，
  /// 否则使用 [MaterialPageRoute] 路由推送页面
  Future<T?> pushPage<T>(
    Widget page, {
    String? title,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
  }) async {
    final route = _pageRoute<T>(
      page,
      title: title,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      barrierDismissible: barrierDismissible,
    );
    var state = el.navigatorState;
    return state.push<T>(route);
  }

  /// 用新页面替换当前栈顶页面，路由类型选择与 [pushPage] 一致
  Future<T?> pushReplacementPage<T extends Object?, TO extends Object?>(
    Widget page, {
    String? title,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
    TO? result,
  }) {
    final route = _pageRoute<T>(
      page,
      title: title,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      barrierDismissible: barrierDismissible,
    );
    return el.navigatorState.pushReplacement<T, TO>(route, result: result);
  }

  /// 推送新页面并移除栈中直到 [predicate] 为 true 的路由之上的所有路由，路由类型选择与 [pushPage] 一致
  Future<T?> pushPageAndRemoveUntil<T extends Object?>(
    Widget page,
    RoutePredicate predicate, {
    String? title,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
  }) {
    final route = _pageRoute<T>(
      page,
      title: title,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      barrierDismissible: barrierDismissible,
    );
    return el.navigatorState.pushAndRemoveUntil<T>(route, predicate);
  }

  PageRoute<T> _pageRoute<T extends Object?>(
    Widget page, {
    String? title,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
  }) {
    var hasCupertinoApp = ElFlutterUtil.hasAncestorWidget<CupertinoApp>(el.context);
    if (hasCupertinoApp) {
      return CupertinoPageRoute<T>(
        builder: (context) => page,
        title: title,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        allowSnapshotting: allowSnapshotting,
        barrierDismissible: barrierDismissible,
      );
    }
    return MaterialPageRoute<T>(
      builder: (context) => page,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      barrierDismissible: barrierDismissible,
    );
  }
}
