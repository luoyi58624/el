import 'package:el_flutter/el_flutter.dart';
import 'package:el_http/el_http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common.dart';

void main() async {
  group('el.loading 服务测试', () {
    testWidgets('服务基础行为', (tester) async {
      await _runLoadingTest(tester, () async {
        await el.loading.open('加载中...');
        await _pumpLoading(tester);

        expect(find.text('加载中...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        el.loading.close();
        await _pumpOverlayClose(tester);

        expect(find.text('加载中...'), findsNothing);
        final cancelToken = CancelToken();

        await el.loading.open(
          '等待中',
          closeModel: ElLoadingCloseModel(
            title: '关闭提示',
            content: '确定要关闭当前 loading 吗？',
            cancel: '继续等待',
            confirm: '立即关闭',
            cancelToken: cancelToken,
          ),
        );
        await _pumpLoading(tester);

        await _openClosePrompt(tester, loadingText: '等待中');

        expect(find.text('关闭提示'), findsOneWidget);
        expect(find.text('确定要关闭当前 loading 吗？'), findsOneWidget);
        expect(find.text('继续等待'), findsOneWidget);
        expect(find.text('立即关闭'), findsOneWidget);

        await tester.tap(find.text('继续等待'));
        await _pumpOverlayClose(tester, duration: const Duration(milliseconds: 300));

        expect(find.text('等待中'), findsOneWidget);
        expect(find.text('关闭提示'), findsNothing);
        expect(cancelToken.isCancelled, isFalse);

        el.loading.close();
        await _pumpOverlayClose(tester);
        expect(find.text('等待中'), findsNothing);

        await el.loading.open(
          '处理中',
          closeModel: ElLoadingCloseModel(title: '关闭提示', content: '关闭时要一起收起弹窗'),
        );
        await _pumpLoading(tester);

        await _openClosePrompt(tester, loadingText: '处理中');
        expect(find.text('关闭提示'), findsOneWidget);

        el.loading.close();
        await _pumpOverlayClose(tester, duration: const Duration(milliseconds: 350));
        await tester.pump();

        expect(find.text('处理中'), findsNothing);
        expect(find.text('关闭提示'), findsNothing);

        final confirmToken = CancelToken();

        await el.loading.open(
          '提交中',
          closeModel: ElLoadingCloseModel(
            title: '关闭提示',
            content: '确认终止当前请求？',
            cancel: '返回',
            confirm: '确认关闭',
            cancelToken: confirmToken,
          ),
        );
        await _pumpLoading(tester);

        await _openClosePrompt(tester, loadingText: '提交中');
        await tester.tap(find.text('确认关闭'));
        await _pumpOverlayClose(tester, duration: const Duration(milliseconds: 400));

        expect(find.text('提交中'), findsNothing);
        expect(find.text('关闭提示'), findsNothing);
        expect(confirmToken.isCancelled, isTrue);
      });
    });
  });
}

Future<void> _runLoadingTest(WidgetTester tester, Future<void> Function() body) async {
  await tester.pumpWidget(const TestApp(child: SizedBox()));
  await tester.pump();

  try {
    await body();
  } finally {
    await _closeOverlays(tester);
  }
}

Future<void> _closeOverlays(WidgetTester tester) async {
  el.prompt.close();
  el.loading.close();
  await _pumpOverlayClose(tester, duration: const Duration(milliseconds: 500));
  await tester.pump();
}

Future<void> _pumpLoading(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _pumpOverlayClose(WidgetTester tester, {Duration duration = const Duration(milliseconds: 150)}) async {
  await tester.pump();
  await tester.pump(duration);
  await tester.pump();
  await tester.pump(duration);
  await tester.pump();
  await tester.pump(duration);
}

Future<void> _openClosePrompt(WidgetTester tester, {required String loadingText}) async {
  await tester.tap(find.text(loadingText));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
