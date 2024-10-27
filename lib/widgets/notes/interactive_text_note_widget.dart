import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/note_text_editor_controller.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_note_part.dart';

class InteractiveTextNoteWidget extends StatefulWidget {
  final SchoolNoteUI note;
  final SchoolNotePartText partText;

  const InteractiveTextNoteWidget({
    super.key,
    required this.note,
    required this.partText,
  });

  @override
  State<InteractiveTextNoteWidget> createState() =>
      _InteractiveTextNoteWidgetState();
}

class _InteractiveTextNoteWidgetState extends State<InteractiveTextNoteWidget> {
  final _textEditController = NoteTextEditorController();

  @override
  void initState() {
    _textEditController.text = widget.partText.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.partText.inEditMode) {
      child = _editModeWidget();
    } else {
      child = _normalWidget();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: child,
    );
  }

  Widget _editModeWidget() {
    return Column(
      children: [
        _normalWidget(),
        _editBar(),
      ],
    );
  }

  Widget _normalWidget() {
    return Stack(
      children: [
        TextFormField(
          onChanged: (value) {
            widget.partText.value = value;
          },
          onEditingComplete: () {
            widget.note.callOnChange();
          },
          onTapOutside: (event) {
            widget.note.callOnChange();
          },
          // autofocus: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          controller: _textEditController,
          keyboardType: TextInputType.multiline,
          expands: false,
          minLines: 1,
          maxLines: 999,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Visibility(
            visible: !widget.partText.inEditMode,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
              child: IconButton(
                onPressed: () {
                  widget.partText.inEditMode = !widget.partText.inEditMode;
                  setState(() {});
                },
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _editBar() {
    return Container(
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
              widget.partText.inEditMode = false;
              setState(() {});
            },
            icon: const Icon(Icons.done),
          ),
          IconButton(
            onPressed: () {
              widget.note.moveNotePartUp(widget.partText);
            },
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: () {
              widget.note.moveNotePartDown(widget.partText);
            },
            icon: const Icon(Icons.arrow_downward),
          ),
          const IconButton(
            onPressed: null,
            // onPressed: () async {
            //   await Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (context) => ImagePreviewScreen(
            //         pathToImg: widget.partImage.value,
            //         heroObj: widget.partImage,
            //       ),
            //     ),
            //   );
            // },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              widget.note.removeNotePart(widget.partText);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
