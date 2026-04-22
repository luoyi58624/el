import 'package:el_flutter/ext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

ElStorage? _localStorage;

/// 默认的本地存储对象
ElStorage get localStorage {
  assert(_localStorage != null, '请执行 el.init() 方法');
  return _localStorage!;
}

extension ElInitExt on El {
  /// 初始化 Element 全局服务，只需在 main 方法中执行一次：
  /// ```dart
  /// void main() async {
  ///   await el.init();
  /// }
  /// ```
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    String? storagePath;
    if (kIsWeb) {
      storagePath = null;
    } else {
      storagePath = p.join((await getApplicationSupportDirectory()).path, 'el_storage');
    }
    ElStorage.init(storagePath: storagePath);
    _localStorage = ElStorage.createStorage('local_storage');
  }
}

// 提示：Element 主题不使用 InheritedWidget 注入数据，而是直接使用静态全局对象，
// 你可以直接通过 el.theme 修改主题数据，若要动态更新 UI 可以调用 ElFlutterUtil.refreshApp 方法。
extension ElExt on El {
  static final _navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'el_root_navigator');
  static ElThemeData _theme = const ElThemeData();
  static ElThemeData _darkTheme = const ElThemeData.dark();
  static ElConfigData _config = ElConfigData(
    fontFamilyFallback: ElPlatform.isApple
        ? ['PingFang SC', '.AppleSystemUIFont']
        : ElPlatform.isWindows
        ? ['Segoe UI', 'Noto Sans SC', '微软雅黑', 'Microsoft YaHei']
        : null,
  );
  static ({Duration duration, Curve curve})? $themeAnimation;

  /// 亮色主题
  ElThemeData get theme => _theme;

  set theme(ElThemeData v) => _theme = v;

  /// 暗色主题
  ElThemeData get darkTheme => _darkTheme;

  set darkTheme(ElThemeData v) => _darkTheme = v;

  /// 全局配置
  ElConfigData get config => _config;

  set config(ElConfigData v) => _config = v;

  /// Element 组件大多使用隐式动画小部件，由于各个组件的动画时间均不相同，所以需要一种机制来确保动画平滑过渡，
  /// 而此方法则是用于解决该问题（主要是颜色过渡）。
  ///
  /// 原理：当修改 [ElApp] 的 brightness 属性时，ElApp 会将 el.config.animationStyle 应用至 [$themeAnimation]，
  /// 由于组件已经依赖 [ElBrightness]，所以组件重建时会拿到 el.config.animationStyle 全局动画样式，
  /// 当全局动画时间结束后，ElApp 会将 [$themeAnimation] 重新设置为 null，这时组件便会取默认的动画属性。
  ///
  /// 使用：
  /// ```dart
  /// final (duration, curve) = el.globalAnimation(Duration(milliseconds: 500));
  /// AnimatedContainer(duration: duration, curve: curve);
  /// ```
  ///
  /// 提示：使用 Element 提供的隐式动画小部件无需使用此方法，因为 [ElImplicitlyAnimatedWidget] 已默认实现。
  ElGlobalAnimation globalAnimation([Duration? duration, Curve? curve]) {
    return ($themeAnimation?.duration ?? duration ?? Duration.zero, $themeAnimation?.curve ?? curve ?? Curves.linear);
  }

  /// 顶级路由导航 key，请将它附加到顶级 App 的 navigatorKey 中：
  /// ```dart
  /// MaterialApp(
  ///   navigatorKey: el.navigatorKey,
  /// );
  /// ```
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// 顶级路由所持有的 context，通过此 context 可以进行全局路由操作。
  ///
  /// 注意：Flutter 初学者可能会将全局 context 引用主题等资源，这是错误的用法，因为当主题发生变化时，
  /// 它通知的将会是顶级 [NavigatorState] 对象，组件所持有的主题并没有建立关联，导致组件主题不会发生更新。
  BuildContext get context {
    assert(() {
      if (_navigatorKey.currentWidget == null || _navigatorKey.currentWidget is! Navigator) {
        throw FlutterError(
          'ElFlutter Error: 请在 WidgetsApp、MaterialApp、CupertinoApp 等任意顶级 App 中设置 navigatorKey: el.navigatorKey，\n'
          '若您使用声明式路由，则在声明式路由实例中设置 navigatorKey: el.navigatorKey',
        );
      }
      return true;
    }());
    return navigatorKey.currentContext!;
  }

  /// 访问顶级路由的实例对象
  NavigatorState get navigatorState {
    assert(navigatorKey.currentState != null, 'ElFlutter Error: 顶级 navigatorState 为 null，你是否忘记设置 el.navigatorKey？');
    return navigatorKey.currentState!;
  }

  /// 访问顶级路由所创建的 Overlay 实例
  OverlayState get overlay {
    assert(navigatorKey.currentState != null, 'ElFlutter Error: 顶级 overlay 为 null，你是否忘记设置 el.navigatorKey？');
    return navigatorState.overlay!;
  }

  /// 抽屉服务，它是基于 [Navigator] 推送弹窗
  ElDrawerService get drawer => ElDrawerService();
}
