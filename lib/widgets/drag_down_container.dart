import 'dart:math';
import 'package:flutter/material.dart';

class DragDownContainerController with ChangeNotifier {
  double _maxContainerHeight;
  double get maxContainerHeight => _maxContainerHeight;

  double _containerHeight = 0;
  double get containerHeight => _containerHeight;

  bool get isOpen => containerHeight >= _maxContainerHeight * 0.90;
  bool get isClosed => containerHeight <= _maxContainerHeight * 0.10;

  ValueNotifier<double> containerHeightPercentNotifier =
      ValueNotifier<double>(0);

  DragDownContainerController({
    double maxContainerHeight = double.infinity,
  }) : _maxContainerHeight = maxContainerHeight;

  void _setContainerHeight(double height) {
    _containerHeight = height;
    containerHeightPercentNotifier.value =
        _containerHeight / _maxContainerHeight;
  }

  void open() {
    _setContainerHeight(_maxContainerHeight);
    notifyListeners();
  }

  void close() {
    _setContainerHeight(0);
    notifyListeners();
  }

  //wird aufgerufen, wenn der Benutzer los lässt
  void _notify() {
    notifyListeners();
  }
}

class DragDownContainer extends StatefulWidget {
  final Widget child;
  final Widget containerChild;
  final double maxContainerHeight;
  final bool Function()? canBeOpened;
  final DragDownContainerController? controller;
  // Adjust this value to control the drag sensitivity
  final double dragFactor;

  const DragDownContainer({
    super.key,
    required this.child,
    required this.containerChild,
    this.maxContainerHeight = 300.0,
    this.dragFactor = 1,
    this.controller,
    this.canBeOpened,
  });

  @override
  State<DragDownContainer> createState() => _DragDownContainerState();
}

class _DragDownContainerState extends State<DragDownContainer> {
  late final DragDownContainerController controller;
  Offset _lastDragPos = Offset.zero;
  double _xDragDistance = 0;
  double _yDragDistance = 0;
  bool _isDragging = false;
  bool _wasOpenOnPressStart = false;

  void _controllerListener() {
    setState(() {});
  }

  @override
  void initState() {
    controller = widget.controller ?? DragDownContainerController();
    if (controller._maxContainerHeight.isInfinite) {
      controller._maxContainerHeight = widget.maxContainerHeight;
    }

    controller.addListener(_controllerListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        _lastDragPos = details.position;
        _xDragDistance = 0;
        _yDragDistance = 0;
        _isDragging = widget.canBeOpened?.call() ?? true;
        _wasOpenOnPressStart = controller.isOpen;
      },
      onPointerMove: (details) {
        _isDragging = widget.canBeOpened?.call() ?? true;
        if (!_isDragging) {
          setState(() {
            controller._setContainerHeight(0);
          });
          return;
        }

        Offset dragOffset = details.position - _lastDragPos;
        _lastDragPos = details.position;

        _xDragDistance += dragOffset.dx.abs();
        _yDragDistance += dragOffset.dy.abs();

        const threshold = 20.0; // Minimum drag distance to consider a drag
        final completeDist = sqrt(
          pow(_xDragDistance, 2) + pow(_yDragDistance, 2),
        );

        if (completeDist > threshold &&
            _xDragDistance > _yDragDistance &&
            !controller.isOpen) {
          setState(() {
            controller._setContainerHeight(0);
          });
          return;
        }

        setState(() {
          controller._setContainerHeight(
            (controller._containerHeight + dragOffset.dy * widget.dragFactor)
                .clamp(0, widget.maxContainerHeight),
          );
        });
      },
      onPointerUp: (details) {
        _isDragging = false;

        // If there was a tap, close the container
        if (_xDragDistance == 0 &&
            _yDragDistance == 0 && // ist nicht schön, aber funktioniert
            details.position.dy > widget.maxContainerHeight / 2) {
          setState(() {
            controller._setContainerHeight(0);
            if (_wasOpenOnPressStart) {
              controller._notify();
            }
          });
          return;
        }

        // Snap behavior
        if (controller._containerHeight > widget.maxContainerHeight / 2) {
          setState(() {
            controller._setContainerHeight(widget.maxContainerHeight);
            if (!_wasOpenOnPressStart) {
              controller._notify();
            }
          });
        } else {
          setState(() {
            controller._setContainerHeight(0);
            if (_wasOpenOnPressStart) {
              controller._notify();
            }
          });
        }
      },
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            child: IgnorePointer(
              ignoring: !controller.isClosed,
              child: widget.child,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height:
                controller._containerHeight.clamp(0, widget.maxContainerHeight),
            width: double.infinity,
            color: Colors.transparent,
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: OverflowBox(
                maxHeight: widget.maxContainerHeight,
                child: widget.containerChild,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
