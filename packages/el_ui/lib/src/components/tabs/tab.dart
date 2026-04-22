part of 'index.dart';

class ElTab extends StatelessWidget {
  const ElTab({super.key, required this.title, required this.child, this.leading, this.showClose = false});

  /// 标签标题
  final String title;

  /// 选中标签展示的目标小部件
  final Widget child;

  /// 前缀小部件
  final Widget? leading;

  /// 显示 close 按钮
  final bool showClose;

  Widget buildActiveBanner(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(color: context.elTheme.primary, borderRadius: .circular(1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final $key = key as ValueKey<int>;
    final themeData = ElTabsTheme.of(context);
    final $data = ElTabs.of(context);
    final isActive = $key.value == $data.modelValue;
    return ElEvent(
      child: Builder(
        builder: (context) {
          final hasHover = context.hasHover;
          return ElTagTheme(
            data: ElTagThemeData(bgColor: isActive || context.hasHover ? context.elTheme.primary : themeData.bgColor),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: themeData.bgColor,
                  padding: .only(left: 14, right: showClose ? 8 : 14),
                  child: Row(
                    children: [
                      DefaultTextStyle.merge(
                        style: isActive || context.hasHover ? themeData.activeTextStyle : themeData.textStyle,
                        child: ElRichText(title, style: TextStyle(height: 1.2)),
                      ),
                      if (showClose) const Gap(8),
                      if (showClose)
                        SizedBox(
                          height: themeData.height,
                          child: ElStopPropagation(
                            child: ElEvent(
                              style: ElEventStyle(onTap: (e) {}, behavior: HitTestBehavior.opaque),
                              child: Builder(
                                builder: (context) {
                                  return Center(
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      padding: .all(2),
                                      decoration: BoxDecoration(
                                        color: context.hasHover ? themeData.bgColor!.deepen(16) : null,
                                        borderRadius: .circular(10),
                                      ),
                                      child: Center(
                                        child: Visibility(
                                          visible: hasHover || isActive,
                                          child: Icon(ElIcons.close, size: 13),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isActive) Positioned(left: 0, right: 0, bottom: 0, child: buildActiveBanner(context)),
              ],
            ),
            // child: ElCloseButtonTheme(
            //   data: const ElCloseButtonThemeData(cursor: SystemMouseCursors.click),
            //   child: ElTag(
            //     title,
            //     height: $theme.size!,
            //     borderRadius: BorderRadius.zero,
            //     closable: true,
            //     onClose: () {
            //       el.message.show('关闭');
            //     },
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
