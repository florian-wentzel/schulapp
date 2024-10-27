import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/widgets/notes/interactive_file_note_widget.dart';
import 'package:schulapp/widgets/notes/interactive_image_note_widget.dart';
import 'package:schulapp/widgets/notes/interactive_text_note_widget.dart';

abstract class SchoolNotePart {
  static const String typeKey = "type";
  static const String valueKey = "value";

  String value;
  bool inEditMode = false;

  SchoolNotePart({required this.value});

  Widget render(SchoolNoteUI schoolNote);

  Map<String, dynamic> toJson();

  static SchoolNotePart? fromJson(Map<String, dynamic> json) {
    String type = json[typeKey];

    if (type == SchoolNotePartText.type) {
      return SchoolNotePartText.fromJson(json);
    }
    if (type == SchoolNotePartImage.type) {
      return SchoolNotePartImage.fromJson(json);
    }
    if (type == SchoolNotePartFile.type) {
      return SchoolNotePartFile.fromJson(json);
    }

    return null;
  }
}

class SchoolNotePartImage extends SchoolNotePart {
  static const String type = "SchoolNotePartImage";

  SchoolNotePartImage({required super.value});

  @override
  Widget render(SchoolNoteUI schoolNote) {
    return InteractiveImageNoteWidget(
      note: schoolNote,
      partImage: this,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      SchoolNotePart.typeKey: type,
      SchoolNotePart.valueKey: value,
    };
  }

  static SchoolNotePart? fromJson(Map<String, dynamic> json) {
    String? value = json[SchoolNotePart.valueKey];

    if (value == null) return null;

    return SchoolNotePartImage(value: value);
  }
}

class SchoolNotePartFile extends SchoolNotePart {
  static const String type = "SchoolNotePartFile";

  SchoolNotePartFile({required super.value});

  @override
  Widget render(SchoolNoteUI schoolNote) {
    return InteractiveFileNoteWidget(
      note: schoolNote,
      partFile: this,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      SchoolNotePart.typeKey: type,
      SchoolNotePart.valueKey: value,
    };
  }

  static SchoolNotePart? fromJson(Map<String, dynamic> json) {
    String? value = json[SchoolNotePart.valueKey];

    if (value == null) return null;

    return SchoolNotePartFile(value: value);
  }
}

class SchoolNotePartText extends SchoolNotePart {
  static const String type = "SchoolNotePartText";

  SchoolNotePartText({super.value = ""});

  @override
  Widget render(SchoolNoteUI schoolNote) {
    return InteractiveTextNoteWidget(
      note: schoolNote,
      partText: this,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      SchoolNotePart.typeKey: type,
      SchoolNotePart.valueKey: value,
    };
  }

  static SchoolNotePart? fromJson(Map<String, dynamic> json) {
    String? value = json[SchoolNotePart.valueKey];

    if (value == null) return null;

    return SchoolNotePartText(value: value);
  }
}
