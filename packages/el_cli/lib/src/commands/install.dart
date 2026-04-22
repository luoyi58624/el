import 'package:args/command_runner.dart';

import '../utils/common.dart';

class InstallCommand extends Command {
  @override
  final name = 'i';

  @override
  final description = 'install package';

  InstallCommand() {
    argParser.addFlag('global', abbr: 'g', help: 'Install global package', negatable: false);
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final packageName = args.rest.isNotEmpty ? args.rest[0] : null;
    final isGlobal = args['global'] == true;

    if (packageName == null) {
      print('Error: Package name is required');
      print('Usage: i [-g] <package_name>');
      return;
    }

    if (isGlobal) {
      await shell.run('dart pub global activate $packageName');
    } else {
      final pubspec = await getLocalPubspec();
      if (pubspec.dependencies.containsKey('flutter')) {
        await shell.run('flutter pub add $packageName');
      } else {
        await shell.run('dart pub add $packageName');
      }
    }
  }
}
