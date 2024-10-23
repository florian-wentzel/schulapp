import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/note_text_editor_controller.dart';
import 'package:schulapp/screens/notes/interactive_image_note_widget.dart';

class SchoolNoteUI extends SchoolNote with ChangeNotifier {
  //only modify via SchoolNoteUI methods
  final SchoolNote schoolNote;

  SchoolNoteUI({required this.schoolNote});

  void moveNotePartUp(SchoolNotePart part) {
    int index = schoolNote.parts.indexOf(part);

    if (index <= 0) return;
    if (index >= schoolNote.parts.length) return;

    SchoolNotePart partHolder = schoolNote.parts[index];
    schoolNote.parts[index] = schoolNote.parts[index - 1];
    schoolNote.parts[index - 1] = partHolder;
    notifyListeners();
  }

  void moveNotePartDown(SchoolNotePart part) {
    int index = schoolNote.parts.indexOf(part);

    if (index < 0) return;
    if (index >= schoolNote.parts.length - 1) return;

    SchoolNotePart partHolder = schoolNote.parts[index];
    schoolNote.parts[index] = schoolNote.parts[index + 1];
    schoolNote.parts[index + 1] = partHolder;
    notifyListeners();
  }

  void addPart(SchoolNotePart schoolNotePart) {
    schoolNote.parts.add(schoolNotePart);
    notifyListeners();
  }

  void removeNotePart(SchoolNotePartImage partImage) {
    schoolNote.parts.remove(partImage);
    notifyListeners();
  }
}

class SchoolNote {
  static get defaultParts => <SchoolNotePart>[
        SchoolNotePartText(value: ""),
      ];

  final List<SchoolNotePart> parts;

  SchoolNote({
    List<SchoolNotePart>? parts,
  }) : parts = parts ?? defaultParts;
}

abstract class SchoolNotePart {
  final String value;
  bool inEditMode = false;

  SchoolNotePart({required this.value});

  Widget render(SchoolNoteUI schoolNote);
}

class SchoolNotePartImage extends SchoolNotePart {
  SchoolNotePartImage({required super.value});

  @override
  Widget render(SchoolNoteUI schoolNote) {
    return InteractiveImageNoteWidget(
      note: schoolNote,
      partImage: this,
    );
  }
}

class SchoolNotePartText extends SchoolNotePart {
  final _textEditController = NoteTextEditorController();

  SchoolNotePartText({super.value = ""});

  @override
  Widget render(SchoolNoteUI schoolNote) {
    return TextFormField(
      onChanged: (value) {
        print(value);
      },
      autofocus: true,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      controller: _textEditController,
      keyboardType: TextInputType.multiline,
      expands: false,
      minLines: 1,
      maxLines: 999,
    );
  }
}
