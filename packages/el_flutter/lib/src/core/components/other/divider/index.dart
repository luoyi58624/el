import 'package:el_flutter/el_flutter.dart';
import 'package:flutter/material.dart';

part 'theme.dart';

part 'index.g.dart';

class ElDivider extends StatelessWidget {
  const ElDivider({super.key, this.vertical = false});

  /// 是否为垂直分割线
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final themeData = ElDividerTheme.of(context);
    return ElAnimatedDefaultColor(
      themeData.color!,
      child: Builder(
        builder: (context) {
          return vertical
              ? VerticalDivider(
                  width: themeData.size ?? themeData.thickness,
                  thickness: themeData.thickness,
                  indent: themeData.indent,
                  color: context.elDefaultColor,
                )
              : Divider(
                  height: themeData.size ?? themeData.thickness,
                  thickness: themeData.thickness,
                  indent: themeData.indent,
                  color: context.elDefaultColor,
                );
        },
      ),
    );
  }
}
