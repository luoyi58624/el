import 'dart:io';

import 'package:el_cli/src/utils/common.dart';
import 'package:path/path.dart' as path;

void createDartBlockTemplate(String projectName) {
  final dir = createDir(projectName);
  final pubspecFile = File(path.join(dir.path, 'pubspec.yaml'));

  pubspecFile.writeAsStringSync('''name: $projectName
description: A simple dart project.
version: 0.0.1
environment:
  sdk: $dartVersion

dependencies:
''');

  final libDir = Directory(path.join(dir.path, 'lib'))..createSync();

  final mainDartFile = File(path.join(libDir.path, 'main.dart'));
  mainDartFile.writeAsStringSync('''void main() {
  
}''');
}
