import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/note_text_editor_controller.dart';
import 'package:schulapp/screens/notes/interactive_image_note_widget.dart';

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

  SchoolNotePart({required this.value});

  Widget render();
}

class SchoolNotePartImage extends SchoolNotePart {
  SchoolNotePartImage({required super.value});

  @override
  Widget render() {
    return InteractiveImageNoteWidget(
      partImage: this,
    );
  }
}

class SchoolNotePartText extends SchoolNotePart {
  final _textEditController = NoteTextEditorController();

  SchoolNotePartText({super.value = ""});

  @override
  Widget render() {
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
