import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_note_part.dart';
import 'package:schulapp/code_behind/utils.dart';

class SchoolNoteUI with ChangeNotifier {
  ///only modify via SchoolNoteUI methods
  final SchoolNote schoolNote;

  SchoolNoteUI({required this.schoolNote});

  String? addFile(
    File file, {
    bool keepFileName = false,
  }) {
    return schoolNote.addFile(
      file,
      keepFileName: keepFileName,
    );
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

  //wenn die Notiz noch nicht gespeichert wurde,
  //zum Beispiel wenn sie importiert wird
  final bool isImporting;
  //dieses Directory zeigt auf den speicher ort für die verbundenen Datein
  final Directory? noteImportDirectory;

  final DateTime _creationDate;
  DateTime _lastModifiedDate;

  DateTime get creationDate => _creationDate;
  DateTime get lastModifiedDate => _lastModifiedDate;

  String title;
  String getTitle(BuildContext context) {
    if (title.isNotEmpty) {
      return title;
    }

    return "${Utils.dateToString(creationDate)}, ${TimeOfDay.fromDateTime(creationDate).format(context)}";
  }

  SchoolNote({
    List<SchoolNotePart>? parts,
    this.title = "",
    this.isImporting = false,
    this.noteImportDirectory,
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

  static SchoolNote? fromJson(
    Map<String, dynamic> json, {
    bool isImporting = false,
    Directory? noteImportDirectory,
  }) {
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
      isImporting: isImporting,
      noteImportDirectory: noteImportDirectory,
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

  String? addFile(
    File file, {
    bool keepFileName = false,
  }) {
    if (isImporting) {
      final importDir = noteImportDirectory;
      //wenn es nicht gegeben ist, ist irgendwas gewaltig schief..
      if (importDir == null) return null;
      if (!importDir.existsSync()) return null;

      try {
        if (!file.existsSync()) {
          return null;
        }

        final dir = Directory(join(
          importDir.path,
          SaveManager.schoolNoteAddedFilesSaveDirName,
        ));

        final fileName = keepFileName
            ? basename(file.path)
            : "${DateTime.now().millisecondsSinceEpoch}${extension(file.path)}";

        String pathToAppDataFile = join(dir.path, fileName);

        if (File(pathToAppDataFile).existsSync()) {
          return null;
        }

        file.copySync(pathToAppDataFile);

        return fileName;
      } on Exception catch (_) {
        return null;
      }
    }
    return SaveManager().addFileToSchoolNote(
      this,
      file,
      keepFileName: keepFileName,
    );
  }

  bool removeFile(String fileName) {
    if (isImporting) {
      final importDir = noteImportDirectory;
      //wenn es nicht gegeben ist, ist irgendwas gewaltig schief..
      if (importDir == null) return false;
      if (!importDir.existsSync()) return false;

      try {
        final file = File(join(
          importDir.path,
          SaveManager.schoolNoteAddedFilesSaveDirName,
          fileName,
        ));

        if (!file.existsSync()) {
          return false;
        }

        file.deleteSync();

        return true;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }

    return SaveManager().removeFileToSchoolNote(this, fileName);
  }

  ///returns null if the file does not exist
  String? getFilePath(String fileName) {
    if (isImporting) {
      final importDir = noteImportDirectory;
      //wenn es nicht gegeben ist, ist irgendwas gewaltig schief..
      if (importDir == null) return null;
      if (!importDir.existsSync()) return null;

      final file = File(join(
        importDir.path,
        SaveManager.schoolNoteAddedFilesSaveDirName,
        fileName,
      ));

      if (!file.existsSync()) {
        return null;
      }

      return file.path;
    }
    return SaveManager().getFilePathFromSchoolNoteFile(this, fileName);
  }
}
