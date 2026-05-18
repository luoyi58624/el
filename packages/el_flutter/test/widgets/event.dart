import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:el_flutter/el_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common.dart';

void main() {
  group('ElListener 测试', () {
    _listenerTest();
  });

  group('ElTap 测试', () {
    _tapTest();
  });

  group('冒泡测试', () {
    _stopPropagationTest();
  });

  group('ElDrag 拖拽测试', () {
    _dragTest();
  });
}

void _listenerTest() {
  testWidgets('基础测试', (tester) async {
    int count = 0;

    await tester.pumpWidget(
      TestApp(
        child: ElListener(
          style: ElListenerStyle(
            onPointerDown: (e) {
              count++;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    final gesture = await tester.startGesture(Offset.zero);
    await gesture.up();
    expect(count, 1);

    final gesture2 = await tester.startGesture(Offset.zero);
    await gesture2.up();
    expect(count, 2);

    // ElListenerGestureRecognizer 手势只能识别一个指针事件
    final gesture3 = await tester.startGesture(Offset.zero);
    final gesture4 = await tester.startGesture(Offset.zero);
    await gesture3.up();
    await gesture4.up();

    expect(count, 3);
  });

  testWidgets('冒泡测试', (tester) async {
    int count = 0;
    int count2 = 0;
    bool stopPropagation = false;
    late int currentPointer;
    await tester.pumpWidget(
      TestApp(
        child: ElListener(
          style: ElListenerStyle(
            onPointerDown: (e) {
              count++;
            },
          ),
          child: ElListener(
            style: ElListenerStyle(
              onPointerDown: (e) {
                currentPointer = e.pointer;
                count2++;
                if (stopPropagation) {
                  ElListenerPointerManager.managers[e.pointer]?.prevent = true;
                }
              },
            ),
            child: Text('text'),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(Offset.zero);
    await gesture.up();
    expect(count, 1);
    expect(count2, 1);

    stopPropagation = true;
    final gesture2 = await tester.startGesture(Offset.zero);
    await gesture2.up();
    expect(count, 1);
    expect(count2, 2);

    // ElListener 需要自动清理竞技场
    expect(ElListenerPointerManager.managers[currentPointer], null);
  });
}

void _tapTest() {
  testWidgets('基础测试', (tester) async {
    int count = 0;
    bool flag = false;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          style: ElTapStyle(
            onTap: (e) {
              count++;
            },
            onTapDown: (e) {
              flag = true;
            },
            onTapUp: (e) {
              flag = false;
            },
            onCancel: (e) {
              flag = false;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    final gesture = await tester.startGesture(Offset.zero);
    expect(flag, true);
    await gesture.up();
    expect(flag, false);
    expect(count, 1);

    final gesture2 = await tester.startGesture(Offset.zero);
    expect(flag, true);
    await gesture2.moveTo(Offset(20, 20));
    expect(flag, false);
    await gesture2.up();
    expect(count, 1);
  });

  testWidgets('其他按键测试', (tester) async {
    bool flag = false;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          style: ElTapStyle(
            onSecondaryTapDown: (e) {
              flag = true;
            },
            onSecondaryTapUp: (e) {
              flag = false;
            },
            onTertiaryTapDown: (e) {
              flag = true;
            },
            onTertiaryTapUp: (e) {
              flag = false;
            },
            onForwardTapDown: (e) {
              flag = true;
            },
            onForwardTapUp: (e) {
              flag = false;
            },
            onBackTapDown: (e) {
              flag = true;
            },
            onBackTapUp: (e) {
              flag = false;
            },
            onCancel: (e) {
              flag = false;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    final gesture = await tester.startGesture(Offset.zero, buttons: kSecondaryButton);
    expect(flag, true);
    await gesture.up();
    expect(flag, false);

    final gesture2 = await tester.startGesture(Offset.zero, buttons: kSecondaryButton);
    expect(flag, true);
    await gesture2.moveTo(Offset(20, 20));
    expect(flag, false);
    await gesture2.up();

    final gesture3 = await tester.startGesture(Offset.zero, buttons: kTertiaryButton);
    expect(flag, true);
    await gesture3.up();
    expect(flag, false);

    final gesture4 = await tester.startGesture(Offset.zero, buttons: kForwardMouseButton);
    expect(flag, true);
    await gesture4.up();
    expect(flag, false);

    final gesture5 = await tester.startGesture(Offset.zero, buttons: kBackMouseButton);
    expect(flag, true);
    await gesture5.up();
    expect(flag, false);
  });

  testWidgets('长按测试', (tester) async {
    final key = const Key('key');

    int count = 0;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          style: ElEventStyle(
            onLongPress: (e) {
              count++;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    await tester.longPress(find.byKey(key));
    expect(count, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('双击测试', (tester) async {
    final key = const Key('key');
    int count = 0;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          key: key,
          style: ElTapStyle(
            onDoubleTap: (tapCount) {
              if (tapCount == 2) count++;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    expect(count, 0);
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key));
    expect(count, 1);

    // 等待 300 毫秒重置连击计时器
    await tester.pump(Duration(milliseconds: 300));
    await tester.tap(find.byKey(key));
    // 超时导致连击中断
    await tester.pump(Duration(milliseconds: 300));
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.pump(Duration(milliseconds: 299));
    await tester.tap(find.byKey(key));
    expect(count, 2);
    await tester.pump(Duration(milliseconds: 300));
  });

  testWidgets('单击 + 双击测试', (tester) async {
    final key = const Key('key');
    int doubleTapInterval = 50;
    int count = 0;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          key: key,
          style: ElTapStyle(
            doubleTapInterval: doubleTapInterval,
            onTap: (e) {
              count++;
            },
            onDoubleTap: (tapCount) {
              if (tapCount == 2) count++;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    // 单击、双击同时注册，双击不会影响单击的执行，所以单击没有任何延迟
    await tester.tap(find.byKey(key));
    expect(count, 1);
    // 当再次点击时，会同时触发单击 + 双击事件，所以 count 会自增 2 次
    await tester.tap(find.byKey(key));
    expect(count, 3);
    await tester.tap(find.byKey(key));
    expect(count, 4);
    await tester.tap(find.byKey(key));
    expect(count, 5);

    // 重置连击计时器
    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    expect(count, 7);
    await tester.tap(find.byKey(key));
    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    expect(count, 10);
    await tester.pump(Duration(milliseconds: doubleTapInterval));
  });

  testWidgets('三击测试', (tester) async {
    final key = const Key('key');
    int doubleTapInterval = 50;
    int count = 0;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          key: key,
          style: ElTapStyle(
            doubleTapInterval: doubleTapInterval,
            onDoubleTap: (tapCount) {
              if (tapCount == 3) count++;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    expect(count, 0);
    await tester.tap(find.byKey(key));
    expect(count, 0);
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key));
    expect(count, 1);

    // 重置连击计时器
    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key));
    await tester.tap(find.byKey(key));
    expect(count, 2);

    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    await tester.tap(find.byKey(key));
    expect(count, 2);
    await tester.pump(Duration(milliseconds: doubleTapInterval - 1));
    await tester.tap(find.byKey(key));
    expect(count, 3);
    await tester.tap(find.byKey(key));
    await tester.tap(find.byKey(key));
    await tester.tap(find.byKey(key));
    expect(count, 3);
    await tester.pump(Duration(milliseconds: doubleTapInterval - 1));
    expect(count, 3);
    await tester.pump(Duration(milliseconds: doubleTapInterval));
    await tester.tap(find.byKey(key));
    await tester.tap(find.byKey(key));
    await tester.pump(Duration(milliseconds: doubleTapInterval - 1));
    await tester.tap(find.byKey(key));
    expect(count, 4);
    await tester.pump(Duration(milliseconds: doubleTapInterval));
  });

  testWidgets('单击取消测试', (tester) async {
    final key = const Key('key');
    int count = 0;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          key: key,
          style: ElTapStyle(
            behavior: HitTestBehavior.opaque,
            onTap: (e) {
              count++;
            },
          ),

          child: Text('tap'),
        ),
      ),
    );

    final gesture = await tester.press(find.byKey(key));
    await gesture.up();
    await tester.pump();
    expect(count, 1);

    final gesture2 = await tester.startGesture(Offset.zero);
    await gesture2.moveTo(Offset(20, 20));
    await gesture2.up();
    expect(count, 1);
  });

  testWidgets('单击 + 右键测试', (tester) async {
    final key = const Key('key');
    int count = 0;

    await tester.pumpWidget(
      TestApp(
        child: ElTap(
          key: key,
          style: ElTapStyle(
            onTap: (e) {
              count++;
            },
            onSecondaryTapUp: (e) {
              count++;
            },
          ),
          child: Text('text'),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.tap(find.byKey(key), buttons: kSecondaryButton);
    expect(count, 2);
    await tester.pumpAndSettle();
  });

  testWidgets('ElEvent 状态测试', (tester) async {
    final key = const Key('key');

    Color bgColor = Colors.transparent;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          style: ElEventStyle(tapUpDelay: 0),
          child: Builder(
            builder: (context) {
              bgColor = context.hasTap ? Colors.green.elOpacity(0.5) : Colors.transparent;
              return ColoredBox(color: bgColor, child: SizedBox.expand());
            },
          ),
        ),
      ),
    );
    final gesture = await tester.press(find.byKey(key));
    await tester.pump();
    expect(bgColor, Colors.green.elOpacity(0.5));
    await gesture.up();
    await tester.pump();
    expect(bgColor, Colors.transparent);
  });

  testWidgets('ElEvent 状态测试（延迟点击）', (tester) async {
    final key = const Key('key');

    Color bgColor = Colors.transparent;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          child: Builder(
            builder: (context) {
              bgColor = context.hasTap ? Colors.green.elOpacity(0.5) : Colors.transparent;
              return ColoredBox(color: bgColor, child: SizedBox.expand());
            },
          ),
        ),
      ),
    );
    final gesture = await tester.press(find.byKey(key));
    await tester.pump();
    expect(bgColor, Colors.green.elOpacity(0.5));
    await gesture.up();
    // ElEvent 默认设置了 100 毫秒的延迟抬起时间
    await tester.pump(Duration(milliseconds: 100));
    expect(bgColor, Colors.transparent);
  });
}

void _stopPropagationTest() {
  testWidgets('嵌套 1000 个 ElListener 冒泡测试', (tester) async {
    final key = const Key('key');

    int count = 0;
    bool stopPropagation = false;

    // 比较极端的写法，嵌套 1000 个事件小部件测试是否能够正确清理资源
    Widget nestWidget(Widget child) {
      Widget result = child;
      for (int i = 0; i < 1000; i++) {
        result = ElListener(
          style: ElListenerStyle(
            onPointerDown: (e) {
              count++;
            },
          ),
          child: result,
        );
      }

      return result;
    }

    await tester.pumpWidget(
      TestApp(
        child: nestWidget(
          ElListener(
            key: key,
            style: ElListenerStyle(
              onPointerDown: (e) {
                if (stopPropagation) {
                  ElListenerPointerManager.managers[e.pointer]?.prevent = true;
                }
                count++;
              },
            ),
            child: Text('tap'),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(key));
    expect(count, 1001);
    await tester.pump();

    await tester.tap(find.byKey(key));
    expect(count, 2002);
    await tester.pump();

    stopPropagation = true;
    await tester.tap(find.byKey(key));
    expect(count, 2003);
    await tester.pump();

    await tester.tap(find.byKey(key));
    expect(count, 2004);
    await tester.pumpAndSettle();
  });

  testWidgets('ElEvent 冒泡测试', (tester) async {
    final key = const Key('key');

    final stopPropagation = ValueNotifier(false);
    Color bgColor = Colors.transparent;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          child: Builder(
            builder: (context) {
              bgColor = context.hasTap ? Colors.green.elOpacity(0.5) : Colors.transparent;
              return ColoredBox(
                color: bgColor,
                child: SizedBox.expand(
                  child: Center(
                    child: ListenableBuilder(
                      listenable: stopPropagation,
                      builder: (context, child) {
                        return ElStopPropagation(
                          prevent: stopPropagation.value,
                          child: ElBox(
                            style: ElBoxStyle(width: 100, height: 100, decoration: BoxDecoration(color: Colors.green)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    final gesture = await tester.press(find.byKey(key));
    await tester.pump();
    expect(bgColor, Colors.green.elOpacity(0.5));
    await gesture.up();
    await tester.pump(Duration(milliseconds: 100));
    expect(bgColor, Colors.transparent);

    stopPropagation.value = true;
    await tester.pump();
    final gesture2 = await tester.press(find.byKey(key));
    await tester.pump();
    expect(bgColor, Colors.transparent);
    await gesture2.up();
    await tester.pumpAndSettle();
  });

  testWidgets('ElStopPropagation 阻止冒泡小部件测试', (tester) async {
    final key = const Key('key');

    Color bgColor = Colors.transparent;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          child: Builder(
            builder: (context) {
              bgColor = context.hasTap ? Colors.green.elOpacity(0.5) : Colors.transparent;
              return ColoredBox(
                color: bgColor,
                child: SizedBox.expand(
                  child: Center(
                    child: ElStopPropagation(
                      key: key,
                      child: ElBox(
                        style: ElBoxStyle(width: 100, height: 100, decoration: BoxDecoration(color: Colors.green)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    final gesture = await tester.press(find.byKey(key));
    await tester.pump();
    expect(bgColor, Colors.transparent);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('ElEvent 阻止 GestureDetector 冒泡', (tester) async {
    final key = const Key('key');
    final key2 = const Key('key2');
    int count = 0;
    final preventTapGesture = ValueNotifier(false);
    await tester.pumpWidget(
      TestApp(
        child: GestureDetector(
          key: key,
          onTap: () {
            count++;
          },
          child: ListenableBuilder(
            listenable: preventTapGesture,
            builder: (context, child) {
              return ElStopPropagation(
                preventTapGesture: preventTapGesture.value,
                child: ElEvent(
                  key: key2,
                  style: ElEventStyle(
                    onTap: (e) {
                      count++;
                    },
                  ),
                  child: Text('text'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    expect(count, 2);
    await tester.pump();

    await tester.tap(find.byKey(key2));
    expect(count, 4);
    await tester.pump();

    preventTapGesture.value = true;

    await tester.tap(find.byKey(key));
    expect(count, 6);
    await tester.pump();

    await tester.tap(find.byKey(key2));
    expect(count, 7);
    await tester.pump(Duration(milliseconds: 100));
  });

  testWidgets('右键冒泡测试', (tester) async {
    final key = const Key('key');
    final key2 = const Key('key2');
    int count = 0;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          style: ElEventStyle(
            onSecondaryTapDown: (e) {
              count++;
            },
          ),
          child: ElEvent(
            key: key2,
            style: ElEventStyle(
              onSecondaryTapUp: (e) {
                count++;
              },
            ),
            child: Text('text'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key), buttons: kSecondaryButton);
    expect(count, 1);
    await tester.pump();

    await tester.tap(find.byKey(key2), buttons: kSecondaryButton);
    expect(count, 2);
    await tester.pumpAndSettle();
  });

  testWidgets('右键冒泡测试2', (tester) async {
    final key = const Key('key');
    final key2 = const Key('key2');
    int count1 = 0;
    int count2 = 0;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          style: ElEventStyle(
            onSecondaryTapDown: (e) {
              count1++;
            },
          ),
          child: ElEvent(
            key: key2,
            style: ElEventStyle(
              onSecondaryTapUp: (e) {
                count2++;
              },
            ),
            child: Text('text'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key), buttons: kSecondaryButton);
    expect(count1, 0);
    expect(count2, 1);
    await tester.pump();

    await tester.tap(find.byKey(key2), buttons: kSecondaryButton);
    expect(count1, 0);
    expect(count2, 2);
    await tester.pumpAndSettle();
  });

  testWidgets('单击 + 右键冒泡测试', (tester) async {
    final key = const Key('key');
    final key2 = const Key('key2');
    int count = 0;
    await tester.pumpWidget(
      TestApp(
        child: ElEvent(
          key: key,
          style: ElEventStyle(
            onSecondaryTapUp: (e) {
              count++;
            },
          ),
          child: ElEvent(
            key: key2,
            style: ElEventStyle(
              onTap: (e) {
                count++;
              },
              onSecondaryTapUp: (e) {
                count++;
              },
            ),
            child: Text('text'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(key));
    expect(count, 1);
    await tester.pump();

    await tester.tap(find.byKey(key2), buttons: kSecondaryButton);
    expect(count, 2);
    await tester.pumpAndSettle();
  });
}

final _box = ColoredBox(color: Colors.green, child: SizedBox.expand());

void _dragTest() {
  testWidgets('拖拽基础测试', (tester) async {
    int count = 0;
    late int currentPointer;
    // 嵌套拖拽事件只会执行一个手势
    await tester.pumpWidget(
      TestApp(
        child: ElDrag(
          style: ElDragStyle(
            onDragStart: (e) {
              count++;
            },
          ),
          child: ElDrag(
            style: ElDragStyle(
              onPointerDown: (e) {
                currentPointer = e.pointer;
              },
              onDragStart: (e) {
                count++;
              },
            ),
            child: _box,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(Offset.zero);
    expect(ElDragPointerManager.managers[currentPointer]?.pointers.length, 2);
    await gesture.moveTo(Offset(10, 10));
    expect(count, 1);
    expect(ElDragPointerManager.managers[currentPointer]?.pointers.length, 1);
    await gesture.up();
    expect(ElDragPointerManager.managers[currentPointer], null);

    final gesture2 = await tester.startGesture(Offset.zero);
    expect(ElDragPointerManager.managers[currentPointer]?.pointers.length, 2);
    await gesture2.moveTo(Offset(10, 10));
    expect(count, 2);
    expect(ElDragPointerManager.managers[currentPointer]?.pointers.length, 1);
    await gesture2.up();
    expect(ElDragPointerManager.managers[currentPointer], null);
  });

  testWidgets('拖拽方向测试', (tester) async {
    int count = 0;
    int verticalCount = 0;
    int horizontalCount = 0;
    int horizontalCount2 = 0;
    AxisDirection? direction;
    final preventDrag = ValueNotifier(false);

    await tester.pumpWidget(
      TestApp(
        child: ElDrag(
          style: ElDragStyle(
            axis: Axis.horizontal,
            onDragStart: (e) {
              direction = e.direction;
              horizontalCount++;
            },
          ),
          child: ElDrag(
            style: ElDragStyle(
              axis: Axis.vertical,
              onDragStart: (e) {
                direction = e.direction;
                verticalCount++;
              },
            ),
            child: ElDrag(
              style: ElDragStyle(
                axis: Axis.horizontal,
                onDragStart: (e) {
                  direction = e.direction;
                  horizontalCount2++;
                },
              ),
              child: ElDrag(
                style: ElDragStyle(
                  onPointerDown: (e) {
                    if (preventDrag.value) {
                      ElDragPointerManager.managers[e.pointer]!.prevent = true;
                    }
                  },
                  onDragStart: (e) {
                    direction = e.direction;
                    count++;
                  },
                ),
                child: _box,
              ),
            ),
          ),
        ),
      ),
    );

    Future<void> dragTest(Offset offset, VoidCallback fun) async {
      final gesture = await tester.startGesture(Offset.zero);
      await gesture.moveTo(offset);
      fun();
      await gesture.up();
      await tester.pump();
    }

    await dragTest(Offset(100, -30), () {
      expect(count, 0);
      expect(verticalCount, 0);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 1);
      expect(direction, AxisDirection.right);
    });

    await dragTest(Offset(100, 0), () {
      expect(count, 0);
      expect(verticalCount, 0);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 2);
      expect(direction, AxisDirection.right);
    });

    await dragTest(Offset(100, 30), () {
      expect(count, 0);
      expect(verticalCount, 0);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 3);
      expect(direction, AxisDirection.right);
    });

    await dragTest(Offset(100, 100), () {
      expect(count, 0);
      expect(verticalCount, 1);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 3);
      expect(direction, AxisDirection.down);
    });
    await dragTest(Offset(30, 100), () {
      expect(count, 0);
      expect(verticalCount, 2);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 3);
      expect(direction, AxisDirection.down);
    });
    await dragTest(Offset(0, 100), () {
      expect(count, 0);
      expect(verticalCount, 3);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 3);
      expect(direction, AxisDirection.down);
    });
    await dragTest(Offset(-30, 100), () {
      expect(count, 0);
      expect(verticalCount, 4);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 3);
      expect(direction, AxisDirection.down);
    });
    await dragTest(Offset(-100, 100), () {
      expect(count, 0);
      expect(verticalCount, 5);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 3);
      expect(direction, AxisDirection.down);
    });
    await dragTest(Offset(-100, 30), () {
      expect(count, 0);
      expect(verticalCount, 5);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 4);
      expect(direction, AxisDirection.left);
    });
    await dragTest(Offset(-100, 0), () {
      expect(count, 0);
      expect(verticalCount, 5);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 5);
      expect(direction, AxisDirection.left);
    });
    await dragTest(Offset(-100, -30), () {
      expect(count, 0);
      expect(verticalCount, 5);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 6);
      expect(direction, AxisDirection.left);
    });
    await dragTest(Offset(-100, -100), () {
      expect(count, 0);
      expect(verticalCount, 6);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 6);
      expect(direction, AxisDirection.up);
    });
    await dragTest(Offset(-30, -100), () {
      expect(count, 0);
      expect(verticalCount, 7);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 6);
      expect(direction, AxisDirection.up);
    });
    await dragTest(Offset(0, -100), () {
      expect(count, 0);
      expect(verticalCount, 8);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 6);
      expect(direction, AxisDirection.up);
    });

    preventDrag.value = true;
    await tester.pump();

    await dragTest(Offset(100, 100), () {
      expect(count, 1);
      expect(verticalCount, 8);
      expect(horizontalCount, 0);
      expect(horizontalCount2, 6);
      expect(direction, AxisDirection.down);
    });
  });

  // testWidgets('激活拖拽取消 tap 事件', (tester) async {
  //   int count = 0;
  //
  //   final tap = ElTapGestureRecognizer()
  //     ..style = ElTapStyle(
  //       onTap: () {
  //         count++;
  //       },
  //     );
  //   final drag = ElDragGestureRecognizer()..onDragStart = (e) {};
  //   await tester.pumpWidget(
  //     TestApp(
  //       child: Listener(
  //         onPointerDown: (e) {
  //           tap.addPointer(e);
  //           drag.addPointer(e);
  //         },
  //         child: _box,
  //       ),
  //     ),
  //   );
  //
  //   final gesture = await tester.startGesture(Offset.zero);
  //   await gesture.moveTo(Offset(4, 0));
  //   await gesture.up();
  //   expect(count, 1);
  //   await tester.pump();
  //
  //   final gesture2 = await tester.startGesture(Offset.zero);
  //   await gesture2.moveTo(Offset(10, 0));
  //   await gesture2.up();
  //   expect(count, 1);
  //   await tester.pump();
  // });
}
