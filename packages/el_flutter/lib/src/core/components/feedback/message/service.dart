part of 'index.dart';

extension ElMessageExt on El {
  static final _instance = ElMessageService();

  /// 在页面上展示全局消息对象
  ElMessageService get message => _instance;
}

/// Element UI 消息服务，它会在屏幕中上方显示一连串的消息，并支持合并相同类型的消息
class ElMessageService extends ElAnimatedOverlayService with ChangeNotifier {
  int _messageId = 0;

  /// 消息列表
  final List<_MessageModel> _messageList = [];

  double? _firstTopOffset;

  @protected
  @override
  int get zIndex => el.config.messageIndex;

  /// 在页面上显示一条消息
  /// * content 消息内容
  /// * type 主题类型
  /// * icon 自定义消息图标，如果 content 是 [Widget]，则此属性无效
  /// * closeDuration 持续时间
  /// * showClose 是否显示关闭按钮
  /// * offset 第一条消息距离顶部窗口的距离
  /// * grouping 是否合并内容相同的消息，注意：type 也必须相同
  /// * builder 自定义构建消息内容
  void show(
    dynamic content, {
    ElThemeType type = .info,
    Widget? icon,
    Duration? closeDuration,
    Duration? animationDuration,
    bool? showClose,
    double? offset,
    bool? grouping,
    ElMessageBuilder? builder,
    int? zIndex,
  }) {
    ElAssert.themeTypeRequired(type, '_MessageModel');

    if (grouping == true) {
      for (final model in _messageList.reversed) {
        if (model.type == type && model.content == content && model._closing == false) {
          model._groupCount.value++;
          return;
        }
      }
    }

    final id = _messageId++;
    _firstTopOffset ??= offset ?? 20.0;
    late final _MessageModel model;
    model = _MessageModel(
      id,
      type,
      content,
      icon,
      showClose ?? true,
      closeDuration ?? const Duration(milliseconds: 3000),
      animationDuration ?? const Duration(milliseconds: 300),
      builder == null ? (context) => _defaultBuilder(context, model) : (context) => builder(context, content),
      Obs(0),
      () => _closeById(id),
    );

    _messageList.add(model);
    notifyListeners();

    model._overlayId = insert(
      (remove, onHide) => _MessageWidget(message: model, service: this, remove: remove, onHide: onHide),
      zIndex: zIndex,
    );
  }

  /// primary 主题消息
  void primary(
    dynamic content, {
    Widget? icon,
    Duration? closeDuration,
    bool? showClose,
    double? offset,
    bool? grouping,
    int? zIndex,
  }) {
    show(
      content,
      type: .primary,
      icon: icon,
      closeDuration: closeDuration,
      showClose: showClose,
      offset: offset,
      grouping: grouping,
      zIndex: zIndex,
    );
  }

  /// success 主题消息
  void success(
    dynamic content, {
    Widget? icon,
    Duration? closeDuration,
    bool? showClose,
    double? offset,
    bool? grouping,
    int? zIndex,
  }) {
    show(
      content,
      type: .success,
      icon: icon,
      closeDuration: closeDuration,
      showClose: showClose,
      offset: offset,
      grouping: grouping,
      zIndex: zIndex,
    );
  }

  /// info 主题消息
  void info(
    dynamic content, {
    Widget? icon,
    Duration? closeDuration,
    bool? showClose,
    double? offset,
    bool? grouping,
    int? zIndex,
  }) {
    show(
      content,
      type: .info,
      icon: icon,
      closeDuration: closeDuration,
      showClose: showClose,
      offset: offset,
      grouping: grouping,
      zIndex: zIndex,
    );
  }

  /// warning 主题消息
  void warning(
    dynamic content, {
    Widget? icon,
    Duration? closeDuration,
    bool? showClose,
    double? offset,
    bool? grouping,
    int? zIndex,
  }) {
    show(
      content,
      type: .warning,
      icon: icon,
      closeDuration: closeDuration,
      showClose: showClose,
      offset: offset,
      grouping: grouping,
      zIndex: zIndex,
    );
  }

  /// error 主题消息
  void error(
    dynamic content, {
    Widget? icon,
    Duration? closeDuration,
    bool? showClose,
    double? offset,
    bool? grouping,
    int? zIndex,
  }) {
    show(
      content,
      type: .error,
      icon: icon,
      closeDuration: closeDuration,
      showClose: showClose,
      offset: offset,
      grouping: grouping,
      zIndex: zIndex,
    );
  }

  double _topOffsetOf(_MessageModel message) {
    double result = _firstTopOffset ?? 20.0;
    for (final current in _messageList) {
      if (current.id == message.id) break;
      result += current._messageSize.value.height + _messageGap;
    }
    return result;
  }

  void _updateMessageSize(_MessageModel message, Size size) {
    if (message._closing || message._messageSize.value == size) return;
    message._messageSize.value = size;
    notifyListeners();
  }

  Future<void> _closeById(int id) async {
    final message = _messageList.where((e) => e.id == id).firstOrNull;
    if (message == null) return;
    await _closeMessage(message);
  }

  Future<void> _closeMessage(_MessageModel message) async {
    if (message._closing) return;
    final overlayId = message._overlayId;
    if (overlayId == null) return;
    message._closing = true;
    notifyListeners();
    await remove(overlayId);
  }

  @override
  void onRemoved(int id) {
    final index = _messageList.indexWhere((message) => message._overlayId == id);
    if (index == -1) return;

    final message = _messageList.removeAt(index);
    message._overlayId = null;
    message._groupCount.dispose();
    message._messageSize.dispose();

    if (_messageList.isEmpty) {
      _firstTopOffset = null;
    }

    notifyListeners();
  }
}

class _MessageModel {
  final int id;

  /// 消息类型
  final ElThemeType type;

  /// 消息内容
  final dynamic content;

  /// 消息图标
  final Widget? icon;

  /// 是否显示关闭按钮
  final bool showClose;

  /// 自动关闭时长
  final Duration closeDuration;

  /// 进出场动画时长
  final Duration animationDuration;

  final WidgetBuilder builder;
  final Future<void> Function() close;

  int? _overlayId;
  bool _closing = false;

  /// 如果开启了合并消息，出现 (相同内容 & 相同类型) 的消息该值会自增
  final Obs<int> _groupCount;

  /// 当前消息元素大小
  final Obs<Size> _messageSize = Obs(Size.zero);

  _MessageModel(
    this.id,
    this.type,
    this.content,
    this.icon,
    this.showClose,
    this.closeDuration,
    this.animationDuration,
    this.builder,
    this._groupCount,
    this.close,
  );
}
