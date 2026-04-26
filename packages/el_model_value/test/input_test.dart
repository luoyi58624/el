// ElInputModelValue 行为：不依赖 example，使用本文件内 _TestStringInput。

import 'package:el_flutter/ext.dart';
import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElInputModelValue', () {
    testWidgets('modelValue: 输入会写回 ValueNotifier，下游 ListenableBuilder 能读到', (tester) async {
      final username = ValueNotifier<String>('');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                _TestStringInput(key: const Key('in1'), modelValue: username),
                ListenableBuilder(
                  listenable: username,
                  builder: (context, _) {
                    return Text(username.value, key: const Key('out'));
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.widget<Text>(find.byKey(const Key('out'))).data, '');
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('out'))).data, 'hi');
      expect(username.value, 'hi');

      username.dispose();
    });

    testWidgets('modelValue: 外部更新 ValueNotifier 时 TextField 文本跟随', (tester) async {
      final username = ValueNotifier<String>('a');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestStringInput(key: const Key('in2'), modelValue: username),
          ),
        ),
      );

      final field = find.byType(TextField);
      expect(tester.widget<TextField>(field).controller!.text, 'a');

      username.value = 'xyz';
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller!.text, 'xyz');

      username.dispose();
    });

    testWidgets('value + onChanged: 受控输入与回调', (tester) async {
      var value = 'x';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    _TestStringInput(key: const Key('in3'), value: value, onChanged: (v) => setState(() => value = v)),
                    Text(value, key: const Key('echo')),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(tester.widget<Text>(find.byKey(const Key('echo'))).data, 'x');
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('echo'))).data, 'hello');
    });
  });

  group('与 HookWidget / useState 组合', () {
    testWidgets('同一路 useState 下 modelValue 与 value+onChanged 两路输入与底部 Text 一致', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _HookStringInputPage()));

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), 'm1');
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(1), 'm2');
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.byKey(const Key('username_display'))).data, 'm2');
    });
  });
}

class _TestStringInput extends ElInputModelValue<String> {
  _TestStringInput({super.key, super.value = '', super.modelValue, super.onChanged});

  @override
  Widget obsBuild(BuildContext context) {
    super.obsBuild(context);
    return buildInput(context);
  }

  Widget buildInput(BuildContext context) {
    return TextField(
      controller: $textEditingController,
      onChanged: (v) {
        $obs.value = v;
      },
    );
  }
}

class _HookStringInputPage extends HookWidget {
  const _HookStringInputPage();

  @override
  Widget build(BuildContext context) {
    final username = useState('');
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TestStringInput(modelValue: username),
          _TestStringInput(
            value: username.value,
            onChanged: (v) {
              username.value = v;
            },
          ),
          Text(username.value, key: const Key('username_display')),
        ],
      ),
    );
  }
}
