import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:el_dart/ext.dart';
import 'package:source_gen/source_gen.dart';
import 'package:el_dart/el_dart.dart';

import '../config.dart';
import '../utils.dart';

@immutable
class ElModelGenerator extends GeneratorForAnnotation<ElModelGenerator> {
  @override
  generateForAnnotatedElement(element, annotation, buildStep) {
    final classInfo = element as ClassElement;
    final className = classInfo.name!;
    final isConstConstructor = MirrorUtils.getDefaultConstructor(classInfo).isConst;
    final fields = MirrorUtils.getFieldsByConstructor(classInfo, visitSuper: true);

    return '''
extension $className${ModelTemplateConfig.instance.extSuffix} on $className {
  ${_generateFromJson(classInfo, className, isConstConstructor, fields, annotation)}
  ${_generateToJson(classInfo, fields, annotation)}
  ${_generateCopyWith(classInfo, className, fields, annotation)}
  ${_generateMerge(classInfo, className, fields, annotation)}
  ${_generateProps(classInfo, annotation)}
}
''';
  }

  String _generateFromJson(ClassElement classInfo, String className, bool isConstConstructor,
      List<FieldElement> fields, ConstantReader annotation) {
    if (!annotation.read('formJson').boolValue) return '';

    final fromJsonDiff = annotation.read('fromJsonDiff').boolValue;
    final content = StringBuffer();
    final defaultModelContent = StringBuffer();

    for (final fieldInfo in fields) {
      final field = fieldInfo.name!;
      final fieldType = fieldInfo.type.toString();

      final fieldAnnotation = _tryGetFieldAnnotation(fieldInfo);
      final jsonKey = fieldAnnotation?.getField('jsonKey')?.toStringValue() ?? field;
      final defaultValue = fieldAnnotation != null
          ? _extractDefaultValue(fieldAnnotation, fieldInfo)
          : null;

      String valueContent;
      String? defaultModelValueContent;

      if (fieldType == 'String' || fieldType == 'String?') {
        valueContent = "\$ElJsonUtil.\$string(json, '$jsonKey')";
        if (defaultValue != null) {
          valueContent = '$valueContent ?? $defaultValue';
          defaultModelValueContent = '$defaultValue';
        } else {
          if (fieldType == 'String') {
            valueContent = "$valueContent ?? ''";
            defaultModelValueContent = "''";
          }
        }
      } else if (fieldType == 'num' || fieldType == 'num?') {
        valueContent = "\$ElJsonUtil.\$num(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$int(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$double(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$bool(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$list<${fieldType.getGenericType}>(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$set<${fieldType.getGenericType}>(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$map<${fieldType.getMapGenericType?.value}>(json, '$jsonKey')";
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
        valueContent = "\$ElJsonUtil.\$model<$fieldType>(json, '$jsonKey', $defaultModel)";

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
          valueContent = "json['$jsonKey']";
          defaultModelContent.write('$field: null,');
        } else {
          valueContent = "\$ElJsonUtil.\$custom<$fieldType>(json, '$jsonKey', const $serializeName())";
          if (fieldType.endsWith('?') == false) {
            throw ArgumentError(
              'fromJson Error: $fieldType $field 为自定义序列化类型，生成器无法设置默认值、'
              '同时也无法访问配置的默认值，你必须添加可为空符号 ?',
            );
          }
        }
      }

      content.write('$field: $valueContent,\n');
      if (defaultModelValueContent != null) {
        defaultModelContent.write('$field: $defaultModelValueContent,\n');
      }
    }

    return '''
  static ${isConstConstructor ? 'const' : 'final'} $className defaultModel = $className(
    $defaultModelContent
  );

  static $className fromJson${fromJsonDiff ? className : ''}(Map<String, dynamic>? json) {
    if(json == null) return defaultModel;
    return $className(
      $content
    );
  }
''';
  }

  String _generateToJson(ClassElement classInfo, List<FieldElement> fields, ConstantReader annotation) {
    if (!annotation.read('toJson').boolValue) return '';

    final toJsonUnderline = annotation.read('toJsonUnderline').boolValue;
    final content = StringBuffer();

    for (final fieldInfo in fields) {
      final field = fieldInfo.name!;
      final fieldType = fieldInfo.type.toString();
      final jsonKey = _getJsonKey(fieldInfo);

      final key = "'${jsonKey ?? (toJsonUnderline ? field.toUnderline : field)}'";
      late String value;
      if (MirrorUtils.hasSerializeModel(fieldInfo.type.element)) {
        final suffix = fieldType.endsWith('?') ? '?' : '';
        value = '$field$suffix.toJson()';
      } else {
        final serializeName = _getCustomSerialize(fieldInfo);
        if (serializeName == null) {
          value = field;
        } else {
          value = "const $serializeName().serialize($field)";
        }
      }
      content.write('$key: $value,\n');
    }

    return '''
  Map<String, dynamic> _toJson() {
    return {
      $content
    };
  }
''';
  }

  String _generateCopyWith(ClassElement classInfo, String className, List<FieldElement> fields,
      ConstantReader annotation) {
    if (!(annotation.read('copyWith').boolValue || annotation.read('merge').boolValue)) {
      return '';
    }

    final copyWithArg = StringBuffer();
    final copyWithBody = StringBuffer();

    for (final fieldInfo in fields) {
      final fieldTypeStr = fieldInfo.type.toString();
      final field = fieldInfo.name!;

      if (fieldTypeStr == 'dynamic') {
        copyWithArg.write('dynamic $field,\n');
      } else {
        copyWithArg.write('${fieldTypeStr.replaceAll('?', '')}? $field,\n');
      }

      if (_hasMergeMethod(fieldInfo)) {
        if (fieldTypeStr.endsWith('?')) {
          copyWithBody.write('$field: this.$field == null ? $field : this.$field!.merge($field),');
        } else {
          copyWithBody.write('$field: this.$field.merge($field),');
        }
      } else {
        copyWithBody.write('$field: $field ?? this.$field,\n');
      }
    }

    return '''
  $className copyWith({
    $copyWithArg
  }) {
    return $className(
      $copyWithBody
    );
  }
''';
  }

  String _generateMerge(ClassElement classInfo, String className, List<FieldElement> fields,
      ConstantReader annotation) {
    if (!annotation.read('merge').boolValue) return '';

    final content = StringBuffer();
    for (final fieldInfo in fields) {
      content.write('${fieldInfo.name}: other.${fieldInfo.name},\n');
    }

    return '''
  $className merge([$className? other]) {
    if (other == null) return this;
    return copyWith(
      $content
    );
  }
''';
  }

  String _generateProps(ClassElement classInfo, ConstantReader annotation) {
    if (!annotation.read('generateProps').boolValue) return '';
    final fields = MirrorUtils.getFieldsByConstructor(classInfo);
    return '''
  List<Object?> get _props => [${fields.map((e) => e.name).join(',')}];
''';
  }
}

DartObject? _tryGetFieldAnnotation(FieldElement fieldInfo) {
  try {
    return MirrorUtils.getElFieldAnnotation(fieldChecker, fieldInfo);
  } catch (_) {
    return null;
  }
}

dynamic _extractDefaultValue(DartObject annotation, FieldElement fieldInfo) {
  try {
    final value = annotation.getField('defaultValue');
    if (value == null || value.isNull) return null;
    return MirrorUtils.deepGetFieldValue(ConstantReader(value), fieldInfo.type.element, true);
  } catch (_) {
    return null;
  }
}

/// 获取当前字段配置的 jsonKey，如果为空则表示用户没有指定 jsonKey
String? _getJsonKey(FieldElement fieldInfo) {
  try {
    final annotation = MirrorUtils.getElFieldAnnotation(fieldChecker, fieldInfo);
    if (annotation == null) return null;
    return annotation.getField('jsonKey')?.toStringValue();
  } catch (_) {
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

    final classElement = fieldInfo.type.element;
    if (classElement is ClassElement) {
      final classAnnotation = MirrorUtils.getElFieldAnnotation(modelChecker, classElement);
      if (classAnnotation != null) {
        if (classAnnotation.getField('merge')?.toBoolValue() == true) {
          return true;
        }
      }
      if (classElement.methods.any((m) => m.name == 'merge')) {
        return true;
      }
    }
    return false;
  } catch (_) {
    return false;
  }
}

/// 获取自定义序列化的注解名字
String? _getCustomSerialize(FieldElement fieldInfo) {
  if (fieldInfo.metadata.annotations.isEmpty) return null;

  for (final meta in fieldInfo.metadata.annotations) {
    final element = meta.element;
    if (element is ConstructorElement) {
      final flag = element.enclosingElement.allSupertypes.any(
        (e) => e.toString().contains('$ElSerialize'.replaceAll(ElReg.generics, '')),
      );
      if (flag) return element.displayName;
    }
  }
  return null;
}
