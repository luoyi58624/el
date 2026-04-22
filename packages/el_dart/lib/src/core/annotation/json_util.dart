import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';

const String _formJsonErrorStart = '(error) ElModelGenerator fromJson: ';
const String _formJsonErrorEnd = '提示：此错误仅在开发环境下显示。';

/// 此工具类用于代码生成（fromJson），直接访问 Map 对象很容易出现低级类型转换错误，
/// 例如：int is not String.
class ElJsonUtil {
  ElJsonUtil._(); // coverage:ignore-line

  /// json key 需要同时支持驼峰、下划线
  static dynamic _getJsonValue(dynamic json, String key) {
    if (json is! Map) return null;
    return json[key] ?? json[key.toUnderline];
  }

  static String? $string(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    return value.toString();
  }

  static num? $num(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  static int? $int(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final v = num.tryParse(value.trim());
      return v?.toInt();
    }
    return int.tryParse(value.toString().trim());
  }

  static double? $double(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return double.tryParse(value.toString().trim());
  }

  static bool? $bool(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().trim().toLowerCase();
    if (s == '1') return true;
    if (s == '0') return false;
    return bool.tryParse(s);
  }

  static List<T>? $list<T>(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value is List) {
      try {
        return List<T>.from(value);
      } catch (e) {
        if (!El.kReleaseMode) {
          throw '$_formJsonErrorStart: $key -> List<${T.toString()}> 类型转换失败, '
              'json data: \n'
              '================================================================\n'
              '$value\n'
              '================================================================\n'
              '$_formJsonErrorEnd';
        }
      }
    }
    return null;
  }

  static Set<T>? $set<T>(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value is Iterable) {
      try {
        return Set<T>.from(value);
      } catch (e) {
        if (!El.kReleaseMode) {
          throw '$_formJsonErrorStart: $key -> Set<${T.toString()}> 类型转换失败, '
              'json data: \n'
              '================================================================\n'
              '$value\n'
              '================================================================\n'
              '$_formJsonErrorEnd';
        }
      }
    }
    return null;
  }

  static Map<String, T>? $map<T>(dynamic json, String key) {
    final value = _getJsonValue(json, key);
    if (value is Map) {
      try {
        return Map<String, T>.from(value);
      } catch (e) {
        if (!El.kReleaseMode) {
          throw '$_formJsonErrorStart: $key -> Map<String, ${T.toString()}> 类型转换失败, '
              'json data: \n'
              '================================================================\n'
              '$value\n'
              '================================================================\n'
              '$_formJsonErrorEnd';
        }
      }
    }
    return null;
  }

  static T? $model<T>(dynamic json, String key, T model) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    if (model is ElSerializeModel) {
      return model.fromJson(value);
    }
    return null;
  }

  /// 当内置的数据转换不满足目标类型时，将统一进入自定义序列化方法，
  /// 如果用户没有提供自定义序列化，那么程序将抛出异常
  static T? $custom<T>(dynamic json, String key, ElSerialize<T> model) {
    final value = _getJsonValue(json, key);
    if (value == null) return null;
    return model.deserialize(value);
  }

  static bool eqList(List? value1, List? value2) {
    if (value1 == null && value2 == null) return true;
    return value1!.eq(value2!);
  }

  static bool eqSet(Set? value1, Set? value2) {
    if (value1 == null && value2 == null) return true;
    return value1!.eq(value2!);
  }

  static bool eqMap(Map? value1, Map? value2) {
    if (value1 == null && value2 == null) return true;
    return value1!.eq(value2!);
  }
}
