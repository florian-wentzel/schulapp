import 'package:flutter/material.dart';

class ResizebleWidgetController extends ChangeNotifier {
  double? _width;
  double? _height;

  double? get width => _width;
  double? get height => _height;

  set width(double? value) {
    _width = value;
    notifyListeners();
  }

  set height(double? value) {
    _height = value;
    notifyListeners();
  }

  ResizebleWidgetController({
    double? width,
    double? height,
  })  : _height = height,
        _width = width;
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

  ResizebleWidgetController? controller;

  double top = 0;
  double left = 0;

  @override
  void initState() {
    controller = widget.controller;
    controller ??= ResizebleWidgetController();

    controller!.addListener(onValueChanged);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final childRenderBox =
          _childKey.currentContext!.findRenderObject() as RenderBox;
      controller!.width = childRenderBox.size.width;

      controller!.height = childRenderBox.size.height;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller!.removeListener(onValueChanged);
  }

  @override
  Widget build(BuildContext context) {
    // width = MediaQuery.sizeOf(context).width;
    // height = MediaQuery.sizeOf(context).height;
    return Container(
      color: Colors.amber,
      width: controller!.width,
      height: controller!.height,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              key: _childKey,
              child: widget.child,
            ),
          ),
          if (controller!.width != null && controller!.height != null)
            Align(
              alignment: Alignment.centerLeft,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = controller!.height! - dy;

                  setState(() {
                    controller!.height = newHeight > 0 ? newHeight : 0;
                    top = top + dy;
                  });
                },
              ),
            ),
          // top left
          // Positioned(
          //   top: top - ResizebleWidget.ballDiameter / 2,
          //   left: left - ResizebleWidget.ballDiameter / 2,
          //   child: ManipulatingBall(
          //     onDrag: (dx, dy) {
          //       var mid = (dx + dy) / 2;
          //       var newHeight = height - 2 * mid;
          //       var newWidth = width - 2 * mid;

          //       setState(() {
          //         height = newHeight > 0 ? newHeight : 0;
          //         width = newWidth > 0 ? newWidth : 0;
          //         top = top + mid;
          //         left = left + mid;
          //       });
          //     },
          //   ),
          // ),
          // top middle
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top - ResizebleWidget.ballDiameter / 2,
          //     left: left +
          //         controller!.width! / 2 -
          //         ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var newHeight = controller!.height! - dy;

          //         setState(() {
          //           controller!.height = newHeight > 0 ? newHeight : 0;
          //           top = top + dy;
          //         });
          //       },
          //     ),
          //   ),
          // // top right
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top - ResizebleWidget.ballDiameter / 2,
          //     left: left + controller!.width! - ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var mid = (dx + (dy * -1)) / 2;

          //         var newHeight = controller!.height! + 2 * mid;
          //         var newWidth = controller!.width! + 2 * mid;

          //         setState(() {
          //           controller!.height = newHeight > 0 ? newHeight : 0;
          //           controller!.width = newWidth > 0 ? newWidth : 0;
          //           top = top - mid;
          //           left = left - mid;
          //         });
          //       },
          //     ),
          //   ),
          // // center right
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top +
          //         controller!.height! / 2 -
          //         ResizebleWidget.ballDiameter / 2,
          //     left: left + controller!.width! - ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var newWidth = controller!.width! + dx;

          //         setState(() {
          //           controller!.width = newWidth > 0 ? newWidth : 0;
          //         });
          //       },
          //     ),
          //   ),
          // // bottom right
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top + controller!.height! - ResizebleWidget.ballDiameter / 2,
          //     left: left + controller!.width! - ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var mid = (dx + dy) / 2;

          //         var newHeight = controller!.height! + 2 * mid;
          //         var newWidth = controller!.width! + 2 * mid;

          //         setState(() {
          //           controller!.height = newHeight > 0 ? newHeight : 0;
          //           controller!.width = newWidth > 0 ? newWidth : 0;
          //           top = top - mid;
          //           left = left - mid;
          //         });
          //       },
          //     ),
          //   ),
          // // bottom center
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top + controller!.height! - ResizebleWidget.ballDiameter / 2,
          //     left: left +
          //         controller!.width! / 2 -
          //         ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var newHeight = controller!.height! + dy;

          //         setState(() {
          //           controller!.height = newHeight > 0 ? newHeight : 0;
          //         });
          //       },
          //     ),
          //   ),
          // // bottom left
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top + controller!.height! - ResizebleWidget.ballDiameter / 2,
          //     left: left - ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var mid = ((dx * -1) + dy) / 2;

          //         var newHeight = controller!.height! + 2 * mid;
          //         var newWidth = controller!.width! + 2 * mid;

          //         setState(() {
          //           controller!.height = newHeight > 0 ? newHeight : 0;
          //           controller!.width = newWidth > 0 ? newWidth : 0;
          //           top = top - mid;
          //           left = left - mid;
          //         });
          //       },
          //     ),
          //   ),
          // //left center
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top +
          //         controller!.height! / 2 -
          //         ResizebleWidget.ballDiameter / 2,
          //     left: left - ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         var newWidth = controller!.width! - dx;

          //         setState(() {
          //           controller!.width = newWidth > 0 ? newWidth : 0;
          //           left = left + dx;
          //         });
          //       },
          //     ),
          //   ),

          // center center
          // if (controller!.width != null && controller!.height != null)
          //   Positioned(
          //     top: top +
          //         controller!.height! / 2 -
          //         ResizebleWidget.ballDiameter / 2,
          //     left: left +
          //         controller!.width! / 2 -
          //         ResizebleWidget.ballDiameter / 2,
          //     child: ManipulatingBall(
          //       onDrag: (dx, dy) {
          //         setState(() {
          //           top = top + dy;
          //           left = left + dx;
          //         });
          //       },
          //     ),
          //   ),
        ],
      ),
    );
  }

  void onDrag(double dx, double dy) {
    if (controller!.height == null || controller!.width == null) return;

    var newHeight = controller!.height! + dy;
    var newWidth = controller!.width! + dx;

    setState(() {
      controller!.height = newHeight > 0 ? newHeight : 0;
      controller!.width = newWidth > 0 ? newWidth : 0;
    });
  }

  void onValueChanged() {
    if (!mounted) return;
    setState(() {});
  }
}

class ManipulatingBall extends StatefulWidget {
  final void Function(double dx, double dy) onDrag;

  const ManipulatingBall({
    super.key,
    required this.onDrag,
  });

  @override
  State<ManipulatingBall> createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ResizebleWidget.ballDiameter,
        height: ResizebleWidget.ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
