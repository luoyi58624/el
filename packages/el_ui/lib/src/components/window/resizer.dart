part of 'index.dart';

class ElWindowResizer extends StatefulWidget {
  /// 调整窗口尺寸、拖拽位置部件
  const ElWindowResizer({
    super.key,
    required this.child,
    this.positionBuilder,
    this.curve = Curves.linear,
    this.duration = Duration.zero,
    this.offset = Offset.zero,
    this.alignment = Alignment.topLeft,
    required this.size,
    this.minSize = Size.zero,
    required this.maxSize,
    this.triggerSize = 8,
    this.borderWidth = 0,
    this.disabledBorderDrag = false,
    this.disabledEdgeDrag = false,
    this.cacheKey,
    this.borderBuilder,
    this.edgeBuilder,
  });

  final Widget child;

  /// 默认构建 [Positioned] 小部件，如果你不使用 [State] 堆栈布局，
  /// 那么请通过此属性自定义构建 [ParentDataWidget] 子类的小部件
  final Widget Function(Offset offset, Widget child, Duration duration)? positionBuilder;

  /// 切换最大化时窗口过渡曲线
  final Curve curve;

  /// 切换最大化时窗口过渡时间
  final Duration duration;

  /// 窗口偏移位置，此属性会在 [alignment] 定位后再应用偏移
  final Offset offset;

  /// 窗口初始定位，默认窗口左上方
  final Alignment alignment;

  /// 窗口初始尺寸
  final Size size;

  /// 窗口最小尺寸，默认 0
  final Size minSize;

  /// 窗口最大尺寸
  final Size maxSize;

  /// 调整尺寸的交互范围
  final double triggerSize;

  /// 边框宽度，拖拽控件会根据边框宽度来计算偏移值，保持居中对齐
  final double borderWidth;

  /// 禁止拖拽边框
  final bool disabledBorderDrag;

  /// 禁止拖拽对角
  final bool disabledEdgeDrag;

  /// 将布局信息缓存至本地 key
  final String? cacheKey;

  /// 自定义四个边框小部件，绘制的索引顺序为 1 - 4，分别代表：左、上、右、下
  final Widget Function(BuildContext context, int index)? borderBuilder;

  /// 自定义四个边角小部件，绘制的索引顺序为 1 - 4，分别代表：上左、上右、下右、下左
  final Widget Function(BuildContext context, int index)? edgeBuilder;

  /// 启动窗口位置拖拽事件
  static void startDrag(BuildContext context, PointerDownEvent e) {
    _ElWindowResizerInheritedWidget.get(context).startDrag(e);
  }

  /// 启动边框拖拽事件
  static void startBorderDrag(BuildContext context, PointerDownEvent e, int index) {
    _ElWindowResizerInheritedWidget.get(context).startBorderDrag(e, index);
  }

  /// 启动对角拖拽事件
  static void startEdgeDrag(BuildContext context, PointerDownEvent e, int index) {
    _ElWindowResizerInheritedWidget.get(context).startEdgeDrag(e, index);
  }

  /// 当前窗口是否处于最大化状态
  static bool isMaximize(BuildContext context) {
    return _ElWindowResizerInheritedWidget.of(context).isMaximize;
  }

  /// 将窗口最大化
  static void maximize(BuildContext context) {
    _ElWindowResizerInheritedWidget.get(context).maximize();
  }

  /// 将窗口还原
  static void reset(BuildContext context) {
    _ElWindowResizerInheritedWidget.get(context).reset();
  }

  /// 当前窗口是否处于最大化状态
  static Duration getDuration(BuildContext context) {
    return _ElWindowResizerInheritedWidget.of(context).duration;
  }

  @override
  State<ElWindowResizer> createState() => _ElWindowResizerState();
}

class _ElWindowResizerState extends State<ElWindowResizer> {
  late double _borderWidth;
  late double _triggerSize;

  /// 只有当切换最大化时才会应用传递的动画过渡
  Duration _duration = Duration.zero;

  /// 当指针按下时记录子组件当前尺寸
  late Size _pointDownChildSize;

  /// 当指针按下时记录子组件当前位置
  late Offset _pointDownChildOffset;

  /// 当指针按下时记录指针全局位置
  late Offset _pointDownPosition;

  /// 当指针按下时记录指针局部位置
  Offset? _pointDownLocalPosition;

  late final Obs<Offset> _offset;

  Offset get offset => _offset.value;

  late final Obs<Size> _size;

  Size get size => _size.value;

  late final _disabledBorderDragFlag = Obs(widget.disabledBorderDrag);

  late final _disabledEdgeDragFlag = Obs(widget.disabledEdgeDrag);

  final _startDragFlag = Obs(false);

  /// 启动拖拽位置事件
  void _startDrag(PointerDownEvent e) {
    _startDragFlag.value = true;
    _pointDownPosition = e.position;
    _pointDownLocalPosition = e.localPosition;
    _pointDownChildOffset = offset;
  }

  /// 更新拖拽位置
  void _updateDrag(PointerMoveEvent e) {
    if (_startDragFlag.value == false || _pointDownLocalPosition == null) {
      return;
    }

    final delta = e.position - _pointDownPosition;
    _offset.value = Offset(
      min(
        max(_pointDownChildOffset.dx + delta.dx, -_pointDownLocalPosition!.dx),
        widget.maxSize.width - _pointDownLocalPosition!.dx,
      ),
      min(
        max(_pointDownChildOffset.dy + delta.dy, -_pointDownLocalPosition!.dy),
        widget.maxSize.height - _pointDownLocalPosition!.dy,
      ),
    );
  }

  /// 结束拖拽位置
  void _endDrag(PointerUpEvent e) {
    ElCursorUtil.removeGlobalCursor();
    _startDragFlag.value = false;
    _saveLocalData();
  }

  void _startBorderDrag(PointerDownEvent e, int index) {
    _disabledBorderDragFlag.value = false;
    _pointDownPosition = e.position;
    _pointDownLocalPosition = e.localPosition;
    _pointDownChildSize = _size.value;
    _pointDownChildOffset = _offset.value;
  }

  void _updateBorderDrag(PointerMoveEvent e, int index) {
    switch (index) {
      case 1:
        _left(e);
        break;
      case 2:
        _top(e);
        break;
      case 3:
        _right(e);
        break;
      case 4:
        _bottom(e);
        break;
    }
  }

  void _endBorderDrag(PointerUpEvent e) {
    ElCursorUtil.removeGlobalCursor();
    _disabledBorderDragFlag.value = widget.disabledBorderDrag;
    _saveLocalData();
  }

  /// 拖拽左边框
  void _left(PointerMoveEvent e) {
    // 对齐偏移值，让边框与指针保存同步
    if (_pointDownLocalPosition != null) {
      final x = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dx;
      _pointDownChildOffset = Offset(_pointDownChildOffset.dx - x, _pointDownChildOffset.dy);
      _pointDownChildSize = Size(_pointDownChildSize.width + x, _pointDownChildSize.height);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = (_pointDownChildSize - delta) as Size;
    _size.value = Size(
      min(
        min(max(widget.minSize.width, size.width), widget.maxSize.width),
        _pointDownChildOffset.dx + _pointDownChildSize.width,
      ),
      _pointDownChildSize.height,
    );
    _offset.value = Offset(
      _pointDownChildOffset.dx + (_pointDownChildSize.width - _size.value.width),
      _pointDownChildOffset.dy,
    );
  }

  /// 拖拽上边框
  void _top(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final y = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dy;
      _pointDownChildOffset = Offset(_pointDownChildOffset.dx, _pointDownChildOffset.dy - y);
      _pointDownChildSize = Size(_pointDownChildSize.width, _pointDownChildSize.height + y);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = (_pointDownChildSize - delta) as Size;
    _size.value = Size(
      _pointDownChildSize.width,
      min(
        min(max(widget.minSize.height, size.height), widget.maxSize.height),
        _pointDownChildOffset.dy + _pointDownChildSize.height,
      ),
    );
    _offset.value = Offset(
      _pointDownChildOffset.dx,
      _pointDownChildOffset.dy + (_pointDownChildSize.height - _size.value.height),
    );
  }

  /// 拖拽右边框
  void _right(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final x = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dx;
      _pointDownChildSize = Size(_pointDownChildSize.width - x, _pointDownChildSize.height);
      _pointDownLocalPosition = null;
    }

    final delta = e.position - _pointDownPosition;
    final size = _pointDownChildSize + delta;
    _size.value = Size(
      min(
        min(max(size.width, widget.minSize.width), widget.maxSize.width),
        widget.maxSize.width - _pointDownChildOffset.dx,
      ),
      _pointDownChildSize.height,
    );
  }

  /// 拖拽下边框
  void _bottom(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final y = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dy;
      _pointDownChildSize = Size(_pointDownChildSize.width, _pointDownChildSize.height - y);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = _pointDownChildSize + delta;
    _size.value = Size(
      _pointDownChildSize.width,
      min(
        min(max(widget.minSize.height, size.height), widget.maxSize.height),
        widget.maxSize.height - _pointDownChildOffset.dy,
      ),
    );
  }

  void _startEdgeDrag(PointerDownEvent e, int index) {
    _disabledEdgeDragFlag.value = false;
    _pointDownPosition = e.position;
    _pointDownLocalPosition = e.localPosition;
    _pointDownChildSize = _size.value;
    _pointDownChildOffset = _offset.value;
  }

  void _updateEdgeDrag(PointerMoveEvent e, int index) {
    switch (index) {
      case 1:
        _topLeft(e);
        break;
      case 2:
        _topRight(e);
        break;
      case 3:
        _bottomRight(e);
        break;
      case 4:
        _bottomLeft(e);
        break;
    }
  }

  void _endEdgeDrag(PointerUpEvent e) {
    ElCursorUtil.removeGlobalCursor();
    _disabledEdgeDragFlag.value = widget.disabledEdgeDrag;
    _saveLocalData();
  }

  /// 拖拽左上对角
  void _topLeft(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final x = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dx;
      final y = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dy;
      _pointDownChildOffset = Offset(_pointDownChildOffset.dx - x, _pointDownChildOffset.dy - y);
      _pointDownChildSize = Size(_pointDownChildSize.width + x, _pointDownChildSize.height + y);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = (_pointDownChildSize - delta) as Size;
    _size.value = Size(
      min(
        min(max(widget.minSize.width, size.width), widget.maxSize.width),
        _pointDownChildOffset.dx + _pointDownChildSize.width,
      ),
      min(
        min(max(widget.minSize.height, size.height), widget.maxSize.height),
        _pointDownChildOffset.dy + _pointDownChildSize.height,
      ),
    );
    _offset.value = Offset(
      _pointDownChildOffset.dx + (_pointDownChildSize.width - _size.value.width),
      _pointDownChildOffset.dy + (_pointDownChildSize.height - _size.value.height),
    );
  }

  /// 拖拽右上对角
  void _topRight(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final x = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dx;
      final y = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dy;
      _pointDownChildOffset = Offset(_pointDownChildOffset.dx, _pointDownChildOffset.dy - y);
      _pointDownChildSize = Size(_pointDownChildSize.width - x, _pointDownChildSize.height + y);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = _pointDownChildSize + delta;
    _size.value = Size(
      min(
        min(max(widget.minSize.width, size.width), widget.maxSize.width),
        widget.maxSize.width - _pointDownChildOffset.dx,
      ),
      min(
        min(max(widget.minSize.height, _pointDownChildSize.height - delta.dy), widget.maxSize.height),
        _pointDownChildOffset.dy + _pointDownChildSize.height,
      ),
    );
    _offset.value = Offset(
      _pointDownChildOffset.dx,
      _pointDownChildOffset.dy + (_pointDownChildSize.height - _size.value.height),
    );
  }

  /// 拖拽右下对角
  void _bottomRight(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final x = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dx;
      final y = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dy;
      _pointDownChildSize = Size(_pointDownChildSize.width - x, _pointDownChildSize.height - y);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = _pointDownChildSize + delta;
    _size.value = Size(
      min(
        min(max(widget.minSize.width, size.width), widget.maxSize.width),
        widget.maxSize.width - _pointDownChildOffset.dx,
      ),
      min(
        min(max(widget.minSize.height, size.height), widget.maxSize.height),
        widget.maxSize.height - _pointDownChildOffset.dy,
      ),
    );
  }

  /// 拖拽左下对角
  void _bottomLeft(PointerMoveEvent e) {
    if (_pointDownLocalPosition != null) {
      final x = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dx;
      final y = _triggerSize + (_borderWidth / 2) - _pointDownLocalPosition!.dy;
      _pointDownChildOffset = Offset(_pointDownChildOffset.dx - x, _pointDownChildOffset.dy);
      _pointDownChildSize = Size(_pointDownChildSize.width + x, _pointDownChildSize.height - y);
      _pointDownLocalPosition = null;
    }
    final delta = e.position - _pointDownPosition;
    final size = (_pointDownChildSize - delta) as Size;
    _size.value = Size(
      min(
        min(max(widget.minSize.width, size.width), widget.maxSize.width),
        _pointDownChildOffset.dx + _pointDownChildSize.width,
      ),
      min(
        min(max(widget.minSize.height, _pointDownChildSize.height + delta.dy), widget.maxSize.height),
        widget.maxSize.height - _pointDownChildOffset.dy,
      ),
    );
    _offset.value = Offset(
      _pointDownChildOffset.dx + (_pointDownChildSize.width - _size.value.width),
      _pointDownChildOffset.dy,
    );
  }

  /// 当前是否处于最大化状态
  late final Obs<bool> _isMaximize;

  Timer? _maximizeDurationTimer;

  void _cancelMaximizeDurationTimer() {
    if (_maximizeDurationTimer != null) {
      _maximizeDurationTimer!.cancel();
      _maximizeDurationTimer = null;
    }
  }

  /// 最大化窗口
  void _maximize() {
    _cancelMaximizeDurationTimer();
    _duration = widget.duration;
    _isMaximize.value = true;
    _saveLocalData();
    _maximizeDurationTimer = ElAsyncUtil.setTimeout(() {
      _duration = Duration.zero;
      _maximizeDurationTimer = null;
    }, widget.duration.inMilliseconds);
  }

  /// 重置窗口
  void _reset() {
    _cancelMaximizeDurationTimer();
    _duration = widget.duration;
    _isMaximize.value = false;
    _saveLocalData();
    _maximizeDurationTimer = ElAsyncUtil.setTimeout(() {
      _duration = Duration.zero;
      _maximizeDurationTimer = null;
    }, widget.duration.inMilliseconds);
  }

  /// 保存本地数据
  void _saveLocalData() {
    if (widget.cacheKey == null) return;
    Obs.localStorage.setItem(widget.cacheKey!, {
      'isMaximize': _isMaximize.value,
      'width': size.width,
      'height': size.height,
      'dx': offset.dx,
      'dy': offset.dy,
    });
  }

  @override
  void initState() {
    super.initState();

    bool flag = true;
    if (widget.cacheKey != null) {
      final localData = Obs.localStorage.getItem(widget.cacheKey!);
      if (localData != null) {
        final obj = localData as Map;
        _size = Obs(
          Size(ElTypeUtil.safeDouble(obj['width'], widget.size.width), ElTypeUtil.safeDouble(obj['height'], widget.size.height)),
        );
        _offset = Obs(Offset(ElTypeUtil.safeDouble(obj['dx']), ElTypeUtil.safeDouble(obj['dy'])));
        _isMaximize = Obs(ElTypeUtil.safeBool(obj['isMaximize']));
        flag = false;
      }
    }

    if (flag) {
      _isMaximize = Obs(false);
      _size = Obs(widget.size);
      late Offset offset;
      switch (widget.alignment) {
        case Alignment.center:
          offset = Offset((widget.maxSize.width - size.width) / 2, (widget.maxSize.height - size.height) / 2);
          break;
        case Alignment.topLeft:
          offset = Offset.zero;
          break;
        case Alignment.topCenter:
          offset = Offset((widget.maxSize.width - size.width) / 2, 0);
          break;
        case Alignment.topRight:
          offset = Offset(widget.maxSize.width - size.width, 0);
          break;
        case Alignment.centerLeft:
          offset = Offset(0, (widget.maxSize.height - size.height) / 2);
          break;
        case Alignment.centerRight:
          offset = Offset(widget.maxSize.width - size.width, (widget.maxSize.height - size.height) / 2);
          break;
        case Alignment.bottomLeft:
          offset = Offset(0, widget.maxSize.height - size.height);
          break;
        case Alignment.bottomCenter:
          offset = Offset((widget.maxSize.width - size.width) / 2, widget.maxSize.height - size.height);
          break;
        case Alignment.bottomRight:
          offset = Offset(widget.maxSize.width - size.width, widget.maxSize.height - size.height);
          break;
      }

      _offset = Obs(offset + widget.offset);
    }
  }

  @override
  void didUpdateWidget(covariant ElWindowResizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disabledBorderDrag != oldWidget.disabledBorderDrag) {
      _disabledBorderDragFlag.value = widget.disabledBorderDrag;
    }

    if (widget.disabledEdgeDrag != oldWidget.disabledEdgeDrag) {
      _disabledEdgeDragFlag.value = widget.disabledEdgeDrag;
    }
  }

  /// 构建边框拖拽
  Widget _buildBorderDrag(int index) {
    Widget result = Builder(
      builder: (context) {
        return SizedBox(
          width: index == 1 || index == 3 ? widget.triggerSize : null,
          height: index == 2 || index == 4 ? widget.triggerSize : null,
          child: widget.borderBuilder?.call(context, index) ?? ElEmptyWidget.instance,
        );
      },
    );

    return ObsBuilder(
      builder: (context) {
        final cursor = index == 1 || index == 3 ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow;
        return ElEvent(
          style: ElEventStyle(
            behavior: HitTestBehavior.opaque,
            cursor: _disabledBorderDragFlag.value ? null : cursor,
            onPointerDown: _disabledBorderDragFlag.value
                ? null
                : (e) {
                    ElCursorUtil.insertGlobalCursor(cursor);
                    _startBorderDrag(e, index);
                  },
            onPointerMove: _disabledBorderDragFlag.value ? null : (e) => _updateBorderDrag(e, index),
            onPointerUp: _disabledBorderDragFlag.value ? null : _endBorderDrag,
          ),
          child: result,
        );
      },
    );
  }

  /// 构建对角拖拽
  Widget _buildEdgeDrag(int index) {
    Widget result = Builder(
      builder: (context) {
        return SizedBox(
          width: widget.triggerSize,
          height: widget.triggerSize,
          child: widget.edgeBuilder?.call(context, index),
        );
      },
    );

    return ObsBuilder(
      builder: (context) {
        final cursor = index == 1 || index == 3
            ? SystemMouseCursors.resizeUpLeftDownRight
            : SystemMouseCursors.resizeUpRightDownLeft;

        return ElEvent(
          style: ElEventStyle(
            behavior: HitTestBehavior.opaque,
            cursor: _disabledEdgeDragFlag.value ? null : cursor,
            onPointerDown: _disabledEdgeDragFlag.value
                ? null
                : (e) {
                    ElCursorUtil.insertGlobalCursor(cursor);
                    _startEdgeDrag(e, index);
                  },
            onPointerMove: _disabledEdgeDragFlag.value ? null : (e) => _updateEdgeDrag(e, index),
            onPointerUp: _disabledEdgeDragFlag.value ? null : _endEdgeDrag,
          ),
          child: result,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _borderWidth = widget.borderWidth;
    _triggerSize = (widget.triggerSize - _borderWidth) / 2;

    Widget result = ObsBuilder(
      builder: (context) {
        List<Widget> children = [
          ObsBuilder(
            builder: (context) {
              final $size = _isMaximize.value ? widget.maxSize : size;
              return AnimatedContainer(
                duration: _duration,
                curve: widget.curve,
                width: $size.width,
                height: $size.height,
                child: widget.child,
              );
            },
          ),
        ];
        // 当窗口处于最大化时，将不会添加所有拖拽控件
        if (_isMaximize.value == false) {
          children.addAll([
            Positioned(left: -_triggerSize, top: _triggerSize, bottom: _triggerSize, child: _buildBorderDrag(1)),
            Positioned(top: -_triggerSize, left: _triggerSize, right: _triggerSize, child: _buildBorderDrag(2)),
            Positioned(right: -_triggerSize, top: _triggerSize, bottom: _triggerSize, child: _buildBorderDrag(3)),
            Positioned(bottom: -_triggerSize, left: _triggerSize, right: _triggerSize, child: _buildBorderDrag(4)),
            Positioned(top: -_triggerSize, left: -_triggerSize, child: _buildEdgeDrag(1)),
            Positioned(top: -_triggerSize, right: -_triggerSize, child: _buildEdgeDrag(2)),
            Positioned(right: -_triggerSize, bottom: -_triggerSize, child: _buildEdgeDrag(3)),
            Positioned(left: -_triggerSize, bottom: -_triggerSize, child: _buildEdgeDrag(4)),
            Positioned(
              left: _triggerSize,
              top: _triggerSize,
              right: _triggerSize,
              bottom: _triggerSize,
              child: ObsBuilder(
                builder: (context) {
                  return Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerMove: _startDragFlag.value ? _updateDrag : null,
                    onPointerUp: _startDragFlag.value ? _endDrag : null,
                  );
                },
              ),
            ),
          ]);
        }
        return _ElWindowResizerInheritedWidget(
          _startDrag,
          _startBorderDrag,
          _startEdgeDrag,
          _isMaximize.value,
          _maximize,
          _reset,
          _duration,
          child: _Stack(triggerSize: _triggerSize, children: children),
        );
      },
    );

    return ObsBuilder(
      builder: (context) {
        final $offset = _isMaximize.value ? Offset.zero : offset;
        if (widget.positionBuilder != null) {
          return widget.positionBuilder!($offset, result, _duration);
        } else {
          return AnimatedPositioned(
            duration: _duration,
            curve: widget.curve,
            left: $offset.dx,
            top: $offset.dy,
            child: result,
          );
        }
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_offset', _offset));
  }
}

class _ElWindowResizerInheritedWidget extends InheritedWidget {
  const _ElWindowResizerInheritedWidget(
    this.startDrag,
    this.startBorderDrag,
    this.startEdgeDrag,
    this.isMaximize,
    this.maximize,
    this.reset,
    this.duration, {
    required super.child,
  });

  final PointerDownEventListener startDrag;
  final void Function(PointerDownEvent e, int index) startBorderDrag;
  final void Function(PointerDownEvent e, int index) startEdgeDrag;
  final bool isMaximize;
  final VoidCallback maximize;
  final VoidCallback reset;
  final Duration duration;

  static _ElWindowResizerInheritedWidget get(BuildContext context) {
    final _ElWindowResizerInheritedWidget? result = context
        .getInheritedWidgetOfExactType<_ElWindowResizerInheritedWidget>();
    assert(result != null, 'No _ElWindowResizerInheritedWidget found in context');
    return result!;
  }

  static _ElWindowResizerInheritedWidget of(BuildContext context) {
    final _ElWindowResizerInheritedWidget? result = context
        .dependOnInheritedWidgetOfExactType<_ElWindowResizerInheritedWidget>();
    assert(result != null, 'No _ElWindowResizerInheritedWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_ElWindowResizerInheritedWidget oldWidget) =>
      isMaximize != oldWidget.isMaximize || duration != oldWidget.duration;
}

/// 根据 [_triggerSize] 扩大 [Stack] 事件命中范围，同时不影响组件的尺寸
class _Stack extends Stack {
  const _Stack({required this.triggerSize, super.children}) : super(clipBehavior: Clip.none);

  final double triggerSize;

  @override
  RenderStack createRenderObject(BuildContext context) {
    return _RenderStack(
      triggerSize: triggerSize,
      textDirection: Directionality.maybeOf(context),
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderStack renderObject) {
    renderObject
      ..triggerSize = triggerSize
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior;
  }
}

class _RenderStack extends RenderStack {
  _RenderStack({required this.triggerSize, super.textDirection, super.clipBehavior});

  double triggerSize;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (Size(
          size.width + triggerSize * 2,
          size.height + triggerSize * 2,
        ).contains(position + Offset(triggerSize, triggerSize)) ||
        Size(-triggerSize, -triggerSize).contains(position)) {
      if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
}
