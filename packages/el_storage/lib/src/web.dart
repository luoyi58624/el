import 'dart:convert';

import 'package:el_dart/el_dart.dart';
import 'package:web/web.dart' show window;

import '../el_storage.dart';

// web 端无需创建文件目录文件夹
void $init([String? storagePath, String? storageDir]) {}

class $Storage extends ElStorage {
  $Storage(super.key, super.debounceTime) {
    final result = window.localStorage.getItem(key);
    try {
      if (result != null) {
        final json = jsonDecode(result);
        super.data = json.cast<String, dynamic>();
      } else {
        super.data = {};
      }
    } catch (e) {
      ElLog.w(e, title: 'ElStorage init data Exception');
      super.data = {};
    }
  }

  @override
  void write() {
    super.write();
    if (isDispose == true) return;
    final snapshot = jsonEncode(data);
    enqueuePersist(() {
      window.localStorage.setItem(key, snapshot);
    });
  }

  @override
  void removeStorage() {
    try {
      window.localStorage.removeItem(key);
    } finally {
      super.removeStorage();
    }
  }
}
