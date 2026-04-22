import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';
import 'package:test/test.dart';

void main() {
  group('extension full coverage', () {
    test('optional notBlankCallback', () {
      int? v;
      expect(v.notBlankCallback((e) => e + 1), null);
      v = 1;
      expect(v.notBlankCallback((e) => e + 1), 2);
    });

    test('Duration and int delay/operators', () async {
      var called = false;
      await (10.ms).delay(() {
        called = true;
      });
      expect(called, true);

      expect((2.ss).inSeconds, 2);
      expect((3.mm).inMinutes, 3);
      expect((4.hh).inHours, 4);
      expect((5.dd).inDays, 5);

      // Explicitly invoke extension operator (Duration itself may define `*`)
      final d = ElDartDurationExt(const Duration(milliseconds: 10)) * 2;
      expect(d.inMilliseconds, 20);

      // cover int.delay convenience
      var called2 = false;
      await 1.delay(() {
        called2 = true;
      });
      expect(called2, true);
    });

    test('double floatToInt8', () {
      expect(0.0.floatToInt8, 0);
      expect(1.0.floatToInt8, 255);
      expect(0.5.floatToInt8, inInclusiveRange(127, 128));
    });

    test('string basic helpers', () {
      expect('abc'.firstUpperCase, 'Abc');
      expect('Abc'.firstLowerCase, 'abc');

      expect(''.removeFirstChar(), '');
      expect('a'.removeFirstChar(), '');
      expect('ab'.removeFirstChar(), 'b');

      expect(''.removeLastChar(), '');
      expect('a'.removeLastChar(), '');
      expect('ab'.removeLastChar(), 'a');

      expect('userId'.toUnderline, 'user_id');
      expect('  a '.clearFrontBackBlank, 'a');
      expect('List<E>?'.excludeGeneric, 'List');
      expect('List<E>'.getGenericType, 'E');
      expect('List'.getGenericType, null);

      expect('Map<String, int>'.getMapGenericType, (key: 'String', value: 'int'));
      expect('Map<String>'.getMapGenericType, null);
    });

    test('chinese space insertion helpers', () {
      expect('中文'.isTwoChineseCharacters, true);
      expect('中文a'.isTwoChineseCharacters, false);
      expect(''.insertSpaceBetweenChars, '');
      expect('ab'.insertSpaceBetweenChars, 'a b');
      expect('中文'.autoInsertSpace, '中 文');
      expect('abc'.autoInsertSpace, 'abc');
    });

    test('List/Set/Map eq/neq and utilities', () {
      expect([1, 2].eq([1, 2]), true);
      expect([1, 2].neq([2, 1]), true);
      expect(([1] * 3).eq([1, 1, 1]), true);
      expect([].insertBetween(0), []);
      expect([1, 2, 3].insertBetween(0).eq([1, 0, 2, 0, 3]), true);

      final m = [1, 2, 3];
      expect(m.move(0, 2), true);
      expect(m.eq([2, 3, 1]), true);
      // cover move(from>to) branch
      expect(m.move(2, 0), true);
      expect(m.eq([1, 2, 3]), true);
      expect(m.move(2, 2), false);
      expect(m.move(-1, 0), false);

      expect({1, 2}.eq({2, 1}), true);
      expect({1, 2}.neq({1}), true);

      final map = {'name': 'a', 'age': 1, 'money': 100};
      expect(map.eq({'age': 1, 'name': 'a', 'money': 100}), true);
      expect(map.neq({'age': 2}), true);
      expect(map.filter((k, v) => v is int), {'age': 1, 'money': 100});
      expect(map.filterFromKeys(['age']).eq({'age': 1}), true);
      expect(map.getKeyByValue('a'), 'name');
      expect(map.getKeyByValue('missing'), null);
      expect(map.mapToList((k, v) => '$k=$v').length, 3);
      expect(map.mapToSet((k, v) => k).contains('age'), true);
    });

    test('Function.time: enabled/log branches and filterTime', () {
      // cover El.kReleaseMode branch deterministically
      if (El.kReleaseMode) {
        var c = 0;
        (() => c++).time();
        expect(c, 1);
        return;
      }

      // ensure enabled=false branch
      var count = 0;
      (() => count++).time(enabled: false);
      expect(count, 1);

      // ensure enabled=true branch with custom log (avoid ElLog.d)
      final logs = <String>[];
      void myLog(dynamic message, {dynamic title, dynamic config}) {
        logs.add(message.toString());
      }

      (() {}).time(logPrefix: 'T', debugLabel: 'x', log: myLog);
      expect(logs.isNotEmpty, true);

      // filterTime branch: should early return and not log
      logs.clear();
      (() {}).time(filterTime: const Duration(days: 1), log: myLog);
      expect(logs, isEmpty);

      // Note: "end >= 1000" 分支对运行环境较敏感，这里不强依赖覆盖
    });
  });
}

