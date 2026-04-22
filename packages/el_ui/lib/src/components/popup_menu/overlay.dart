part of 'index.dart';

class _Overlay<T> extends HookWidget {
  const _Overlay({required this.state});

  final ElPopupMenuState<T> state;

  @override
  Widget build(BuildContext context) {
    final themeData = ElPopupMenuTheme.of(context);
    final scrollController = useGlobalScrollController();
    final curveAnimation = useCurvedAnimation(parent: state.animationController, curve: Curves.easeInSine);

    final children = state.widget.menuList
        .map(
          (e) => ElListTile(
            onTap: () {
              e.onTap?.call();
              state.widget.onMenuChanged?.call(e);
              state.modelValue = false;
            },
            leading: e.leading,
            trailing: e.trailing,
          ),
        )
        .toList();

    Widget result;

    if (state.isTight == false) {
      result = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: state.widget.minWidth ?? themeData.minWidth!,
          maxWidth: themeData.maxWidth!,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: RepaintBoundary(
            child: Padding(
              padding: .only(top: themeData.padding!.top, bottom: themeData.padding!.bottom),
              child: Column(children: children),
            ),
          ),
        ),
      );

      // ElPopup 会对 popup 组件进行尺寸预测，由于 ListTile 会填满整个宽度，
      // 所以需要包裹 IntrinsicWidth 才能正确计算子项的真实宽度
      if (ElChildSizeBuilder.isTempLayout(context)) {
        result = IntrinsicWidth(child: result);
      }
    } else {
      result = SizedBox.fromSize(
        size: state.popupSize,
        child: ListView.builder(
          padding: .symmetric(vertical: 16.0),
          itemCount: children.length,
          prototypeItem: children.isEmpty ? ElEmptyWidget.instance : children.first,
          itemBuilder: (context, index) => children[index],
        ),
      );
    }

    result = ElCardTheme(
      data: ElCardThemeData(elevation: 4),
      child: ElCard(
        child: FadeTransition(opacity: curveAnimation, child: result),
      ),
    );

    return MediaQuery.removePadding(context: context, removeLeft: true, removeRight: true, child: result);
  }
}
