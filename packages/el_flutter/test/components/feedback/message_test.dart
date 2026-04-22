import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  group('el.message 服务测试', () {
    testWidgets('服务基础行为', (tester) async {
      await tester.pumpWidget(const TestApp(child: SizedBox()));
      await tester.pump();

      try {
        el.message.show('第一条消息');
        await _pumpMessage(tester);

        expect(find.text('第一条消息'), findsOneWidget);

        el.message.show('第一条消息', grouping: true);
        await _pumpMessage(tester);

        expect(find.text('第一条消息'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);

        el.message.success('第二条消息', closeDuration: const Duration(milliseconds: 800));
        await _pumpMessage(tester);

        expect(find.text('第二条消息'), findsOneWidget);
        expect(find.byIcon(ElIcons.close), findsNWidgets(2));

        await tester.tap(find.byIcon(ElIcons.close).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('第一条消息'), findsNothing);
        expect(find.text('第二条消息'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('第二条消息'), findsNothing);
      } finally {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
      }
    });
  });
}

Future<void> _pumpMessage(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}
