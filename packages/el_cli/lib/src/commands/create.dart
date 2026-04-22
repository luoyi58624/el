import 'package:args/command_runner.dart';

class CreateCommand extends Command {
  @override
  final name = 'create';

  @override
  final description = 'Create a new Aim framework project';

  @override
  String get invocation => 'el create <project_name>';

  @override
  Future<void> run() async {
    final args = argResults!;
    final projectName = args.rest.isNotEmpty ? args.rest.first : null;

    if (projectName == null) {
      printUsage();
      return;
    }

    // console.writeLine();
    // console.cursorPosition = Coordinate(console.cursorPosition!.row, 10);

    // final oldCol = console.cursorPosition!.col;
    // console.write(red.wrap('world') ?? 'world');
    // console.cursorPosition = Coordinate(console.cursorPosition!.row, oldCol);
    // console.eraseCursorToEnd();

    // console.writeLine();
    // stdout.writeln();
    // console.write('xx');
    // console.writeLine('xx');

    // console.eraseLine();
    // stdout.writeln();
    // createDartBlockTemplate(projectName);

    // final result = getBool('你要创建新的文件夹吗?');

    // 显示模板列表选项
    // _showTemplateList();
  }

  // void _showTemplateList() {
  //   print('Creating project...');
  //
  //   final template = choose('Please choose a template: ', ['default', 'web', 'mobile', 'api', 'cli']);
  //
  //   print('\n✓ Selected template: $template');
  // }
}
