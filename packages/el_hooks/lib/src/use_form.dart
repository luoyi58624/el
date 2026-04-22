import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 与 React Hook Form 思路接近的最小实现：字段注册、[resolver] 校验、[handleSubmit] 提交。
///
/// 仅支持通过 [TextEditingController] 与 [TextField] / [TextFormField] 绑定；
/// 首帧会拷贝 [defaultValues] 作为初始文本。
UseFormResult useForm({required Map<String, dynamic> defaultValues, FormResolver? resolver}) {
  final resolverRef = useRef<FormResolver?>(resolver);
  resolverRef.value = resolver;

  final errors = useState<Map<String, String>>({});

  final impl = useMemoized(() => _UseFormImpl(Map<String, dynamic>.from(defaultValues)), const []);

  useEffect(() {
    return impl.dispose;
  }, [impl]);

  return UseFormResult._(impl: impl, errors: errors, resolve: () => resolverRef.value);
}

typedef FormResolver = Map<String, String>? Function(Map<String, dynamic> values);

class UseFormResult {
  UseFormResult._({
    required _UseFormImpl impl,
    required ValueNotifier<Map<String, String>> errors,
    required FormResolver? Function() resolve,
  }) : _impl = impl,
       _errors = errors,
       _resolve = resolve;

  final _UseFormImpl _impl;
  final ValueNotifier<Map<String, String>> _errors;
  final FormResolver? Function() _resolve;

  /// 绑定到 [TextField.controller]；同一 [name] 多次调用返回同一实例。
  TextEditingController register(String name) => _impl.register(name);

  Map<String, String> get errors => _errors.value;

  bool get hasErrors => errors.isNotEmpty;

  String? error(String name) => errors[name];

  /// 校验通过后执行 [onValid]，否则更新 [errors] 并触发重建。
  void handleSubmit(void Function(Map<String, dynamic> data) onValid) {
    final data = _impl.collectValues();
    final resolver = _resolve();
    final fieldErrors = resolver?.call(data);
    if (fieldErrors != null && fieldErrors.isNotEmpty) {
      _errors.value = Map<String, String>.from(fieldErrors);
      return;
    }
    _errors.value = <String, String>{};
    onValid(data);
  }

  /// 清空错误；提交前一般由 [handleSubmit] 自行处理。
  void clearErrors() {
    _errors.value = <String, String>{};
  }
}

class _UseFormImpl {
  _UseFormImpl(this._defaults);

  final Map<String, dynamic> _defaults;
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController register(String name) {
    return _controllers.putIfAbsent(name, () {
      final initial = _defaults[name];
      final text = initial == null ? '' : initial.toString();
      return TextEditingController(text: text);
    });
  }

  Map<String, dynamic> collectValues() {
    return {for (final e in _controllers.entries) e.key: e.value.text};
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
  }
}
