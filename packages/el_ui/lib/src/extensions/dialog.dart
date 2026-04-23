import 'package:el_flutter/el_flutter.dart' as e;
import 'package:el_flutter/ext.dart';
import 'package:el_ui/el_ui.dart';
import 'package:flutter/material.dart';

extension ElDialogServiceExt on El {
  static final _instance = ElDialogService();

  /// 弹窗服务，它是基于 [Navigator] 推送弹窗
  ElDialogService get dialog => _instance;
}

class ElDialogService extends e.ElDialogService {
  /// 构建对话框通用外观小部件
  Widget buildDialogWrapper({required Widget child, final List<BoxShadow>? boxShadow}) {
    return Builder(
      builder: (context) {
        final bgColor = context.elTheme.cardColor;
        Widget result = Container(
          width: 450,
          padding: const .all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: el.config.cardBorderRadius,
            boxShadow: boxShadow ?? ElFlutterUtil.shadow(elevation: 4),
          ),
          child: ElDefaultColor(bgColor, child: child),
        );
        if (ElPlatform.isMobile) {
          result = AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            padding: const EdgeInsets.all(28) + MediaQuery.viewInsetsOf(context),
            child: result,
          );
        }
        return result;
      },
    );
  }

  /// 显示简单提示对话框
  /// * enabledLoading 当确认按钮执行异步任务时，是否启动 loading 动画
  /// * onConfirm 点击确认按钮时执行的回调函数，支持异步回调
  Future<bool?> alert({
    String? title = '提示',
    required String content,
    String? cancelText = '取消',
    String? confirmText = '确定',
    bool enabledLoading = false,
    Future<bool> Function()? onConfirm,
  }) async {
    final loading = Obs(false);

    final child = buildDialogWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .start,
        children: [
          if (title != null) H3(title),
          Padding(padding: const .symmetric(vertical: 16), child: ElRichText(content)),
          Row(
            children: [
              const Spacer(),
              if (cancelText != null)
                ObsBuilder(
                  builder: (context) {
                    return ElButton(onPressed: loading.value ? null : close, child: cancelText);
                  },
                ),
              const Gap(8),
              if (confirmText != null)
                ObsBuilder(
                  builder: (context) {
                    return ElButton(
                      onPressed: () async {
                        bool result = true;
                        if (onConfirm != null) {
                          if (enabledLoading) loading.value = true;
                          result = await onConfirm();
                          if (enabledLoading) loading.value = false;
                        }
                        if (result) close(true);
                      },
                      type: .primary,
                      loading: loading.value,
                      child: confirmText,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );

    return await show(builder: (context) => child);
  }

  /// 显示简单文本输入对话框
  Future<String?> input({
    String title = '请输入',
    String value = '',
    String? cancelText = '取消',
    String? confirmText = '确定',
    double width = 450,
    bool rootNavigator = false,
    bool enabledLoading = false,
    Future<bool> Function(String value)? onConfirm,
  }) async {
    final loading = Obs(false);
    final inputValue = Obs(value);

    final child = buildDialogWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          H3(title),
          Padding(padding: const .symmetric(vertical: 16), child: ElInput(modelValue: inputValue, autofocus: true)),
          Row(
            children: [
              const Spacer(),
              if (cancelText != null)
                ObsBuilder(
                  builder: (context) {
                    return ElButton(onPressed: loading.value ? null : close, child: cancelText);
                  },
                ),
              const Gap(8),
              if (confirmText != null)
                ObsBuilder(
                  builder: (context) {
                    return ElButton(
                      onPressed: () async {
                        bool result = true;
                        if (onConfirm != null) {
                          if (enabledLoading) loading.value = true;
                          result = await onConfirm(inputValue.value);
                          if (enabledLoading) loading.value = false;
                        }
                        if (result) close(inputValue.value);
                      },
                      type: .primary,
                      loading: loading.value,
                      child: confirmText,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
    final result = await show(builder: (context) => child);
    inputValue.dispose();
    return result;
  }
}
