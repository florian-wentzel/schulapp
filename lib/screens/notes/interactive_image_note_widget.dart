import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_note.dart';

class InteractiveImageNoteWidget extends StatefulWidget {
  final SchoolNote note;
  final SchoolNotePartImage partImage;

  const InteractiveImageNoteWidget({
    super.key,
    required this.partImage,
    required this.note,
  });

  @override
  State<InteractiveImageNoteWidget> createState() =>
      _InteractiveImageNoteWidgetState();
}

class _InteractiveImageNoteWidgetState
    extends State<InteractiveImageNoteWidget> {
  bool inEditMode = false;

  @override
  Widget build(BuildContext context) {
    if (inEditMode) {
      return _editModeWidget();
    }
    return _normalWidget();
  }

  Widget _normalWidget() {
    return InkWell(
      onLongPress: () {
        print("show pop up with options");
        inEditMode = true;
        setState(() {});
      },
      child: Image.file(
        File(widget.partImage.value),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _editModeWidget() {
    return Column(
      children: [
        InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(widget.partImage.value),
            fit: BoxFit.contain,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(1, 8, 1, 1),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  inEditMode = false;
                  setState(() {});
                },
                icon: const Icon(Icons.done),
              ),
              IconButton(
                onPressed: () {
                  widget.note.moveNotePartUp(widget.partImage);
                },
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                onPressed: () {
                  widget.note.moveNotePartDown(widget.partImage);
                },
                icon: const Icon(Icons.arrow_downward),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
