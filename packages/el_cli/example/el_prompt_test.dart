import 'package:el_cli/el_cli.dart';

void main() {
  final username = Input(
    'Enter your username:',
    defaultValue: 'root',
    validate: (v) {
      return v!.length > 6 ? 'username max 6 char' : null;
    },
  ).build();

  final password = Password(
    'Enter your password:',
    validate: (v) {
      return v!.length < 6 ? 'password min 6 char' : null;
    },
  ).build();

  final ok = Confirm('Are you OK? (y/n)', defaultValue: true).build();

  print({'username': username, 'password': password, 'ok': ok});
}
