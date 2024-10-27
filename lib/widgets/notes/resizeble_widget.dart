import 'package:flutter/material.dart';

class ResizebleWidgetController extends ChangeNotifier {
  double _minWidth, _minHeight;
  double _maxWidth, _maxHeight;

  double _top = 0;
  double _left = 0;
  double _width = 0;
  double _height = 0;

  double get maxWidth => _maxWidth;
  set maxWidth(double value) {
    _maxWidth = value.abs();

    if (_width > _maxWidth) {
      _width = _maxWidth;
    }

    notifyListeners();
  }

  double get maxHeight => _maxHeight;
  set maxHeight(double value) {
    _maxHeight = value.abs();

    if (_height > _maxHeight) {
      _height = _maxHeight;
    }

    notifyListeners();
  }

  double get minWidth => _minWidth;
  set minWidth(double value) {
    _minWidth = value.abs();

    if (_width < _minWidth) {
      _width = _minWidth;
    }

    notifyListeners();
  }

  double get minHeight => _minHeight;
  set minHeight(double value) {
    _minHeight = value.abs();

    if (_height < _minHeight) {
      _height = _minHeight;
    }

    notifyListeners();
  }

  double get width => _width;
  double get height => _height;

  double get top => _top;
  double get left => _left;

  ResizebleWidgetController({
    double width = 0,
    double height = 0,
    double top = 0,
    double left = 0,
    double maxHeight = 0,
    double maxWidth = 0,
    double minHeight = 0,
    double minWidth = 0,
  })  : _height = height,
        _width = width,
        _top = top,
        _left = left,
        _maxHeight = maxHeight,
        _maxWidth = maxWidth,
        _minHeight = minHeight,
        _minWidth = minWidth;

  set width(double value) {
    if (value > _maxWidth) {
      value = _maxWidth - left;
    }

    if (value < _minWidth) {
      value = _minWidth;
    }

    _width = value;
    notifyListeners();
  }

  set height(double value) {
    if (value > _maxHeight) {
      value = _maxHeight;
    }

    if (value < _minHeight) {
      value = _minHeight;
    }

    _height = value;
    notifyListeners();
  }

  set left(double value) {
    if (value + _width > _maxWidth) {
      value = _maxWidth - _width;
    }

    if (value < 0) {
      value = 0;
    }

    _left = value;
    notifyListeners();
  }

  set top(double value) {
    if (value + _height > _maxHeight) {
      value = _maxHeight - _height;
    }

    if (value < 0) {
      value = 0;
    }

    _top = value;
    notifyListeners();
  }
}

class ResizebleWidget extends StatefulWidget {
  static const ballDiameter = 30.0;
  final ResizebleWidgetController? controller;
  final Widget child;

  const ResizebleWidget({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<ResizebleWidget> createState() => _ResizebleWidgetState();
}

class _ResizebleWidgetState extends State<ResizebleWidget> {
  final _childKey = GlobalKey();

  late ResizebleWidgetController controller;

  @override
  void initState() {
    final widgetController = widget.controller;

    if (widgetController != null) {
      controller = widgetController;
    } else {
      controller = ResizebleWidgetController();
    }

    controller.addListener(onValueChanged);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(onValueChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: controller.maxWidth,
      height: controller.maxHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: controller.top,
            left: controller.left,
            child: Container(
              key: _childKey,
              color: Theme.of(context).cardColor.withAlpha(127),
              width: controller.width,
              height: controller.height,
              child: widget.child,
            ),
          ),
          // top center
          Positioned(
            top: controller.top,
            left: controller.left +
                controller.width / 2 -
                ResizebleWidget.ballDiameter / 2,
            child: ManipulatingBall(
              horizontal: true,
              onDrag: (dx, dy) {
                var newHeight = (controller.height - dy);

                setState(() {
                  var correctDY = controller.height;
                  controller.height = newHeight;
                  correctDY -= controller.height;

                  controller.top += correctDY;
                });
              },
            ),
          ),
          //bottom, center
          Positioned(
            top: controller.top +
                controller.height -
                ResizebleWidget.ballDiameter / 2,
            left: controller.left +
                controller.width / 2 -
                ResizebleWidget.ballDiameter / 2,
            child: ManipulatingBall(
              horizontal: true,
              onDrag: (dx, dy) {
                var newHeight = controller.height + dy;

                setState(() {
                  controller.height = newHeight;
                  //damit top nochmal überprüft wird
                  controller.top = controller.top;
                });
              },
            ),
          ),
          //center,right
          Positioned(
            top: controller.top +
                controller.height / 2 -
                ResizebleWidget.ballDiameter / 2,
            left: controller.left +
                controller.width -
                ResizebleWidget.ballDiameter / 2,
            child: ManipulatingBall(
              horizontal: false,
              onDrag: (dx, dy) {
                var newWidth = controller.width + dx;

                setState(() {
                  controller.width = newWidth;
                  //damit left nochmal überprüft wird
                  controller.left = controller.left;
                });
              },
            ),
          ),
          //center left
          Positioned(
            top: controller.top +
                controller.height / 2 -
                ResizebleWidget.ballDiameter / 2,
            left: controller.left,
            child: ManipulatingBall(
              horizontal: false,
              onDrag: (dx, dy) {
                var newWidth = controller.width - dx;

                setState(() {
                  var correctDX = controller.width;
                  controller.width = newWidth;
                  correctDX -= controller.width;

                  controller.left += correctDX;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void onDrag(double dx, double dy) {
    var newHeight = controller.height + dy;
    var newWidth = controller.width + dx;

    setState(() {
      controller.height = newHeight;
      controller.width = newWidth;
    });
  }

  void onValueChanged() {
    if (!mounted) return;
    setState(() {});
  }
}

class ManipulatingBall extends StatefulWidget {
  final void Function(double dx, double dy) onDrag;
  final bool horizontal;

  const ManipulatingBall({
    super.key,
    required this.onDrag,
    required this.horizontal,
  });

  @override
  State<ManipulatingBall> createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  late double _width, _height;

  double initX = 0;
  double initY = 0;

  void _handleDrag(DragStartDetails details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  void _handleUpdate(DragUpdateDetails details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  void initState() {
    _width = ResizebleWidget.ballDiameter;
    _height = ResizebleWidget.ballDiameter;
    if (widget.horizontal) {
      _height /= 2;
    } else {
      _width /= 2;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).hintColor.withOpacity(1),
        ),
      ),
    );
  }
}
