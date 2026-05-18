// import 'dart:io';
// import 'package:charcode/ascii.dart';
// import 'package:io/ansi.dart';
//
// /// Goes up one line.
// void goUpOneLine() {
//   stdout.add([$esc, $lbracket, $1, $A]);
// }
//
// /// Clears the current line, and goes back to the start of the line.
// void clearLine() {
//   stdout.add([$esc, $lbracket, $2, $k, $cr]);
// }
//
// /// Prompt the user, and return the first line read.
// /// This is the core of [Prompter], and the basis for all other
// /// functions.
// ///
// /// A function to [validate] may be passed. If `null`, it defaults
// /// to checking if the string is not empty.
// ///
// /// A default value may be given as [defaultsTo]. If present, the [message]
// /// will have `' ($defaultsTo)'` append to it.
// ///
// /// If [chevron] is `true` (default), then a `>` will be appended to the prompt.
// ///
// /// If [color] is `true` (default), then pretty ANSI colors will be used in the prompt.
// ///
// /// [inputColor] may be used to give a color to the user's input as they type.
// ///
// /// If [allowMultiline] is `true` (default: `false`), then lines ending in a
// /// backslash (`\`) will be interpreted as a signal that another line of
// /// input is to come. This is helpful for building REPL's.
// String get(
//   String message, {
//   bool Function(String)? validate,
//   String? defaultsTo,
//   bool chevron = true,
//   bool color = true,
//   bool allowMultiline = false,
//   bool conceal = false,
//   AnsiCode inputColor = cyan,
// }) {
//   validate ??= (s) => s.trim().isNotEmpty;
//
//   if (defaultsTo != null) {
//     var oldValidate = validate;
//     validate = (s) => s.trim().isEmpty || oldValidate(s);
//   }
//
//   var prefix = '?';
//   var code = cyan;
//   var currentChevron = '\u00BB';
//   var oldEchoMode = stdin.echoMode;
//
//   void writeIt() {
//     var msg = color ? ('${code.wrap(prefix)!} ${wrapWith(message, [darkGray, styleBold])!}') : message;
//     stdout.write(msg);
//     if (defaultsTo != null) stdout.write(' ($defaultsTo)');
//     if (chevron) {
//       stdout.write(color ? lightGray.wrap(' $currentChevron') : ' $currentChevron');
//     }
//
//     stdout.write(' ');
//
//     if (ansiOutputEnabled) {
//       stdout.add([$esc, $lbracket, $0, $K]);
//     }
//   }
//
//   while (true) {
//     if (message.isNotEmpty) {
//       writeIt();
//     }
//
//     var buf = StringBuffer();
//     if (conceal) stdin.echoMode = false;
//
//     while (true) {
//       var line = stdin.readLineSync()!.trim();
//
//       if (!line.endsWith('\\')) {
//         buf.writeln(line);
//         break;
//       } else {
//         buf.writeln(line.substring(0, line.length - 1));
//       }
//
//       clearLine();
//     }
//
//     if (conceal) {
//       stdin.echoMode = oldEchoMode;
//       stdout.writeln();
//     }
//
//     var line = buf.toString().trim();
//
//     if (validate(line)) {
//       String out;
//
//       if (defaultsTo != null) {
//         out = line.isEmpty ? defaultsTo : line;
//       } else {
//         out = line;
//       }
//
//       if (color) {
//         var toWrite = line;
//         if (conceal) {
//           var asterisks = List.filled(line.length, $asterisk);
//           toWrite = String.fromCharCodes(asterisks);
//         }
//
//         prefix = '\u2714';
//         code = green;
//         currentChevron = '\u2025';
//
//         if (ansiOutputEnabled) stdout.add([$esc, $F]);
//         goUpOneLine();
//         clearLine();
//         writeIt();
//         stdout.writeln(color ? darkGray.wrap(toWrite) : toWrite);
//       }
//
//       return out;
//     } else {
//       code = red;
//       prefix = '\u2717';
//       if (ansiOutputEnabled) stdout.add([$esc, $F]);
//
//       goUpOneLine();
//       clearLine();
//     }
//   }
// }
//
// /// Presents a yes/no prompt to the user.
// ///
// /// If [appendYesNo] is `true`, then a `(y/n)`, `(Y/n)` or `(y/N)` is
// /// appended to the [message], depending on its value.
// ///
// /// [color], [inputColor], [conceal], and [chevron] are forwarded to [get].
// bool getBool(
//   String message, {
//   bool defaultsTo = true,
//   bool appendYesNo = true,
//   bool color = true,
//   bool chevron = true,
//   bool conceal = false,
//   AnsiCode inputColor = cyan,
// }) {
//   if (appendYesNo) {
//     message += (defaultsTo ? ' (Y/n)' : ' (y/N)');
//   }
//   var result = get(
//     message,
//     color: color,
//     inputColor: inputColor,
//     conceal: conceal,
//     chevron: chevron,
//     validate: (s) {
//       s = s.trim().toLowerCase();
//       return (s.isEmpty) || s.startsWith('y') || s.startsWith('n');
//     },
//   );
//   result = result.toLowerCase();
//
//   if (result.isEmpty) {
//     return defaultsTo;
//   } else if (result == 'y') {
//     return true;
//   }
//
//   return false;
// }
//
// String choose(
//   String message,
//   List<String> options, {
//   String prompt = 'Enter your choice',
//   AnsiCode inputColor = cyan,
//   bool color = true,
//   bool conceal = false,
// }) {
//   if (options.isEmpty) {
//     throw ArgumentError.value('`options` may not be empty.');
//   }
//
//   var b = StringBuffer();
//
//   b.writeln(message);
//
//   b.writeln();
//
//   for (var i = 0; i < options.length; i++) {
//     var indicator = (i + 1).toString();
//     b.write('$indicator) ${options[i]}');
//     if (i == 0) b.write(' [Default - Press Enter]');
//     b.writeln();
//   }
//
//   b.writeln();
//   if (color) {
//     print(wrapWith(b.toString(), [darkGray, styleBold]));
//   } else {
//     print(b);
//   }
//
//   var line = get(
//     prompt,
//     defaultsTo: options.first,
//     inputColor: inputColor,
//     color: color,
//     conceal: conceal,
//     validate: (s) {
//       if (s.isEmpty) return true;
//       if (options.contains(s)) return true;
//       var i = int.tryParse(s);
//       if (i == null) return false;
//       return i >= 1 && i <= options.length;
//     },
//   );
//
//   if (line.isEmpty) return options.first;
//   int? i = int.tryParse(line);
//
//   if (i != null) return options.elementAt(i - 1);
//   return options.elementAt(options.toList(growable: false).indexOf(line));
// }
