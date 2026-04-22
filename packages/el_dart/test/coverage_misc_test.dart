import 'package:el_dart/el_dart.dart';
import 'package:test/test.dart';

final class _SerModel implements ElSerializeModel<_SerModel> {
  final int id;
  _SerModel(this.id);

  @override
  _SerModel fromJson(Map<String, dynamic>? json) {
    return _SerModel(ElJsonUtil.$int(json, 'id') ?? 0);
  }

  @override
  Map<String, dynamic> toJson() => {'id': id};
}

void main() {
  group('annotation & tiny utils coverage', () {
    test('annotations can be constructed', () {
      const a0 = ElModelGenerator();
      const a1 = ElModelGenerator.all();
      const a2 = ElModelGenerator.json();
      const a3 = ElModelGenerator.copy();
      const f = ElFieldGenerator(jsonKey: 'a', defaultValue: 1, useMerge: true);
      const t = ElThemeGenerator();

      expect(a0.toJsonUnderline, false);
      expect(a1.copyWith, true);
      expect(a2.formJson, true);
      expect(a3.merge, true);
      expect(f.jsonKey, 'a');
      expect(t.generateThemeWidget, true);
    });

    test('serialize helpers', () {
      const dt = ElDateTimeSerialize();
      const du = ElDurationSerialize();

      final now = DateTime.fromMillisecondsSinceEpoch(123);
      expect(dt.serialize(now), '123');
      expect(dt.deserialize('123')?.millisecondsSinceEpoch, 123);
      expect(dt.deserialize(null), null);

      final d = Duration(microseconds: 456);
      expect(du.serialize(d), '456');
      expect(du.deserialize('456')?.inMicroseconds, 456);
      expect(du.deserialize(null), null);
    });

    test('ElReg expressions are usable', () {
      expect('   a'.replaceAll(ElReg.removeFirstBlank, ''), 'a');
      expect('a   '.replaceAll(ElReg.removeEndBlank, ''), 'a');
      expect('<b>x</b>'.replaceAll(ElReg.htmlTag, ''), 'x');
      expect('List<E>?'.replaceAll(ElReg.generics, ''), 'List');
    });

    test('ElLabelModel and Equatable props', () {
      final a = ElLabelModel('x', 1);
      final b = ElLabelModel('x', 1);
      expect(a == b, true);
      expect(a.props.length, 2);
      expect(a.stringify, true);
    });

    test('ElNestModel stringify & not-found path', () {
      final root = _Menu(key: 'A', children: const []);
      expect(root.stringify, true);
      expect(ElNestModel.findKeyPath<_Menu>([root], 'NOT_FOUND'), isEmpty);
    });
  });

  group('ElJsonUtil error branches', () {
    test(r'$list/$set/$map cast failure throws in debug', () {
      // Only meaningful in non-release mode; in release it returns null.
      if (El.kReleaseMode) return;

      expect(
        () => ElJsonUtil.$list<String>({'l': [1, 2]}, 'l'),
        throwsA(isA<String>()),
      );

      expect(
        () => ElJsonUtil.$set<String>({'s': [1, 2]}, 's'),
        throwsA(isA<String>()),
      );

      expect(
        () => ElJsonUtil.$map<int>({'m': {'a': 'x'}}, 'm'),
        throwsA(isA<String>()),
      );
    });

    test(r'$model delegates to ElSerializeModel', () {
      final json = {'id': 7};
      final model = ElJsonUtil.$model(json, 'self', _SerModel(0));
      // $model expects json['self']; so provide nested.
      final model2 = ElJsonUtil.$model({'self': json}, 'self', _SerModel(0));
      expect(model, null);
      expect(model2?.id, 7);
    });

    test(r'$custom delegates to ElSerialize', () {
      final ser = _IntSer();
      final v = ElJsonUtil.$custom({'v': '9'}, 'v', ser);
      expect(v, 9);
    });

    test('eqList/eqSet/eqMap null semantics', () {
      expect(ElJsonUtil.eqList(null, null), true);
      expect(ElJsonUtil.eqSet(null, null), true);
      expect(ElJsonUtil.eqMap(null, null), true);

      expect(ElJsonUtil.eqList([1], [1]), true);
      expect(ElJsonUtil.eqSet({1}, {1}), true);
      expect(ElJsonUtil.eqMap({'a': 1}, {'a': 1}), true);
    });
  });
}

final class _IntSer implements ElSerialize<int> {
  @override
  String? serialize(int? obj) => obj?.toString();

  @override
  int? deserialize(String? str) => str == null ? null : int.tryParse(str);
}

final class _Menu extends ElNestModel<_Menu> {
  const _Menu({required super.key, super.children = const []});
}

