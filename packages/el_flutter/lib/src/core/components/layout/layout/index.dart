import 'dart:math';

import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

import 'package:el_flutter/el_flutter.dart';

part 'index.g.dart';

class ElContainer extends StatefulWidget {
  const ElContainer({
    super.key,
    this.header,
    required this.body,
    this.sidebar,
    this.rightSidebar,
    this.footer,
    this.topToolbar,
    this.leftToolbar,
    this.rightToolbar,
    this.bottomToolbar,
    this.cacheKey,
  });

  /// 顶部导航栏
  final ElHeader? header;

  /// 布局的主要内容区域
  final ElBody body;

  /// 左边侧边栏，当窗口为移动端尺寸时，会自动收起
  final ElSidebar? sidebar;

  /// 右边侧边栏
  final ElSidebar? rightSidebar;

  /// 底部区域栏
  final ElFooter? footer;

  /// 顶部工具栏，它位于 [navbar] 上方
  final ElToolbar? topToolbar;

  /// 左侧工具栏，它位于 [sidebar] 左边
  final ElToolbar? leftToolbar;

  /// 右侧工具栏，它位于 [rightSidebar] 右边
  final ElToolbar? rightToolbar;

  /// 底部工具栏，它位于 [footer] 下方
  final ElToolbar? bottomToolbar;

  /// 持久化缓存 key
  final String? cacheKey;

  /// 访问 [ElLayout] 布局信息
  static ElLayoutData of(BuildContext context) => _LayoutInheritedWidget.of(context);

  @override
  State<ElContainer> createState() => ElContainerState();
}

class ElContainerState extends State<ElContainer> {
  late BoxConstraints _constraints;

  /// 拖拽过程中保存的布局数据，所产生的数据不受布局约束
  late ElLayoutData _dragLayoutData;

  /// 支持本地持久化的最终布局数据
  late final Obs<ElLayoutData> _layoutData;

  ElLayoutData get layoutData => _layoutData.value;

  Size get bodySize => Size(widget.body.minWidth, widget.body.minHeight);

  void _updateNavbar(double value) {
    _dragLayoutData.header += value;
    double result = _dragLayoutData.header;

    if (layoutData.footer + bodySize.height >= _constraints.maxHeight) {
      return;
    }
    if (result < widget.header!.minHeight) {
      result = widget.header!.minHeight;
    } else {
      final maxHeight = _constraints.maxHeight - layoutData.footer - bodySize.height;
      if (widget.header!.maxHeight != null) {
        result = min(result, min(widget.header!.maxHeight!, maxHeight));
      } else {
        result = min(result, maxHeight);
      }
    }
    if (_layoutData.value.header != result) {
      _layoutData.value = layoutData.copyWith(header: result);
    }
  }

  void _updateSidebar(double value) {
    _dragLayoutData.sidebar += value;
    double result = _dragLayoutData.sidebar;

    if (layoutData.rightSidebar + bodySize.width >= _constraints.maxWidth) {
      return;
    }
    if (result < widget.sidebar!.minWidth) {
      result = widget.sidebar!.minWidth;
    } else {
      final maxWidth = _constraints.maxWidth - layoutData.rightSidebar - bodySize.width;

      if (widget.sidebar!.maxWidth != null) {
        result = min(result, min(widget.sidebar!.maxWidth!, maxWidth));
      } else {
        result = min(result, maxWidth);
      }
    }
    if (layoutData.sidebar != result) {
      _layoutData.value = layoutData.copyWith(sidebar: result);
    }
  }

  void _updateRightSidebar(double value) {
    _dragLayoutData.rightSidebar -= value;

    double result = _dragLayoutData.rightSidebar;

    if (layoutData.sidebar + bodySize.width >= _constraints.maxWidth) {
      return;
    }
    if (result < widget.rightSidebar!.minWidth) {
      result = widget.rightSidebar!.minWidth;
    } else {
      final maxWidth = _constraints.maxWidth - layoutData.sidebar - bodySize.width;
      if (widget.rightSidebar!.maxWidth != null) {
        result = min(result, min(widget.rightSidebar!.maxWidth!, maxWidth));
      } else {
        result = min(result, maxWidth);
      }
    }
    if (_layoutData.value.rightSidebar != result) {
      _layoutData.value = layoutData.copyWith(rightSidebar: result);
    }
  }

  void _updateFooter(double value) {
    _dragLayoutData.footer -= value;
    double result = _dragLayoutData.footer;

    if (layoutData.header + bodySize.height >= _constraints.maxHeight) {
      return;
    }
    if (result < widget.footer!.minHeight) {
      result = widget.footer!.minHeight;
    } else {
      final maxHeight = _constraints.maxHeight - layoutData.header - bodySize.height;
      if (widget.footer!.maxHeight != null) {
        result = min(result, min(widget.footer!.maxHeight!, maxHeight));
      } else {
        result = min(result, maxHeight);
      }
    }
    if (_layoutData.value.footer != result) {
      _layoutData.value = layoutData.copyWith(footer: result);
    }
  }

  /// 重置布局信息
  void resetLayout() {
    _layoutData.value = initialLayoutData;
    _dragLayoutData = layoutData.copyWith();
  }

  ElLayoutData get initialLayoutData => ElLayoutData(
    header: widget.header?.height ?? 0.0,
    sidebar: widget.sidebar?.width ?? 0.0,
    rightSidebar: widget.rightSidebar?.width ?? 0.0,
    footer: widget.footer?.height ?? 0.0,
  );

  @override
  void initState() {
    super.initState();
    _layoutData = Obs(initialLayoutData, cacheKey: widget.cacheKey);
    _dragLayoutData = layoutData.copyWith();
  }

  @override
  void didUpdateWidget(covariant ElContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    ElLayoutData newLayoutData = layoutData.copyWith();
    bool flag = false;

    if (widget.header != null) {
      if (oldWidget.header == null) {
        newLayoutData.header = widget.header!.height;
        flag = true;
      }
    } else {
      if (oldWidget.header != null) {
        newLayoutData.header = 0;
        flag = true;
      }
    }

    if (widget.sidebar != null) {
      if (oldWidget.sidebar == null) {
        newLayoutData.sidebar = widget.sidebar!.width;
        flag = true;
      }
    } else {
      if (oldWidget.sidebar != null) {
        newLayoutData.sidebar = 0;
        flag = true;
      }
    }

    if (widget.rightSidebar != null) {
      if (oldWidget.rightSidebar == null) {
        newLayoutData.rightSidebar = widget.rightSidebar!.width;
        flag = true;
      }
    } else {
      if (oldWidget.rightSidebar != null) {
        newLayoutData.rightSidebar = 0;
        flag = true;
      }
    }

    if (flag) {
      _layoutData.value = newLayoutData;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _layoutData.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splitResizerThemeData = ElSplitResizerTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        _constraints = constraints;

        return ObsBuilder(
          builder: (context) {
            List<Widget> children = [];

            children.add(
              Positioned(
                top: layoutData.header,
                bottom: 0,
                left: layoutData.sidebar,
                right: layoutData.rightSidebar,
                child: widget.body,
              ),
            );

            if (widget.sidebar != null) {
              final top = widget.sidebar!.expandedTop ? 0.0 : layoutData.header;
              final bottom = widget.sidebar!.expandedBottom ? 0.0 : layoutData.footer;
              children.add(
                Positioned(
                  top: top,
                  bottom: bottom,
                  left: 0,
                  child: SizedBox(width: layoutData.sidebar, child: widget.sidebar!),
                ),
              );
              if (widget.sidebar!.enabledDrag) {
                children.add(
                  Positioned(
                    top: top,
                    bottom: bottom,
                    left: layoutData.sidebar,
                    child: ElSplitResizerTheme(
                      data: const ElSplitResizerThemeData(position: ElSplitPosition.right),
                      child: ElSplitResizer(
                        onChanged: _updateSidebar,
                        onEnd: () {
                          _dragLayoutData.sidebar = _layoutData.value.sidebar;
                        },
                      ),
                    ),
                  ),
                );
              }
            }
            if (widget.rightSidebar != null) {
              final top = widget.rightSidebar!.expandedTop ? 0.0 : layoutData.header;
              final bottom = widget.rightSidebar!.expandedBottom ? 0.0 : layoutData.footer;
              children.add(
                Positioned(
                  top: top,
                  bottom: bottom,
                  right: 0,
                  child: SizedBox(width: layoutData.rightSidebar, child: widget.rightSidebar!),
                ),
              );
              if (widget.rightSidebar!.enabledDrag) {
                children.add(
                  Positioned(
                    top: top,
                    bottom: bottom,
                    right: layoutData.rightSidebar,
                    child: ElSplitResizerTheme(
                      data: const ElSplitResizerThemeData(position: ElSplitPosition.right),
                      child: ElSplitResizer(
                        onChanged: _updateRightSidebar,
                        onEnd: () {
                          _dragLayoutData.rightSidebar = _layoutData.value.rightSidebar;
                        },
                      ),
                    ),
                  ),
                );
              }
            }
            if (widget.header != null) {
              final left = widget.sidebar?.expandedTop == true ? layoutData.sidebar + splitResizerThemeData.size! : 0.0;
              final right = widget.rightSidebar?.expandedTop == true
                  ? layoutData.rightSidebar + splitResizerThemeData.size!
                  : 0.0;
              children.add(
                Positioned(
                  left: left,
                  right: right,
                  child: SizedBox(height: layoutData.header, child: widget.header!),
                ),
              );
              if (widget.header!.enabledDrag) {
                children.add(
                  Positioned(
                    top: layoutData.header,
                    left: left,
                    right: right,
                    child: ElSplitResizerTheme(
                      data: const ElSplitResizerThemeData(axis: Axis.horizontal, position: ElSplitPosition.center),
                      child: ElSplitResizer(
                        onChanged: _updateNavbar,
                        onEnd: () {
                          _dragLayoutData.header = _layoutData.value.header;
                        },
                      ),
                    ),
                  ),
                );
              }
            }
            if (widget.footer != null) {
              final left = widget.sidebar?.expandedBottom == true
                  ? layoutData.sidebar + splitResizerThemeData.size!
                  : 0.0;
              final right = widget.rightSidebar?.expandedBottom == true
                  ? layoutData.rightSidebar + splitResizerThemeData.size!
                  : 0.0;
              children.add(
                Positioned(
                  left: left,
                  right: right,
                  bottom: 0,
                  child: SizedBox(height: layoutData.footer, child: widget.footer!),
                ),
              );
              if (widget.footer!.enabledDrag) {
                children.add(
                  Positioned(
                    bottom: layoutData.footer,
                    left: left,
                    right: right,
                    child: ElSplitResizerTheme(
                      data: const ElSplitResizerThemeData(axis: Axis.horizontal, position: ElSplitPosition.center),
                      child: ElSplitResizer(
                        onChanged: _updateFooter,
                        onEnd: () {
                          _dragLayoutData.footer = _layoutData.value.footer;
                        },
                      ),
                    ),
                  ),
                );
              }
            }
            return _LayoutInheritedWidget(layoutData, child: Stack(children: children));
          },
        );
      },
    );
  }
}

@ElModelGenerator.all()
// ignore: must_be_immutable
class ElLayoutData with EquatableMixin implements ElSerializeModel {
  /// 导航头位置
  double header;

  /// 侧边栏位置
  double sidebar;

  /// 右边侧边栏位置
  double rightSidebar;

  /// 底部区域栏位置
  double footer;

  ElLayoutData({required this.header, required this.sidebar, required this.rightSidebar, required this.footer});

  @override
  ElLayoutData fromJson(Map<String, dynamic>? json) => ElLayoutDataExt.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _toJson();

  @override
  List<Object?> get props => _props;

  @override
  bool? get stringify => true;
}

class _LayoutInheritedWidget extends InheritedWidget {
  const _LayoutInheritedWidget(this.layoutData, {required super.child});

  final ElLayoutData layoutData;

  static ElLayoutData of(BuildContext context) {
    final _LayoutInheritedWidget? result = context.dependOnInheritedWidgetOfExactType<_LayoutInheritedWidget>();
    assert(result != null, 'No _LayoutInheritedWidget found in context');
    return result!.layoutData;
  }

  @override
  bool updateShouldNotify(_LayoutInheritedWidget oldWidget) => true;
}
