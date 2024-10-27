import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/notes/resizeble_widget.dart';
import 'package:image/image.dart' as img;

class ImagePreviewScreen extends StatefulWidget {
  final String pathToImg;
  final Object heroObj;
  final bool editMode;

  const ImagePreviewScreen({
    super.key,
    required this.pathToImg,
    required this.heroObj,
    this.editMode = false,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final _animDuration = const Duration(milliseconds: 500);
  final _controller = ResizebleWidgetController();
  final _imageKey = GlobalKey();

  bool _showMenu = true;
  bool _editMode = false;

  @override
  void initState() {
    _editMode = widget.editMode;

    _addPostFrameCallback();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: _animDuration,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_editMode) {
      return _editBody();
    }
    return _normalBody();
  }

  Widget _normalBody() {
    return GestureDetector(
      key: const ValueKey("normal"),
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
              // minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: widget.heroObj,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: getSafeHeight(context),
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

  Widget _editBody() {
    return Stack(
      key: const ValueKey("resizeMode"),
      children: [
        Center(
          child: SizedBox(
            height: getSafeHeight(context) -
                kBottomNavigationBarHeight -
                kToolbarHeight -
                32 /*padding (because of [_editBar()])*/ -
                8 * 2 /* own padding */,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.heroObj,
                      child: Image.file(
                        File(widget.pathToImg),
                        fit: BoxFit.contain,
                        key: _imageKey,
                      ),
                    ),
                    ResizebleWidget(
                      controller: _controller,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _appBar(),
        _editBar(),
      ],
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
          title:
              Text(AppLocalizationsManager.localizations.strImagePreviewTitle),
          actions: [
            AnimatedSwitcher(
              duration: _animDuration,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _editMode
                  ? IconButton(
                      key: const ValueKey("finishButton"),
                      onPressed: _finishPressed,
                      icon: const Icon(
                        Icons.done,
                      ),
                    )
                  : IconButton(
                      key: const ValueKey("editButton"),
                      onPressed: _editPressed,
                      icon: const Icon(
                        Icons.edit,
                      ),
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

  Widget _editBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        height: kBottomNavigationBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _finishPressed,
              icon: const Icon(Icons.done),
            ),
            IconButton(
              onPressed: () {
                _rotateImg(-90);
              },
              icon: const Icon(Icons.rotate_left),
            ),
            IconButton(
              onPressed: () {
                _rotateImg(90);
              },
              icon: const Icon(Icons.rotate_right),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _editMode = false;
                });
              },
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rotateImg(num angle) async {
    final imageFile = File(widget.pathToImg);

    try {
      if (!imageFile.existsSync()) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
        return;
      }

      final imageBytes = imageFile.readAsBytesSync();

      final image = img.decodeImage(imageBytes);

      if (image == null) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
        return;
      }

      final croppedImage = img.copyRotate(
        image,
        angle: angle,
      );

      final croppedImageBytes = img.encodePng(croppedImage);

      imageFile.writeAsBytesSync(croppedImageBytes);

      //delete cache
      await FileImage(imageFile).evict();
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
      }
      return;
    }

    setState(() {
      _editMode = false;
      _showMenu = true;
    });
  }

  Future<void> _finishPressed() async {
    final imageFile = File(widget.pathToImg);
    try {
      if (!imageFile.existsSync()) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
        return;
      }

      final imageBytes = imageFile.readAsBytesSync();

      final image = img.decodeImage(imageBytes);

      if (image == null) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
        return;
      }

      final x = map(
        _controller.left,
        0,
        _controller.maxWidth,
        0,
        image.width.toDouble(),
      );
      final y = map(
        _controller.top,
        0,
        _controller.maxHeight,
        0,
        image.height.toDouble(),
      );
      final w = map(
        _controller.width,
        0,
        _controller.maxWidth,
        0,
        image.width.toDouble(),
      );
      final h = map(
        _controller.height,
        0,
        _controller.maxHeight,
        0,
        image.height.toDouble(),
      );

      final croppedImage = img.copyCrop(
        image,
        x: x.toInt(),
        y: y.toInt(),
        width: w.toInt(),
        height: h.toInt(),
      );

      final croppedImageBytes = img.encodePng(croppedImage);

      imageFile.writeAsBytesSync(croppedImageBytes);

      //delete cache
      await FileImage(imageFile).evict();
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
      }
      return;
    }

    setState(() {
      _editMode = false;
      _showMenu = true;
    });
  }

  double map(
      double value, double start1, double stop1, double start2, double stop2) {
    return start2 + (value - start1) * (stop2 - start2) / (stop1 - start1);
  }

  void _editPressed() {
    _editMode = true;
    _showMenu = true;
    setState(() {});

    _addPostFrameCallback();
  }

  void _addPostFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //is animation is running width and height would be trash, thats why wait
      await Future.delayed(
        const Duration(milliseconds: 150),
      );

      if (!_editMode) {
        _controller.width = 0;
        _controller.height = 0;
        return;
      }

      final childRenderBox =
          _imageKey.currentContext!.findRenderObject() as RenderBox;

      _controller.top = 0;
      _controller.left = 0;
      _controller.maxWidth = childRenderBox.size.width;
      _controller.maxHeight = childRenderBox.size.height;
      _controller.minWidth = childRenderBox.size.width / 10;
      _controller.minHeight = childRenderBox.size.height / 10;

      _controller.width = childRenderBox.size.width;
      _controller.height = childRenderBox.size.height;
    });
  }

  double getSafeHeight(BuildContext context) =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;
}
