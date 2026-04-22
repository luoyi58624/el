part of 'index.dart';

class _ElDialogRoute<T> extends ElPopupRoute<T> {
  _ElDialogRoute({required super.builder, this.modalColor = Colors.black54, this.ignoreModalPointer = false});

  final Color modalColor;
  final bool ignoreModalPointer;

  final _show = ValueNotifier(true);

  void closePopup(BuildContext context) {
    if (_show.value == true) Navigator.of(context).pop();
  }

  @override
  Duration get transitionDuration => ElDialog.defaultDuration;

  @override
  bool didPop(T? result) {
    _show.value = false;
    return super.didPop(result);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return _Transition(
      onModalTap: () => closePopup(context),
      controller: controller!,
      modalColor: modalColor,
      ignoreModalPointer: ignoreModalPointer,
      child: super.buildPage(context, animation, secondaryAnimation),
    );
  }
}
