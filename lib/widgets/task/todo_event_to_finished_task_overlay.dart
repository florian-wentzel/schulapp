import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/widgets/task/todo_event_list_item_widget.dart';

class TodoEventToFinishedTaskOverlay extends StatefulWidget {
  final TodoEvent todoEvent;
  final Offset itemStartCenter;
  final Offset itemEndCenter;
  final Size itemSize;
  final VoidCallback onComplete;

  const TodoEventToFinishedTaskOverlay({
    super.key,
    required this.todoEvent,
    required this.itemSize,
    required this.itemStartCenter,
    required this.itemEndCenter,
    required this.onComplete,
  });

  @override
  State<TodoEventToFinishedTaskOverlay> createState() =>
      _TodoEventToFinishedTaskOverlayState();
}

class _TodoEventToFinishedTaskOverlayState
    extends State<TodoEventToFinishedTaskOverlay>
    with SingleTickerProviderStateMixin {
  final _animDuration = const Duration(milliseconds: 600);

  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _animDuration,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.itemStartCenter,
      end: widget.itemEndCenter,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().then((value) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - widget.itemSize.width / 2,
          top: _positionAnimation.value.dy - widget.itemSize.height / 2,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.itemSize.width,
              height: widget.itemSize.height,
              child: Material(
                elevation: 4.0,
                child: TodoEventListItemWidget(
                  event: widget.todoEvent,
                  onDeleteSwipe: () {},
                  onInfoPressed: () {},
                  onLongPressed: () {},
                  onPressed: () {},
                  isSelected: false,
                  removeHero: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
