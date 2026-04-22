import 'dart:convert';
import 'package:el_dart/ext.dart';
import 'package:el_flutter/el_flutter.dart';

import 'package:flutter/material.dart';

@Target({TargetKind.field})
class ElBrightnessSerialize implements ElSerialize<Brightness> {
  const ElBrightnessSerialize();

  @override
  String? serialize(Brightness? obj) => obj?.name;

  @override
  Brightness? deserialize(String? str) {
    if (str == null) return null;
    if (str == 'dark') return Brightness.dark;
    if (str == 'light') return Brightness.light;
    return null;
  }
}

@Target({TargetKind.field})
class ElColorSerialize implements ElSerialize<Color> {
  const ElColorSerialize();

  @override
  String? serialize(Color? obj) => obj?.toHex();

  @override
  Color? deserialize(String? str) => str?.toColor();
}

/// Material 颜色对象序列化。
///
/// 注意：反序列化后的 Material 无法完全匹配原有对象，因为逻辑只是按照梯度创建不同颜色值。
@Target({TargetKind.field})
class ElMaterialElColorSerialize implements ElSerialize<MaterialColor> {
  const ElMaterialElColorSerialize();

  @override
  String? serialize(MaterialColor? obj) => obj?.toHex();

  @override
  MaterialColor? deserialize(String? str) => str?.toColor().toMaterialColor();
}

@Target({TargetKind.field})
class ElSizeSerialize implements ElSerialize<Size> {
  const ElSizeSerialize();

  @override
  String? serialize(Size? obj) => jsonEncode({'width': obj?.width, 'height': obj?.height});

  @override
  Size? deserialize(String? str) {
    if (str == null) return null;
    final map = jsonDecode(str);
    if (map is Map) {
      return Size(ElTypeUtil.safeDouble(map['width']), ElTypeUtil.safeDouble(map['height']));
    } else {
      return null;
    }
  }
}

@Target({TargetKind.field})
class ElOffsetSerialize implements ElSerialize<Offset> {
  const ElOffsetSerialize();

  @override
  String? serialize(Offset? obj) => jsonEncode({'dx': obj?.dx, 'dy': obj?.dy});

  @override
  Offset? deserialize(String? str) {
    if (str == null) return null;
    final map = jsonDecode(str);
    if (map is Map) {
      return Offset(ElTypeUtil.safeDouble(map['dx']), ElTypeUtil.safeDouble(map['dy']));
    } else {
      return null;
    }
  }
}

@Target({TargetKind.field})
class ElLocaleSerialize implements ElSerialize<Locale> {
  const ElLocaleSerialize();

  @override
  String? serialize(Locale? obj) =>
      obj == null ? null : jsonEncode({'languageCode': obj.languageCode, 'countryCode': obj.countryCode});

  @override
  Locale? deserialize(String? str) {
    if (str == null) return null;
    final map = jsonDecode(str);
    if (map is Map) {
      return Locale(ElTypeUtil.safeString(map['languageCode']), ElTypeUtil.safeString(map['countryCode']));
    } else {
      return null;
    }
  }
}
