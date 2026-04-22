import 'package:args/command_runner.dart';
import 'package:el_cli/src/commands/create.dart';
import 'package:el_cli/src/commands/install.dart';
import 'package:el_cli/src/commands/list.dart';
import 'package:el_cli/src/commands/remove.dart';
import 'package:el_cli/src/commands/version.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner('el', 'Command-line tool for El framework')
    ..addCommand(CreateCommand())
    ..addCommand(InstallCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(ListCommand())
    ..addCommand(VersionCommand());

  try {
    await runner.run(args);
  } catch (e) {
    print('Error: $e');
  }
}
