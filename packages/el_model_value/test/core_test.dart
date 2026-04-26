// ElModelValue（core/hook）行为：不依赖 example，使用本文件内 _TestBoolModelValue。

import 'package:el_flutter/ext.dart';
import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElModelValue', () {
    testWidgets('modelValue: 点击开关会同步到 ValueNotifier', (tester) async {
      final model = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestBoolModelValue(key: const Key('s1'), modelValue: model),
          ),
        ),
      );

      Switch sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.value, isFalse);
      expect(model.value, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.value, isTrue);
      expect(model.value, isTrue);

      model.dispose();
    });

    testWidgets('modelValue: 外部更新 ValueNotifier 时界面跟随', (tester) async {
      final model = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestBoolModelValue(key: const Key('s2'), modelValue: model),
          ),
        ),
      );

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      model.value = true;
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      model.dispose();
    });

    testWidgets('value + onChanged: 受控方式随外部状态变化', (tester) async {
      var external = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return _TestBoolModelValue(
                  key: const Key('s3'),
                  value: external,
                  onChanged: (v) => setState(() => external = v),
                );
              },
            ),
          ),
        ),
      );

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(external, isTrue);
    });

    testWidgets('多个子组件绑定同一 modelValue 时保持同步', (tester) async {
      final model = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                _TestBoolModelValue(key: const Key('a'), modelValue: model),
                _TestBoolModelValue(key: const Key('b'), modelValue: model),
              ],
            ),
          ),
        ),
      );

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switches.at(0)).value, isTrue);
      expect(tester.widget<Switch>(switches.at(1)).value, isTrue);
      expect(model.value, isTrue);

      model.dispose();
    });
  });

  group('与 HookWidget / useState 组合', () {
    testWidgets('同一路 useState 下 modelValue 与 value+onChanged 两路开关联动', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _HookBoolSwitchPage(),
        ),
      );

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      expect(tester.widget<Switch>(switches.at(0)).value, isFalse);
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(switches.at(0)).value, isTrue);
      expect(tester.widget<Switch>(switches.at(1)).value, isTrue);

      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(switches.at(1)).value, isFalse);
    });
  });
}

class _TestBoolModelValue extends ElModelValue<bool> {
  _TestBoolModelValue({super.key, super.value = false, super.modelValue, super.onChanged});

  @override
  Widget obsBuild(BuildContext context) {
    return Switch(
      value: $obs.value,
      onChanged: (v) {
        $obs.value = v;
      },
    );
  }
}

class _HookBoolSwitchPage extends HookWidget {
  const _HookBoolSwitchPage();

  @override
  Widget build(BuildContext context) {
    final flag = useState(false);
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TestBoolModelValue(modelValue: flag),
          _TestBoolModelValue(
            value: flag.value,
            onChanged: (v) {
              flag.value = v;
            },
          ),
        ],
      ),
    );
  }
}
