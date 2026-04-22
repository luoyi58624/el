import 'dart:async';

/// 异步工具类
class ElAsyncUtil {
  ElAsyncUtil._();

  /// 创建一个串行任务队列。
  ///
  /// 队列中的任务会按调用顺序一个接一个执行，前一个未完成时，后一个会等待。
  static ElSerialTaskQueue serialQueue() => ElSerialTaskQueue();

  /// 延迟指定时间执行函数，单位：毫秒
  static Timer setTimeout(void Function() fun, int wait) {
    return Timer(Duration(milliseconds: wait), fun);
  }

  /// 每隔一段时间执行函数，单位：毫秒
  static Timer setInterval(void Function() fun, int wait) {
    return Timer.periodic(Duration(milliseconds: wait), (e) {
      fun();
    });
  }

  static final Set<Object> _throttleKeys = {};
  static final Map<Object, Timer?> _throttleTrailingKeys = {};

  /// 对目标函数进行包装，返回一个节流函数，此函数会忽略指定时间内的多次执行
  /// * wait 节流时间(毫秒)
  /// * key 指定函数标识符，如果 fun 是匿名函数，则需要指定它
  /// * trailing 当多次调用函数时，确保最后一次函数执行
  static void Function() throttle(Function fun, int wait, {Object? key, bool trailing = false}) {
    assert(wait > 0);
    key ??= fun.hashCode;
    return () {
      if (_throttleKeys.contains(key)) {
        if (trailing) {
          _throttleTrailingKeys[key]?.cancel();
          _throttleTrailingKeys[key!] = ElAsyncUtil.setTimeout(() {
            _throttleTrailingKeys.remove(key);
            fun();
          }, wait);
        }

        return;
      } else {
        if (trailing) _throttleTrailingKeys[key]?.cancel();
        _throttleKeys.add(key!);
        ElAsyncUtil.setTimeout(() {
          _throttleKeys.remove(key);
        }, wait);

        fun();
      }
    };
  }

  static final Map<Object, Timer> _debounceTimerMap = {};

  /// 对函数进行防抖处理，如果在指定时间内多次执行函数，那么会忽略掉它，并重置等待时间，当等待时间结束后再执行函数
  /// * wait 防抖时间(毫秒)
  /// * key 指定函数标识符，如果 fun 是匿名函数，则需要指定它
  static void Function() debounce(Function fun, int wait, {Object? key}) {
    assert(wait > 0);
    key ??= fun.hashCode;
    return () {
      if (_debounceTimerMap.containsKey(key)) {
        _debounceTimerMap[key!]!.cancel();
        _debounceTimerMap.remove(key);
      }
      _debounceTimerMap[key!] = ElAsyncUtil.setTimeout(() {
        fun();
        _debounceTimerMap.remove(key);
      }, wait);
    };
  }

  static final Map<Object, Future> _shareTaskQueue = {};

  /// 运行共享结果任务，当同时运行多个异步任务时，确保只处理一个任务、并排除其他任务，
  /// 当第一个任务运行结束时，其他任务会得到第一个任务的结果
  static Future<T> runShareTask<T>(Object id, Future<T> Function() task) {
    if (_shareTaskQueue.containsKey(id)) {
      return _shareTaskQueue[id]! as Future<T>;
    }

    Completer<T>? completer = Completer<T>();
    _shareTaskQueue[id] = completer.future;

    task()
        .then((result) => completer!.complete(result))
        .catchError((error) => completer!.completeError(error))
        .whenComplete(() {
          _shareTaskQueue.remove(id);
          completer = null;
        });

    return _shareTaskQueue[id] as Future<T>;
  }
}

/// 串行任务队列
class ElSerialTaskQueue {
  Future<void> _tail = Future.value();

  /// 将任务加入队列，并按顺序串行执行。
  ///
  /// 无论前一个任务成功还是失败，后续任务都仍然可以继续排队执行。
  Future<T> run<T>(FutureOr<T> Function() task) {
    final next = _tail.then((_) => Future.sync(task));
    _tail = next.then((_) {}, onError: (_) {});
    return next;
  }
}
