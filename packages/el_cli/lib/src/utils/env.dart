import 'dart:io';
import 'package:path/path.dart' as path;

/// CLI 执行环境检测工具
class CLIEnvDetector {
  CLIEnvDetector._();

  /// 是否通过 pub global 运行
  static bool get isGlobalActivated {
    final script = Platform.script;
    if (script.scheme == 'data') return true;

    final scriptPath = script.toFilePath();
    final pubCachePath = _pubCachePath;
    if (scriptPath.contains(pubCachePath)) return true;
    if (scriptPath.contains('global_packages')) return true;

    return false;
  }

  /// 是否直接从源码运行
  static bool get isRunningFromSource {
    final executable = Platform.executable;
    final script = Platform.script;
    return executable.contains('dart') && script.scheme == 'file' && script.path.endsWith('.dart');
  }

  /// 是否编译为可执行文件
  static bool get isCompiledExecutable {
    final executable = Platform.executable;
    final script = Platform.script;
    return script.scheme == 'data' && !executable.contains('dart');
  }

  /// 获取当前执行模式
  static String get currentMode {
    if (isGlobalActivated) return 'global';
    if (isRunningFromSource) return 'source';
    if (isCompiledExecutable) return 'compiled';
    return 'unknown';
  }

  /// 是否为 JIT 模式
  static bool get isJIT {
    return !const bool.fromEnvironment('dart.vm.product') && !const bool.fromEnvironment('dart.vm.profile');
  }

  /// 是否为 AOT 模式
  static bool get isAOT {
    return const bool.fromEnvironment('dart.vm.product') || const bool.fromEnvironment('dart.vm.profile');
  }

  /// 获取编译模式
  static String get buildMode {
    if (const bool.fromEnvironment('dart.vm.product')) return 'release';
    if (const bool.fromEnvironment('dart.vm.profile')) return 'profile';
    return 'debug';
  }

  /// 获取 Pub 缓存路径
  static String get _pubCachePath {
    if (Platform.environment.containsKey('PUB_CACHE')) {
      return Platform.environment['PUB_CACHE']!;
    }

    if (Platform.isWindows) {
      return path.join(Platform.environment['APPDATA']!, 'Pub', 'Cache');
    }

    return path.join(Platform.environment['HOME']!, '.pub-cache');
  }

  /// 获取配置目录
  static String get configDirectory {
    String configDir;

    if (Platform.isWindows) {
      configDir = path.join(Platform.environment['APPDATA']!, 'my_cli');
    } else if (Platform.isMacOS) {
      configDir = path.join(Platform.environment['HOME']!, 'Library', 'Application Support', 'my_cli');
    } else {
      configDir = path.join(Platform.environment['HOME']!, '.config', 'my_cli');
    }

    Directory(configDir).createSync(recursive: true);
    return configDir;
  }

  /// 获取缓存目录
  static String get cacheDirectory {
    final cacheDir = path.join(configDirectory, 'cache');
    Directory(cacheDir).createSync(recursive: true);
    return cacheDir;
  }

  /// 获取包根目录
  static String get packageRoot {
    final script = Platform.script;

    if (script.scheme == 'file') {
      var dir = File(script.toFilePath()).parent;
      while (dir.existsSync()) {
        final pubspec = File(path.join(dir.path, 'pubspec.yaml'));
        if (pubspec.existsSync()) {
          return dir.path;
        }
        dir = dir.parent;
      }
    }

    return configDirectory;
  }
}
