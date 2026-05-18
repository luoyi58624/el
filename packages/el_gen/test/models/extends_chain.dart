import 'package:el_dart/el_dart.dart';

part '../generates/models/extends_chain.g.dart';

class One {
  final String? one;

  One({this.one});
}

@ElModelGenerator(copyWith: true)
class Two extends One {
  Two({super.one, this.two});

  final String? two;
}

@ElModelGenerator(copyWith: true)
class Three extends Two {
  Three({super.one, super.two, this.three});

  final String? three;
}

class Four extends Three {
  Four({super.one, super.two, super.three, this.four});

  final String? four;
}

@ElModelGenerator(copyWith: true)
class Five extends Four {
  Five({super.one, super.two, super.three, super.four, this.five});

  final String? five;
}
