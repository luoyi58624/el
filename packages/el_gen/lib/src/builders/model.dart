import 'package:analyzer/dart/element/element.dart';
import 'package:el_dart/ext.dart';
import 'package:source_gen/source_gen.dart';
import 'package:el_dart/el_dart.dart';

import '../config.dart';
import '../utils.dart';

/// 当前实体类的信息
late ClassElement _classInfo;

/// 当前实体类的类名
late String _className;

/// 当前实体类的默认构造函数是否使用 const 修饰
late bool _isConstConstructor;

@immutable
class ElModelGenerator extends GeneratorForAnnotation<ElModelGenerator> {
  @override
  generateForAnnotatedElement(element, annotation, buildStep) {
    _classInfo = element as ClassElement;
    _className = _classInfo.name!;
    _isConstConstructor = MirrorUtils.getDefaultConstructor(_classInfo).isConst;

    String result =
        """
extension $_className${ModelTemplateConfig.instance.extSuffix} on $_className {
  ${generateFromJson(annotation)}
  ${generateToJson(annotation)}
  ${generateCopyWidth(annotation)}
  ${generateMerge(annotation)}
  ${generateProps(annotation)}
}
  """;

    return result;
  }

  /// 生成 fromJson 方法
  String generateFromJson(ConstantReader annotation) {
    if (!annotation.read('formJson').boolValue) return '';

    String content = '';
    String defaultModelContent = '';

    final fromJsonDiff = annotation.read('fromJsonDiff').boolValue;

    final fields = MirrorUtils.getFieldsByConstructor(_classInfo, visitSuper: true);
    for (int i = 0; i < fields.length; i++) {
      final fieldInfo = fields[i];
      String field = fieldInfo.name!;
      String fieldType = fieldInfo.type.toString();
      String jsonKey = _getJsonKey(fieldInfo) ?? field;
      dynamic defaultValue = _getDefaultValue(fieldInfo);

      String valueContent = '';
      String? defaultModelValueContent;

      // 尽可能地安全处理 json 数据类型转换
      if (fieldType == 'String' || fieldType == 'String?') {
        valueContent = "ElJsonUtil.\$string(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType == 'String') {
            valueContent = '$valueContent ?? \'\'';
            defaultModelValueContent = '\'\'';
          }
        }
      } else if (fieldType == 'num' || fieldType == 'num?') {
        valueContent = "ElJsonUtil.\$num(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType == 'num') {
            valueContent = '$valueContent ?? 0.0';
            defaultModelValueContent = '0.0';
          }
        }
      } else if (fieldType == 'int' || fieldType == 'int?') {
        valueContent = "ElJsonUtil.\$int(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType == 'int') {
            valueContent = '$valueContent ?? 0';
            defaultModelValueContent = '0';
          }
        }
      } else if (fieldType == 'double' || fieldType == 'double?') {
        valueContent = "ElJsonUtil.\$double(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType == 'double') {
            valueContent = '$valueContent ?? 0.0';
            defaultModelValueContent = '0.0';
          }
        }
      } else if (fieldType == 'bool' || fieldType == 'bool?') {
        valueContent = "ElJsonUtil.\$bool(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType == 'bool') {
            valueContent = '$valueContent ?? false';
            defaultModelValueContent = 'false';
          }
        }
      } else if (fieldInfo.type.isDartCoreList) {
        valueContent = "ElJsonUtil.\$list<${fieldType.getGenericType}>(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType.endsWith('?') == false) {
            valueContent = '$valueContent ?? []';
            defaultModelValueContent = '[]';
          }
        }
      } else if (fieldInfo.type.isDartCoreSet) {
        valueContent = "ElJsonUtil.\$set<${fieldType.getGenericType}>(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType.endsWith('?') == false) {
            valueContent = '$valueContent ?? {}';
            defaultModelValueContent = '{}';
          }
        }
      } else if (fieldInfo.type.isDartCoreMap) {
        valueContent = "ElJsonUtil.\$map<${fieldType.getMapGenericType?.value}>(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType.endsWith('?') == false) {
            valueContent = '$valueContent ?? {}';
            defaultModelValueContent = '{}';
          }
        }
      } else if (MirrorUtils.hasSerializeModel(fieldInfo.type.element)) {
        final fieldClassName = fieldType.replaceAll(ElReg.generics, '');
        final defaultModel = '$fieldClassName${ModelTemplateConfig.instance.extSuffix}.defaultModel';
        valueContent = "ElJsonUtil.\$model<$fieldType>(json, '$jsonKey', $defaultModel)";

        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType.endsWith('?') == false) {
            valueContent = "$valueContent ?? $defaultModel";
            defaultModelValueContent = defaultModel;
          }
        }
      } else {
        final serializeName = _getCustomSerialize(fieldInfo);
        if (serializeName == null) {
          // 对于未知数据类型的字段，直接应用默认值，不做任何处理
          valueContent = "json['$jsonKey']";
          defaultModelContent += '$field: null';
        } else {
          valueContent = "ElJsonUtil.\$custom<$fieldType>(json, '$jsonKey', const $serializeName())";
          if (fieldType.endsWith('?') == false) {
            throw 'fromJson Error: $fieldType $field 为自定义序列化类型，生成器无法设置默认值、'
                '同时也无法访问配置的默认值，你必须添加可为空符号 ?';
          }
        }
      }

      content += '$field: $valueContent,\n';
      if (defaultModelValueContent != null) {
        defaultModelContent += '$field: $defaultModelValueContent,\n';
      }
    }

    return """
static ${_isConstConstructor ? 'const' : 'final'} $_className defaultModel = $_className(
  $defaultModelContent
);

static $_className fromJson${fromJsonDiff ? _className : ''}(Map<String, dynamic>? json) {
  if(json == null) return defaultModel;
  return $_className(
    $content
  );
}
    """;
  }

  /// 生成 toJson 方法
  String generateToJson(ConstantReader annotation) {
    if (!annotation.read('toJson').boolValue) return '';

    String content = '';
    final toJsonUnderline = annotation.read('toJsonUnderline').boolValue;

    final fields = MirrorUtils.getFieldsByConstructor(_classInfo, visitSuper: true);
    for (int i = 0; i < fields.length; i++) {
      final fieldInfo = fields[i];
      String field = fieldInfo.name!;
      String fieldType = fieldInfo.type.toString();
      String? jsonKey = _getJsonKey(fieldInfo);

      String key = "'${jsonKey ?? (toJsonUnderline ? field.toUnderline : field)}'";
      late String value;
      if (MirrorUtils.hasSerializeModel(fieldInfo.type.element)) {
        if (fieldType.endsWith('?')) field += '?';
        value = "$field.toJson()";
      } else {
        final serializeName = _getCustomSerialize(fieldInfo);
        if (serializeName == null) {
          value = field;
        } else {
          value = "$serializeName.instance.serialize($field)";
        }
      }
      content += '$key: $value,\n';
    }

    return """
  Map<String, dynamic> _toJson() {
    return {
      $content
    };
  }
    """;
  }

  /// 生成 copyWith 拷贝方法
  String generateCopyWidth(ConstantReader annotation) {
    if (!(annotation.read('copyWith').boolValue || annotation.read('merge').boolValue)) {
      return '';
    }

    String copyWithArgument = '';
    String copyWithContent = '';

    final fields = MirrorUtils.getFieldsByConstructor(_classInfo, visitSuper: true);
    for (int i = 0; i < fields.length; i++) {
      final fieldInfo = fields[i];
      String fieldType = '${fieldInfo.type.toString().replaceAll('?', '')}?';
      if (fieldInfo.type.toString() == 'dynamic') {
        fieldType = fieldType.substring(0, fieldType.length - 1);
      }
      String field = fieldInfo.name!;
      copyWithArgument += '$fieldType $field,\n';

      if (_hasMergeMethod(fieldInfo)) {
        bool isAllowNull = fieldInfo.type.toString().endsWith('?');
        if (isAllowNull) {
          copyWithContent += '$field: this.$field == null ? $field : this.$field!.merge($field),';
        } else {
          copyWithContent += '$field: this.$field.merge($field),';
        }
      } else {
        copyWithContent += '$field: $field ?? this.$field,\n';
      }
    }

    return """
  $_className copyWith({
    $copyWithArgument
  }) {
    return $_className(
      $copyWithContent
    );
  }
    """;
  }

  /// 生成 merge 合并对象方法
  String generateMerge(ConstantReader annotation) {
    if (!annotation.read('merge').boolValue) return '';

    String content = '';
    final fields = MirrorUtils.getFieldsByConstructor(_classInfo, visitSuper: true);
    for (int i = 0; i < fields.length; i++) {
      FieldElement fieldInfo = fields[i];
      final field = fieldInfo.name;
      content += '$field: other.$field,\n';
    }

    return """
  $_className merge([$_className? other]) {
    if (other == null) return this;
    return copyWith(
      $content
    );
  }
    """;
  }

  /// 生成 props 方法
  String generateProps(ConstantReader annotation) {
    if (!annotation.read('generateProps').boolValue) return '';
    final fields = MirrorUtils.getFieldsByConstructor(_classInfo);

    return """ 
List<Object?> get _props => [${fields.map((e) => e.name).join(',')}];
    """;
  }
}

/// 获取当前字段配置的 jsonKey，如果为空则表示用户没有指定 jsonKey
String? _getJsonKey(FieldElement fieldInfo) {
  try {
    final annotation = MirrorUtils.getElFieldAnnotation(fieldChecker, fieldInfo);
    if (annotation == null) return null;
    var value = annotation.getField('jsonKey')?.toStringValue();
    return value;
  } catch (error) {
    return null;
  }
}

/// 获取当前字段配置的 defaultValue，如果为空则表示用户没有指定 defaultValue
dynamic _getDefaultValue(FieldElement fieldInfo) {
  try {
    final annotation = MirrorUtils.getElFieldAnnotation(fieldChecker, fieldInfo);
    if (annotation == null) return null;
    var value = annotation.getField('defaultValue');
    return MirrorUtils.deepGetFieldValue(ConstantReader(value), fieldInfo.type.element, true);
  } catch (e) {
    return null;
  }
}

/// 判断反射的字段是否包含 merge 方法，如果包含，则生成 copyWith 时需要调用目标的 merge 方法
bool _hasMergeMethod(FieldElement fieldInfo) {
  try {
    final annotation = MirrorUtils.getElFieldAnnotation(fieldChecker, fieldInfo);
    bool? useMerge;
    if (annotation != null) {
      useMerge = annotation.getField('useMerge')?.toBoolValue();
    }
    if (useMerge != null) return useMerge;

    // 若用户没有指定 useMerge 配置，那么访问字段目标对象，查询此对象是否包含 merge 方法
    final classElement = fieldInfo.type.element;
    if (classElement is ClassElement) {
      // 如果目标 class 声明 ElModelGenerator 注解，那么先判断它是否设置了 merge 配置
      final classAnnotation = MirrorUtils.getElFieldAnnotation(modelChecker, classElement);
      if (classAnnotation != null) {
        if (classAnnotation.getField('merge')?.toBoolValue() == true) {
          return true;
        }
      }
      // 最后判断实体类是否包含了 merge 方法
      if (classElement.methods.map((method) => method.name).contains('merge')) {
        return true;
      }
    }
    return false;
  } catch (error) {
    return false;
  }
}

/// 获取自定义序列化的注解名字
String? _getCustomSerialize(FieldElement fieldInfo) {
  if (fieldInfo.metadata.annotations.isEmpty) return null;

  String? serializeClassName;
  for (final meta in fieldInfo.metadata.annotations) {
    final element = meta.element;
    if (element is ConstructorElement) {
      var flag = element.enclosingElement.allSupertypes.any(
        (e) => e.toString().contains('$ElSerialize'.replaceAll(ElReg.generics, '')),
      );

      if (flag) serializeClassName = element.displayName;
    }
  }
  if (serializeClassName == null) return null;
  return serializeClassName;
}
