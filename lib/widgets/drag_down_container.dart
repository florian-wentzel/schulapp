import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DragDownContainerController with ChangeNotifier {
  double _maxContainerHeight;
  double get maxContainerHeight => _maxContainerHeight;

  double _containerHeight = 0;
  double get containerHeight => _containerHeight;

  bool get isOpen => containerHeight >= _maxContainerHeight * 0.90;

  DragDownContainerController({
    double maxContainerHeight = double.infinity,
  }) : _maxContainerHeight = maxContainerHeight;

  void open() {
    _containerHeight = _maxContainerHeight;
    notifyListeners();
  }

  void close() {
    _containerHeight = 0;
    notifyListeners();
  }
}

class DragDownContainer extends StatefulWidget {
  final Widget child;
  final Widget containerChild;
  final double maxContainerHeight;
  final bool Function()? canBeOpened;
  final DragDownContainerController? controller;

  const DragDownContainer({
    super.key,
    required this.child,
    required this.containerChild,
    this.maxContainerHeight = 300.0,
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
      },
      onPointerMove: (details) {
        if (!_isDragging) return;
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
            controller._containerHeight = 0;
          });
          return;
        }

        setState(() {
          controller._containerHeight =
              (controller._containerHeight + dragOffset.dy)
                  .clamp(0, widget.maxContainerHeight);
        });
      },
      onPointerUp: (_) {
        _isDragging = false;
        // Snap behavior
        if (controller._containerHeight > widget.maxContainerHeight / 2) {
          setState(() {
            controller._containerHeight = widget.maxContainerHeight;
          });
        } else {
          setState(() {
            controller._containerHeight = 0;
          });
        }
      },
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            child: IgnorePointer(
              ignoring: controller.isOpen,
              child: widget.child,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height:
                controller._containerHeight.clamp(0, widget.maxContainerHeight),
            width: double.infinity,
            color: Colors.transparent,
            alignment: Alignment.center,
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
