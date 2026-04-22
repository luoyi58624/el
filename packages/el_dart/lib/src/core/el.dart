/// Element 全局单例服务对象
const el = El._();

class El {
  const El._();

  static const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
  static const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
  static const bool kDebugMode = !kReleaseMode && !kProfileMode;
  static const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop');
}
