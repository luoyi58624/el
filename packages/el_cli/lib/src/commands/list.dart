import 'dart:io';

import 'package:args/command_runner.dart';

class ListCommand extends Command {
  @override
  final name = 'list';

  @override
  final description = 'List the global packages';

  @override
  Future<void> run() async {
    // 获取全局包目录
    final pubCachePath = _getPubCachePath();
    final globalBinPath = Platform.isWindows ? '$pubCachePath\\bin' : '$pubCachePath/bin';

    final result = await Process.run('dart', ['pub', 'global', 'list']);

    // 输出目录信息
    print('📁 Global packages directory:');
    print('   $globalBinPath');
    print('─' * 60);

    if (result.stdout.toString().isNotEmpty) {
      print(result.stdout);
    } else {
      print('No global packages installed');
    }

    // 检查 PATH
    _checkPath(globalBinPath);
  }

  String _getPubCachePath() {
    if (Platform.environment.containsKey('PUB_CACHE')) {
      return Platform.environment['PUB_CACHE']!;
    }

    if (Platform.isWindows) {
      return '${Platform.environment['APPDATA']}\\Pub\\Cache';
    }

    return '${Platform.environment['HOME']}/.pub-cache';
  }

  void _checkPath(String globalBinPath) {
    final pathEnv = Platform.environment['PATH'] ?? '';

    if (!pathEnv.contains(globalBinPath)) {
      print('\n⚠️  PATH warning:');
      print('   Global bin directory is not in PATH');
      print('   You can add it with:');

      if (Platform.isWindows) {
        print('   setx PATH "%PATH%;$globalBinPath"');
      } else {
        print('   echo \'export PATH="\\\$PATH:$globalBinPath"\' >> ~/.bashrc');
        print('   echo \'   source ~/.bashrc\'');
      }
    }
  }
}
