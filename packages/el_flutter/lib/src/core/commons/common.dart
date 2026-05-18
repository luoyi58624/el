import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// 当框架正在处理下一帧持久回调时（build/layout），它将返回 true，当你在此阶段调用 setState 时，
/// Flutter 框架将会抛出异常：setState() or markNeedsBuild() called during build.
bool get atDrawFrame => SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks;

/// 将回调函数添加到下一帧执行，注意：如果框架没有触发帧重建，那么注册的回调将不会执行
void nextTick(VoidCallback fun) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    fun();
  });
}

/// 注册下一帧回调函数，此函数会主动请求下一帧
void nextFrame(VoidCallback fun) {
  WidgetsBinding.instance.scheduleFrameCallback((_) {
    fun();
  });
}

/// 安全地执行回调函数，在框架 build 期间，你不可以调用 setState、markNeedsBuild 之类重建方法，
/// 此函数会判断当前 Flutter 框架是否正在执行重建，若为 true 则会将回调安排到帧后运行
void safeCallback(VoidCallback fun) {
  atDrawFrame ? nextTick(fun) : fun();
}

/// 用于 [AnimationController] 的 vsync 参数，它与使用 [TickerProviderStateMixin] 区别在于：
/// * 后者拥有完善的 assert 断言警告，帮你规避一些错误；
/// * 后者允许通过 [TickerMode] 控制子树动画运行、暂停；
///
/// 所以，当你使用全局 vsync 时需要明白以下问题：
/// * 要记得在 dispose 前销毁动画控制器，否则会内存泄漏（没有 assert 断言提示）；
/// * 只用于瞬时动画、而不是持久动画，当页面不可见时使用此 ticker 动画会一直保持运行；
const vsync = _TickerProvider();

class _TickerProvider implements TickerProvider {
  const _TickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
