import 'package:el_cli/el_cli.dart';

void main() {
  Select(
    'Select a package manager:',
    children: [
      Choice(name: 'npm', desc: 'npm is the most popular package manager'),
      Choice(name: 'yarn', desc: 'yarn is an awesome package manager'),
      Choice(name: 'pnpm'),
      Choice(name: 'bun'),
    ],
  ).build();

  Checkbox(
    'Select more package manager:',
    validate: (v) => v == null || v.isEmpty ? 'Please select at least one option.' : null,
    children: [
      Choice(name: 'npm', desc: 'npm is the most popular package manager'),
      Choice(name: 'yarn', desc: 'yarn is an awesome package manager'),
      Choice(name: 'pnpm'),
      Choice(name: 'bun'),
    ],
  ).build();
}
