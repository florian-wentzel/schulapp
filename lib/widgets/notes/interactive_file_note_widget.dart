import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_note_part.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/notes/resizeble_widget.dart';

class InteractiveFileNoteWidget extends StatefulWidget {
  final SchoolNoteUI note;
  final SchoolNotePartFile partFile;

  const InteractiveFileNoteWidget({
    super.key,
    required this.partFile,
    required this.note,
  });

  @override
  State<InteractiveFileNoteWidget> createState() =>
      _InteractiveFileNoteWidgetState();
}

class _InteractiveFileNoteWidgetState extends State<InteractiveFileNoteWidget> {
  final resizebleController = ResizebleWidgetController();

  String? pathToFile;

  @override
  void initState() {
    if (widget.partFile.isLink) {
      pathToFile = widget.partFile.value;
    } else {
      pathToFile = widget.note.schoolNote.getFilePath(widget.partFile.value);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (pathToFile == null) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizationsManager.localizations.strSelectedFileDoesNotExist,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.note.removeNotePart(widget.partFile);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else {
      if (widget.partFile.inEditMode) {
        child = _editModeWidget(context);
      } else {
        child = _normalWidget();
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: child,
    );
  }

  Widget _normalWidget() {
    return InkWell(
      onTap: _openFile,
      onLongPress: () {
        widget.partFile.inEditMode = true;
        setState(() {});
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            basename(pathToFile!),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _openFile,
            icon: const Icon(Icons.description),
          ),
        ],
      ),
    );
  }

  Widget _editModeWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              basename(pathToFile!),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _openFile,
              icon: const Icon(Icons.description),
            ),
          ],
        ),
        _editBar(context),
      ],
    );
  }

  Widget _editBar(BuildContext context) {
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
              widget.partFile.inEditMode = false;
              setState(() {});
            },
            icon: const Icon(Icons.done),
          ),
          IconButton(
            onPressed: () {
              widget.note.moveNotePartUp(widget.partFile);
            },
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: () {
              widget.note.moveNotePartDown(widget.partFile);
            },
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            onPressed: () {
              if (!widget.partFile.isLink) {
                widget.note.schoolNote.removeFile(widget.partFile.value);
              }
              widget.note.removeNotePart(widget.partFile);
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

  Future<void> _openFile() async {
    await OpenFile.open(pathToFile);
  }
}
