import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() {
  group('el.dialog2 服务测试', () {
    testWidgets('show 销毁状态，showForHandle 保留状态', (tester) async {
      await tester.pumpWidget(const TestApp(child: SizedBox()));
      await tester.pump();

      final removableHandle = await el.dialog2.show(const _CounterDialog(label: '销毁弹窗'));
      await _pumpDialog2(tester);

      expect(find.text('销毁弹窗:0'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('销毁弹窗-button')));
      await tester.pump();
      expect(find.text('销毁弹窗:1'), findsOneWidget);

      final removeFuture = removableHandle.remove();
      await _pumpDialog2(tester);
      await removeFuture;

      expect(find.text('销毁弹窗:1'), findsNothing);
      expect(removableHandle.isActive, isFalse);

      final persistentHandle = el.dialog2.createHandle(const _CounterDialog(label: '保留弹窗'));
      await el.dialog2.showForHandle(persistentHandle);
      await _pumpDialog2(tester);

      expect(find.text('保留弹窗:0'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('保留弹窗-button')));
      await tester.pump();
      expect(find.text('保留弹窗:1'), findsOneWidget);

      final hideFuture = persistentHandle.hide();
      await _pumpDialog2(tester);
      await hideFuture;

      expect(persistentHandle.isHidden, isTrue);
      expect(persistentHandle.isActive, isTrue);

      await el.dialog2.showForHandle(persistentHandle);
      await _pumpDialog2(tester);

      expect(find.text('保留弹窗:1'), findsOneWidget);

      final finalRemoveFuture = persistentHandle.remove();
      await _pumpDialog2(tester);
      await finalRemoveFuture;

      expect(find.text('保留弹窗:1'), findsNothing);
      expect(persistentHandle.isActive, isFalse);
    });

    // 诊断用例：当前可复现 dialog2 多层堆叠后点击一次遮罩仍有残留，待修复后启用。
    testWidgets('连续 show 后点击一次遮罩，旧弹窗仍会残留在页面上', (tester) async {
      await tester.pumpWidget(const TestApp(child: SizedBox()));
      await tester.pump();

      await el.dialog2.show(const _RapidDialog(label: 'A'));
      await el.dialog2.show(const _RapidDialog(label: 'B'));
      await el.dialog2.show(const _RapidDialog(label: 'C'));
      await _pumpDialog2(tester);

      expect(find.byKey(const ValueKey('el_dialog2_backdrop')), findsNWidgets(3));
      expect(find.byKey(const ValueKey('rapid-dialog-A')), findsOneWidget);
      expect(find.byKey(const ValueKey('rapid-dialog-B')), findsOneWidget);
      expect(find.byKey(const ValueKey('rapid-dialog-C')), findsOneWidget);

      final backdrop = find.byKey(const ValueKey('el_dialog2_backdrop')).first;
      await tester.tapAt(tester.getTopLeft(backdrop) + const Offset(8, 8));
      await _pumpDialog2(tester);

      expect(find.byKey(const ValueKey('el_dialog2_backdrop')), findsNWidgets(2));
      expect(find.byKey(const ValueKey('rapid-dialog-C')), findsNothing);
      expect(find.byKey(const ValueKey('rapid-dialog-A')), findsOneWidget);
      expect(find.byKey(const ValueKey('rapid-dialog-B')), findsOneWidget);

      await tester.tapAt(tester.getTopLeft(backdrop) + const Offset(8, 8));
      await _pumpDialog2(tester);
      await tester.tapAt(tester.getTopLeft(backdrop) + const Offset(8, 8));
      await _pumpDialog2(tester);

      expect(find.byKey(const ValueKey('el_dialog2_backdrop')), findsNothing);
    }, skip: true);
  });
}

class _CounterDialog extends StatefulWidget {
  const _CounterDialog({required this.label});

  final String label;

  @override
  State<_CounterDialog> createState() => _CounterDialogState();
}

class _CounterDialogState extends State<_CounterDialog> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.label}:$count'),
            const SizedBox(height: 12),
            TextButton(
              key: ValueKey('${widget.label}-button'),
              onPressed: () => setState(() => count++),
              child: const Text('增加'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RapidDialog extends StatelessWidget {
  const _RapidDialog({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(label, key: ValueKey('rapid-dialog-$label')),
      ),
    );
  }
}

Future<void> _pumpDialog2(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(el.config.duration + const Duration(milliseconds: 50));
  await tester.pump();
  await tester.pump(el.config.duration + const Duration(milliseconds: 50));
}
