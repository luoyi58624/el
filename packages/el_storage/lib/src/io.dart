import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../el_storage.dart';
import 'config.dart';

void $init([String? storagePath, String? storageDir]) {
  $storagePath = storagePath ?? Directory.current.path;
  if (storageDir != null) {
    $storagePath = p.join($storagePath!, storageDir);
  }
  final dir = Directory($storagePath!);
  if (dir.existsSync() != true) dir.createSync(recursive: true);
}

class $Storage extends ElStorage {
  $Storage(super.key, super.debounceTime) {
    file = File(p.join($storagePath!, key));
    if (!file.existsSync()) file.createSync();
    try {
      final str = file.readAsStringSync();
      if (str.trim() != '') {
        final json = jsonDecode(str);
        super.data = json.cast<String, dynamic>();
      } else {
        super.data = {};
      }
    } catch (e) {
      super.data = {};
    }
  }

  late final File file;

  @override
  void write() {
    super.write();
    if (isDispose == true) return;
    final snapshot = jsonEncode(data);
    enqueuePersist(() async {
      if (!file.existsSync()) file.createSync();
      await file.writeAsString(snapshot);
    });
  }

  @override
  void removeStorage() {
    try {
      if (file.existsSync()) file.deleteSync();
    } finally {
      super.removeStorage();
    }
  }
}
