import 'package:el_dart/ext.dart';
import 'package:test/test.dart';

void main() {
  group('扩展方法测试', () {
    test('filter', () {
      final map = {'name': 'hihi', 'age': 20};
      final newMap = map.filter((k, v) => v is int);
      expect(newMap, {'age': 20});
    });
    test('filterFromKeys', () {
      final map = {'name': 'hihi', 'age': 20, 'money': 1000};
      final newMap = map.filterFromKeys(['age', 'money']);
      expect(newMap, {'age': 20, 'money': 1000});
    });

    test('excludeGeneric', () {
      expect('List<E>'.excludeGeneric, 'List');
      expect('UserModel<T>?'.excludeGeneric, 'UserModel');
    });

    test('getGenericType', () {
      expect('List<E>'.getGenericType, 'E');
      expect('UserModel<T>?'.getGenericType, 'T');
    });
  });
}
