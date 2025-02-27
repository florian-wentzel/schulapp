import 'dart:async';
import 'package:flutter/material.dart';

class ClickMeWidget extends StatefulWidget {
  static const Duration waitTillShowDuration = Duration(minutes: 5);
  static const enabled = true;
  final Widget child;

  const ClickMeWidget({super.key, required this.child});

  @override
  State<ClickMeWidget> createState() => _ClickMeWidgetState();
}

class _ClickMeWidgetState extends State<ClickMeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  DateTime lastClick = DateTime.now();
  bool isFadingOut = false;
  Timer? _timer;

  bool get active =>
      DateTime.now()
          .difference(lastClick)
          .compareTo(ClickMeWidget.waitTillShowDuration) >
      0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!active) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!active) {
          return GestureDetector(
            onTap: _onPressed,
            child: widget.child,
          );
        }

        return Stack(
          children: [
            widget.child,
            AnimatedOpacity(
              opacity: isFadingOut ? _fadeAnimation.value : 1,
              duration: const Duration(milliseconds: 500),
              child: AnimatedScale(
                scale: isFadingOut ? 0.0 : _scaleAnimation.value,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  color: Colors.black.withAlpha(127),
                  child: Center(
                    child: InkWell(
                      onTap: _onPressed,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Drück mich!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onPressed() {
    setState(() {
      isFadingOut = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        lastClick = DateTime.now();
        isFadingOut = false;
      });
    });
  }
}
