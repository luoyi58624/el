import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  group('el.toast 服务测试', () {
    testWidgets('服务基础行为', (tester) async {
      await tester.pumpWidget(const TestApp(child: SizedBox()));
      await tester.pump();

      try {
        el.toast.show('第一条提示');
        await _pumpToast(tester);

        expect(find.text('第一条提示'), findsOneWidget);

        el.toast.warning('第二条提示');
        await _pumpToast(tester);

        expect(find.text('第一条提示'), findsNothing);
        expect(find.text('第二条提示'), findsOneWidget);

      } finally {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
    });
  });
}

Future<void> _pumpToast(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}
