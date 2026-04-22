part of 'index.dart';

abstract class ElFormModelValue<D> extends ElModelValue<D> {
  const ElFormModelValue({super.key, super.value, super.modelValue, super.onChanged, this.prop});

  /// 访问 [ElForm] 表单 model 数据 key
  final String? prop;

  @override
  Widget build(BuildContext context) {
    Widget result = super.build(context);
    final formState = ElForm.maybeOf(context);

    useEffect(() {
      return () {
        formState?.props.remove(prop);
      };
    }, []);

    if (formState != null && prop != null) {
      formState.props.add(prop!);

      // 若存在表单校验规则，则在表单下方构建错误文本
      if (formState.rules != null && formState.rules!.containsKey(prop)) {
        result = ElStack(
          child: result,
          children: [
            ElPositioned(
              key: ValueKey(0),
              top: '100%',
              child: ObsBuilder(
                builder: (context) {
                  if (formState.errorMessages.containsKey(prop)) {
                    return Text(formState.errorMessages[prop], style: formState.errorTextStyle);
                  } else {
                    return ElEmptyWidget.instance;
                  }
                },
              ),
            ),
          ],
        );
      }
    }

    return result;
  }
}
