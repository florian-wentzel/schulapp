//https://stackoverflow.com/a/75293519/15447789

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

///This widget provides correct scrolling and swiping behavior when scrolling view are placed inside pageview with same direction
///The widget works both for vertical and horizontal scrolling direction
///To use this widget you have to do following:
///* set physics: NeverScrollableScrollPhysics(parent: ClampingScrollPhysics()) argument for both PageView and ScrollView
///* create scrollController for ScrollView and pageController for PageView. Do not forget to dispose then at dispose() State callback
///* make sure that scrolling direction on both views are the same and equals to scrollDirection argument here

class PageViewScrollableChild extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final PageController pageController;
  final Axis scrollDirection;

  const PageViewScrollableChild(
      {super.key,
      required this.scrollController,
      required this.pageController,
      required this.child,
      required this.scrollDirection});

  @override
  State<StatefulWidget> createState() {
    return _PageViewScrollableChildState();
  }
}

class _PageViewScrollableChildState extends State<PageViewScrollableChild> {
  late bool atTheStart;
  late bool atTheEnd;

  ///true if scroll view content does not overscroll screen size
  late bool bothSides;

  ScrollController? activeScrollController;
  Drag? drag;

  @override
  void initState() {
    super.initState();

    atTheStart = true;
    atTheEnd = false;
    bothSides = false;
  }

  void handleDragStart(
      DragStartDetails details, ScrollController scrollController) {
    if (scrollController.hasClients) {
      if (scrollController.position.minScrollExtent == 0 &&
          scrollController.position.maxScrollExtent == 0) {
        bothSides = true;
      } else if (scrollController.position.pixels <=
          scrollController.position.minScrollExtent) {
        atTheStart = true;
      } else if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        atTheEnd = true;
      } else {
        atTheStart = false;
        atTheEnd = false;

        activeScrollController = scrollController;
        drag = activeScrollController?.position.drag(details, disposeDrag);
        return;
      }
    }

    activeScrollController = widget.pageController;
    drag = widget.pageController.position.drag(details, disposeDrag);
  }

  void handleDragUpdate(
      DragUpdateDetails details, ScrollController scrollController) {
    final offset = widget.scrollDirection == Axis.vertical
        ? details.delta.dy
        : details.delta.dx;
    if (offset > 0 && (atTheStart || bothSides)) {
      //Arrow direction is to the bottom.
      //Swiping up.

      activeScrollController = widget.pageController;
      drag?.cancel();
      drag = widget.pageController.position.drag(
          DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition),
          disposeDrag);
    } else if (offset < 0 && (atTheEnd || bothSides)) {
      //Arrow direction is to the top.
      //Swiping down.

      activeScrollController = widget.pageController;
      drag?.cancel();
      drag = widget.pageController.position.drag(
          DragStartDetails(
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          ),
          disposeDrag);
    } else if (atTheStart || atTheEnd) {
      activeScrollController = scrollController;
      drag?.cancel();
      drag = scrollController.position.drag(
          DragStartDetails(
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          ),
          disposeDrag);
    }

    drag?.update(details);
  }

  void handleDragEnd(DragEndDetails details) {
    drag?.end(details);

    if (atTheStart) {
      atTheStart = false;
    } else if (atTheEnd) {
      atTheEnd = false;
    }
  }

  void handleDragCancel() {
    drag?.cancel();
  }

  void disposeDrag() {
    drag = null;
  }

  @override
  Widget build(BuildContext context) {
    final scrollDirection = widget.scrollDirection;
    return GestureDetector(
      onVerticalDragStart: scrollDirection == Axis.vertical
          ? (details) => handleDragStart(details, widget.scrollController)
          : null,
      onVerticalDragUpdate: scrollDirection == Axis.vertical
          ? (details) => handleDragUpdate(details, widget.scrollController)
          : null,
      onVerticalDragEnd: scrollDirection == Axis.vertical
          ? (details) => handleDragEnd(details)
          : null,
      onHorizontalDragStart: scrollDirection == Axis.horizontal
          ? (details) => handleDragStart(details, widget.scrollController)
          : null,
      onHorizontalDragUpdate: scrollDirection == Axis.horizontal
          ? (details) => handleDragUpdate(details, widget.scrollController)
          : null,
      onHorizontalDragEnd: scrollDirection == Axis.horizontal
          ? (details) => handleDragEnd(details)
          : null,
      child: widget.child,
    );
  }
}
