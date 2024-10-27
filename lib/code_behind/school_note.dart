import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_note_part.dart';

class SchoolNoteUI with ChangeNotifier {
  ///only modify via SchoolNoteUI methods
  final SchoolNote schoolNote;

  SchoolNoteUI({required this.schoolNote});

  String? addFile(File file) {
    return schoolNote.addFile(file);
  }

  void moveNotePartUp(SchoolNotePart part) {
    int index = schoolNote.parts.indexOf(part);

    if (index <= 0) return;
    if (index >= schoolNote.parts.length) return;

    SchoolNotePart partHolder = schoolNote.parts[index];
    schoolNote.parts[index] = schoolNote.parts[index - 1];
    schoolNote.parts[index - 1] = partHolder;
    schoolNote.setLastModifiedDate();
    notifyListeners();
  }

  void moveNotePartDown(SchoolNotePart part) {
    int index = schoolNote.parts.indexOf(part);

    if (index < 0) return;
    if (index >= schoolNote.parts.length - 1) return;

    SchoolNotePart partHolder = schoolNote.parts[index];
    schoolNote.parts[index] = schoolNote.parts[index + 1];
    schoolNote.parts[index + 1] = partHolder;
    schoolNote.setLastModifiedDate();
    notifyListeners();
  }

  void addPart(SchoolNotePart schoolNotePart) {
    schoolNote.parts.add(schoolNotePart);
    schoolNote.setLastModifiedDate();
    notifyListeners();
  }

  void removeNotePart(SchoolNotePart partImage) {
    schoolNote.parts.remove(partImage);
    schoolNote.setLastModifiedDate();
    notifyListeners();
  }

  void callOnChange() {
    schoolNote.setLastModifiedDate();
    notifyListeners();
  }
}

class SchoolNote {
  static get defaultParts => <SchoolNotePart>[
        SchoolNotePartText(value: ""),
      ];

  final List<SchoolNotePart> parts;

  final DateTime _creationDate;
  DateTime _lastModifiedDate;

  DateTime get creationDate => _creationDate;
  DateTime get lastModifiedDate => _lastModifiedDate;

  String title;

  SchoolNote({
    List<SchoolNotePart>? parts,
    this.title = "",
    DateTime? creationDate,
    DateTime? lastModifiedDate,
  })  : parts = parts ?? defaultParts,
        _creationDate = creationDate ?? DateTime.now(),
        _lastModifiedDate =
            lastModifiedDate ?? creationDate?.copyWith() ?? DateTime.now();

  static const String titleKey = "title";
  static const String creationDateKey = "creationDate";
  static const String lastModifiedDateKey = "lastModifiedDate";
  static const String partsKey = "parts";

  String get saveFileName => creationDate.millisecondsSinceEpoch.toString();

  static SchoolNote? fromJson(Map<String, dynamic> json) {
    String title = json[titleKey];
    DateTime creationDate =
        DateTime.fromMillisecondsSinceEpoch(json[creationDateKey]);
    DateTime lastModifiedDate =
        DateTime.fromMillisecondsSinceEpoch(json[lastModifiedDateKey]);
    List<Map<String, dynamic>> partsJson = (json[partsKey] as List).cast();

    List<SchoolNotePart> schoolNoteParts = [];

    for (int i = 0; i < partsJson.length; i++) {
      final schoolnotePart = SchoolNotePart.fromJson(partsJson[i]);

      if (schoolnotePart == null) {
        debugPrint(
            "There was an error while loading SchoolNotePart: ${partsJson[i][SchoolNotePart.typeKey]}");
        continue;
      }

      schoolNoteParts.add(schoolnotePart);
    }

    return SchoolNote(
      title: title,
      creationDate: creationDate,
      lastModifiedDate: lastModifiedDate,
      parts: schoolNoteParts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      titleKey: title,
      creationDateKey: creationDate.millisecondsSinceEpoch,
      lastModifiedDateKey: lastModifiedDate.millisecondsSinceEpoch,
      partsKey: List.generate(
        parts.length,
        (index) => parts[index].toJson(),
      ),
    };
  }

  void setLastModifiedDate() {
    _lastModifiedDate = DateTime.now();
  }

  String? addFile(File file) {
    return SaveManager().addFileToSchoolNote(this, file);
  }

  bool removeFile(String fileName) {
    return SaveManager().removeFileToSchoolNote(this, fileName);
  }

  ///returns null if the file does not exist
  String? getFilePath(String fileName) {
    return SaveManager().getFilePathFromSchoolNoteFile(this, fileName);
  }
}
