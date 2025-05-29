import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart';
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
    //wenn man es gerade importiert muss noch der "files" ordner kopiert werden
    final noteImportDirectory = schoolNote.noteImportDirectory;

    if (schoolNote.isImporting && noteImportDirectory != null) {
      final json = schoolNote.toJson();
      final noteWithoutImport = SchoolNote.fromJson(json);
      if (noteWithoutImport != null) {
        final targetDir =
            SaveManager().getFileDirectoryFromSchoolNote(noteWithoutImport);
        final filesDir = Directory(join(
          noteImportDirectory.path,
          SaveManager.schoolNoteAddedFilesSaveDirName,
        ));
        if (filesDir.existsSync()) {
          for (var entity in filesDir.listSync(recursive: false)) {
            if (entity is File) {
              final fileName = basename(entity.path);
              final newFile = File(join(targetDir.path, fileName));
              entity.copySync(newFile.path);
            }
          }
        }
        _schoolNotes.add(noteWithoutImport);
        SaveManager().saveSchoolNote(noteWithoutImport);
        return;
      }
    }
    _schoolNotes.add(schoolNote);
    SaveManager().saveSchoolNote(schoolNote);
  }

  bool removeSchoolNote(SchoolNote schoolNote) {
    _schoolNotes.remove(schoolNote);
    return SaveManager().deleteSchoolNote(schoolNote);
  }

  SchoolNote? getSchoolNoteBySaveName(String? saveFileName) {
    if (saveFileName == null) return null;

    return schoolNotes.cast<SchoolNote?>().firstWhere(
          (element) => element?.saveFileName == saveFileName,
          orElse: () => null,
        );
  }

  void markAllDataToBeReloaded() {
    _schoolNotes = SaveManager().loadAllSchoolNotes();
  }
}
