part of 'index.dart';

/// 将 [ElPopupAlignment] 12 种定位类型划分 3 种基本类型，左对齐、居中对齐、右对齐，
/// 如果 alignment 为 center，此类型将为 null
enum _ElPopupPositionType { start, center, end }

/// 计算 [LayerLink] 位置逻辑
mixin _LayerMixin<T extends ElLinkPopup> on ElPopupState<T> {
  final layerLink = LayerLink();
  final childKey = GlobalKey();

  /// 指针在目标子组件上的位置，只有当 float 浮动对齐时才会设置此变量
  Offset? localPosition;

  /// [LayerLink] 链接的偏移位置
  Offset get layerOffset => _layerOffset!;
  Offset? _layerOffset;

  /// 目标 child 的大小（当插入 popup 时初始化）
  Size get childSize => _childSize!;
  Size? _childSize;

  /// 目标 child 相对 Overlay 的位置
  Offset get childPosition => _childPosition!;
  Offset? _childPosition;

  /// 弹出层尺寸
  Size get popupSize => _popupSize!;
  Size? _popupSize;

  /// 弹出层对齐位置，如果设置了延迟显示，那么默认弹出层对齐为浮动
  ElPopupAlignment get alignment => widget.alignment ?? ElPopupAlignment.bottom;

  /// 弹出层与目标小部件之间的间隔
  double get spacing => widget.spacing ?? 0.0;

  /// 弹出层与 Overlay 画布之间的间隔
  double get edgeSpacing => widget.edgeSpacing ?? 8.0;

  ElPopupAlignment? _popupAlignment;

  /// 默认对齐方式可能放不下内容，所以在渲染前会进行一次预估，此变量是弹出层最终的对齐位置
  ElPopupAlignment? get popupAlignment => _popupAlignment;

  set popupAlignment(ElPopupAlignment? v) {
    if (_popupAlignment == null || v == null) {
      _popupAlignment = v;
    } else {
      if (_popupAlignment != v) {
        _popupAlignment = v;
        if (animationController.isCompleted) {
          animationController.reverse().then((e) {
            animationController.forward();
          });
        }
      }
    }
  }

  /// 弹出层的约束是否为强制最大、最小宽高
  bool get isTight => _isTight!;
  bool? _isTight;

  /// 弹出层的基本类型，如果 [alignment] 为 center 类型，那么该属性为 null
  _ElPopupPositionType? get positionType => _positionType;
  _ElPopupPositionType? _positionType;

  /// 适配 [SafeArea] 安全区域
  EdgeInsets get safePadding => _safePadding;
  EdgeInsets _safePadding = .zero;

  /// 是否为浮动对齐
  bool get isFloat => alignment == ElPopupAlignment.float;

  /// 是否为居中对齐
  bool get isCenter => alignment == ElPopupAlignment.center;

  /// 目标 child 处于偏上位置
  bool get childAlignTop => childPosition.dy + childSize.height / 2 < overlaySize.height / 2;

  /// 目标 child 处于偏下位置
  bool get childAlignBottom => !childAlignTop;

  /// 目标 child 处于偏左位置
  bool get childAlignLeft => childPosition.dx + childSize.width / 2 < overlaySize.width / 2;

  /// 目标 child 处于偏右位置
  bool get childAlignRight => !childAlignLeft;

  /// popup 上下对齐时顶部最大高度
  double get topMaxHeight => childPosition.dy - spacing - edgeSpacing + _coverHeight - safePadding.top;

  /// popup 上下对齐时底部最大高度
  double get bottomMaxHeight =>
      overlaySize.height -
      spacing -
      edgeSpacing -
      childPosition.dy -
      childSize.height +
      _coverHeight -
      safePadding.bottom;

  /// popup 左右对齐时左侧最大宽度
  double get leftMaxWidth => childPosition.dx - edgeSpacing - spacing + _coverWidth - safePadding.left;

  /// popup 左右对齐时右侧最大宽度
  double get rightMaxWidth =>
      overlaySize.width - spacing - edgeSpacing - childPosition.dx - childSize.width + _coverWidth - safePadding.right;

  /// 若开启 coverTarget 覆盖子组件，计算的 [layerOffset] 需要对子组件的属性进行偏移
  double get _coverWidth => widget.coverTarget == true ? childSize.width : 0.0;

  double get _coverHeight => widget.coverTarget == true ? childSize.height : 0.0;

  /// 1. 对默认的 popup 对齐进行一次转换
  void _calcPopupAlignment() {
    switch (alignment) {
      case ElPopupAlignment.bottom || ElPopupAlignment.bottomStart || ElPopupAlignment.bottomEnd:
        if ((widget.adjustPosition == ElPopupAdjustPosition.center && childAlignBottom) ||
            (popupSize.height > bottomMaxHeight && childAlignBottom)) {
          if (alignment == ElPopupAlignment.bottomStart) {
            popupAlignment = ElPopupAlignment.topStart;
          } else if (alignment == ElPopupAlignment.bottomEnd) {
            popupAlignment = ElPopupAlignment.topEnd;
          } else {
            popupAlignment = ElPopupAlignment.top;
          }
        } else {
          popupAlignment = alignment;
        }
      case ElPopupAlignment.top || ElPopupAlignment.topStart || ElPopupAlignment.topEnd:
        if ((widget.adjustPosition == ElPopupAdjustPosition.center && childAlignTop) ||
            (popupSize.height > topMaxHeight && childAlignTop)) {
          if (alignment == ElPopupAlignment.topStart) {
            popupAlignment = ElPopupAlignment.bottomStart;
          } else if (alignment == ElPopupAlignment.topEnd) {
            popupAlignment = ElPopupAlignment.bottomEnd;
          } else {
            popupAlignment = ElPopupAlignment.bottom;
          }
        } else {
          popupAlignment = alignment;
        }
      case ElPopupAlignment.left || ElPopupAlignment.leftStart || ElPopupAlignment.leftEnd:
        if ((widget.adjustPosition == ElPopupAdjustPosition.center && childAlignLeft) ||
            (popupSize.width > leftMaxWidth && childAlignLeft)) {
          if (alignment == ElPopupAlignment.leftStart) {
            popupAlignment = ElPopupAlignment.rightStart;
          } else if (alignment == ElPopupAlignment.leftEnd) {
            popupAlignment = ElPopupAlignment.rightEnd;
          } else {
            popupAlignment = ElPopupAlignment.right;
          }
        } else {
          popupAlignment = alignment;
        }
      case ElPopupAlignment.right || ElPopupAlignment.rightStart || ElPopupAlignment.rightEnd:
        if ((widget.adjustPosition == ElPopupAdjustPosition.center && childAlignRight) ||
            (popupSize.width > rightMaxWidth && childAlignRight)) {
          if (alignment == ElPopupAlignment.rightStart) {
            popupAlignment = ElPopupAlignment.leftStart;
          } else if (alignment == ElPopupAlignment.rightEnd) {
            popupAlignment = ElPopupAlignment.leftEnd;
          } else {
            popupAlignment = ElPopupAlignment.left;
          }
        } else {
          popupAlignment = alignment;
        }
      case ElPopupAlignment.center || ElPopupAlignment.float:
        popupAlignment = alignment;
    }
  }

  /// 2. 设置 popup 对齐类型
  void _setPositionType() {
    if (isCenter || isFloat) return;
    switch (popupAlignment) {
      case ElPopupAlignment.bottom:
      case ElPopupAlignment.top:
      case ElPopupAlignment.left:
      case ElPopupAlignment.right:
        _positionType = _ElPopupPositionType.center;
        break;
      case ElPopupAlignment.bottomStart:
      case ElPopupAlignment.topStart:
      case ElPopupAlignment.leftStart:
      case ElPopupAlignment.rightStart:
        _positionType = _ElPopupPositionType.start;
        break;
      case ElPopupAlignment.bottomEnd:
      case ElPopupAlignment.topEnd:
      case ElPopupAlignment.leftEnd:
      case ElPopupAlignment.rightEnd:
        _positionType = _ElPopupPositionType.end;
        break;
      default:
        throw '_setPositionType 错误';
    }
  }

  /// 3. 计算 popup 位置
  void _calcLayerOffset() {
    var maxWidth = min(popupSize.width, overlaySize.width - edgeSpacing * 2 - safePadding.horizontal);
    var maxHeight = min(popupSize.height, overlaySize.height - edgeSpacing * 2 - safePadding.vertical);
    late double dx;
    late double dy;

    if (isFloat) {
      assert(localPosition != null, 'ElLinkPopup Error: 浮动对齐 localPosition 未初始化');
      dx = localPosition!.dx;
      dy = localPosition!.dy;
      final maxDx = overlaySize.width - (maxWidth + childPosition.dx + edgeSpacing);
      final minDx = -childPosition.dx + edgeSpacing + safePadding.left;

      if (dx >= maxDx) dx = maxDx;
      if (dx <= minDx) dx = minDx;
    } else if (isCenter) {
      dx = -(maxWidth - childSize.width) / 2;
      dy = -(maxHeight - childSize.height) / 2;

      final maxDx = overlaySize.width - (maxWidth + childPosition.dx + edgeSpacing);
      final minDx = -childPosition.dx + edgeSpacing + safePadding.left;
      var maxDy = overlaySize.height - (maxHeight + childPosition.dy + edgeSpacing + safePadding.bottom);
      var minDy = -childPosition.dy + edgeSpacing + safePadding.top;

      dx = max(min(dx, maxDx), minDx);
      dy = max(min(dy, maxDy), minDy);
    } else {
      // 计算上下对齐的 x 轴坐标
      void calcVerticalDx() {
        if (positionType == _ElPopupPositionType.center) {
          dx = (childSize.width - maxWidth) / 2;
        } else if (positionType == _ElPopupPositionType.start) {
          dx = 0;
        } else if (positionType == _ElPopupPositionType.end) {
          dx = childSize.width - maxWidth;
        }

        final maxDx = overlaySize.width - (maxWidth + childPosition.dx + edgeSpacing);
        final minDx = -childPosition.dx + edgeSpacing + safePadding.left;

        if (dx >= maxDx) dx = maxDx;
        if (dx <= minDx) dx = minDx;
      }

      // 计算左右对齐的 y 轴坐标
      void calcHorizontalDy() {
        double safeTop = 0.0;
        double safeBottom = 0.0;

        if (positionType == _ElPopupPositionType.center) {
          dy = (childSize.height - maxHeight) / 2;
          safeTop = safePadding.top;
          safeBottom = safePadding.bottom;
        } else if (positionType == _ElPopupPositionType.start) {
          dy = 0;
          safeBottom = safePadding.bottom;
        } else if (positionType == _ElPopupPositionType.end) {
          dy = childSize.height - maxHeight;
          safeTop = safePadding.top;
        }

        var maxDy = overlaySize.height - (maxHeight + childPosition.dy + edgeSpacing + safeBottom);
        var minDy = -childPosition.dy + edgeSpacing + safeTop;

        bool activeLimitButton = false;
        if (dy >= maxDy) {
          activeLimitButton = true;
          dy = maxDy;
        }

        if (activeLimitButton && positionType == _ElPopupPositionType.start) {
          minDy += safePadding.top;
        }
        if (dy <= minDy) dy = minDy;
      }

      switch (popupAlignment) {
        case ElPopupAlignment.bottom || ElPopupAlignment.bottomStart || ElPopupAlignment.bottomEnd:
          calcVerticalDx();
          maxHeight = min(popupSize.height, bottomMaxHeight);
          dy = childSize.height + spacing - _coverHeight;
          break;
        case ElPopupAlignment.top || ElPopupAlignment.topStart || ElPopupAlignment.topEnd:
          calcVerticalDx();
          maxHeight = min(popupSize.height, topMaxHeight);
          dy = -maxHeight - spacing + _coverHeight;
          break;
        case ElPopupAlignment.left || ElPopupAlignment.leftStart || ElPopupAlignment.leftEnd:
          calcHorizontalDy();
          maxWidth = min(popupSize.width, leftMaxWidth);
          dx = -maxWidth - spacing + _coverWidth;
          break;
        case ElPopupAlignment.right || ElPopupAlignment.rightStart || ElPopupAlignment.rightEnd:
          calcHorizontalDy();
          maxWidth = min(popupSize.width, rightMaxWidth);
          dx = childSize.width + spacing - _coverWidth;
          break;
        default:
          throw '';
      }
    }

    _layerOffset = Offset(dx, dy);
    _popupSize = Size(maxWidth, maxHeight);
  }
}
