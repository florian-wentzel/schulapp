import 'dart:collection';

import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_note.dart';

class SchoolNotesManager {
  static final SchoolNotesManager _instance =
      SchoolNotesManager._privateConstructor();

  SchoolNotesManager._privateConstructor() {
    _schoolNotes = SaveManager().loadAllSchoolNotes();
  }

  factory SchoolNotesManager() {
    return _instance;
  }

  late List<SchoolNote> _schoolNotes;
  List<SchoolNote> get schoolNotes => UnmodifiableListView(_schoolNotes);

  void addSchoolNote(SchoolNote schoolNote) {
    _schoolNotes.add(schoolNote);
    SaveManager().saveSchoolNote(schoolNote);
  }

  bool removeSchoolNote(SchoolNote schoolNote) {
    _schoolNotes.remove(schoolNote);
    return SaveManager().deleteSchoolNote(schoolNote);
  }

  SchoolNote? getSchoolNoteBySaveName(String saveFileName) {
    return schoolNotes.cast<SchoolNote?>().firstWhere(
          (element) => element?.saveFileName == saveFileName,
          orElse: () => null,
        );
  }
}
