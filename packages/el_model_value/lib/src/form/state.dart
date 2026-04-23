part of 'index.dart';

class ElFormController extends ElHookState {
  ElFormController({required this.initialValue, this.rules, this.errorTextStyle}) {
    formData = MapObs<String, dynamic>(initialValue);
  }

  /// 表单初始值
  final Map<String, dynamic> initialValue;

  /// 表单规则集合，其中 key 对应模型数据的 key，value 为表单规则对象
  final Map<String, List<ElFormRule>>? rules;

  /// 错误文本样式
  final TextStyle? errorTextStyle;

  /// 表单响应式对象
  late final MapObs<String, dynamic> formData;

  /// 收集验证失败的错误消息，你可以直接操作此对象，它会自动更新 UI 上的错误信息
  final errorMessages = MapObs<String, String>({});

  Set<String> props = {};

  /// 验证表单
  bool validate() {
    for (final prop in props) {
      String? msg;

      if (rules != null && rules!.containsKey(prop)) {
        List<ElFormRule> rules = this.rules![prop]!;
        for (final rule in rules) {
          if (rule.validator(rule, formData[prop]) != true) {
            msg = rule.message;
            break;
          }
        }
      }

      if (msg == null) {
        errorMessages.remove(prop);
      } else {
        errorMessages[prop] = msg;
      }
    }

    return errorMessages.value.isEmpty;
  }

  /// 重置表单
  void reset() {
    errorMessages.clear();
    formData.value = Map.from(initialValue);
  }
}
