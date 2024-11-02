import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/zip_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:share_plus/share_plus.dart';

class SaveManager {
  static final SaveManager _instance = SaveManager._privateConstructor();
  SaveManager._privateConstructor();

  factory SaveManager() {
    return _instance;
  }

  static const String mainDirName = "Schulapp";
  static const String settingsFileName = "settings.json";
  static const String timetableSaveDirName = "timetables";
  static const String schoolNotesSaveDirName = "notes";
  static const String schoolNoteAddedFilesSaveDirName = "files";
  //for backups
  static const String tempDirName = "temp";
  static const String exportDirName = "exports";
  static const String importDirName = "imports";
  static const String semestersSaveDirName = "semesters";
  static const String todoEventSaveDirName = "todos";
  static const String finishedEventSaveName = "finsihedTodos.json";
  static const String todoEventSaveName = "todos.json";
  static const String timetableFileName = "timetable.json";
  static const String schoolNoteFileName = "note.json";
  static const String semesterFileName = "semester.json";
  static const String specialLessonsDirName = "special-lessons";
  static const String timetableExportExtension = ".timetable";
  static const String todosKey = "todos";
  static const String itemsKey = "items";

  Directory? applicationDocumentsDirectory;

  Directory getFileDirectoryFromSchoolNote(SchoolNote schoolNote) {
    String schoolNoteDirPath =
        join(getSchoolNotesDir().path, schoolNote.saveFileName);

    String schoolNoteAddedFilesDirPath =
        join(schoolNoteDirPath, schoolNoteAddedFilesSaveDirName);

    Directory dir = Directory(schoolNoteAddedFilesDirPath);
    dir.createSync();

    return dir;
  }

  ///returns null if the file does not exist
  String? getFilePathFromSchoolNoteFile(
      SchoolNote schoolNote, String fileName) {
    final dir = getFileDirectoryFromSchoolNote(schoolNote);
    final path = join(dir.path, fileName);
    if (!File(path).existsSync()) {
      return null;
    }
    return path;
  }

  bool removeFileToSchoolNote(SchoolNote schoolNote, String fileName) {
    try {
      Directory dir = getFileDirectoryFromSchoolNote(schoolNote);

      String pathToAppDataFile = join(dir.path, fileName);

      File(pathToAppDataFile).deleteSync();
      return true;
    } catch (e) {
      return false;
    }
  }

  String? addFileToSchoolNote(
    SchoolNote schoolNote,
    File file, {
    bool keepFileName = false,
  }) {
    try {
      Directory dir = getFileDirectoryFromSchoolNote(schoolNote);

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

  bool deleteSchoolNote(SchoolNote schoolNote) {
    try {
      String schoolNoteDirPath =
          join(getSchoolNotesDir().path, schoolNote.saveFileName);

      Directory schoolNoteDir = Directory(schoolNoteDirPath);

      if (schoolNoteDir.existsSync()) {
        schoolNoteDir.deleteSync(recursive: true);
      }

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  void saveSchoolNote(
    SchoolNote schoolNote, {
    String? schoolNoteDirPath,
  }) {
    try {
      schoolNote.title = schoolNote.title.trim();

      schoolNoteDirPath ??= join(
        getSchoolNotesDir().path,
        schoolNote.saveFileName,
      );

      Directory schoolNoteDir = Directory(schoolNoteDirPath);
      schoolNoteDir.createSync();

      File schoolNoteFile = File(join(schoolNoteDirPath, schoolNoteFileName));

      if (!schoolNoteDir.existsSync()) {
        throw Exception(
          "school note dir could not be created: ${schoolNoteDir.path}",
        );
      }

      String jsonString = json.encode(schoolNote.toJson());

      schoolNoteFile.writeAsStringSync(jsonString);
    } catch (_) {}
  }

  List<SchoolNote> loadAllSchoolNotes() {
    final schoolNotesDir = getSchoolNotesDir();
    final files = schoolNotesDir.listSync();

    List<String> names = List.generate(
      files.length,
      (index) => basename(files[index].path),
    );

    return loadSchoolNotes(names);
  }

  List<SchoolNote> loadSchoolNotes(List<String> names) {
    List<SchoolNote> schoolNotes = [];
    int errorCount = 0;

    for (var name in names) {
      try {
        SchoolNote? note = loadSchoolNote(name);
        if (note == null) {
          errorCount++;
          continue;
        }
        schoolNotes.add(note);
      } catch (e) {
        debugPrint('Error reading or parsing the JSON file: $e');
      }
    }

    if (errorCount != 0) {
      debugPrint("Errorcount while loading: $errorCount");
    }

    schoolNotes.sort(
      (a, b) => a.title.compareTo(b.title),
    );

    return schoolNotes;
  }

  SchoolNote? loadSchoolNote(String name) {
    try {
      String schoolNotesDirPath = join(getSchoolNotesDir().path, name);

      final schoolNoteFile = File(join(schoolNotesDirPath, schoolNoteFileName));

      if (!schoolNoteFile.existsSync()) {
        return null;
      }

      String jsonString = schoolNoteFile.readAsStringSync();

      Map<String, dynamic> jsonData = json.decode(jsonString);

      return SchoolNote.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  List<Timetable> loadAllTimetables() {
    final timetablesDir = getTimetablesDir();
    final files = timetablesDir.listSync();

    List<String> names = List.generate(
      files.length,
      (index) => basename(files[index].path),
    );

    return loadTimetables(names);
  }

  List<Timetable> loadTimetables(List<String> names) {
    List<Timetable> timetables = [];
    int errorCount = 0;
    for (var name in names) {
      try {
        Timetable? tt = loadTimetable(name);
        if (tt == null) {
          errorCount++;
          continue;
        }
        timetables.add(tt);
      } catch (e) {
        debugPrint('Error reading or parsing the JSON file: $e');
      }
    }

    if (errorCount != 0) {
      debugPrint("Errorcount while loading: $errorCount");
    }

    timetables.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return timetables;
  }

  Timetable? loadTimetable(String name) {
    String timetbaleDirPath = join(getTimetablesDir().path, name);

    //load timetable
    final timetableFile = File(join(timetbaleDirPath, timetableFileName));

    if (!timetableFile.existsSync()) {
      return null;
    }

    // Read the contents of the file
    String jsonString = timetableFile.readAsStringSync();

    // Parse the JSON string into a Dart object
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // Now you can work with the loaded JSON data
    debugPrint(jsonData.toString());

    return Timetable.fromJson(jsonData);
  }

  void saveAllTimetables() {
    final timetables = TimetableManager().timetables;
    saveTimetables(timetables);
  }

  void saveTimetables(List<Timetable> timetables) {
    for (var timetable in timetables) {
      saveTimetable(timetable);
    }
  }

  void saveTimetable(
    Timetable timetable, {
    String? timetableDirPath,
  }) {
    timetable.name = timetable.name.trim();
    timetableDirPath ??= join(getTimetablesDir().path, timetable.name);

    Directory timetableDir = Directory(timetableDirPath);
    timetableDir.createSync();

    File timetableFile = File(join(timetableDirPath, timetableFileName));

    if (!timetableDir.existsSync()) {
      throw Exception(
        "timetable dir could not be created: ${timetableDir.path}",
      );
    }

    String jsonString = json.encode(timetable.toJson());

    timetableFile.writeAsStringSync(jsonString);
  }

  void cleanExports() {
    const maxFileCount = 5;
    Directory exportsDir = getExportDir();
    List<FileSystemEntity> files = exportsDir.listSync();

    while (files.length > maxFileCount) {
      files[0].deleteSync(recursive: true);
      files.removeAt(0);
    }
  }

  Timetable? importTimetable(File timetableExportFile) {
    if (!timetableExportFile.existsSync()) return null;
    ZipManager.zipToFolder(timetableExportFile, getImportDir());

    String timetableFilePath =
        join(getImportDir().path, SaveManager.timetableFileName);
    File timetableFile = File(timetableFilePath);

    String jsonString = timetableFile.readAsStringSync();

    getImportDir().deleteSync(recursive: true);

    Map<String, dynamic> json = jsonDecode(jsonString);

    return Timetable.fromJson(json);
  }

  Future<void> shareTimetable(Timetable timetable) async {
    final exportFile = SaveManager().exportTimetable(
      timetable,
      SaveManager().getTempDir().path,
    );

    await Share.shareXFiles(
      [XFile(exportFile.path)],
      subject: AppLocalizationsManager.localizations.strShareYourTimetable,
      text: AppLocalizationsManager.localizations.strShareYourTimetable,
    );

    SaveManager().deleteTempDir();
  }

  File exportTimetable(Timetable timetable, String path) {
    final now = DateTime.now();
    final exportName = " ${now.day}.${now.month}.${now.year}";

    final dirSavePath = join(
      getExportDir().path,
      timetable.name + exportName,
    );
    final zipExportPath = join(
      path,
      timetable.name + exportName + timetableExportExtension,
    );

    saveTimetable(
      timetable,
      timetableDirPath: dirSavePath,
    );

    ZipManager.folderToZip(
      Directory(dirSavePath),
      File(zipExportPath),
    );

    Directory(dirSavePath).deleteSync(recursive: true);

    // if (Platform.isAndroid || Platform.isIOS) {
    //   DocumentFileSavePlus().saveFile(
    //     File(zipExportPath).readAsBytesSync(),
    //     basename(zipExportPath),
    //     "application/zip",
    //   );
    // }

    return File(zipExportPath);
  }

  Future<void> loadApplicationDocumentsDirectory() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      applicationDocumentsDirectory = dir;
    } catch (e) {
      applicationDocumentsDirectory = null;
      debugPrint(e.toString());
    }
  }

  void deleteTempDir() {
    final dir = getTempDir();

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  ///Creates a new temp Dir.
  ///IMPORTANT: You need to call deleteTempDir after using it
  Directory getTempDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, tempDirName),
    );

    // if (dir.existsSync()) {
    //   dir.deleteSync(recursive: true);
    // }

    dir.createSync();

    return dir;
  }

  ///WARNING: only call it if you know what your doing!!
  void deleteMainSaveDirExceptTemp() {
    if (applicationDocumentsDirectory == null) {
      loadApplicationDocumentsDirectory();
      throw Exception("document dir not loaded");
    }

    final dir = Directory(
      join(applicationDocumentsDirectory!.path, mainDirName),
    );

    if (dir.existsSync()) {
      _deleteDirSync(
        dir,
        skipDirWithName: basename(getTempDir().path),
      );
    }
  }

  void _deleteDirSync(
    Directory dir, {
    String? skipDirWithName,
  }) {
    dir.listSync(recursive: false).forEach(
      (entity) {
        if (entity is File) {
          entity.deleteSync();
        } else if (entity is Directory) {
          if (skipDirWithName != null &&
              basename(entity.path) == skipDirWithName) {
            return;
          }
          _deleteDirSync(
            entity,
            skipDirWithName: skipDirWithName,
          );
          entity.deleteSync();
        }
      },
    );
  }

  Directory getMainSaveDir() {
    if (applicationDocumentsDirectory == null) {
      loadApplicationDocumentsDirectory();
      throw Exception("document dir not loaded");
    }

    final dir = Directory(
      join(applicationDocumentsDirectory!.path, mainDirName),
    );

    dir.createSync(recursive: true);

    return dir;
  }

  Directory getExportDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, exportDirName),
    );

    dir.createSync();

    return dir;
  }

  Directory getTodosDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, todoEventSaveDirName),
    );

    dir.createSync();

    return dir;
  }

  Directory getImportDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, importDirName),
    );

    dir.createSync();

    return dir;
  }

  Directory getTimetablesDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, timetableSaveDirName),
    );

    dir.createSync();

    return dir;
  }

  Directory getSchoolNotesDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, schoolNotesSaveDirName),
    );

    dir.createSync();

    return dir;
  }

  Directory getSpecialLessonsDirForTimetable(Timetable timetable) {
    String timetbaleDirPath = join(getTimetablesDir().path, timetable.name);
    String specialLessonsDirPath =
        join(timetbaleDirPath, specialLessonsDirName);

    final dir = Directory(specialLessonsDirPath);

    dir.createSync();

    return dir;
  }

  Directory getSemestersDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, semestersSaveDirName),
    );

    dir.createSync();

    return dir;
  }

  Directory getTodoEventDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, todoEventSaveDirName),
    );

    dir.createSync();

    return dir;
  }

  Settings loadSettings() {
    String mainSaveDirPath = getMainSaveDir().path;

    String path = join(mainSaveDirPath, settingsFileName);

    if (!File(path).existsSync()) return Settings();

    String fileContent = File(path).readAsStringSync();

    Map<String, dynamic> json = jsonDecode(fileContent);

    return Settings.fromJson(json);
  }

  void saveSettings(Settings settings) {
    String mainSaveDirPath = getMainSaveDir().path;

    String path = join(mainSaveDirPath, settingsFileName);

    Map<String, dynamic> json = settings.toJson();

    String fileContent = jsonEncode(json);

    File(path).writeAsStringSync(fileContent);
  }

  bool delteTimetable(Timetable timetable) {
    try {
      String timetableDirPath = join(getTimetablesDir().path, timetable.name);

      Directory timetableDir = Directory(timetableDirPath);

      if (timetableDir.existsSync()) {
        timetableDir.deleteSync(recursive: true);
      }

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  List<SchoolSemester> loadAllSemesters() {
    final semestersDir = getSemestersDir();
    final files = semestersDir.listSync();

    List<String> names = List.generate(
      files.length,
      (index) => basename(files[index].path),
    );

    return loadSemesters(names);
  }

  List<SchoolSemester> loadSemesters(List<String> names) {
    List<SchoolSemester> semesters = [];
    int errorCount = 0;

    for (var name in names) {
      try {
        SchoolSemester? semester = loadSemester(name);
        if (semester == null) {
          errorCount++;
          continue;
        }
        semesters.add(semester);
      } catch (e) {
        debugPrint('Error reading or parsing the JSON file: $e');
      }
    }

    if (errorCount != 0) {
      debugPrint("Errorcount while loading: $errorCount");
    }

    semesters.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return semesters;
  }

  SchoolSemester? loadSemester(String name) {
    String semesterDirPath = join(getSemestersDir().path, name);

    final semesterFile = File(join(semesterDirPath, semesterFileName));

    if (!semesterFile.existsSync()) return null;

    String jsonString = semesterFile.readAsStringSync();

    Map<String, dynamic> jsonData = json.decode(jsonString);

    debugPrint(jsonData.toString());

    return SchoolSemester.fromJson(jsonData);
  }

  bool saveSemester(SchoolSemester semester) {
    String semestersDirPath = join(getSemestersDir().path, semester.name);

    Directory timetableDir = Directory(semestersDirPath);
    timetableDir.createSync();

    File semesterFile = File(join(semestersDirPath, semesterFileName));

    if (!timetableDir.existsSync()) {
      throw Exception(
        AppLocalizationsManager.localizations.strTimetableDirNotCreated(
          timetableDir.path,
        ),
      );
    }

    String jsonString = json.encode(semester.toJson());

    semesterFile.writeAsStringSync(jsonString);
    return true;
  }

  bool deleteSemester(SchoolSemester semester) {
    try {
      String semestersDirPath = join(getSemestersDir().path, semester.name);

      Directory semesterDir = Directory(semestersDirPath);

      if (semesterDir.existsSync()) {
        semesterDir.deleteSync(recursive: true);
      }

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  bool saveTodoEvents(List<TodoEvent> todoEvents) {
    Directory eventDir = getTodosDir();
    String pathToFile = join(eventDir.path, todoEventSaveName);
    Map<String, dynamic> json = {
      todosKey: List<Map<String, dynamic>>.generate(
        todoEvents.length,
        (index) => todoEvents[index].toJson(),
      ),
    };

    String fileContent = jsonEncode(json);
    try {
      File(pathToFile).writeAsStringSync(fileContent);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<TodoEvent> loadAllTodoEvents() {
    Directory eventDir = getTodosDir();
    String pathToFile = join(eventDir.path, todoEventSaveName);
    try {
      String fileCOntent = File(pathToFile).readAsStringSync();
      Map<String, dynamic> json = jsonDecode(fileCOntent);
      List<Map<String, dynamic>> todos = (json[todosKey] as List).cast();

      return List.generate(
        todos.length,
        (index) => TodoEvent.fromJson(
          todos[index],
          index,
        ),
      );
    } catch (e) {
      return [];
    }
  }

  String getSpecialLessonsFileName(int year, int weekIndex) {
    return "$year-$weekIndex.json";
  }

  List<SpecialLesson> getSpecialLessonsForWeek({
    required Timetable timetable,
    required int year,
    required int weekIndex,
  }) {
    final specialLessonsDir = getSpecialLessonsDirForTimetable(timetable);
    final specialLessonsDirPath = join(
        specialLessonsDir.path, getSpecialLessonsFileName(year, weekIndex));
    final specialLessonsJsonFile = File(specialLessonsDirPath);

    if (!specialLessonsJsonFile.existsSync()) {
      return [];
    }

    String jsonString = specialLessonsJsonFile.readAsStringSync();

    Map<String, dynamic> jsonData = json.decode(jsonString);

    List<Map<String, dynamic>> jsonList = (jsonData[itemsKey] as List).cast();

    List<SpecialLesson> specialLessons = [];

    for (int i = 0; i < jsonList.length; i++) {
      final json = jsonList[i];
      final type = json[SpecialLesson.typeKey];

      if (type == CancelledSpecialLesson.type) {
        specialLessons.add(
          CancelledSpecialLesson.fromJson(json),
        );
      } //you can just add other types here..
    }

    SpecialLesson.sortSpecialLessons(specialLessons);

    return specialLessons;
  }

  bool saveCurrSpecialLessonsWeek({
    required Timetable timetable,
  }) {
    if (timetable.currSpecialLessonsWeekKey == null ||
        timetable.currSpecialLessonsWeek == null) return false;

    if (timetable.currSpecialLessonsWeekKey?.isEmpty ?? true) {
      return false;
    }

    final dir = getSpecialLessonsDirForTimetable(timetable);
    final specialLessonsWeekFilePath =
        join(dir.path, timetable.currSpecialLessonsWeekKey);

    //if empty delete file to free space
    if (timetable.currSpecialLessonsWeek?.isEmpty == true) {
      final file = File(specialLessonsWeekFilePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      return true;
    }

    Map<String, dynamic> json = {
      itemsKey: List<Map<String, dynamic>>.generate(
        timetable.currSpecialLessonsWeek?.length ?? 0,
        (index) => timetable.currSpecialLessonsWeek![index].toJson(),
      ),
    };

    String fileContent = jsonEncode(json);

    try {
      File(
        specialLessonsWeekFilePath,
      ).writeAsStringSync(fileContent);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Future<File> moveFile(File sourceFile, String newPath) async {
  //   try {
  //     // prefer using rename as it is probably faster
  //     return await sourceFile.rename(newPath);
  //   } on FileSystemException {
  //     // if rename fails, copy the source file and then delete it
  //     final newFile = await sourceFile.copy(newPath);
  //     await sourceFile.delete();
  //     return newFile;
  //   }
  // }
}
