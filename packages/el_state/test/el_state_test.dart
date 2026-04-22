import 'package:el_state/el_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _baseTest();
  _memoryLeakTest();
  _listenablesTest();
}

Future<dynamic> _push(BuildContext context, Widget child) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => child));
}

class _Util {
  _Util._();

  static int getBuilderFunLength(Obs obs) {
    return obs.obsBuilders.length;
  }
}

/// 通用的子页面，包含一个 back 返回文本按钮
class ChildPage extends StatelessWidget {
  const ChildPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Text('back'),
        ),
        child,
      ],
    );
  }
}

/// 局部状态小部件
class LocalStateWidget extends StatelessWidget {
  const LocalStateWidget(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final count = Obs(0);
    return GestureDetector(
      onTap: () {
        count.value++;
      },
      child: ObsBuilder(
        builder: (context) {
          return Text('$name: $count');
        },
      ),
    );
  }
}

// ============================================================================
// 基础测试
// ============================================================================

void _baseTest() {
  group('Obs 基础测试', () {
    testWidgets('局部状态测试', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LocalStateWidget('count')),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
      await tester.tap(find.byType(GestureDetector));
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('count: 3'), findsOneWidget);

      // 重新挂载小部件，状态将被重置
      await tester.pumpWidget(
        MaterialApp(home: LocalStateWidget('count')),
      );
      expect(find.text('count: 0'), findsOneWidget);
    });

    testWidgets('测试 ListenableBuilder、ValueListenableBuilder', (tester) async {
      final count = Obs(0);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  ObsBuilder(
                    builder: (context) {
                      return Text('ObsBuilder: $count');
                    },
                  ),
                  ListenableBuilder(
                    listenable: count,
                    builder: (context, child) {
                      return Text('ListenableBuilder: $count');
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: count,
                    builder: (context, value, child) {
                      return Text('ValueListenableBuilder: $value');
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );

      count.value = 100;

      await tester.pump();
      expect(find.text('ObsBuilder: 100'), findsOneWidget);
      expect(find.text('ListenableBuilder: 100'), findsOneWidget);
      expect(find.text('ListenableBuilder: 100'), findsOneWidget);
    });

    /// 当父组件发生变更时，局部状态会被重置，但如果使用 const 修饰，则依旧可以保持状态
    testWidgets('局部状态重新构建测试', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _BaseTestPage1()));

      await tester.tap(find.text('count1: 0'));
      await tester.tap(find.text('count2: 0'));
      await tester.pump();
      expect(find.text('count1: 1'), findsOneWidget);
      expect(find.text('count2: 1'), findsOneWidget);

      await tester.tap(find.text('count: 0'));
      await tester.pump();
      expect(find.text('count1: 0'), findsOneWidget);
      expect(find.text('count2: 1'), findsOneWidget);
    });

    /// Obs变量可以放置任意位置，当放在组件外部时它将变成全局响应式变量
    testWidgets('全局状态测试', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _BaseTestPage2()));
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);

      // 重新挂载小部件，状态不会重置
      await tester.pumpWidget(const MaterialApp(home: _BaseTestPage2()));
      expect(find.text('count: 1'), findsOneWidget);
    });

    /// 当退出页面时，保存的状态将被重置
    testWidgets('状态路由测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  _push(
                    context,
                    const ChildPage(child: LocalStateWidget('count')),
                  );
                },
                child: const Text('child page'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('child page'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('count: 0'));
      await tester.pump();
      expect(find.text('count: 1'), findsOneWidget);
      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('child page'));
      await tester.pumpAndSettle();
      expect(find.text('count: 0'), findsOneWidget);
    });

    testWidgets('退出路由后监听函数是否被清除', (tester) async {
      final count = Obs(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  _push(
                    context,
                    ChildPage(
                      child: GestureDetector(
                        onTap: () {
                          count.value++;
                        },
                        child: ObsBuilder(
                          builder: (context) {
                            return Text('count: ${count.value}');
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('child page'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('child page'));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(count), 1);
      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(count), 0);
    });
  });
}

class _BaseTestPage1 extends StatefulWidget {
  const _BaseTestPage1();

  @override
  State<_BaseTestPage1> createState() => _BaseTestPage1State();
}

class _BaseTestPage1State extends State<_BaseTestPage1> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              count++;
            });
          },
          child: Text('count: $count'),
        ),
        // ignore: prefer_const_constructors
        LocalStateWidget('count1'),
        const LocalStateWidget('count2'),
      ],
    );
  }
}

class _BaseTestPage2 extends StatelessWidget {
  const _BaseTestPage2();

  static final _count = Obs(0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _count.value++;
      },
      child: ObsBuilder(
        builder: (context) {
          return Text('count: ${_count.value}');
        },
      ),
    );
  }
}

// ============================================================================
// 内存泄漏测试
// ============================================================================

void _memoryLeakTest() {
  group('Obs 内存泄漏测试', () {
    testWidgets('内存泄漏测试1', (tester) async {
      _GlobalState state = _GlobalState(false);
      expect(state.count.value, 0);
      tester.binding.scheduleWarmUpFrame();
      expect(state.activeCountWatch, false);
      // 对于嵌套 ObsBuilder，更新内部响应式变量不会影响外部
      await tester.pumpWidget(
        _MainApp(state: state, child: const _NestBuilder()),
      );
      expect(state.activeCountWatch, false);
      expect(find.text('parentUpdateCount: 0'), findsOneWidget);
      await tester.tap(find.text('count1: 0'));
      await tester.pump();
      expect(state.activeCountWatch, true);
      expect(find.text('parentUpdateCount: 0'), findsOneWidget);
      expect(_Util.getBuilderFunLength(state.count), 1);
      // 移除、重新建立连接
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('parentUpdateCount: 2'), findsOneWidget);
      // 点击count1，外部 ObsBuilder 也会发生构建
      await tester.tap(find.text('count1: 1'));
      await tester.pump();
      // 修复：动态依赖切换后，外部 ObsBuilder 会正确解绑不再使用的 Obs
      // 所以点击内部 count1 不应导致外部重建
      expect(find.text('parentUpdateCount: 2'), findsOneWidget);
      expect(_Util.getBuilderFunLength(state.count), 1);
    });

    testWidgets('内存泄漏测试2', (tester) async {
      // 模拟监听函数需要立即触发
      _GlobalState state = _GlobalState(true);
      // count使用了 late 修饰，所以判断监听函数是否触发前需要先使用它，这里只是做了判断，并未做修改
      expect(state.count.value, 0);
      tester.binding.scheduleWarmUpFrame();
      // 监听函数已立即触发，它修改了 activeCountWatch 变量
      expect(state.activeCountWatch, true);

      await tester.pumpWidget(
        _MainApp(state: state, child: const _StateTestWidget()),
      );

      // 模拟反复销毁 count1-1 的 ObsBuilder，检测 count 依赖的构建函数集合是否正确
      expect(_Util.getBuilderFunLength(state.count), 2);
      await tester.tap(find.text('count1-1: 0'));
      await tester.pump();
      expect(state.activeCountWatch, true);
      expect(find.text('count1-1: 1'), findsOneWidget);
      expect(find.text('count1-2: 1'), findsOneWidget);
      expect(find.text('count2: 0'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(state.count), 1);

      await tester.tap(find.text('count2: 0'));
      await tester.pump();
      expect(find.text('count1-2: 1'), findsOneWidget);
      expect(find.text('count2: 1'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(state.count), 2);

      await tester.tap(find.text('count1-1: 1'));
      await tester.pump();
      expect(find.text('count1-1: 2'), findsOneWidget);
      expect(find.text('count1-2: 2'), findsOneWidget);
      expect(find.text('count2: 1'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(state.count), 1);

      // 进入子页面会绑定1000个响应式构建器，所以 Obs 注册的依赖长度要为1001
      await tester.tap(find.text('child page'));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(state.count2), 1001);
      // 重置响应式变量，count2预期值要为0
      await tester.tap(find.text('reset count2'));
      await tester.pumpAndSettle();
      expect(find.text('child-count2: 0'), findsWidgets);
      // 返回页面，需要自动销毁1000个依赖，count2的依赖预期值要为1
      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();
      expect(_Util.getBuilderFunLength(state.count2), 1);

      // 一旦此变量被销毁，则不可再使用，这是 ChangeNotifier 的机制，所以下方代码需要注释掉
      state.count2.dispose();
      await tester.pumpAndSettle();
      expect(find.text('count2: 0'), findsOneWidget);
      // await tester.tap(find.text('count2: 0'));
      // await tester.pumpAndSettle();
      // expect(find.text('count2: 1'), findsOneWidget);

      // 被销毁的变量可以重新赋值，然后继续使用
      state.count2 = Obs(10);
      await tester.tap(find.byType(Switch)); // 更新 switch 让页面刷新
      await tester.pumpAndSettle();
      await tester.tap(find.text('count2: 10'));
      await tester.pumpAndSettle();
      expect(find.text('count2: 11'), findsOneWidget);
    });
  });
}

class _GlobalState {
  bool activeCountWatch = false;

  _GlobalState(this.immediate);

  /// 是否立即运行一次 count 监听函数，count 使用 late 修饰，
  /// 想要生效必须先访问一次 count
  final bool immediate;

  late final count = Obs(
    0,
    immediate: immediate,
    onChanged: (newValue) {
      activeCountWatch = true;
    },
  );
  var count2 = Obs(0);
}

class _MainApp extends StatelessWidget {
  const _MainApp({required this.state, required this.child});

  final _GlobalState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _StateProvider(
      state,
      child: MaterialApp(home: Material(child: child)),
    );
  }
}

class _StateProvider extends InheritedWidget {
  const _StateProvider(this.state, {required super.child});

  final _GlobalState state;

  static _StateProvider of(BuildContext context) {
    final _StateProvider? result = context
        .dependOnInheritedWidgetOfExactType<_StateProvider>();
    assert(result != null, 'No _StateProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_StateProvider oldWidget) => true;
}

class _NestBuilder extends StatefulWidget {
  const _NestBuilder();

  @override
  State<_NestBuilder> createState() => _NestBuilderState();
}

class _NestBuilderState extends State<_NestBuilder> {
  int parentUpdateCount = -1;
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    final state = _StateProvider.of(context).state;
    return Column(
      children: [
        ObsBuilder(
          builder: (context) {
            parentUpdateCount++;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: flag,
                  onChanged: (v) => setState(() {
                    flag = v;
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.count.value++;
                  },
                  // 不要出现这种写法，这会导致 count 变量持续依赖外部 ObsBuilder
                  child: flag
                      ? ObsBuilder(
                          builder: (context) {
                            return Text('count1: ${state.count.value}');
                          },
                        )
                      : Text('count1: ${state.count.value}'),
                ),
                Text('parentUpdateCount: $parentUpdateCount'),
                ElevatedButton(
                  onPressed: () {
                    state.count2.value++;
                  },
                  child: Text('count2: ${state.count2.value}'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StateTestWidget extends StatefulWidget {
  const _StateTestWidget();

  @override
  State<_StateTestWidget> createState() => _StateTestWidgetState();
}

class _StateTestWidgetState extends State<_StateTestWidget> {
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    final state = _StateProvider.of(context).state;

    return Column(
      children: [
        Switch(
          value: flag,
          onChanged: (v) => setState(() {
            flag = v;
          }),
        ),
        ObsBuilder(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (flag)
                  ElevatedButton(
                    onPressed: () {
                      state.count.value++;
                    },
                    child: ObsBuilder(
                      builder: (context) {
                        return Text('count1-1: ${state.count.value}');
                      },
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    state.count.value++;
                  },
                  child: Text('count1-2: ${state.count.value}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.count2.value++;
                  },
                  child: Text('count2: ${state.count2.value}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _push(context, _ChildPage(state: state));
                  },
                  child: Text('child page'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ChildPage extends StatelessWidget {
  const _ChildPage({required this.state});

  final _GlobalState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('back'),
          ),
          ElevatedButton(
            onPressed: () {
              state.count2.value = 0;
            },
            child: Text('reset count2'),
          ),
          ...List.generate(
            1000,
            (index) => ObsBuilder(
              builder: (context) {
                return Text('child-count2: ${state.count2.value}');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Watch 监听测试
// ============================================================================

/// ObsBuilder listenables 属性测试
void _listenablesTest() {
  testWidgets('ObsBuilder listenables 属性测试', (tester) async {
    await tester.pumpWidget(const _ListenablesTestPage());
    expect(find.text('buildCount: 0'), findsOneWidget);
    await tester.tap(find.text('count1++'));
    await tester.pump();
    expect(find.text('buildCount: 0'), findsOneWidget);

    // 监听 count1
    await tester.tap(find.byKey(_ListenablesTestPage._switch1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('count1++'));
    await tester.pump();
    expect(find.text('buildCount: 1'), findsOneWidget);
    await tester.tap(find.text('count2++')); // 只监听了count1，所以count2++无变化
    await tester.pump();
    expect(find.text('buildCount: 1'), findsOneWidget);

    // 监听 count1、count2
    await tester.tap(find.byKey(_ListenablesTestPage._switch2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('count1++'));
    await tester.pump();
    await tester.tap(find.text('count2++'));
    await tester.pump();
    expect(find.text('buildCount: 2'), findsOneWidget);

    // 不监听count2
    await tester.tap(find.byKey(_ListenablesTestPage._switch2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('count1++'));
    await tester.pump();
    await tester.tap(find.text('count2++'));
    await tester.pump();
    expect(find.text('buildCount: 1'), findsOneWidget);

    // 不监听count1
    await tester.tap(find.byKey(_ListenablesTestPage._switch1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('count1++'));
    await tester.pump();
    await tester.tap(find.text('count2++'));
    await tester.pump();
    expect(find.text('buildCount: 0'), findsOneWidget);
  });
}

class _ListenablesTestPage extends StatefulWidget {
  const _ListenablesTestPage();

  static final _switch1 = const Key('switch1');
  static final _switch2 = const Key('_switch2');

  @override
  State<_ListenablesTestPage> createState() => _ListenablesTestPageState();
}

class _ListenablesTestPageState extends State<_ListenablesTestPage> {
  final count1 = Obs(0);
  final count2 = Obs(0);

  bool flag1 = false;
  bool flag2 = false;

  int buildCount = -1;

  @override
  Widget build(BuildContext context) {
    buildCount = -1;
    return MaterialApp(
      home: Material(
        child: Column(
          children: [
            Switch(
              key: _ListenablesTestPage._switch1,
              value: flag1,
              onChanged: (v) => setState(() {
                flag1 = v;
              }),
            ),
            Switch(
              key: _ListenablesTestPage._switch2,
              value: flag2,
              onChanged: (v) => setState(() {
                flag2 = v;
              }),
            ),
            GestureDetector(
              onTap: () {
                count1.value++;
              },
              child: ObsBuilder(
                builder: (context) {
                  return const Text('count1++');
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                count2.value++;
              },
              child: ObsBuilder(
                builder: (context) {
                  return const Text('count2++');
                },
              ),
            ),
            ObsBuilder(
              ignoreObs: true,
              listenables: [if (flag1) count1, if (flag2) count2],
              builder: (context) {
                buildCount++;
                return Text('buildCount: $buildCount');
              },
            ),
          ],
        ),
      ),
    );
  }
}
