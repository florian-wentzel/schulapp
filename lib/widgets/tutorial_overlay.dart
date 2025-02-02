import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/tutorial/tutorial.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class TutorialOverlay extends StatefulWidget {
  final Tutorial tutorial;
  final OverlayEntry? overlayEntry;

  const TutorialOverlay({
    super.key,
    required this.overlayEntry,
    required this.tutorial,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();

  static void show(BuildContext context, Tutorial tutorial) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        overlayEntry: overlayEntry,
        tutorial: tutorial,
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

  Offset prevPosition = Offset.zero;
  Size prevSize = Size.zero;

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
      prevPosition = Offset.zero;
      prevSize = Size(size.width, size.height);
      _prevDescriptionTopPosition = size.height;
      _descriptionTopPosition = size.height;
      setState(() {});
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    RenderBox? renderBox = widget
        .tutorial.currentStep?.highlightKey.currentContext!
        .findRenderObject() as RenderBox?;

    RenderBox? prevRenderBox = widget
        .tutorial.previousStep?.highlightKey.currentContext!
        .findRenderObject() as RenderBox?;

    Offset? position = renderBox?.localToGlobal(Offset.zero);
    Size? size = renderBox?.size;

    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    if (prevRenderBox != null) {
      prevPosition = prevRenderBox.localToGlobal(Offset.zero);
      prevSize = prevRenderBox.size;
    }

    position ??= Offset.zero;
    size ??= Size(width, height);

    _prevDescriptionTopPosition = _descriptionTopPosition;
    _descriptionTopPosition =
        position.dy > height / 2 ? height * 0.1 : height * 0.6;

    if (widget.tutorial.isOver) {
      _descriptionTopPosition =
          (_prevDescriptionTopPosition ?? height) > height ? 0 : height;
    }

    final tutorialWidget = widget.tutorial.currentStep?.tutorialWidget ??
        widget.tutorial.previousStep?.tutorialWidget ??
        const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.tutorial.lastStep) {
              widget.tutorial.goToEnd();
              _controller.reset();
              _controller.forward().then((value) {
                widget.overlayEntry?.remove();
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
                          prevPosition.dy,
                          position!.dy,
                          _animation.value,
                        )! -
                        paddingForHighlitedWidget / 2;
                    double left = lerpDouble(
                          prevPosition.dx,
                          position.dx,
                          _animation.value,
                        )! -
                        paddingForHighlitedWidget / 2;
                    double containerHeight = lerpDouble(
                          prevSize.height,
                          size!.height,
                          _animation.value,
                        )! +
                        paddingForHighlitedWidget;
                    double containerWidth = lerpDouble(
                          prevSize.width,
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
                          borderRadius:
                              BorderRadius.circular(_animation.value * 100),
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
              child: Positioned(
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
                                if (widget.tutorial.firstStep) {
                                  widget.tutorial.goToEnd();
                                  _controller.reset();
                                  _controller.forward().then((value) {
                                    widget.overlayEntry?.remove();
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
                              if (widget.tutorial.lastStep) {
                                widget.tutorial.goToEnd();
                                _controller.reset();
                                _controller.forward().then((value) {
                                  widget.overlayEntry?.remove();
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
                                  : AppLocalizationsManager
                                      .localizations.strNext,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
