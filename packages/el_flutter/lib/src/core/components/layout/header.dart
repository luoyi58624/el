import 'package:el_flutter/el_flutter.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ElHeader extends StatelessWidget {
  const ElHeader({super.key, this.style, this.boxStyle, required this.child});

  final ElHeaderStyle? style;
  final ElBoxStyle? boxStyle;
  final dynamic child;

  @override
  Widget build(BuildContext context) {
    final (duration, curve) = el.globalAnimation();
    final padding = MediaQuery.paddingOf(context);
    final style = const ElHeaderStyle(safeArea: true, height: 56).merge(this.style);

    final boxStyle = ElBoxStyle(
      height: style.height! + (style.safeArea == true ? padding.top : 0),
      padding: .only(top: style.safeArea == true ? padding.top : 0, left: 8, right: 8),
      alignment: Alignment.center,
    ).merge(this.boxStyle);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // statusBarColor: bgColor,
        statusBarBrightness: Brightness.light, // 仅 IOS 生效
        // statusBarIconBrightness: bgColor.isDark.brightness.reverse,
        systemStatusBarContrastEnforced: false,
      ),
      child: ElBox(
        duration: duration,
        curve: curve,
        style: boxStyle,
        child: AnimatedDefaultTextStyle(
          duration: duration,
          curve: curve,
          style: DefaultTextStyle.of(context).style.copyWith(
            color: context.elTheme.regularTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold.elFontWeight,
          ),
          child: child is Widget ? child : Text(child.toString()),
        ),
      ),
    );
  }
}
