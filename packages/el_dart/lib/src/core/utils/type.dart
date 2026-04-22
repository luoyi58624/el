import 'package:el_dart/ext.dart';
import 'util.dart';

/// 类型转换工具类
class ElTypeUtil {
  ElTypeUtil._();

  /// 判断变量是否是基本数据类型
  static bool isBaseType(dynamic value) => (value is num || value is String || value is bool);

  /// 检查传入的类型字符串是否是基本类型字符串
  static bool isBaseTypeString(String typeString) => ['String', 'num', 'int', 'double', 'bool'].contains(typeString);

  /// 安全解析String，如果传递的value为空，则返回一个默认值
  static String safeString(dynamic value, [String defaultValue = '']) {
    if (ElDartUtil.isEmpty(value)) {
      return defaultValue;
    } else {
      return value.toString();
    }
  }

  /// 安全解析int，如果传递的value不是num类型，则返回默认值
  static int safeInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) {
      return value.isNaN ? defaultValue : value;
    } else if (value is double) {
      if (value.isNaN) return defaultValue;
      return value.toInt();
    } else if (value is String) {
      final s = value.trim();
      final parsed = int.tryParse(s);
      return parsed ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  /// 安全解析double，如果传递的value不是num类型，则返回默认值
  static double safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value is double) {
      return value.isNaN ? defaultValue : value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      final s = value.trim();
      final parsed = double.tryParse(s);
      return parsed ?? defaultValue;
    } else {
      return defaultValue;
    }
  }

  /// 安全解析bool类型
  static bool safeBool(dynamic value, [bool defaultValue = false]) {
    if (value is String) {
      final s = value.trim().toLowerCase();
      if (s == '1') return true;
      if (s == '0') return false;
      try {
        return bool.parse(value, caseSensitive: false);
      } catch (e) {
        return defaultValue;
      }
    } else if (value is num) {
      return value != 0;
    } else if (value is bool) {
      return value;
    }
    return defaultValue;
  }

  /// 安全解析List，若解析失败则返回空List
  static List<T> safeList<T>(dynamic value, [List<T> defaultValue = const []]) {
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (e) {
        return defaultValue;
      }
    } else {
      return defaultValue;
    }
  }

  /// 将动态类型转换成实际基础类型：String、int、double、num、bool，如果
  /// * strict 如果为true，对于非基础类型将一律返回null
  static dynamic dynamicToBaseType(dynamic value, [bool? strict]) {
    String type = value.runtimeType.toString();
    if (type == 'String') {
      dynamic v = int.tryParse(value);
      if (v != null) return v;
      v = double.tryParse(value);
      if (v != null) return v;
      v = bool.tryParse(value);
      if (v != null) return v;
      return value;
    }
    if (type == 'int') return value;
    if (type == 'double') return value;
    if (type == 'bool') return value;
    if (type == 'num') return value;
    return strict == true ? null : value;
  }

  /// 将动态类型转换成指定类型的 List 集合，转换前请判断数据类型是否是 List
  static T dynamicToList<T>(dynamic value) {
    assert(value is List);
    final valueType = T.toString().getGenericType;
    if (valueType == 'dynamic') {
      return List.from(value) as T;
    } else if (valueType == 'Object') {
      return List<Object>.from(value) as T;
    } else if (valueType == 'String') {
      return List<String>.from(value) as T;
    } else if (valueType == 'int') {
      return List<int>.from(value) as T;
    } else if (valueType == 'double') {
      return List<double>.from(value) as T;
    } else if (valueType == 'num') {
      return List<num>.from(value) as T;
    } else if (valueType == 'bool') {
      return List<bool>.from(value) as T;
    } else {
      return List.from(value) as T;
    }
  }

  /// 将动态类型转换成指定类型的 Set 集合，转换前请判断数据类型是否是 Set
  static T dynamicToSet<T>(dynamic value) {
    assert(value is Set);
    final valueType = T.toString().getGenericType;
    if (valueType == 'dynamic') {
      return Set.from(value) as T;
    } else if (valueType == 'Object') {
      return Set<Object>.from(value) as T;
    } else if (valueType == 'String') {
      return Set<String>.from(value) as T;
    } else if (valueType == 'int') {
      return Set<int>.from(value) as T;
    } else if (valueType == 'double') {
      return Set<double>.from(value) as T;
    } else if (valueType == 'num') {
      return Set<num>.from(value) as T;
    } else if (valueType == 'bool') {
      return Set<bool>.from(value) as T;
    } else {
      return Set.from(value) as T;
    }
  }

  /// 将动态类型转换成指定类型的 Map 集合，转换前请判断数据类型是否是 Map
  static dynamic dynamicToMap<T>(dynamic map) {
    assert(map is Map);
    final valueType = T.toString().getMapGenericType;
    String targetKeyType = valueType!.key;
    String targetValueType = valueType.value;
    if (targetKeyType == 'dynamic') {
      if (targetValueType == 'Object') {
        return Map<Object, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<Object, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<Object, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<Object, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<Object, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<Object, bool>.from(map);
      }
      return map.cast<Object, dynamic>();
    }
    if (targetKeyType == 'String') {
      if (targetValueType == 'Object') {
        return Map<String, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<String, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<String, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<String, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<String, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<String, bool>.from(map);
      }
      return Map<String, dynamic>.from(map);
    }
    if (targetKeyType == 'int') {
      if (targetValueType == 'Object') {
        return Map<int, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<int, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<int, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<int, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<int, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<int, bool>.from(map);
      }
      return Map<int, dynamic>.from(map);
    }

    if (targetKeyType == 'double') {
      if (targetValueType == 'Object') {
        return Map<double, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<double, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<double, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<double, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<double, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<double, bool>.from(map);
      }
      return Map<double, dynamic>.from(map);
    }
    if (targetKeyType == 'bool') {
      if (targetValueType == 'Object') {
        return Map<bool, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<bool, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<bool, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<bool, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<bool, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<bool, bool>.from(map);
      }
      return Map<bool, dynamic>.from(map);
    }

    if (targetKeyType == 'num') {
      if (targetValueType == 'Object') {
        return Map<num, Object>.from(map);
      }
      if (targetValueType == 'String') {
        return Map<num, String>.from(map);
      }
      if (targetValueType == 'int') {
        return Map<num, int>.from(map);
      }
      if (targetValueType == 'double') {
        return Map<num, double>.from(map);
      }
      if (targetValueType == 'num') {
        return Map<num, num>.from(map);
      }
      if (targetValueType == 'bool') {
        return Map<num, bool>.from(map);
      }
      return Map<num, dynamic>.from(map);
    }

    return map;
  }
}
