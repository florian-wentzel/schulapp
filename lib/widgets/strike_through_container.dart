import 'package:flutter/material.dart';

class StrikeThroughContainerController {
  bool _strikeThrough = false;

  bool get strikeThrough => _strikeThrough;

  set strikeThrough(bool strikeThrough) {
    _strikeThrough = strikeThrough;
    onStrikeThroughChanged?.call(_strikeThrough);
  }

  void Function(bool strikeThrough)? onStrikeThroughChanged;

  void changeStrikeThrough() {
    _strikeThrough = !_strikeThrough;
    onStrikeThroughChanged?.call(_strikeThrough);
  }
}

class StrikeThroughContainer extends StatefulWidget {
  final StrikeThroughContainerController controller;
  final Widget child;
  final Size? logicalSize;

  const StrikeThroughContainer({
    super.key,
    required this.child,
    required this.controller,
    this.logicalSize,
  });

  @override
  State<StrikeThroughContainer> createState() => _StrikeThroughContainerState();
}

class _StrikeThroughContainerState extends State<StrikeThroughContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    widget.controller.onStrikeThroughChanged = _strikeThroughChangedCB;

    if (widget.controller.strikeThrough) {
      _controller.forward(from: 1.0);
    }
  }

  void _strikeThroughChangedCB(bool strikeThrough) {
    if (strikeThrough) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = -1;
    double height = -1;

    if (widget.logicalSize == null) {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    } else {
      width = widget.logicalSize!.width;
      height = widget.logicalSize!.height;
    }
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(width, height),
              foregroundPainter: StrikeThroughPainter(
                _animation.value,
                context,
              ),
              child: widget.child,
            );
          },
        ),
      ],
    );
  }
}

class StrikeThroughPainter extends CustomPainter {
  final BuildContext context;
  final double progress;

  StrikeThroughPainter(this.progress, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Theme.of(context).disabledColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const startX = 0.0;
    final endX = size.width * progress;

    final startY = size.height;
    final endY = size.height - size.height * progress;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
