part of 'index.dart';

class _Toast extends StatelessWidget {
  const _Toast(this.content);

  final dynamic content;

  @override
  Widget build(BuildContext context) {
    final background = ElBrightness.isDark(context)
        ? const Color.fromRGBO(82, 82, 82, .75)
        : const Color.fromRGBO(0, 0, 0, .65);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
        child: ElRichText(content, style: TextStyle(color: background.elTextColor(context))),
      ),
    );
  }
}
