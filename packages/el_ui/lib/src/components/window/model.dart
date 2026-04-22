part of 'index.dart';

class _WindowModelWidget extends InheritedWidget {
  const _WindowModelWidget(this.model, {required super.child});

  final ElWindowModel model;

  static ElWindowModel of(BuildContext context) {
    final _WindowModelWidget? result = context.dependOnInheritedWidgetOfExactType<_WindowModelWidget>();
    assert(result != null, 'No _WindowModelWidget found in context');
    return result!.model;
  }

  @override
  bool updateShouldNotify(_WindowModelWidget oldWidget) => model != oldWidget.model;
}

@ElModelGenerator.copy()
// ignore: must_be_immutable
class ElWindowModel with EquatableMixin {
  ElWindowModel({
    this.child,
    this.title,
    this.icon,
    required this.size,
    this.minSize = Size.zero,
    this.maxSize,
    this.alignment = Alignment.center,
    this.offset = Offset.zero,
    this.fullscreen = false,
    this.hidden = false,
    this.cacheKey,
  });

  /// 窗口内容小组件，默认 [ElEmptyWidget]
  final Widget? child;

  /// 窗口标题，可选，当使用
  String? title;

  /// 窗口图标，可选
  String? icon;

  /// 创建窗口时的初始尺寸
  final Size size;

  /// 限制窗口的最小尺寸
  final Size minSize;

  /// 限制窗口的最大尺寸，注意：如果限制最大可能无法全屏
  final Size? maxSize;

  /// 指定窗口大致定位，默认居中
  final Alignment alignment;

  /// 基于 [alignment] 的偏移位置
  final Offset offset;

  /// 以全屏打开弹窗
  final bool fullscreen;

  /// 创建窗口时隐藏它
  final bool hidden;

  /// 窗口布局信息缓存 key
  final String? cacheKey;

  /// 当前窗口显示在屏幕的权重，权重越大则越靠近最前面，如果为负数则表示当前窗口被最小化
  late int index;

  /// 窗口 id，当窗口创建时会将生成的 id 设置到模型对象中
  late final String id;

  /// 窗口分组 id，当窗口创建时会将 groupKey 设置到模型对象中
  late final String? groupKey;

  /// 窗口控制器，当窗口创建时会将 controller 设置到模型对象中
  late final ElWindowController controller;

  @override
  List<Object?> get props => _props;

  @override
  String toString() {
    return 'ElWindowModel{title: $title, index: $index, id: $id, groupKey: $groupKey}';
  }
}
