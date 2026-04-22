part of 'index.dart';

enum ElFormRuleTrigger {
  /// 失去焦点触发
  blur,

  /// 当表单项的值发生变化触发
  change,

  /// 当提交表单时触发
  submit,
}

/// 规则校验对象
class ElFormRule {
  const ElFormRule({required this.validator, required this.message, required this.trigger});

  /// 验证函数，当返回 false 表示未通过验证
  final bool Function(ElFormRule rule, dynamic value) validator;

  /// 错误文本提示
  final String message;

  /// 触发验证方式
  final ElFormRuleTrigger trigger;
}

/// 必填规则
class ElRequiredFormRule extends ElFormRule {
  static bool validate(ElFormRule rule, dynamic v) {
    if (v == null) return false;
    if (v is String && v.trim().isEmpty) return false;
    return true;
  }

  const ElRequiredFormRule({
    super.validator = validate,
    required super.message,
    super.trigger = ElFormRuleTrigger.blur,
  });
}

/// 范围区间规则
class ElRangFormRule extends ElFormRule {
  static bool validate(ElFormRule rule, dynamic v) {
    assert(rule is ElRangFormRule);
    rule as ElRangFormRule;

    if (v == null) return false;

    // 如果是字符串、集合，则判断其长度是否满足条件
    if (v is String || v is Iterable || v is Map) {
      if (v.length < rule.min) return false;
      if (rule.max != null && v.length > rule.max!) return false;
    }

    // 如果是数字，则比较其大小
    if (v is num) {
      if (v < rule.min) return false;
      if (rule.max != null && v > rule.max!) return false;
    }
    return true;
  }

  const ElRangFormRule({
    super.validator = validate,
    required super.message,
    super.trigger = ElFormRuleTrigger.change,
    this.min = 0,
    this.max,
  });

  final int min;
  final int? max;
}
