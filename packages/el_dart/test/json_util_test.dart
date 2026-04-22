import 'package:el_dart/src/core/annotation/json_util.dart';
import 'package:test/test.dart';

void main() {
  group('ElJsonUtil', () {
    test('非 Map json 返回 null（不抛异常）', () {
      expect(ElJsonUtil.$string('not map', 'a'), null);
      expect(ElJsonUtil.$int('not map', 'a'), null);
      expect(ElJsonUtil.$double('not map', 'a'), null);
      expect(ElJsonUtil.$bool('not map', 'a'), null);
      expect(ElJsonUtil.$list('not map', 'a'), null);
      expect(ElJsonUtil.$set('not map', 'a'), null);
      expect(ElJsonUtil.$map('not map', 'a'), null);
    });

    test('key 同时支持驼峰和下划线', () {
      final json = {'user_id': '12'};
      expect(ElJsonUtil.$int(json, 'userId'), 12);
    });

    test(r'$num/$int/$double 支持 num 和带空白字符串', () {
      final json = {'a': 1, 'b': ' 2 ', 'c': ' 1.25 '};
      expect(ElJsonUtil.$num(json, 'a'), 1);
      expect(ElJsonUtil.$int(json, 'b'), 2);
      expect(ElJsonUtil.$double(json, 'c'), 1.25);
    });

    test(r'$num/$int/$double fallback 分支覆盖', () {
      final json = {'n': '3', 'i': Object(), 'd': DateTime.fromMillisecondsSinceEpoch(0)};
      expect(ElJsonUtil.$num(json, 'n'), 3);
      expect(ElJsonUtil.$int(json, 'i'), null);
      expect(ElJsonUtil.$double(json, 'd'), null);
    });

    test(r'$bool 支持 bool/num/0-1 字符串', () {
      final json = {'t': true, 'n1': 1, 'n0': 0, 's1': '1', 's0': '0', 'st': ' true ', 'sf': 'FALSE'};
      expect(ElJsonUtil.$bool(json, 't'), true);
      expect(ElJsonUtil.$bool(json, 'n1'), true);
      expect(ElJsonUtil.$bool(json, 'n0'), false);
      expect(ElJsonUtil.$bool(json, 's1'), true);
      expect(ElJsonUtil.$bool(json, 's0'), false);
      expect(ElJsonUtil.$bool(json, 'st'), true);
      expect(ElJsonUtil.$bool(json, 'sf'), false);
    });

    test(r'$list/$set/$map 类型不匹配返回 null', () {
      final json = {'l': 'x', 's': 1, 'm': []};
      expect(ElJsonUtil.$list<int>(json, 'l'), null);
      expect(ElJsonUtil.$set<int>(json, 's'), null);
      expect(ElJsonUtil.$map<int>(json, 'm'), null);
    });

    test('复杂 json 解析（嵌套/混合类型/驼峰下划线）', () {
      final json = <String, dynamic>{
        'user_id': '12',
        'userName': 'Alice',
        'age': ' 18 ',
        'height': 1.65,
        'is_vip': '1',
        'score': ' 99.5 ',
        'tags': ['a', 'b', 'c'],
        'nums': ['1', 2, 3.1, 'x'],
        'prefs': {'dark_mode': true, 'lang': 'zh'},
        'items': [
          {'item_id': '1', 'price': ' 9.9 '},
          {'itemId': 2, 'price': 10},
          {'item_id': 'x', 'price': 'bad'},
        ],
        'misc': null,
      };

      expect(ElJsonUtil.$int(json, 'userId'), 12);
      expect(ElJsonUtil.$string(json, 'userName'), 'Alice');
      expect(ElJsonUtil.$int(json, 'age'), 18);
      expect(ElJsonUtil.$double(json, 'height'), 1.65);
      expect(ElJsonUtil.$bool(json, 'isVip'), true);
      expect(ElJsonUtil.$double(json, 'score'), 99.5);

      expect(ElJsonUtil.$list<String>(json, 'tags'), ['a', 'b', 'c']);
      expect(ElJsonUtil.$set<String>(json, 'tags'), {'a', 'b', 'c'});

      final prefs = ElJsonUtil.$map<dynamic>(json, 'prefs');
      expect(prefs?['dark_mode'], true);
      expect(prefs?['lang'], 'zh');

      final items = ElJsonUtil.$list<Map<String, dynamic>>(json, 'items');
      expect(items?.length, 3);

      expect(ElJsonUtil.$int(items?[0], 'itemId'), 1);
      expect(ElJsonUtil.$double(items?[0], 'price'), 9.9);

      expect(ElJsonUtil.$int(items?[1], 'itemId'), 2);
      expect(ElJsonUtil.$double(items?[1], 'price'), 10.0);

      expect(ElJsonUtil.$int(items?[2], 'itemId'), null);
      expect(ElJsonUtil.$double(items?[2], 'price'), null);

      // 缺失/空字段返回 null
      expect(ElJsonUtil.$string(json, 'notExist'), null);
      expect(ElJsonUtil.$string(json, 'misc'), null);
    });
  });
}

