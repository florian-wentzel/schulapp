import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String pathToImg;
  final Object heroObj;

  const ImagePreviewScreen({
    super.key,
    required this.pathToImg,
    required this.heroObj,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final _animDuration = const Duration(milliseconds: 500);
  final _controller = TransformationController();

  bool _showMenu = true;
  bool _resizeMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: _animDuration,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_resizeMode) {
      return Stack(
        key: const ValueKey("resizeMode"),
        children: [
          Hero(
            tag: widget.heroObj,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              child: Image.file(
                File(widget.pathToImg),
                fit: BoxFit.contain,
              ),
            ),
          ),
          _appBar(),
        ],
      );
    }
    return GestureDetector(
      key: const ValueKey("norma"),
      onTap: () {
        setState(() {
          _showMenu = !_showMenu;
        });
      },
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              transformationController: _controller,
              // minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: widget.heroObj,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  child: Image.file(
                    File(widget.pathToImg),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          _appBar(),
        ],
      ),
    );
  }

  Widget _appBar() {
    Widget child = const SizedBox.shrink(
      key: ValueKey("noting"),
    );

    if (_showMenu) {
      child = SizedBox(
        height: kToolbarHeight,
        child: AppBar(
          key: const ValueKey("appbar"),
          title: const Text("Test"),
          actions: [
            IconButton(
              onPressed: _editPressed,
              icon: const Icon(
                Icons.edit,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: _animDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }

  void _editPressed() {
    setState(() {
      _resizeMode = true;
      _showMenu = true;
    });
  }
}
