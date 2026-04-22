import 'package:args/command_runner.dart';
import 'package:process_run/process_run.dart';

import '../utils/common.dart';

class RemoveCommand extends Command {
  @override
  final name = 'r';

  @override
  final description = 'remove package';

  RemoveCommand() {
    argParser.addFlag('global', abbr: 'g', help: 'Remove global package', negatable: false);
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final packageName = args.rest.isNotEmpty ? args.rest[0] : null;
    final isGlobal = args['global'] == true;

    if (packageName == null) {
      print('❌ Error: Package name is required');
      print('Usage: r [-g] <package_name>');
      return;
    }

    final shell = Shell();

    if (isGlobal) {
      await shell.run('dart pub global deactivate $packageName');
    } else {
      final pubspec = await getLocalPubspec();
      if (pubspec.dependencies.containsKey('flutter')) {
        await shell.run('flutter pub remove $packageName');
      } else {
        await shell.run('dart pub remove $packageName');
      }
    }
  }
}
