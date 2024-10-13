import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/note_text_editor_controller.dart';
import 'package:schulapp/screens/notes/interactive_image_note_widget.dart';

//TODO create SchoolNoteUI class wich holds SchoolNote as memberVar
//EditNoteScreen converts List<SchoolNote> to List<SchoolNoteUI> so we have ChangeNotifier
class SchoolNote with ChangeNotifier {
  static get defaultParts => <SchoolNotePart>[
        SchoolNotePartText(value: ""),
      ];

  List<SchoolNotePart> get parts => UnmodifiableListView(_parts);
  final List<SchoolNotePart> _parts;

  SchoolNote({
    List<SchoolNotePart>? parts,
  }) : _parts = parts ?? defaultParts;

  void moveNotePartUp(SchoolNotePart part) {
    int index = _parts.indexOf(part);

    if (index <= 0) return;
    if (index >= _parts.length) return;

    SchoolNotePart partHolder = _parts[index];
    _parts[index] = _parts[index - 1];
    _parts[index - 1] = partHolder;
    notifyListeners();
  }

  void moveNotePartDown(SchoolNotePart part) {
    int index = _parts.indexOf(part);

    if (index < 0) return;
    if (index > _parts.length) return;

    SchoolNotePart partHolder = _parts[index];
    _parts[index] = _parts[index + 1];
    _parts[index + 1] = partHolder;
    notifyListeners();
  }

  void addPart(SchoolNotePart schoolNotePart) {
    _parts.add(schoolNotePart);
    notifyListeners();
  }
}

abstract class SchoolNotePart {
  final String value;

  SchoolNotePart({required this.value});

  Widget render(SchoolNote schoolNote);
}

class SchoolNotePartImage extends SchoolNotePart {
  SchoolNotePartImage({required super.value});

  @override
  Widget render(SchoolNote schoolNote) {
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
  Widget render(SchoolNote schoolNote) {
    return TextFormField(
      onChanged: (value) {
        print(value);
      },
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
