import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/tutorial/tutorial.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class TutorialOverlay extends StatefulWidget {
  final Tutorial tutorial;
  final OverlayEntry? overlayEntry;
  final VoidCallback? onOverlayRemoved;

  const TutorialOverlay({
    super.key,
    required this.overlayEntry,
    required this.tutorial,
    this.onOverlayRemoved,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();

  static void show(
    BuildContext context,
    Tutorial tutorial, {
    VoidCallback? onOverlayRemoved,
  }) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        overlayEntry: overlayEntry,
        tutorial: tutorial,
        onOverlayRemoved: onOverlayRemoved,
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  final paddingForHighlitedWidget = 16.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  double? _prevDescriptionTopPosition;
  double? _descriptionTopPosition;

  Offset _prevPosition = Offset.zero;
  Size _prevSize = Size.zero;
  double _prevCornerRadius = 0;
  double _cornerRadius = 0;

  bool get _waitForAnimFinish => _controller.isAnimating;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final size = MediaQuery.sizeOf(context);
      _prevPosition = Offset.zero;
      _prevSize = Size(size.width, size.height);
      _prevDescriptionTopPosition = size.height;
      _descriptionTopPosition = size.height;
      widget.tutorial.init();
      setState(() {});
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    RenderBox? renderBox;
    RenderBox? prevRenderBox;
    try {
      renderBox = widget.tutorial.currentStep?.highlightKey.currentContext!
          .findRenderObject() as RenderBox?;
      prevRenderBox = widget.tutorial.previousStep?.highlightKey.currentContext!
          .findRenderObject() as RenderBox?;
    } catch (e) {
      widget.overlayEntry?.remove();
      return const SizedBox.shrink();
    }

    Offset? position = renderBox?.localToGlobal(Offset.zero);
    Size? size = renderBox?.size;

    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    if (prevRenderBox != null) {
      _prevPosition = prevRenderBox.localToGlobal(Offset.zero);
      _prevSize = prevRenderBox.size;
    }

    position ??= Offset.zero;
    size ??= Size(width, height);

    _prevDescriptionTopPosition = _descriptionTopPosition;
    _descriptionTopPosition =
        position.dy > height / 2 ? height * 0.1 : height * 0.6;

    _prevCornerRadius = _cornerRadius;
    if (widget.tutorial.isOver) {
      _descriptionTopPosition =
          (_prevDescriptionTopPosition ?? height) > height ? 0 : height;
      _cornerRadius = 0;
    } else {
      _cornerRadius = 16;
    }

    final tutorialWidget = widget.tutorial.currentStep?.tutorialWidget ??
        widget.tutorial.previousStep?.tutorialWidget ??
        const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (_waitForAnimFinish) {
              return;
            }
            if (widget.tutorial.lastStep) {
              widget.tutorial.goToEnd();
              _controller.reset();
              _controller.forward().then((value) {
                widget.overlayEntry?.remove();
                widget.onOverlayRemoved?.call();
              });
            } else {
              widget.tutorial.goToNextStep();
              _controller.reset();
              _controller.forward();
            }
            setState(() {});
          },
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.8),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    double top = lerpDouble(
                          _prevPosition.dy,
                          position!.dy,
                          _animation.value,
                        )! -
                        paddingForHighlitedWidget / 2;
                    double left = lerpDouble(
                          _prevPosition.dx,
                          position.dx,
                          _animation.value,
                        )! -
                        paddingForHighlitedWidget / 2;
                    double containerHeight = lerpDouble(
                          _prevSize.height,
                          size!.height,
                          _animation.value,
                        )! +
                        paddingForHighlitedWidget;
                    double containerWidth = lerpDouble(
                          _prevSize.width,
                          size.width,
                          _animation.value,
                        )! +
                        paddingForHighlitedWidget;

                    return Positioned(
                      top: top,
                      left: left,
                      child: Container(
                        height: containerHeight,
                        width: containerWidth,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                            lerpDouble(
                                  _prevCornerRadius,
                                  _cornerRadius,
                                  _animation.value,
                                ) ??
                                _cornerRadius,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final top = lerpDouble(
                  _prevDescriptionTopPosition ?? height,
                  _descriptionTopPosition,
                  _animation.value,
                ) ??
                height - height * 0.1;

            return Positioned(
              left: width / 2 - width * 0.4,
              top: top,
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: EdgeInsets.only(
                  top: height * 0.1,
                  bottom: height * 0.1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Colors.black, width: 1), // Rahmen
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                width: width * 0.8,
                child: Column(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    tutorialWidget,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (!(widget.tutorial.firstStep &&
                            widget.tutorial.lastStep))
                          ElevatedButton(
                            onPressed: () {
                              if (_waitForAnimFinish) {
                                return;
                              }
                              if (widget.tutorial.firstStep) {
                                widget.tutorial.goToEnd();
                                _controller.reset();
                                _controller.forward().then((value) {
                                  widget.overlayEntry?.remove();
                                  widget.onOverlayRemoved?.call();
                                });
                              } else {
                                widget.tutorial.goToPreviousStep();
                                _controller.reset();
                                _controller.forward();
                              }
                              setState(() {});
                            },
                            child: Text(
                              widget.tutorial.firstStep
                                  ? AppLocalizationsManager
                                      .localizations.strSkip
                                  : AppLocalizationsManager
                                      .localizations.strBack,
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            if (_waitForAnimFinish) {
                              return;
                            }
                            if (widget.tutorial.lastStep) {
                              widget.tutorial.goToEnd();
                              _controller.reset();
                              _controller.forward().then((value) {
                                widget.overlayEntry?.remove();
                                widget.onOverlayRemoved?.call();
                              });
                            } else {
                              widget.tutorial.goToNextStep();
                              _controller.reset();
                              _controller.forward();
                            }
                            setState(() {});
                          },
                          child: Text(
                            widget.tutorial.lastStep
                                ? AppLocalizationsManager
                                    .localizations.strFinished
                                : AppLocalizationsManager.localizations.strNext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
