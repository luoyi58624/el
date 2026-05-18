import 'dart:convert';

import 'package:test/test.dart';

import 'models/animal.dart';
import 'models/class_extended.dart';
import 'models/test.dart';
import 'models/user.dart';

void main() {
  group('fromJson / toJson', () {
    elementGeneratesTest();
    fromJsonNullTest();
    toJsonRoundTripTest();
  });

  group('defaultModel', () {
    defaultModelTest();
    defaultModelWithNestedTest();
  });

  group('copyWith', () {
    copyWithTest();
    copyWithNestedModelTest();
    copyWithPreservesUnchangedTest();
  });

  group('merge', () {
    mergeTest();
    mergeNullTest();
    mergeNestedModelTest();
  });

  group('props', () {
    propsEqualsTest();
    propsNotEqualsTest();
  });

  group('inheritance', () {
    extendsChainTest();
    superFieldTest();
  });
}

void elementGeneratesTest() {
  test('fromJson 基础类型转换', () {
    final json =
        '{"custom_string": "10.0", "stringField2": 10.0, "stringField3": 10, "stringField4": false, '
        '"num_field": "10", "num_field2": 10, "numField3": 10.0, "numField4": true,'
        '"int_field": "10.0", "intField4": true,'
        '"double_field": "10", "doubleField2": 10, "doubleField4": true,'
        '"bool_field": "true", "boolField3": 10, "custom_bool": false,'
        '"list_field": ["luoyi", 100.0, "20", 50, ["xx"]],'
        '"map_field": {"name":"luoyi"},'
        '"user_model": {"username":"hihi", "age":"50"},'
        '"color": "#F8F8FF"'
        '}';

    final model = TestModelExt.fromJson(jsonDecode(json));
    expect(model.stringField, "10.0");
    expect(model.stringField2, "10.0");
    expect(model.stringField3, "10");
    expect(model.stringField4, "false");
    expect(model.numField, 10);
    expect(model.numField2, 10);
    expect(model.numField3, 10.0);
    expect(model.numField4, 10);
    expect(model.intField, 10);
    expect(model.intField2, null);
    expect(model.intField3, 10);
    expect(model.intField4, 20);
    expect(model.doubleField, 10.0);
    expect(model.doubleField2, 10.0);
    expect(model.doubleField3, 10.0);
    expect(model.doubleField4, 10.0);
    expect(model.boolField, true);
    expect(model.boolField2, null);
    expect(model.boolField3, true);
    expect(model.boolField4, false);
    expect(model.listField, ["luoyi", 100.0, "20", 50, ["xx"]]);
    expect(model.listField2, [1, 'hello', false]);
    expect(model.mapField, {'name': 'luoyi'});
    expect(model.mapField2, {
      'name': 'hihi',
      'child': {'age': 20},
    });
    expect(TestModelExt.fromJson(model.toJson()), model);
  });
}

void fromJsonNullTest() {
  test('fromJson(null) 返回 defaultModel', () {
    final model = TestModelExt.fromJson(null);
    final defaultModel = TestModelExt.defaultModel;
    expect(model.stringField, defaultModel.stringField);
    expect(model.intField, defaultModel.intField);
    expect(model.boolField, defaultModel.boolField);
  });

  test('fromJson 空 map 使用默认值', () {
    final model = TestModelExt.fromJson({});
    expect(model.stringField, '');
    expect(model.numField, 0.0);
    expect(model.intField, 0);
    expect(model.doubleField, 0.0);
    expect(model.boolField, false);
    expect(model.listField, [1, 'hello', false, ['hihi']]);
    expect(model.listStringField, []);
    expect(model.listIntField, []);
    expect(model.mapField, {});
    expect(model.setField, {'hihi'});
  });
}

void toJsonRoundTripTest() {
  test('toJson → fromJson 往返一致性 (AnimalModel)', () {
    final original = const AnimalModel(name: '旺财', type: '小狗');
    final json = original.toJson();
    final restored = AnimalModelExt.fromJson(json);
    expect(restored.name, original.name);
    expect(restored.type, original.type);
  });

  test('toJson → fromJson 往返一致性 (UserModel)', () {
    final original = const UserModel(username: 'test', age: 25);
    final json = original.toJson();
    final restored = UserModelExt.fromJson(json);
    expect(restored.username, original.username);
    expect(restored.age, original.age);
  });

  test('toJson 嵌套模型序列化', () {
    final model = UserModelExt.fromJson({
      'username': 'parent',
      'age': 40,
      'child': {'username': 'child', 'age': 10},
    });
    final json = model.toJson();
    expect(json['username'], 'parent');
    expect(json['child'], isA<Map<String, dynamic>>());
    expect((json['child'] as Map)['username'], 'child');
  });
}

void defaultModelTest() {
  test('TestModel.defaultModel 使用配置的默认值', () {
    final dm = TestModelExt.defaultModel;
    expect(dm.stringField3, 'hello');
    expect(dm.stringField4, 'hello');
    expect(dm.numField3, 10.0);
    expect(dm.numField4, 10);
    expect(dm.intField3, 10);
    expect(dm.intField4, 20);
    expect(dm.boolField3, true);
    expect(dm.boolField4, true);
    expect(dm.listField2, [1, 'hello', false]);
    expect(dm.listStringField3, ['hello', 'world']);
    expect(dm.listIntField3, [1, 2, 3, 4, 5]);
    expect(dm.setField, {'hihi'});
  });

  test('AnimalModel.defaultModel 存在且可用', () {
    final dm = AnimalModelExt.defaultModel;
    expect(dm.name, isNull);
    expect(dm.type, isNull);
  });
}

void defaultModelWithNestedTest() {
  test('UserModel.defaultModel 包含嵌套默认值', () {
    final dm = UserModelExt.defaultModel;
    expect(dm, isNotNull);
    expect(dm.username, isNull);
    expect(dm.age, isNull);
  });
}

void copyWithTest() {
  test('copyWith 覆盖指定字段', () {
    final original = TestModelExt.defaultModel;
    final copy = original.copyWith(stringField: 'new_value', intField: 42);

    expect(copy.stringField, 'new_value');
    expect(copy.intField, 42);
  });

  test('copyWith 未指定字段保持原值', () {
    final original = TestModelExt.defaultModel;
    final copy = original.copyWith(stringField: 'changed');
    expect(copy.intField, original.intField);
    expect(copy.boolField, original.boolField);
    expect(copy.listField, original.listField);
  });
}

void copyWithNestedModelTest() {
  test('copyWith 嵌套模型调用 merge', () {
    final dm = UserModelExt.defaultModel;
    final user = dm.copyWith(username: 'test');
    expect(user.username, 'test');

    final merged = user.copyWith(
      child: const UserModel(username: 'kid'),
    );
    expect(merged.child?.username, 'kid');
  });
}

void copyWithPreservesUnchangedTest() {
  test('copyWith 不传任何参数返回等价对象', () {
    final original = TestModelExt.defaultModel;
    final copy = original.copyWith();
    expect(copy.stringField, original.stringField);
    expect(copy.intField, original.intField);
    expect(copy.boolField, original.boolField);
    expect(copy.listField, original.listField);
    expect(copy.mapField, original.mapField);
  });
}

void mergeTest() {
  test('merge 合并两个对象的非 null 字段', () {
    final base = UserModelExt.defaultModel.copyWith(
      username: 'base',
      age: 20,
    );
    final other = UserModelExt.defaultModel.copyWith(username: 'other');
    final merged = base.merge(other);

    // other.username 覆盖 base
    expect(merged.username, 'other');
    // other.age 为 null，保留 base 的值
    expect(merged.age, 20);
  });

  test('merge 嵌套模型深度合并', () {
    final parent = UserModelExt.defaultModel.copyWith(
      username: 'parent',
      child: UserModelExt.defaultModel.copyWith(
        username: 'child1',
        age: 5,
      ),
    );

    final other = UserModelExt.defaultModel.copyWith(
      child: UserModelExt.defaultModel.copyWith(username: 'child2'),
    );

    final merged = parent.merge(other);
    expect(merged.child?.username, 'child2');
    expect(merged.child?.age, 5); // 保留原值
  });
}

void mergeNullTest() {
  test('merge(null) 返回自身', () {
    final original = TestModelExt.defaultModel.copyWith(stringField: 'hello');
    final result = original.merge(null);
    expect(identical(result, original), isTrue);
  });
}

void mergeNestedModelTest() {
  test('merge 保留未在 other 中设置的字段', () {
    final base = AnimalModelExt.defaultModel.copyWith(name: 'original');
    final other = AnimalModelExt.defaultModel.copyWith(type: 'dog');
    final merged = base.merge(other);
    expect(merged.name, 'original');
    expect(merged.type, 'dog');
  });
}

void propsEqualsTest() {
  test('Animal 相同属性 props 相等', () {
    final a = AnimalModelExt.defaultModel.copyWith(name: '旺财', type: '小狗');
    final b = AnimalModelExt.defaultModel.copyWith(name: '旺财', type: '小狗');
    expect(a.props, b.props);
    expect(a, b);
  });

  test('ChildModel 相同属性继承相等', () {
    final child1 = ChildModel(childName: 'child');
    final child2 = ChildModel(childName: 'child');
    expect(child1, child2);

    final child3 = ChildModel(childName: 'child', parentName: 'parent');
    final child4 = ChildModel(childName: 'child', parentName: 'parent');
    expect(child3 == child4, isTrue);

    final child5 = ChildModel(childName: 'child', parentName: 'parent1');
    final child6 = ChildModel(childName: 'child', parentName: 'parent2');
    expect(child5 == child6, isFalse);
  });
}

void propsNotEqualsTest() {
  test('Animal 不同属性 props 不相等', () {
    final a = AnimalModelExt.defaultModel.copyWith(name: '旺财');
    final b = AnimalModelExt.defaultModel.copyWith(name: '小白');
    expect(a.props, isNot(b.props));
    expect(a, isNot(b));
  });
}

void extendsChainTest() {
  test('extends_chain 三层继承', () {
    final child = ChildModel(childName: 'child', parentName: 'parent');
    expect(child.childName, 'child');
    expect(child.parentName, 'parent');

    final child2 = ChildModel2(childName: 'child2');
    expect(child2.childName, 'child2');
    expect(child2.parentName, isNull);
  });
}

void superFieldTest() {
  test('子类构造器携带父类字段', () {
    final child = ChildModel(
      childName: 'child',
      parentName: 'parent',
      rootName: 'root',
    );
    expect(child.childName, 'child');
    expect(child.parentName, 'parent');
    expect(child.rootName, 'root');

    final merged = child.copyWith(childName: 'new_child');
    expect(merged.childName, 'new_child');
    expect(merged.parentName, 'parent');
  });
}
