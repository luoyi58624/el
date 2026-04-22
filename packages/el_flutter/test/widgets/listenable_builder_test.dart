import 'package:el_dart/ext.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import '../common.dart';

void main() {
  final controller = _TestController();
  _baseTest(controller);
}

void _baseTest(_TestController controller) {
  group('ElListenableBuilder 测试', () {
    testWidgets('局部状态测试', (tester) async {
      await tester.pumpWidget(_TestApp(controller));

      // button2 由于只监听 count2 的变化，所以只有 button1 重建
      await tester.tap(find.byKey(_TestApp.key1));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
      expect(controller.button1Builds - controller.button2Builds, 1);

      // button1 由于没有设置 select 精确构建，所以更新 count2 将会重建 button1
      await tester.tap(find.byKey(_TestApp.key2));
      await tester.pump();
      expect(find.text('count2: 1'), findsOneWidget);
      expect(controller.button1Builds - controller.button2Builds, 1);

      // 测试自定义重建条件，当前重建条件是 count1 >= 3 && count2 <=5，
      // 当前点击 count1、count2 == 2，所以现在还不会重建
      await tester.tap(find.byKey(_TestApp.key3));
      await tester.pump();
      expect(find.text('count3: 0'), findsOneWidget);
      expect(find.text('count4: 0'), findsOneWidget);

      await tester.tap(find.byKey(_TestApp.key3));
      await tester.pump();
      expect(find.text('count3: 3'), findsOneWidget);
      expect(find.text('count4: 3'), findsOneWidget);

      await tester.tap(find.byKey(_TestApp.key3));
      await tester.pump();
      await tester.tap(find.byKey(_TestApp.key3));
      await tester.pump();
      expect(find.text('count3: 5'), findsOneWidget);
      expect(find.text('count4: 5'), findsOneWidget);

      // 再次点击，count2 == 6，不满足第二个条件，所以不会重建
      await tester.tap(find.byKey(_TestApp.key3));
      await tester.pump();
      expect(find.text('count3: 5'), findsOneWidget);
      expect(find.text('count4: 5'), findsOneWidget);

      // button4 只监听 count1、count3 的变化，所以它应该只重建 2 次
      controller.button4Builds = 0;
      await tester.tap(find.byKey(_TestApp.key1));
      await tester.pump();
      await tester.tap(find.byKey(_TestApp.key2));
      await tester.pump();
      await tester.tap(find.byKey(_TestApp.key4));
      await tester.pump();
      expect(controller.button4Builds, 2);
    });
  });
}

class _TestController with ChangeNotifier {
  int count1 = 0;
  int count2 = 0;
  int count3 = 0;

  // 记录 button1、button2 重建次数
  int button1Builds = 0;
  int button2Builds = 0;
  int button4Builds = 0;

  void notify() {
    notifyListeners();
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp(this.controller);

  final _TestController controller;

  static final key1 = const Key('key1');
  static final key2 = const Key('key2');
  static final key3 = const Key('key3');
  static final key4 = const Key('key4');

  @override
  Widget build(BuildContext context) {
    final button1 = GestureDetector(
      key: key1,
      onTap: () {
        controller.count1++;
        controller.notify();
      },
      child: ElListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          controller.button1Builds++;
          return Text('count: ${controller.count1}');
        },
      ),
    );

    final button2 = GestureDetector(
      key: key2,
      onTap: () {
        controller.count2++;
        controller.notify();
      },
      child: ElListenableBuilder(
        listenable: controller,
        select: (_TestController c) => c.count2,
        builder: (context, child) {
          controller.button2Builds++;
          return Text('count2: ${controller.count2}');
        },
      ),
    );

    final button3 = GestureDetector(
      key: key3,
      onTap: () {
        controller.count1++;
        controller.count2++;
        controller.notify();
      },
      child: ElListenableBuilder(
        listenable: controller,
        select: (_TestController c) => [c.count1, c.count2],
        // 自定义重建条件
        shouldRebuild: (newValue, oldValue) => newValue.first >= 3 && newValue.last <= 5,
        builder: (context, child) {
          return Column(children: [Text('count3: ${controller.count1}'), Text('count4: ${controller.count2}')]);
        },
      ),
    );

    final button4 = GestureDetector(
      key: key4,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.count3++;
        controller.notify();
      },
      child: ElListenableBuilder(
        listenable: controller,
        select: (_TestController c) => [c.count1, c.count3],
        shouldRebuild: (newValue, oldValue) => newValue.neq(oldValue),
        builder: (context, child) {
          controller.button4Builds++;
          return SizedBox(width: 100, height: 100);
        },
      ),
    );

    return TestApp(child: Column(children: [button1, button2, button3, button4]));
  }
}
