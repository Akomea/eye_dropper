part of eye_dropper;

class EyeDropper extends StatefulWidget {
  const EyeDropper({
    super.key,
    required this.child,
    this.haveTextColorWidget = true,
  });

  final Widget child;
  final bool haveTextColorWidget;

  static void enableEyeDropper(
      BuildContext context, Function(Color?)? onEyeDropper) async {
    _EyeDropperState? state =
        context.findAncestorStateOfType<_EyeDropperState>();
    state?.enableEyeDropper(onEyeDropper);
  }

  @override
  State<EyeDropper> createState() => _EyeDropperState();
}

class _EyeDropperState extends State<EyeDropper> {
  final GlobalKey _renderKey = GlobalKey();

  static const double eyeDropperPadding = 20.0;
  Offset? _lastPickedPosition;


  ui.Image? _image;
  bool _enableEyeDropper = false;

  final _offsetNotifier = ValueNotifier<Offset>(const Offset(0, 0));
  final _colorNotifier = ValueNotifier<Color?>(null);
  final _byteDataStateNotifier = ValueNotifier<ByteData?>(null);
  Function(Color?)? _onEyeDropper;

  void enableEyeDropper(Function(Color?)? onEyeDropper) async {
    var renderBox = _renderKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final boundary =
        _renderKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // initial image - byte data
    _image = await boundary.toImage();
    _byteDataStateNotifier.value = await _image!.toByteData();

    setState(() {
      // enable color picker
      _enableEyeDropper = true;
      // place the color picker overlay's position in the center
      // Check if there's a last picked position, otherwise use center
      if (_lastPickedPosition != null) {
        updatePosition(_lastPickedPosition!);
      } else {
        updatePosition(Offset(size.width / 2, size.height / 2));
      }

      _onEyeDropper = onEyeDropper;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: onPointerDown,
          onPointerMove: onPointerMove,
          onPointerUp: onPointerUp,
          child: RepaintBoundary(
            key: _renderKey,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: _enableEyeDropper,
          child: Positioned(
            left: getOverlayPosition().dx,
            top: getOverlayPosition().dy,
            child: Listener(
              onPointerMove: onPointerMove,
              onPointerUp: onPointerUp,
              child: EyeDropperOverlay(
                color: _colorNotifier.value ?? Colors.transparent,
              ),
            ),
          ),
        ),
        Visibility(
          visible: !(_colorNotifier.value != null && widget.haveTextColorWidget == false),
          child: Positioned(
            left: _offsetNotifier.value.dx - 30,
            top: _offsetNotifier.value.dy + 20,
            child: Material(
              shadowColor: Colors.black,
              elevation: 1.0,
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  _colorNotifier.value == null
                      ? ''
                      : colorToHexString(_colorNotifier.value!),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset getOverlayPosition() {
    double dx = _offsetNotifier.value.dx - kOverlaySize.width / 2;
    double dy =
        _offsetNotifier.value.dy - kOverlaySize.height + kEyeDropperSize / 2 - 80;
    return Offset(dx, dy);
  }

  void onPointerDown(PointerDownEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    if (_enableEyeDropper) {
      if (_colorNotifier.value != null) {
        _onEyeDropper?.call(_colorNotifier.value);
      }

      setState(() {
        _enableEyeDropper = false;
        _offsetNotifier.value = const Offset(0, 0);
        _colorNotifier.value = null;
        _image = null;
      });
    }
  }

  updatePosition(Offset newPosition) async {
    // Adjust the newPosition's y coordinate to pick color from above the touch point
    Offset adjustedPosition = Offset(
        newPosition.dx,
        newPosition.dy - 80  // Subtract 30 pixels from the y coordinate
    );

    var color = getPixelFromByteData(
      _byteDataStateNotifier.value!,
      width: _image!.width,
      x: adjustedPosition.dx.toInt(),
      y: adjustedPosition.dy.toInt(),
    );

    setState(() {
      // update position
      _offsetNotifier.value = newPosition;  // Keep the actual touch position for the overlay

      // update color
      _colorNotifier.value = color;

      _lastPickedPosition = newPosition;  // Save the last picked position

    });
  }

}