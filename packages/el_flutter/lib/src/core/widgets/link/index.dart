import 'dart:async';

import 'package:el_flutter/ext.dart';
import 'package:flutter/material.dart';

import 'package:el_flutter/el_flutter.dart';

import './web.dart' if (dart.library.io) './io.dart';

/// 超链接地址显示、隐藏动画控制器
AnimationController? _controller;

/// 透明动画持续时间
const int _animationTime = 200;

/// 延迟显示、隐藏时间
const int _delayTime = 300;

/// 超链接地址预览浮层
OverlayEntry? _linkOverlay;

/// 延迟显示控制器
Timer? _delayShowOverlay;

/// 延迟隐藏控制器
Timer? _delayHideOverlay;

/// 移除浮层前需要先执行隐藏动画，动画结束后再移除浮层
Timer? _delayRemoveOverlay;

/// 响应式变量 - 超链接预览地址
final Obs<String> _href = Obs('');

enum ElLinkDecoration {
  /// 不显示下划线
  none,

  /// 总是显示下划线
  underline,

  /// 当悬停时显示下划线
  hoverUnderline,
}

class ElLink extends StatelessWidget {
  /// 超链接默认颜色构建
  static ElColorBuilder defaultColorBuilder = (BuildContext context) {
    return ElBrightness.isDark(context) ? const .fromRGBO(64, 158, 255, 1.0) : const .fromRGBO(9, 105, 218, 1.0);
  };

  /// 超链接默认激活颜色构建
  static ElColorBuilder defaultActiveColorBuilder = defaultColorBuilder;

  /// 超链接小部件，链接跳转基于 [url_launcher] 第三方库，当鼠标悬停时会在左下角显示链接地址。
  const ElLink({
    super.key,
    required this.href,
    required this.child,
    this.color,
    this.activeColor,
    this.decoration,
    this.cursor = SystemMouseCursors.click,
    this.target = LinkTarget.blank,
  });

  /// 超链接地址
  final String href;

  /// 超链接子组件，如果不是 Widget 类型，则渲染默认样式文本
  final dynamic child;

  /// 默认的超链接文本颜色
  final Color? color;

  /// 激活的超链接文本颜色
  final Color? activeColor;

  /// 超链接下划线显示逻辑
  final ElLinkDecoration? decoration;

  /// 自定义光标样式，默认点击
  final MouseCursor cursor;

  /// 打开链接的目标位置，默认 blank 新窗口打开
  final LinkTarget target;

  void _show(BuildContext context, String href) {
    _delayShowOverlay = null;
    _href.value = href;

    if (_linkOverlay == null) {
      _linkOverlay = OverlayEntry(builder: (context) => const _LinkOverlay());
      Overlay.of(context, rootOverlay: true).insert(_linkOverlay!);
    }
  }

  void _hide() {
    if (_linkOverlay != null) {
      _delayHideOverlay = null;
      _controller!.reverse();
      _delayRemoveOverlay = ElAsyncUtil.setTimeout(() {
        _delayRemoveOverlay = null;
        _linkOverlay!.remove();
        _linkOverlay!.dispose();
        _linkOverlay = null;
      }, _animationTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? defaultColorBuilder(context);
    final activeColor = this.activeColor ?? defaultActiveColorBuilder(context);
    final previewLink = getPreviewLink(href);
    return DefaultSelectionStyle(
      mouseCursor: cursor,
      child: ElEvent(
        style: ElEventStyle(
          cursor: cursor,
          onTap: (e) => toLink(href, target),
          onSecondaryTapDown: (e) {
            // el.contextMenu.show(context, hashCode, e.globalPosition, [
            //   ElMenuEntry(
            //     title: '在新标签中打开链接',
            //     onTap: () {
            //       el.message.show('点击了返回');
            //     },
            //   ),
            //   ElMenuEntry(title: '在新窗口中打开链接'),
            //   ElMenuEntry(title: '在隐身窗口中打开链接'),
            //   ElMenuSeparator(),
            //   ElMenuEntry(title: '复制链接地址'),
            //   ElMenuEntry(title: '复制文本'),
            //   ElMenuSeparator(),
            //   ElMenuEntry(title: '翻译成中文 (简体)'),
            // ]);
          },
          onEnter: previewLink == null
              ? null
              : (e) {
                  if (_delayHideOverlay != null) {
                    _delayHideOverlay!.cancel();
                    _delayHideOverlay = null;
                  } else {
                    if (_delayRemoveOverlay != null) {
                      _controller!.forward();
                      _delayRemoveOverlay!.cancel();
                      _delayRemoveOverlay = null;
                    }
                  }
                  if (_linkOverlay == null) {
                    _delayShowOverlay = ElAsyncUtil.setTimeout(() {
                      _show(context, previewLink);
                    }, _delayTime);
                  } else {
                    _show(context, previewLink);
                  }
                },
          onExit: previewLink == null
              ? null
              : (e) {
                  if (_delayShowOverlay != null) {
                    _delayShowOverlay!.cancel();
                    _delayShowOverlay = null;
                  }
                  if (_linkOverlay != null) {
                    _delayHideOverlay = ElAsyncUtil.setTimeout(_hide, _delayTime);
                  }
                },
        ),
        child: Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return FocusTraversalGroup(
                descendantsAreTraversable: false,
                child: ElRing(
                  show: hasFocus,
                  strokeAlign: BorderSide.strokeAlignInside,
                  color: activeColor,
                  offset: 0,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: context.hasHover ? activeColor : color,
                      decoration: hasFocus
                          ? TextDecoration.none
                          : decoration == ElLinkDecoration.underline
                          ? TextDecoration.underline
                          : decoration == ElLinkDecoration.hoverUnderline
                          ? (context.hasHover ? TextDecoration.underline : TextDecoration.none)
                          : TextDecoration.none,
                      decorationColor: context.hasHover ? activeColor : color,
                    ),
                    child: child is Widget ? child : ElRichText(child),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LinkOverlay extends StatefulWidget {
  const _LinkOverlay();

  @override
  State<_LinkOverlay> createState() => _LinkOverlayState();
}

class _LinkOverlayState extends State<_LinkOverlay> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animationTime.ms);
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: IgnorePointer(
        child: ElBrightness(
          Brightness.light,
          child: AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return Opacity(
                opacity: _controller!.value,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 50),
                  padding: const .symmetric(horizontal: 8, vertical: 2),
                  decoration: const BoxDecoration(
                    color: .fromRGBO(227, 227, 227, 1),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(4)),
                    border: Border(top: _linkBorderSide, right: _linkBorderSide),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, offset: Offset(0, 0), blurRadius: 12, spreadRadius: 0),
                    ],
                  ),
                  child: DefaultTextStyle(
                    style: context.elRegularTextStyle,
                    child: ObsBuilder(
                      builder: (context) {
                        return Text(
                          _href.value,
                          style: const TextStyle(fontSize: 12, fontWeight: .w500),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

const BorderSide _linkBorderSide = BorderSide(
  // width: 0.5,
  color: .fromRGBO(174, 174, 174, 0.4),
);
