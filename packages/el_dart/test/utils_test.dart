import 'dart:convert';
import 'package:el_dart/ext.dart';
import 'package:test/test.dart';
import 'package:el_dart/el_dart.dart';

void main() {
  group('工具类测试', () {
    test('onlyOneNotNull', () {
      expect(['x', null].onlyOne(), isTrue);
      expect(['x', null, 1].onlyOne(), isFalse);
      expect([null, null, null].onlyOne(), isFalse);
      expect([null, null, null].onlyOne(allowAllNull: true), isTrue);
    });

    test('dynamicToList', () {
      dynamic list = ['hello', 'world'];
      final newList = ElTypeUtil.dynamicToList<List<String>>(list);
      expect(newList.runtimeType.toString(), 'List<String>');

      final listString = jsonEncode(list);
      final newList2 = jsonDecode(listString);
      expect(newList2.runtimeType.toString(), 'List<dynamic>');

      final newList3 = ElTypeUtil.dynamicToList<List<String>>(newList2);
      expect(newList3.runtimeType.toString(), 'List<String>');
    });

    test('dynamicToMap', () {
      Map map = {'name': 'hihi', 'age': 20};
      Map<String, dynamic> castMap = ElTypeUtil.dynamicToMap<Map<String, Object>>(map);
      expect(map.runtimeType.toString(), '_Map<dynamic, dynamic>');
      expect(castMap.runtimeType.toString(), '_Map<String, Object>');

      Map map2 = {'name': 'hihi', 'age': '20'};
      Map castMap2 = ElTypeUtil.dynamicToMap<Map<String, String>>(map2);
      expect(map2.runtimeType.toString(), '_Map<dynamic, dynamic>');
      expect(castMap2.runtimeType.toString(), '_Map<String, String>');
    });

    test('isTwoChineseCharacters', () {
      expect('你好'.isTwoChineseCharacters, true);
      expect('你 好'.isTwoChineseCharacters, false);
      expect('你a'.isTwoChineseCharacters, false);
      expect('𠀀好'.isTwoChineseCharacters, true);
      expect('你'.isTwoChineseCharacters, false);
      expect('\uD840\uDC00'.isTwoChineseCharacters, false);
      expect('你好呀'.isTwoChineseCharacters, false);
    });
  });
}
