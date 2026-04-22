part of 'index.dart';

class ElMenuBar extends StatelessWidget {
  /// 菜单栏小部件（仅适用于桌面端），
  const ElMenuBar({super.key, required this.children});

  final List<ElMenuBarItem> children;

  /// 构建菜单栏外观，你可以覆写此方法自定义主题
  Widget buildWrapper(BuildContext context) => Row(children: children);

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      skipTraversal: true,
      child: FocusTraversalGroup(
        policy: WidgetOrderTraversalPolicy(),
        child: Builder(
          builder: (context) {
            final focusScopeNode = FocusScope.of(context);
            return ElShortcut(
              shortcuts: {
                const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                  focusScopeNode.previousFocus();
                  focusScopeNode.previousFocus();
                  return true;
                },
                const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                  focusScopeNode.nextFocus();
                  return true;
                },
              },
              child: buildWrapper(context),
            );
          },
        ),
      ),
    );
  }
}
