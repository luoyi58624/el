part of 'index.dart';

/// 表单双向绑定小部件，继承此类的小部件将会参与 [ElForm] 的校验
abstract class ElFormModelValue<D> extends ElModelValue<D> {
  const ElFormModelValue(super.modelValue, {super.key, super.onChanged, this.prop});

  /// 访问 [ElForm] 表单 model 数据 key，如果不为 null，祖先必须提供 [ElForm] 组件
  final String? prop;

  @override
  State<ElFormModelValue> createState();
}

abstract class ElFormModelValueState<T extends ElFormModelValue<D>, D> extends State<T> with ElModelValueMixin<T, D> {
  /// 祖先表单实例对象
  ElFormState? get formState => _formState;
  ElFormState? _formState;

  @mustCallSuper
  @override
  set modelValue(D v) {
    super.modelValue = v;

    // 若设置 prop，则同步更新 ElForm 的状态
    if (widget.prop != null) {
      assert(
        formState != null && formState!.modelValue.containsKey(widget.prop),
        'ElForm model 不包含目标 prop: [${widget.prop}]',
      );
      formState!.modelValue = {...formState!.modelValue, widget.prop!: v};
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    if (formState != null) {
      formState!.fields.remove(this);
      _formState = null;
    }
    super.dispose();
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);

    if (widget.prop != null) {
      assert(widget.modelValue is! ValueNotifier, 'ElFormModelValue Error: 如果设置 prop，其 modelValue 必须为普通数据类型！');
      _formState = ElForm.of(context);
      formState!.fields.add(this);

      // 若存在表单校验规则，则在表单下方构建错误文本
      if (formState!.widget.rules != null && formState!.widget.rules!.containsKey(widget.prop)) {
        result = ElStack(
          child: result,
          children: [
            ElPositioned(
              key: ValueKey(0),
              top: '100%',
              child: ObsBuilder(
                builder: (context) {
                  if (formState!.errorMessages.containsKey(widget.prop)) {
                    return Text(formState!.errorMessages[widget.prop], style: formState!.widget.errorTextStyle);
                  } else {
                    return ElEmptyWidget.instance;
                  }
                },
              ),
            ),
          ],
        );
      }
    } else {
      if (formState != null) {
        formState!.fields.remove(this);
        _formState = null;
      }
    }

    return result;
  }
}
