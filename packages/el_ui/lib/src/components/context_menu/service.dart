part of 'index.dart';

/// 右键菜单默认的构建器
ElContextMenuBuilder _defaultBuilder = (key, menuId, position, menuList, prevMenu) =>
    ElDesktopContextMenu(key: key, menuId: menuId, position: position, menuList: menuList, prevMenu: prevMenu);

extension ElContextMenuServiceExt on El {
  ElContextMenuService get contextMenu => ElContextMenuService();
}

/// 右键菜单全局服务类
class ElContextMenuService {
  static ElContextMenuService? _instance;

  factory ElContextMenuService() {
    _instance ??= ElContextMenuService._();
    return _instance!;
  }

  ElContextMenuService._();

  OverlayEntry? _overlayEntry;

  Completer<ElMenuEntry?>? _completer;

  ElMenuEntry? _selectedMenu;

  late ElContextMenuBuilder _builder;

  Object? _menuId;

  /// 当前菜单 id，此标识用于安全关闭菜单，只允许关闭自身创建的菜单
  Object? get menuId => _menuId;

  BuildContext? _context;

  /// 打开菜单的 context
  BuildContext get context => _context!;

  late ElContextMenuThemeData _themeData;

  Size? _targetSize;

  /// 打开菜单的目标尺寸
  Size get targetSize => _targetSize!;

  /// 在显示右键菜单前注入的主题数据
  ElContextMenuThemeData get themeData => _themeData;

  /// 指定菜单的上级焦点，当显示菜单时此焦点也会聚焦
  FocusNode? _parentNode;

  /// 划分右键菜单外部区域分组标识
  Object? _groupId;

  bool? _isMenuAnchor;

  /// 展开的菜单是否存在固定锚点，这类菜单的偏移位置会固定展示在下方、上方，例如 [ElMenuBar]，
  /// 对于这种菜单需要限制第一条菜单的尺寸，使其高度不能超过锚点位置（默认情况下菜单被限制在 Overlay 的最大尺寸中）
  bool? get isMenuAnchor => _isMenuAnchor;

  FocusTraversalPolicy? _policy;

  /// 自定义菜单焦点遍历逻辑
  FocusTraversalPolicy get policy => _policy!;

  /// 是否存在菜单
  bool get hasMenu => _overlayEntry != null;

  /// 在页面上显示右键菜单
  Future<ElMenuEntry?> show(
    BuildContext context,
    Object menuId,
    Offset position,
    List<ElMenuEntry> menuList, {
    ElContextMenuBuilder? builder,
    FocusNode? parentNode,
    Object? groupId,
    bool? isMenuAnchor,
    FocusTraversalPolicy? policy,
  }) {
    _remove();
    _completer = Completer<ElMenuEntry?>();
    _builder = builder ?? _defaultBuilder;
    _context = context;
    _targetSize = context.size;
    _themeData = ElContextMenuTheme.of(context);
    _parentNode = parentNode;
    _groupId = groupId;
    _menuId = menuId;
    _isMenuAnchor = isMenuAnchor;
    _policy = policy ?? _MenuOrderTraversalPolicy();
    _overlayEntry = OverlayEntry(builder: (context) => _builder(null, menuId, position, menuList, null));
    el.overlay.insert(_overlayEntry!);
    return _completer!.future;
  }

  /// 移除当前创建的右键菜单
  void remove(Object menuId) {
    if (_menuId == menuId) {
      _remove();
      _menuId = null;
    }
  }

  void _remove() {
    if (hasMenu) {
      _completer!.complete(_selectedMenu);
      _overlayEntry!.remove();
      _overlayEntry!.dispose();
      _overlayEntry = null;
      _context = null;
      _completer = null;
      _selectedMenu = null;
    }
  }
}
