part of 'index.dart';

class ElWinMinimizeButton extends StatelessWidget {
  const ElWinMinimizeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _WinButton(onPressed: onPressed, activeColor: Colors.black12, builder: (active) => _MinimizeIcon());
  }
}

class ElWinMaximizeButton extends StatelessWidget {
  const ElWinMaximizeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _WinButton(onPressed: onPressed, activeColor: Colors.black12, builder: (active) => _MaximizeIcon());
  }
}

class ElWinCloseButton extends StatelessWidget {
  const ElWinCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _WinButton(
      onPressed: onPressed,
      activeColor: .fromRGBO(255, 28, 0, 0.75),
      builder: (active) => _CloseIcon(active),
    );
  }
}

class _WinButton extends StatelessWidget {
  const _WinButton({required this.builder, required this.activeColor, required this.onPressed});

  final Widget Function(bool active) builder;
  final Color activeColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElStopPropagation(
      child: ElEvent(
        style: ElEventStyle(cursor: SystemMouseCursors.click, onTap: (e) => onPressed()),
        child: Builder(
          builder: (context) {
            final active = context.hasHover || context.hasTap;
            return SizedBox(
              width: 44,
              height: 44,
              child: ColoredBox(
                color: active ? activeColor : context.elDefaultColor,
                child: Center(child: builder(active)),
              ),
            );
          },
        ),
      ),
    );
  }
}

const _winIconSize = Size(10, 10);

class _MinimizeIcon extends LeafRenderObjectWidget {
  const _MinimizeIcon();

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MinimizeIconRender();
  }
}

class _MinimizeIconRender extends RenderBox {
  _MinimizeIconRender();

  @override
  void performLayout() {
    size = _winIconSize;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var paint = Paint()
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..color = Colors.black;
    final dy = (_winIconSize.height + 1.25) / 2;
    context.canvas.drawLine(offset + Offset(0, dy), offset + Offset(_winIconSize.width, dy), paint);
  }
}

class _MaximizeIcon extends LeafRenderObjectWidget {
  const _MaximizeIcon();

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MaximizeIconRender();
  }
}

class _MaximizeIconRender extends RenderBox {
  _MaximizeIconRender();

  @override
  void performLayout() {
    size = _winIconSize;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var paint = Paint()
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..color = Colors.black;
    context.canvas.drawRect(offset & size, paint);
  }
}

class _CloseIcon extends LeafRenderObjectWidget {
  const _CloseIcon(this.active);

  final bool active;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CloseIconRender(active);
  }

  @override
  void updateRenderObject(BuildContext context, _CloseIconRender renderObject) {
    renderObject.active = active;
  }
}

class _CloseIconRender extends RenderBox {
  _CloseIconRender(this._active);

  bool? _active;

  set active(bool v) {
    _active = v;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = _winIconSize;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var paint = Paint()
      ..strokeWidth = 1.25
      ..style = PaintingStyle.fill
      ..color = _active! ? Colors.white : Colors.black;
    final p1 = offset;
    final p2 = offset + Offset(_winIconSize.width, _winIconSize.height);
    final p3 = offset + Offset(_winIconSize.width, 0);
    final p4 = offset + Offset(0, _winIconSize.height);
    context.canvas.drawLine(p1, p2, paint);
    context.canvas.drawLine(p3, p4, paint);
  }
}
