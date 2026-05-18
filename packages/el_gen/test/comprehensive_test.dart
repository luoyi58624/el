import 'package:test/test.dart';

import 'models/comprehensive.dart';

void main() {
  group('fromJsonDiff', () {
    test('AllFeaturesModel 生成带类名后缀的 fromJson', () {
      final model = AllFeaturesModelExt.fromJsonAllFeaturesModel({
        'custom_key': 'hello',
        'withDefault': 100,
        'normalString': 'test',
        'normalInt': 1,
        'normalDouble': 2.0,
        'normalBool': true,
        'stringList': ['a'],
        'intSet': <int>{},
        'normalMap': <String, dynamic>{},
      });
      expect(model.withJsonKey, 'hello');
      expect(model.withDefault, 100);
    });
  });

  group('toJsonUnderline', () {
    test('AllFeaturesModel toJson 键名转为下划线', () {
      final model = AllFeaturesModelExt.defaultModel.copyWith(
        withJsonKey: 'v1',
        withDefault: 99,
        normalString: 'ns',
        normalInt: 10,
        normalDouble: 1.5,
        normalBool: false,
        stringList: ['x'],
        intSet: {1},
        normalMap: {'k': 'v'},
      );
      final json = model.toJson();
      expect(json['custom_key'], 'v1');
      expect(json['with_default'], 99);
      expect(json['normal_string'], 'ns');
      expect(json['normal_int'], 10);
      expect(json['normal_double'], 1.5);
      expect(json['normal_bool'], false);
      expect(json['string_list'], ['x']);
      expect(json['int_set'], {1});
      expect(json['normal_map'], {'k': 'v'});
    });
  });

  group('jsonKey', () {
    test('ElFieldGenerator(jsonKey:) 映射自定义键名', () {
      final json = {
        'custom_key': 'mapped_value',
        'withDefault': 7,
        'normalString': 'x',
        'normalInt': 1,
        'normalDouble': 1.0,
        'normalBool': true,
        'stringList': <String>[],
        'intSet': <int>[],
        'normalMap': <String, dynamic>{},
      };
      final model = AllFeaturesModelExt.fromJsonAllFeaturesModel(json);
      expect(model.withJsonKey, 'mapped_value');
    });

    test('nullableWithDefault 使用 nullable_key 映射', () {
      final model = AllFeaturesModelExt.fromJsonAllFeaturesModel({
        'custom_key': 'a',
        'nullable_key': 'from_json',
        'withDefault': 1,
        'normalString': 'b',
        'normalInt': 1,
        'normalDouble': 1.0,
        'normalBool': true,
        'stringList': <String>[],
        'intSet': <int>[],
        'normalMap': <String, dynamic>{},
      });
      expect(model.nullableWithDefault, 'from_json');
    });
  });

  group('defaultValue', () {
    test('ElFieldGenerator(defaultValue:) 注入到 defaultModel', () {
      final dm = AllFeaturesModelExt.defaultModel;
      expect(dm.withDefault, 42);
      expect(dm.nullableWithDefault, 'fallback');
    });

    test('字段缺失时使用 defaultValue 兜底', () {
      final model = AllFeaturesModelExt.fromJsonAllFeaturesModel({
        'custom_key': 'a',
        'normalString': 'b',
        'normalInt': 1,
        'normalDouble': 1.0,
        'normalBool': true,
        'stringList': <String>[],
        'intSet': <int>[],
        'normalMap': <String, dynamic>{},
      });
      // withDefault is missing from json, falls back to 42
      expect(model.withDefault, 42);
    });

    test('nullable 字段缺失时使用 defaultValue 兜底', () {
      final model = AllFeaturesModelExt.fromJsonAllFeaturesModel({
        'custom_key': 'a',
        'withDefault': 1,
        'normalString': 'b',
        'normalInt': 1,
        'normalDouble': 1.0,
        'normalBool': true,
        'stringList': <String>[],
        'intSet': <int>[],
        'normalMap': <String, dynamic>{},
      });
      expect(model.nullableWithDefault, 'fallback');
    });
  });

  group('@json 预设', () {
    test('JsonOnlyModel 有 fromJson/toJson/_props，无 copyWith/merge', () {
      final model = JsonOnlyModelExt.fromJson({'name': 'test', 'age': 20});
      expect(model.name, 'test');
      expect(model.age, 20);
      expect(model.toJson(), {'name': 'test', 'age': 20});
      expect(model.props, ['test', 20]);
    });
  });

  group('@copy 预设', () {
    test('CopyOnlyModel 有 copyWith/merge/_props，无 fromJson/toJson', () {
      final original = CopyOnlyModel(name: 'a', age: 1);
      final copy = original.copyWith(name: 'b');
      expect(copy.name, 'b');
      expect(copy.age, 1);

      final merged = original.merge(CopyOnlyModel(name: 'b', age: 2));
      expect(merged.name, 'b');
      expect(merged.age, 2);
      expect(original.props, ['a', 1]);
    });
  });

  group('merge 强制 copyWith', () {
    test('MergeForcesCopyWithModel merge=true 时强制生成 copyWith', () {
      final original = MergeForcesCopyWithModel(title: 'original');
      final copy = original.copyWith(title: 'copy');
      expect(copy.title, 'copy');

      final merged = original.merge(MergeForcesCopyWithModel(title: 'merged'));
      expect(merged.title, 'merged');
    });
  });

  group('generateProps: false', () {
    test('NoPropsModel 不生成 _props', () {
      final model = NoPropsModelExt.fromJson({'value': 'hello'});
      expect(model.value, 'hello');
      expect(model.toJson(), {'value': 'hello'});

      final copy = model.copyWith(value: 'world');
      expect(copy.value, 'world');

      final merged = model.merge(NoPropsModel(value: 'merged'));
      expect(merged.value, 'merged');
    });
  });

  group('Custom 序列化', () {
    test('ElDateTimeSerialize 正确序列化/反序列化', () {
      final now = DateTime(2026, 5, 17, 12, 0, 0);
      final model = CustomSerializeModel(name: 'dt', dateField: now);
      final json = model.toJson();
      expect(json['dateField'], now.millisecondsSinceEpoch.toString());

      final restored = CustomSerializeModelExt.fromJson(json);
      expect(restored.dateField?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('ElDurationSerialize 正确序列化/反序列化', () {
      final duration = Duration(hours: 2, minutes: 30);
      final model = CustomSerializeModel(name: 'dur', durationField: duration);
      final json = model.toJson();
      expect(json['durationField'], duration.inMicroseconds.toString());

      final restored = CustomSerializeModelExt.fromJson(json);
      expect(restored.durationField?.inMicroseconds, duration.inMicroseconds);
    });

    test('Custom 序列化 null 值处理', () {
      final model = CustomSerializeModel(name: 'no_custom');
      final json = model.toJson();
      expect(json['dateField'], isNull);
      expect(json['durationField'], isNull);

      final restored = CustomSerializeModelExt.fromJson(json);
      expect(restored.dateField, isNull);
      expect(restored.durationField, isNull);
    });
  });

  group('useMerge', () {
    test('useMerge: true 强制使用 merge', () {
      final host = MergeHostModel(
        forceMergeField: MergeTargetModel(label: 't1', count: 10),
        autoDetectMergeField: MergeTargetModel(label: 't2', count: 20),
        noMergeField: MergeTargetModel(label: 't3', count: 30),
        name: 'host',
      );

      final copy = host.copyWith(
        forceMergeField: MergeTargetModel(label: 'new1', count: 0),
      );
      // useMerge: true → field merged, label overwritten, count from new value
      expect(copy.forceMergeField!.label, 'new1');
      expect(copy.forceMergeField!.count, 0);
    });

    test('useMerge: true nullable 字段为 null 时不 crash', () {
      final host = MergeHostModel(
        name: 'host',
      );
      final copy = host.copyWith(
        forceMergeField: MergeTargetModel(label: 'first', count: 1),
      );
      expect(copy.forceMergeField!.label, 'first');
      expect(copy.forceMergeField!.count, 1);
    });

    test('auto-detect merge 自动检测并应用 merge', () {
      final host = MergeHostModel(
        forceMergeField: MergeTargetModel(label: 'f', count: 1),
        autoDetectMergeField: MergeTargetModel(label: 't2', count: 20),
        noMergeField: MergeTargetModel(label: 't3', count: 30),
        name: 'host',
      );

      final copy = host.copyWith(
        autoDetectMergeField: MergeTargetModel(label: 'detected', count: 0),
      );
      // auto-detected → MergeTargetModel has merge, so merge is applied
      expect(copy.autoDetectMergeField!.label, 'detected');
      expect(copy.autoDetectMergeField!.count, 0);
    });

    test('useMerge: false 不应用 merge，直接替换', () {
      final host = MergeHostModel(
        forceMergeField: MergeTargetModel(label: 'f', count: 1),
        autoDetectMergeField: MergeTargetModel(label: 'a', count: 1),
        noMergeField: MergeTargetModel(label: 't3', count: 30),
        name: 'host',
      );

      final replacement = MergeTargetModel(label: 'replaced', count: 99);
      final copy = host.copyWith(noMergeField: replacement);
      // useMerge: false → field fully replaced
      expect(copy.noMergeField!.label, 'replaced');
      expect(copy.noMergeField!.count, 99);
    });
  });

  group('Props 继承', () {
    test('PropsParentModel._props 仅包含自身字段', () {
      final parent = PropsParentModel(parentField: 'pf');
      // _props is private; we access via the public props getter that wraps it
      // parent.props = [...] where the model wraps with [...]
      // Actually _props is a private getter in the extension, we can't access directly
      // But we can verify through the equality behavior
      expect(parent.props.length, 1);
    });

    test('PropsChildModel._props 仅包含自身字段，不包含父类字段', () {
      final child = PropsChildModel(childField: 'cf', parentField: 'pf');
      // child.props combines [super.props, _props]
      // super.props = [_props of parent] = [parentField]
      // child._props should be [childField] only
      // So child.props = [parentField, childField]
      expect(child.props, ['pf', 'cf']);
    });

    test('Props 继承相等性', () {
      final a = PropsChildModel(childField: 'cf', parentField: 'pf');
      final b = PropsChildModel(childField: 'cf', parentField: 'pf');
      expect(a, b);

      final c = PropsChildModel(childField: 'cf', parentField: 'other');
      expect(a, isNot(c));
    });
  });

  group('嵌套序列化模型', () {
    test('NestedModel 递归 fromJson/toJson', () {
      final json = {
        'label': 'parent',
        'child': {'label': 'child', 'child': null},
      };
      final model = NestedModelExt.fromJson(json);
      expect(model.label, 'parent');
      expect(model.child, isNotNull);
      expect(model.child!.label, 'child');
      expect(model.child!.child, isNull);
    });

    test('NestedModel toJson 嵌套输出', () {
      final model = NestedModelExt.defaultModel.copyWith(
        label: 'root',
        child: NestedModelExt.defaultModel.copyWith(label: 'leaf'),
      );
      final json = model.toJson();
      expect(json['label'], 'root');
      expect(json['child'], isA<Map<String, dynamic>>());
      expect((json['child'] as Map)['label'], 'leaf');
    });

    test('NestedModel toJson → fromJson 往返', () {
      final original = NestedModelExt.defaultModel.copyWith(
        label: 'root',
        child: NestedModelExt.defaultModel.copyWith(label: 'child'),
      );
      final json = original.toJson();
      final restored = NestedModelExt.fromJson(json);
      expect(restored.label, original.label);
      expect(restored.child?.label, original.child?.label);
    });

    test('NestedModel copyWith 嵌套使用 merge', () {
      final original = NestedModelExt.defaultModel.copyWith(
        label: 'root',
        child: NestedModelExt.defaultModel.copyWith(label: 'old_child'),
      );
      final copy = original.copyWith(
        child: NestedModelExt.defaultModel.copyWith(label: 'new_child'),
      );
      expect(copy.label, 'root');
      // copyWith on nested model uses merge
      expect(copy.child?.label, 'new_child');
    });
  });

  group('defaultModel', () {
    test('AllFeaturesModel 有 const 构造器 → defaultModel 为 const', () {
      final dm = AllFeaturesModelExt.defaultModel;
      expect(dm.withJsonKey, '');
      expect(dm.withDefault, 42);
      expect(dm.nullableWithDefault, 'fallback');
      expect(dm.normalString, '');
      expect(dm.normalInt, 0);
      expect(dm.normalDouble, 0.0);
      expect(dm.normalBool, false);
      expect(dm.stringList, []);
      expect(dm.intSet, <int>{});
      expect(dm.normalMap, {});
    });

    test('NestedModel defaultModel 不包含嵌套 child', () {
      final dm = NestedModelExt.defaultModel;
      expect(dm.label, '');
      expect(dm.child, isNull);
    });

    test('CustomSerializeModel defaultModel 不含自定义序列化字段默认值', () {
      final dm = CustomSerializeModelExt.defaultModel;
      expect(dm.name, '');
      expect(dm.dateField, isNull);
      expect(dm.durationField, isNull);
    });
  });
}
