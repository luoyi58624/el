part of 'index.dart';

/// 在目标子组件上构建默认的交互小部件
class ElPopoverBuilder extends StatelessWidget {
  const ElPopoverBuilder({super.key, required this.state});

  final ElPopoverState state;

  /// 构建桌面端事件小部件
  Widget buildDesktopEvent(BuildContext context, Widget child) {
    return ElEvent(
      style: ElEventStyle(
        ignoreStatus: true,
        onEnter: (e) => state.delayHoverShow(),
        onExit: (e) => state.delayHoverHide(),
        onHover: state.staticHover
            ? (e) {
                if (state.modelValue != true) {
                  state.cancelDelayShowTimer();
                  state.delayHoverShow();
                }
              }
            : null,
        onTapDown: (e) {
          state.cancelDelayShowTimer();
          state.modelValue = false;
        },
      ),
      child: child,
    );
  }

  /// 构建移动端事件小部件，默认情况下，在移动端上需要长按显示弹窗，点击自身、点击外部隐藏弹窗
  Widget buildMobileEvent(BuildContext context, Widget child) {
    return TapRegion(
      groupId: state.groupId,
      child: ElEvent(
        style: ElEventStyle(
          onTap: (e) => state.modelValue = false,
          onLongPress: (e) {
            state.modelValue = true;
          },
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = state.widget.child;

    if (state.widget.disabledEvent == true) return result;

    return ElPlatform.isDesktop ? buildDesktopEvent(context, result) : buildMobileEvent(context, result);
  }
}
