import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:barbecue/barbecue.dart';
import 'package:collection/collection.dart';
import 'package:el_cli/src/utils/env.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

class VersionCommand extends Command {
  @override
  final name = '-v';

  @override
  final description = 'show version';

  @override
  String get invocation => 'el -v';

  @override
  Future<void> run() async {
    late String version;
    final isDebug = CLIEnvDetector.isGlobalActivated != true;
    final scriptDir = path.dirname(Platform.script.toFilePath());
    final packageRoot = path.dirname(scriptDir);
    String pubspecPath = path.join(packageRoot, isDebug ? 'pubspec.yaml' : 'pubspec.lock');

    try {
      final pubspecFile = File(pubspecPath);
      if (pubspecFile.existsSync()) {
        final yamlString = pubspecFile.readAsStringSync();
        if (isDebug) {
          final pubspec = Pubspec.parse(yamlString);
          version = pubspec.version.toString();
        } else {
          final yaml = loadYaml(yamlString);
          version = yaml?['packages']?['el_cli']?['version'];
        }
      }
    } catch (e) {
      version = '';
    } finally {
      final infoMap = {
        '版本': version,
        '执行模式': CLIEnvDetector.currentMode,
        '编译模式': '${CLIEnvDetector.buildMode} (${CLIEnvDetector.isJIT ? 'JIT' : 'AOT'})',
        '是否全局包': CLIEnvDetector.isGlobalActivated.toString(),
        '是否源码运行': CLIEnvDetector.isRunningFromSource.toString(),
        '是否编译执行': CLIEnvDetector.isCompiledExecutable.toString(),
      };

      final infoMap2 = {
        '脚本 URI': Platform.script.toString(),
        '可执行文件': Platform.executable,
        '工作目录': Directory.current.path,
        '配置目录': CLIEnvDetector.configDirectory,
        '缓存目录': CLIEnvDetector.cacheDirectory,
        '包根目录': packageRoot,
      };

      print(
        Table(
          tableStyle: TableStyle(border: false),
          header: TableSection(
            cellStyle: CellStyle(alignment: TextAlignment.MiddleCenter),
            rows: [
              Row(
                cells: [Cell('CLI 环境信息')],
                cellStyle: CellStyle(borderTop: true, borderBottom: true, borderLeft: true),
              ),
            ],
          ),
          body: TableSection(
            cellStyle: CellStyle(paddingLeft: 1, paddingRight: 1),
            rows: [
              ...infoMap.keys.mapIndexed(
                (i, k) => Row(
                  cells: [Cell('$k: ${infoMap[k]}')],
                  cellStyle: CellStyle(borderLeft: true, borderBottom: i == infoMap.length - 1),
                ),
              ),
              ...infoMap2.keys.mapIndexed(
                (i, k) => Row(
                  cells: [Cell('$k: ${infoMap2[k]}')],
                  cellStyle: CellStyle(borderLeft: true, borderBottom: i == infoMap2.length - 1),
                ),
              ),
            ],
          ),
        ).render(),
      );
    }
  }
}
