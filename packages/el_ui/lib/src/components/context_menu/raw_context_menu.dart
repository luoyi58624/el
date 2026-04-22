part of 'index.dart';

abstract class ElRawContextMenu extends StatefulWidget {
  /// 无样式右键菜单，此类封装了展开级联右键菜单的核心逻辑
  const ElRawContextMenu({
    super.key,
    required this.menuId,
    required this.position,
    required this.menuList,
    this.prevMenu,
  });

  /// 菜单唯一标识，此标识用于安全关闭菜单，只允许关闭自身创建的菜单
  final Object menuId;

  /// 菜单位置
  final Offset position;

  /// 菜单列表
  final List<ElMenuEntry> menuList;

  /// 上一级菜单对象，如果为 null，将表示当前菜单为一级菜单
  final ElRawContextMenuState? prevMenu;

  @override
  State<ElRawContextMenu> createState();
}

abstract class ElRawContextMenuState<T extends ElRawContextMenu> extends State<T> {
  late Listenable scrollNotify;

  /// 菜单内边距
  EdgeInsets get padding;

  /// 展开级联菜单的偏移，其计算公式为：嵌套菜单位置 - [padding] + [expandedOffset]
  double get expandedOffset => 1.0;

  /// 菜单距离 Overlay 的内边距
  double get overlayPadding => 8.0;

  /// 触发虚拟滚动的阈值
  int get virtualThreshold => 200;

  /// 当触发虚拟滚动时，若用户没有指定宽度将使用此默认值
  double get virtualScrollWidth => 200.0;

  /// 定义菜单背景颜色
  Color get bgColor;

  Color get textColor => bgColor.elTextColor(context);

  /// 定义分割线颜色
  Color get dividerColor;

  /// 菜单允许的最小宽度
  double get minMenuWidth => 150.0;

  /// 构建菜单外观
  Widget buildWrapper(BuildContext context, Widget child);

  /// 构建单个菜单项
  Widget buildItem(BuildContext context, ElMenuEntry menu, int index);

  /// 构建前缀
  Widget? buildLeading(BuildContext context, ElMenuEntry menu, int index);

  /// 构建后缀
  Widget? buildTrailing(BuildContext context, ElMenuEntry menu, int index);

  /// 构建菜单分割线
  Widget buildDivider(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 8, vertical: 2),
      child: ElDividerTheme(
        data: ElDividerThemeData(thickness: 1, size: 8, color: dividerColor),
        child: ElDivider(),
      ),
    );
  }

  // =============================================================================================
  // 上面是推荐用户自定义的内容
  // =============================================================================================

  late final ScrollController scrollController;

  final focusScopeNode = FocusScopeNode();

  /// 记录当前焦点
  FocusNode? currentFocusNode;

  /// 创建的下一个菜单 key
  GlobalKey<ElRawContextMenuState>? nextMenuKey;

  /// 菜单允许的最大宽度
  double get maxMenuWidth {
    final result = overlaySize.width / 2 - overlayPadding * 2;
    if (result < 250.0) return 250.0;
    return result;
  }

  /// 菜单允许的最大高度
  double get maxMenuHeight {
    if (widget.prevMenu == null && el.contextMenu.isMenuAnchor == true) {
      final targetHeight = el.contextMenu.targetSize.height;
      if (widget.position.dy - (targetHeight / 2) < overlaySize.height / 2) {
        return overlaySize.height - overlayPadding - widget.position.dy;
      } else {
        return widget.position.dy - targetHeight - overlayPadding;
      }
    } else {
      return overlaySize.height - overlayPadding * 2;
    }
  }

  /// 当前菜单显示在屏幕上的位置，此属性会在 [menuSize] 赋值时同步更新
  late Offset position;

  Size? _menuSize;

  /// 当前菜单尺寸
  Size get menuSize => _menuSize!;

  /// 设置菜单尺寸，同时计算 [position] 位置
  set menuSize(Size v) {
    if (_menuSize == v) return;
    _menuSize = v;
    double dx = widget.position.dx;
    double dy = widget.position.dy;

    if (widget.prevMenu == null) {
      if (dx + menuSize.width + overlayPadding > overlaySize.width) {
        dx -= menuSize.width + expandedOffset * 2;
        isRightRender = false;
      }
    }
    // 以下处理嵌套子菜单的偏移位置
    else {
      final prevWidth = widget.prevMenu!.menuSize.width;
      if (widget.prevMenu!.isRightRender) {
        if (dx + prevWidth + menuSize.width + overlayPadding < overlaySize.width) {
          dx += prevWidth + expandedOffset - padding.left * 2;
          isRightRender = true;
        } else {
          dx -= menuSize.width + expandedOffset * 2;
          isRightRender = false;
        }
      } else {
        if (dx - menuSize.width - overlayPadding > 0) {
          dx -= menuSize.width + expandedOffset * 2;
          isRightRender = false;
        } else {
          dx += prevWidth + expandedOffset - padding.left * 2;
          isRightRender = true;
        }
      }
    }

    if (widget.prevMenu == null && el.contextMenu.isMenuAnchor == true) {
      final targetHeight = el.contextMenu.targetSize.height;
      if (dy - (targetHeight / 2) > overlaySize.height / 2) {
        dy = widget.position.dy - targetHeight - menuSize.height;
      }
    } else {
      dy = max(min(dy, overlaySize.height - overlayPadding - menuSize.height), overlayPadding);
    }

    position = Offset(dx, dy);
  }

  /// 菜单是否朝右渲染，让右侧空间放不下时，该属性将 false，此时菜单将依次往左边渲染，当左侧放不下时再向右渲染
  bool isRightRender = true;

  /// 是否存在前缀
  bool hasLeading = false;

  /// 是否存在后缀
  bool hasTrailing = false;

  late Color activeColor;
  late Color activeTextColor;

  Timer? _hoverDelayShowTimer;
  Timer? _hoverDelayHideTimer;

  /// 展开的菜单
  int expandedIndex = -1;

  Size get overlaySize => MediaQuery.sizeOf(context);

  OverlayEntry? overlayEntry;

  /// 创建嵌套的右键菜单
  void createContextMenu(Offset position, List<ElMenuEntry> menuList, ElRawContextMenuState prevMenu) {
    removeContextMenu();
    nextMenuKey = GlobalKey();
    overlayEntry = OverlayEntry(
      builder: (context) => el.contextMenu._builder(nextMenuKey, widget.menuId, position, menuList, prevMenu),
    );

    el.overlay.insert(overlayEntry!);
  }

  /// 移除当前菜单创建的子菜单
  void removeContextMenu() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry!.dispose();
      overlayEntry = null;
      nextMenuKey = null;
    }
  }

  /// 移除当前菜单
  void removeCurrentContextMenu() {
    if (widget.prevMenu != null) {
      // 如果是嵌套子菜单，则调用上一个菜单的 removeContextMenu 方法
      widget.prevMenu!.removeContextMenu();
    } else {
      // 没有上一个菜单，表示当前就是全局 contextMenu 创建的第一个菜单
      el.contextMenu.remove(widget.menuId);
    }
  }

  void _focusChangedHandler(BuildContext context, bool hasFocus, FocusNode focusNode, int index) {
    final menu = widget.menuList[index];
    final hasChildren = menu.children != null && menu.children!.isNotEmpty;

    if (hasFocus) {
      currentFocusNode = focusNode;

      if (hasChildren) {
        // 创建子菜单函数
        void fun() {
          if (expandedIndex != index) {
            removeContextMenu();
            expandedIndex = index;

            createContextMenu(ElFlutterUtil.getPosition(context), menu.children!, this);
          }
        }

        if (_hoverDelayHideTimer != null) {
          _hoverDelayHideTimer!.cancel();
          _hoverDelayHideTimer = null;
          // 如果是快速切回原来展开的菜单，直接返回
          if (expandedIndex == index) return;
        }

        if (_hoverDelayShowTimer != null) {
          _hoverDelayShowTimer!.cancel();
          _hoverDelayShowTimer = null;
        }

        // 如果设置延迟显示，那么需要添加到计时器
        final hoverDelayShow = el.contextMenu.themeData.hoverDelayShow;
        if (hoverDelayShow == null || hoverDelayShow <= 0) {
          fun();
        } else {
          _hoverDelayShowTimer = ElAsyncUtil.setTimeout(() {
            _hoverDelayShowTimer = null;
            fun();
          }, hoverDelayShow);
        }
      } else {
        if (overlayEntry != null) {
          void fun() {
            removeContextMenu();
            expandedIndex = -1;
          }

          final hoverDelayHide = el.contextMenu.themeData.hoverDelayHide;
          if (hoverDelayHide == null || hoverDelayHide <= 0) {
            fun();
          } else {
            _hoverDelayHideTimer = ElAsyncUtil.setTimeout(() {
              _hoverDelayHideTimer = null;
              fun();
            }, hoverDelayHide);
          }
        }
      }
    } else {
      if (_hoverDelayShowTimer != null) {
        _hoverDelayShowTimer!.cancel();
        _hoverDelayShowTimer = null;
      }
    }
  }

  /// 处理点击菜单项
  void onTapHandler(int index, FocusNode? focusNode) {
    final menu = widget.menuList[index];
    final hasChildren = menu.children != null && menu.children!.isNotEmpty;
    currentFocusNode = focusNode;

    if (hasChildren) {
      if (ElPlatform.isMobile) {
        removeContextMenu();
        expandedIndex = index;
        createContextMenu(ElFlutterUtil.getPosition(context), menu.children!, this);
      }
    } else {
      menu.onTap?.call();
      el.contextMenu._selectedMenu = menu;
      el.contextMenu.remove(widget.menuId);
    }
  }

  late BuildContext visitScrollableContext;

  void _removeContextMenu() => el.contextMenu.remove(widget.menuId);

  void scrollingNotify() => ElAsyncUtil.debounce(_removeContextMenu, 50)();

  /// 用户定义的菜单宽度
  double? _menuWidth;

  @override
  void initState() {
    super.initState();
    visitScrollableContext = el.contextMenu.context;
    scrollController = el.config.scrollControllerBuilder();
    el.contextMenu._groupId ??= hashCode;
    if (widget.menuList.isNotEmpty) {
      _menuWidth = widget.menuList[0].width;

      for (final menu in widget.menuList) {
        if (menu.leading != null) {
          hasLeading = true;
          break;
        }
      }
      for (final menu in widget.menuList) {
        if (menu.trailing != null || menu.children != null) {
          hasTrailing = true;
          break;
        }
      }
    }

    nextTick(() {
      scrollNotify.addListener(scrollingNotify);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollNotify.removeListener(scrollingNotify);
    scrollController.dispose();
    focusScopeNode.dispose();
    removeContextMenu(); // 递归移除自身以及后代菜单
  }

  /// 构建列表 item 选项
  Widget _itemBuilder(BuildContext context, int index) {
    final menu = widget.menuList[index];
    late BuildContext childContext;
    late FocusNode focusNode;
    if (menu is ElMenuSeparator) {
      return buildDivider(context);
    } else {
      return SizedBox(
        width: double.infinity,
        child: Actions(
          actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (i) => onTapHandler(index, focusNode))},
          child: Focus(
            onFocusChange: (hasFocus) {
              _focusChangedHandler(childContext, hasFocus, focusNode, index);
            },
            child: ElEvent(
              style: ElEventStyle(
                onEnter: (e) => focusNode.requestFocus(),
                onExit: (e) => focusNode.unfocus(),
                onTap: (e) => onTapHandler(index, focusNode),
              ),
              child: Builder(
                builder: (context) {
                  childContext = context;
                  focusNode = Focus.of(context);
                  if (ElChildSizeBuilder.isTempLayout(context) == false) {
                    currentFocusNode ??= focusNode;
                  }
                  return buildItem(context, menu, index);
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  /// 构建 Overlay 菜单浮层
  Widget _buildOverlay(Widget child) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: TapRegion(
            groupId: el.contextMenu._groupId,
            onTapOutside: (e) {
              el.contextMenu.remove(widget.menuId);
            },
            child: ElEvent(
              style: ElEventStyle(
                ignoreStatus: true,
                onSecondaryTapUp: (e) {}, // 添加右键事件阻止冒泡
              ),
              child: buildWrapper(
                context,
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: menuSize.width, maxHeight: menuSize.height),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    ).noScrollbarBehavior(context);
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    scrollNotify = ElApp.scrollNotifyOf(context);
    activeColor = context.elTheme.secondary;
    activeTextColor = activeColor.elTextColor(context);

    late Widget result;

    // 如果是虚拟滚动，同时用户设置了最大宽度，则跳过预估整个菜单尺寸，直接以虚拟滚动方式渲染菜单
    if (widget.menuList.length > virtualThreshold) {
      menuSize = Size(max(_menuWidth ?? virtualScrollWidth, minMenuWidth), maxMenuHeight);
      result = _buildOverlay(
        ListView.builder(
          controller: scrollController,
          itemCount: widget.menuList.length,
          padding: padding,
          prototypeItem: _itemBuilder(context, 0),
          itemBuilder: _itemBuilder,
        ),
      );
    } else {
      // 构建需要预估尺寸的小部件
      Widget child = Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .start,
          children: widget.menuList.mapIndexed((index, menu) => _itemBuilder(context, index)).toList(),
        ),
      );

      result = ElChildSizeBuilder(
        // 每次插入、移除 Overlay 都会导致所有 Overlay 重新构建，除了第一次创建外后续应避免探测布局
        tempChild: _menuSize == null ? IntrinsicWidth(child: child) : ElEmptyWidget.instance,
        builder: (size) {
          if (_menuSize == null) {
            menuSize = Size(
              max(min(_menuWidth ?? size.width, maxMenuWidth), minMenuWidth),
              min(size.height, maxMenuHeight),
            );
          }

          child = SingleChildScrollView(controller: scrollController, child: child);

          return _buildOverlay(child);
        },
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (e) => true,
      child: FocusScope(
        node: focusScopeNode,
        parentNode: widget.prevMenu == null ? el.contextMenu._parentNode : widget.prevMenu!.focusScopeNode,
        child: FocusTraversalGroup(
          policy: _MenuOrderTraversalPolicy(),
          child: ElShortcut(
            autofocus: widget.prevMenu == null,
            shortcuts: {
              const SingleActivator(LogicalKeyboardKey.escape): () {
                el.contextMenu.remove(widget.menuId);
                return true;
              },
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                if (widget.prevMenu != null) {
                  widget.prevMenu!.currentFocusNode!.requestFocus();
                  return true;
                } else {
                  return false;
                }
              },
              const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                if (nextMenuKey != null && nextMenuKey!.currentState != null) {
                  nextMenuKey!.currentState!.currentFocusNode!.requestFocus();
                  return true;
                } else {
                  return false;
                }
              },
            },
            child: result,
          ),
        ),
      ),
    );
  }
}

/// 菜单焦点遍历策略
class _MenuOrderTraversalPolicy extends ReadingOrderTraversalPolicy {
  _MenuOrderTraversalPolicy();

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    switch (direction) {
      case TraversalDirection.down:
        next(currentNode);
        return true;
      case TraversalDirection.up:
        previous(currentNode);
        return true;
      case TraversalDirection.left:
      case TraversalDirection.right:
    }
    return super.inDirection(currentNode, direction);
  }
}
