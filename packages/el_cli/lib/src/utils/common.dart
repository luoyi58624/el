import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:process_run/process_run.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

const dartVersion = '^3.11.0';

final shell = Shell();
final console = Console();

/// 读取本地 pubspec.yaml 对象
Future<Pubspec> getLocalPubspec() async {
  final pubspecFile = File('pubspec.yaml');

  if (!await pubspecFile.exists()) {
    throw 'pubspec.yaml not found';
  }

  final content = await pubspecFile.readAsString();
  final pubspec = Pubspec.parse(content);

  return pubspec;
}

Directory createDir(String projectName) {
  final dir = Directory(projectName);
  if (dir.existsSync()) {
    stderr.writeln('Error: Directory "$projectName" already exists');
    exit(1);
  }

  dir.createSync(recursive: true);

  return dir;
}
