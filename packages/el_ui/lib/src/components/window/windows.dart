part of 'index.dart';

class ElWin10Windows extends StatelessWidget {
  /// Win10 风格窗口
  const ElWin10Windows({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final model = ElWindow.of(context);
    return Container(
      clipBehavior: .hardEdge,
      decoration: BoxDecoration(boxShadow: ElFlutterUtil.shadow(elevation: 4)),
      child: Column(
        children: [
          ElEvent(
            style: ElEventStyle(
              ignoreStatus: true,
              onPointerDown: (e) {
                ElWindowResizer.startDrag(context, e);
              },
            ),
            child: ElDefaultColor(
              Colors.white,
              child: Builder(
                builder: (context) {
                  return Container(
                    height: 44,
                    decoration: BoxDecoration(color: context.elDefaultColor),
                    child: Row(
                      children: [
                        Gap(8),
                        if (model.title != null)
                          Expanded(
                            child: ElRichText(
                              model.title,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ElWinMinimizeButton(onPressed: () {}),
                        ElWinMaximizeButton(
                          onPressed: () {
                            ElWindowResizer.isMaximize(context)
                                ? ElWindowResizer.reset(context)
                                : ElWindowResizer.maximize(context);
                          },
                        ),
                        ElWinCloseButton(
                          onPressed: () {
                            model.controller.removeWindow(groupKey: model.groupKey, id: model.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ElWin11Windows extends StatelessWidget {
  /// Win11 风格窗口
  const ElWin11Windows({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final model = ElWindow.of(context);
    return Container(
      clipBehavior: .hardEdge,
      decoration: BoxDecoration(borderRadius: .circular(8), boxShadow: ElFlutterUtil.shadow(elevation: 6)),
      child: Column(
        children: [
          ElEvent(
            style: ElEventStyle(
              onPointerDown: (e) {
                ElWindowResizer.startDrag(context, e);
              },
            ),
            child: ElDefaultColor(
              Colors.white,
              child: Builder(
                builder: (context) {
                  return Container(
                    height: 44,
                    decoration: BoxDecoration(color: context.elDefaultColor),
                    child: Row(
                      children: [
                        Gap(8),
                        if (model.title != null)
                          Expanded(
                            child: ElRichText(
                              model.title,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ElWinMinimizeButton(onPressed: () {}),
                        ElWinMaximizeButton(onPressed: () {}),
                        ElWinCloseButton(
                          onPressed: () {
                            model.controller.removeWindow(groupKey: model.groupKey, id: model.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ElMacWindows extends StatelessWidget {
  /// Mac 风格窗口
  const ElMacWindows({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
