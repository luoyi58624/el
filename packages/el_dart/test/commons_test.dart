import 'package:el_dart/el_dart.dart';
import 'package:el_dart/ext.dart';
import 'package:test/test.dart';

void main() {
  group('Model 测试', () {
    _modelTest();
  });

  group('safe 方法测试', () {
    _safeTest();
  });

  group('版本对比测试', () {
    _compareVersionTest();
  });
}

final class _MenuModel extends ElNestModel<_MenuModel> {
  _MenuModel({required super.key, super.children = const []});
}

void _modelTest() {
  test('ElNestModel 嵌套模型测试', () {
    var models = [
      _MenuModel(key: 'A'),
      _MenuModel(
        key: 'B',
        children: [
          _MenuModel(key: 'D', children: []),
          _MenuModel(key: 'E', children: []),
        ],
      ),
      _MenuModel(key: 'H'),
      _MenuModel(
        key: 'C',
        children: [
          _MenuModel(
            key: 'F',
            children: [_MenuModel(key: 'G', children: [])],
          ),
        ],
      ),
      _MenuModel(key: 'M'),
    ];

    List<String> findKey(String key) {
      return ElNestModel.findKeyPath(models, key).map((e) => e.key.toString()).toList();
    }

    expect(findKey('A').eq(['A']), true);
    expect(findKey('B').eq(['B']), true);
    expect(findKey('D').eq(['B', 'D']), true);
    expect(findKey('E').eq(['B', 'E']), true);
    expect(findKey('F').eq(['C', 'F']), true);
    expect(findKey('G').eq(['C', 'F', 'G']), true);
    expect(findKey('H').eq(['H']), true);
    expect(findKey('M').eq(['M']), true);

    List<String> findKey2(String key) {
      return ElNestModel.findKeyPath(models, key, inherit: true).map((e) => e.key.toString()).toList();
    }

    expect(findKey2('A').eq(['A']), true);
    expect(findKey2('B').eq(['B']), true);
    expect(findKey2('BD').eq(['B', 'D']), true);
    expect(findKey2('BE').eq(['B', 'E']), true);
    expect(findKey2('CF').eq(['C', 'F']), true);
    expect(findKey2('CFG').eq(['C', 'F', 'G']), true);
    expect(findKey2('H').eq(['H']), true);
    expect(findKey2('M').eq(['M']), true);

    List<String> findKey3(String key) {
      return ElNestModel.findKeyPath(models, key, inherit: true, splitChar: '/').map((e) => e.key.toString()).toList();
    }

    expect(findKey3('A').eq(['A']), true);
    expect(findKey3('B').eq(['B']), true);
    expect(findKey3('B/D').eq(['B', 'D']), true);
    expect(findKey3('B/E').eq(['B', 'E']), true);
    expect(findKey3('C/F').eq(['C', 'F']), true);
    expect(findKey3('C/F/G').eq(['C', 'F', 'G']), true);
    expect(findKey3('H').eq(['H']), true);
    expect(findKey3('M').eq(['M']), true);

    List<String> findKey4(String key) {
      return ElNestModel.findKeyPath(
        models,
        key,
        inherit: true,
        splitChar: ' -> ',
      ).map((e) => e.key.toString()).toList();
    }

    expect(findKey4('A').eq(['A']), true);
    expect(findKey4('B').eq(['B']), true);
    expect(findKey4('B -> D').eq(['B', 'D']), true);
    expect(findKey4('B -> E').eq(['B', 'E']), true);
    expect(findKey4('C -> F').eq(['C', 'F']), true);
    expect(findKey4('C -> F -> G').eq(['C', 'F', 'G']), true);
    expect(findKey4('H').eq(['H']), true);
    expect(findKey4('M').eq(['M']), true);
  });

  test('ElNestModel 地址模型拼接测试', () {
    var models = [
      _MenuModel(
        key: '/nest',
        children: [
          _MenuModel(key: '1'),
          _MenuModel(
            key: '2',
            children: [
              _MenuModel(key: '2-1'),
              _MenuModel(
                key: '2-2',
                children: [
                  _MenuModel(key: '2-2-1'),
                  _MenuModel(key: '2-2-2'),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    List<String> findKey(String key) {
      return ElNestModel.findKeyPath(models, key, inherit: true, splitChar: '/').map((e) => e.key.toString()).toList();
    }

    expect(findKey('/nest/1').eq(['/nest', '1']), true);
    expect(findKey('/nest/2').eq(['/nest', '2']), true);
    expect(findKey('/nest/2/2-1').eq(['/nest', '2', '2-1']), true);
    expect(findKey('/nest/2/2-2').eq(['/nest', '2', '2-2']), true);
    expect(findKey('/nest/2/2-2/2-2-1').eq(['/nest', '2', '2-2', '2-2-1']), true);
    expect(findKey('/nest/2/2-2/2-2-2').eq(['/nest', '2', '2-2', '2-2-2']), true);
  });
}

void _safeTest() {
  test('isEmpty: null / 空白字符串 / Iterable / Map', () {
    expect(ElDartUtil.isEmpty(null), true);
    expect(ElDartUtil.isEmpty('   '), true);
    expect(ElDartUtil.isEmpty([]), true);
    expect(ElDartUtil.isEmpty(<int>{}), true);
    expect(ElDartUtil.isEmpty({}), true);
  });

  test("isEmpty: 'null' 仅在 checkString=true 时为空", () {
    expect(ElDartUtil.isEmpty('null'), false);
    expect(ElDartUtil.isEmpty(' null ', checkString: true), true);
    expect(ElDartUtil.isEmpty('NULL', checkString: true), true);
  });

  test('safeString: 空值返回默认值', () {
    expect(ElTypeUtil.safeString(null, 'x'), 'x');
    expect(ElTypeUtil.safeString('  ', 'x'), 'x');
  });

  test('safeInt: double 不抛异常，字符串支持 trim', () {
    expect(ElTypeUtil.safeInt(1.2), 1);
    expect(ElTypeUtil.safeInt(' 12 '), 12);
    expect(ElTypeUtil.safeInt('1.2', 9), 9);
  });

  test('safeDouble: int 转 double，字符串支持 trim', () {
    expect(ElTypeUtil.safeDouble(2), 2.0);
    expect(ElTypeUtil.safeDouble(' 1.25 '), 1.25);
    expect(ElTypeUtil.safeDouble('x', 9.5), 9.5);
  });

  test('safeBool: 解析失败返回默认值，并支持 0/1', () {
    expect(ElTypeUtil.safeBool('TRUE'), true);
    expect(ElTypeUtil.safeBool('no', true), true);
    expect(ElTypeUtil.safeBool('1'), true);
    expect(ElTypeUtil.safeBool('0'), false);
    expect(ElTypeUtil.safeBool(1), true);
    expect(ElTypeUtil.safeBool(0), false);
  });
}

void _compareVersionTest() {
  // 正常业务场景
  test('1.0.0-test < 1.1.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.0.0-test', '1.1.0'), true);
  });

  // 前缀 v / V
  test('v1.0.0 == 1.0.0 → 不更新', () {
    expect(ElDartUtil.compareVersion('v1.0.0', '1.0.0'), false);
  });
  test('V2.1.3 < 2.2.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('V2.1.3', '2.2.0'), true);
  });

  // 各种后缀
  test('1.0.0+1 == 1.0.0 → 不更新', () {
    expect(ElDartUtil.compareVersion('1.0.0+1', '1.0.0'), false);
  });
  test('1.0.0-beta+hotfix.2 < 1.0.1 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.0.0-beta+hotfix.2', '1.0.1'), true);
  });
  test('1.0.0-release < 1.0.0 → 不更新', () {
    expect(ElDartUtil.compareVersion('1.0.0-release', '1.0.0'), false);
  });

  // 版本段数不一致
  test('1 < 1.0.0 → 不更新', () {
    expect(ElDartUtil.compareVersion('1', '1.0.0'), false);
  });
  test('1.0 < 1.0.1 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.0', '1.0.1'), true);
  });
  test('1.0.0.0 < 1.0.0.1 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.0.0.0', '1.0.0.1'), true);
  });
  test('1.0.0.0.0 == 1 → 不更新', () {
    expect(ElDartUtil.compareVersion('1.0.0.0.0', '1'), false);
  });

  // 跨段大小比较
  test('1.9.9 < 2.0.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.9.9', '2.0.0'), true);
  });
  test('2.0.0 > 1.99.99 → 不更新', () {
    expect(ElDartUtil.compareVersion('2.0.0', '1.99.99'), false);
  });
  test('1.0.10 < 1.0.11 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.0.10', '1.0.11'), true);
  });
  test('1.0.99 < 1.0.100 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.0.99', '1.0.100'), true);
  });

  // 异常格式（容错）
  test('空字符串本地 < 1.0.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('', '1.0.0'), true);
  });
  test('1.0.0 > 空服务端 → 不更新', () {
    expect(ElDartUtil.compareVersion('1.0.0', ''), false);
  });
  test('null 字符串视为 0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('null', '1.0.0'), true);
  });
  test('null 值视为 0 → 需要更新', () {
    expect(ElDartUtil.compareVersion(null, '1.0.0'), true);
  });
  test('服务端 null 值视为 0 → 不更新', () {
    expect(ElDartUtil.compareVersion('1.0.0', null), false);
  });
  test('带空白的 v 前缀版本 == 纯版本 → 不更新', () {
    expect(ElDartUtil.compareVersion('  v1.2.3  ', '  1.2.3 '), false);
  });
  test('数字类型 1 == 1.0.0 → 不更新', () {
    expect(ElDartUtil.compareVersion(1, '1.0.0'), false);
  });
  test('数字类型 1.0 < 1.0.1 → 需要更新', () {
    expect(ElDartUtil.compareVersion(1.0, '1.0.1'), true);
  });
  test('非字符串对象视为 0 → 需要更新', () {
    expect(ElDartUtil.compareVersion({'v': '1.0.0'}, '1.0.0'), true);
  });
  test('版本含字母乱码 < 1.0.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('a.b.c', '1.0.0'), true);
  });
  test('1.x.3 < 1.2.3 → 需要更新', () {
    expect(ElDartUtil.compareVersion('1.x.3', '1.2.3'), true);
  });

  // 前后都带 v 和后缀
  test('v1.2.3-beta == 1.2.3+1 → 不更新', () {
    expect(ElDartUtil.compareVersion('v1.2.3-beta', '1.2.3+1'), false);
  });
  test('V3.10.9-release < 3.11.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('V3.10.9-release', '3.11.0'), true);
  });

  // 超大版本号
  test('999.999.999 < 1000.0.0 → 需要更新', () {
    expect(ElDartUtil.compareVersion('999.999.999', '1000.0.0'), true);
  });
}
