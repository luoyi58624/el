import 'package:el_hooks/el_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('useForm: resolver 失败时不调用 onValid 并写入 errors', (tester) async {
    Map<String, dynamic>? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            final form = useForm(
              defaultValues: {'email': ''},
              resolver: (values) {
                if ((values['email'] as String).isEmpty) {
                  return {'email': '必填'};
                }
                return null;
              },
            );

            return Scaffold(
              body: Column(
                children: [
                  TextField(key: const Key('email'), controller: form.register('email')),
                  Text(key: const Key('err'), form.error('email') ?? ''),
                  FilledButton(
                    onPressed: () => form.handleSubmit((data) => submitted = data),
                    child: const Text('submit'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('submit'));
    await tester.pump();

    expect(submitted, isNull);
    expect(find.text('必填'), findsOneWidget);
  });

  testWidgets('useForm: 校验通过后 onValid 收到当前值', (tester) async {
    Map<String, dynamic>? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            final form = useForm(
              defaultValues: {'email': ''},
              resolver: (values) {
                if ((values['email'] as String).isEmpty) {
                  return {'email': '必填'};
                }
                return null;
              },
            );

            return Scaffold(
              body: Column(
                children: [
                  TextField(controller: form.register('email')),
                  FilledButton(
                    onPressed: () => form.handleSubmit((data) => submitted = data),
                    child: const Text('submit'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a@b.c');
    await tester.tap(find.text('submit'));
    await tester.pump();

    expect(submitted, {'email': 'a@b.c'});
  });
}
