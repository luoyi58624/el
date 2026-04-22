part of 'index.dart';

class _ThemeToast extends StatelessWidget {
  const _ThemeToast(this.content, this.type);

  final dynamic content;
  final ElThemeType type;

  @override
  Widget build(BuildContext context) {
    const bottomOffset = 80.0;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final bgColor = context.elThemeColors[type]!;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 50,
        vertical: bottomPadding >= bottomOffset ? bottomPadding + bottomOffset / 4 : bottomOffset,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: UnconstrainedBox(
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(200),
            clipBehavior: Clip.antiAlias,
            color: bgColor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Center(
                child: ElRichText(content, style: TextStyle(color: bgColor.elTextColor(context))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
