// ElForm、ElFormController、ElFormModelValue（prop / 校验错误展示）行为。

import 'package:el_model_value/el_model_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElForm / ElFormController', () {
    testWidgets('ElForm 向子树提供 ElFormController（maybeOf）', (tester) async {
      final controller = ElFormController(initialValue: <String, dynamic>{});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElForm(
              controller: controller,
              child: Builder(
                builder: (context) {
                  expect(ElForm.maybeOf(context), same(controller));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
    });

    // 用 []= 改键会与 controller.initialValue 共享同一 Map 时同步污染「初值」快照；
    // 整体替换 [formData.value] 后再 [reset] 应回到 [initialValue] 所指对象的内容（此处为 {k:1}）。
    test('reset 会清空 errorMessages，且将 formData 恢复为对 initialValue 的拷贝', () {
      final initial = <String, dynamic>{'k': 1};
      final controller = ElFormController(initialValue: initial);
      expect(controller.formData['k'], 1);

      controller.formData.value = <String, dynamic>{'k': 99};
      controller.errorMessages['any'] = 'e';
      expect(controller.formData['k'], 99);

      controller.reset();

      expect(controller.formData['k'], 1);
      expect(controller.errorMessages.value, isEmpty);
    });
  });

  group('ElFormModelValue', () {
    testWidgets('带 prop 的表单项会把 prop 注册到 controller.props', (tester) async {
      final controller = ElFormController(
        initialValue: <String, dynamic>{'field1': false},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElForm(
              controller: controller,
              child: _TestFormBoolField(
                prop: 'field1',
                value: false,
              ),
            ),
          ),
        ),
      );

      expect(controller.props, contains('field1'));
    });

    testWidgets('当 rules 含该 prop 时，errorMessages 能在表单项下方展示', (tester) async {
      final controller = ElFormController(
        initialValue: <String, dynamic>{'field1': false},
        rules: {
          'field1': [
            ElFormRule(
              validator: (ElFormRule rule, dynamic v) => true,
              message: 'noop',
              trigger: ElFormRuleTrigger.submit,
            ),
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElForm(
              controller: controller,
              child: _TestFormBoolField(
                prop: 'field1',
                value: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('required_msg'), findsNothing);
      controller.errorMessages['field1'] = 'required_msg';
      await tester.pumpAndSettle();

      expect(find.text('required_msg'), findsOneWidget);
    });

    testWidgets('validate 会按当前实现清除已注册 prop 对应的错误信息', (tester) async {
      final controller = ElFormController(
        initialValue: <String, dynamic>{'f': false},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElForm(
              controller: controller,
              child: _TestFormBoolField(prop: 'f', value: false),
            ),
          ),
        ),
      );

      controller.errorMessages['f'] = 'err';
      await tester.pumpAndSettle();
      expect(controller.errorMessages.containsKey('f'), isTrue);

      final ok = controller.validate();
      await tester.pumpAndSettle();

      expect(ok, isTrue);
      expect(controller.errorMessages.containsKey('f'), isFalse);
    });
  });
}

/// 继承 [ElFormModelValue] 的最小表单项（非 ElInput），用于测 prop / 规则 / 错误 UI。
class _TestFormBoolField extends ElFormModelValue<bool> {
  _TestFormBoolField({super.value = false, super.prop});

  @override
  Widget obsBuilder(BuildContext context) {
    return Switch(
      value: $obs.value,
      onChanged: (v) {
        $obs.value = v;
      },
    );
  }
}
