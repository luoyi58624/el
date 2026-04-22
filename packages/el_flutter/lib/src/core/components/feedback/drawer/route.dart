part of 'index.dart';

const Tolerance _kFlingTolerance = Tolerance(velocity: double.infinity, distance: 0.01);

class _ElDrawerRoute<T> extends ElPopupRoute<T> {
  _ElDrawerRoute({
    required super.builder,
    required this.direction,
    required this.drawerMaxSize,
    this.enabledDrag = true,
    this.modalColor = Colors.black54,
    this.ignoreModalPointer = false,
    this.enabledFade = false,
  });

  final AxisDirection direction;
  final Size drawerMaxSize;
  final bool enabledDrag;
  final Color modalColor;
  final bool ignoreModalPointer;
  final bool enabledFade;

  final contentKey = GlobalKey();
  late bool isVertical = direction.isVertical;
  bool isPop = false;

  @override
  Duration get transitionDuration => Duration.zero;

  void closePopup(BuildContext context) {
    if (isPop == false) Navigator.of(context).pop();
  }

  @override
  Simulation? createSimulation({required bool forward}) {
    return ElDrawer.createSimulation(controller: controller!, velocity: forward ? 1.0 : -1.0);
  }

  @override
  bool didPop(T? result) {
    isPop = true;
    return super.didPop(result);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget result = _Transition(
      onModalTap: () => closePopup(context),
      controller: controller!,
      modalColor: modalColor,
      direction: direction,
      ignoreModalPointer: ignoreModalPointer,
      child: ConstrainedBox(
        constraints: ElDrawer.createBoxConstraints(isVertical: isVertical, drawerMaxSize: drawerMaxSize),
        child: Builder(
          key: contentKey,
          builder: (context) {
            return super.buildPage(context, animation, secondaryAnimation);
          },
        ),
      ),
    );

    if (ElPlatform.isDesktop || enabledDrag == false) return result;

    return _DrawerDrag(
      onDragUpdate: (delta) {
        controller!.value += delta;
      },
      onDragEnd: (delta) {
        if (controller!.value + delta < 0.5) {
          controller!.fling(velocity: -1, springDescription: ElDrawer.springDescription).then((e) {
            closePopup(context);
          });
        } else {
          controller!.fling(springDescription: ElDrawer.springDescription);
        }
      },
      direction: direction,
      getContentKey: () => contentKey,
      child: result,
    );
  }
}
