import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schulapp/code_behind/abi_calculator.dart';
import 'package:schulapp/code_behind/backup_manager.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';
import 'package:schulapp/code_behind/school_file.dart';
import 'package:schulapp/code_behind/school_lesson_notification.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/zip_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

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
  static const String abiCalculatorFileName = "abi-calculator.json";
  static const String lessonRemindersFileName = "lesson-reminders.json";
  static const String onlineSyncManagerFile = "online_sync_manager.json";

  //for backups
  static const String tempDirName = "temp";
  static const String exportDirName = "exports";
  static const String importDirName = "imports";
  static const String semestersSaveDirName = "semesters";
  static const String todoEventSaveDirName = "todos";
  static const String finishedEventSaveName = "finsihedTodos.json";
  static const String todoEventSaveName = "todos.json";
  static const String deletedTodoEventSaveName = "deletedTodos.json";
  static const String timetableFileName = "timetable.json";
  static const String todoEventFileName = "todoEvent.json";
  static const String schoolNoteFileName = "note.json";
  static const String semesterFileName = "semester.json";
  static const String specialLessonsDirName = "special-lessons";
  static const String timetableExportExtension = ".timetable";
  static const String todoEventExportExtension = ".todo";
  static const String todosKey = "todos";
  static const String itemsKey = "items";
  static const String notificationsKey = "notifications";
  static const String lastSyncTimeKey = "lastSyncTime";
  static const String lastSyncTimeTryKey = "lastSyncTimeTry";

  Directory? applicationDocumentsDirectory;

  Directory getFileDirectoryFromSchoolNote(SchoolNote schoolNote) {
    String schoolNoteDirPath =
        join(getSchoolNotesDir().path, schoolNote.saveFileName);

    String schoolNoteAddedFilesDirPath =
        join(schoolNoteDirPath, schoolNoteAddedFilesSaveDirName);

    Directory dir = Directory(schoolNoteAddedFilesDirPath);
    dir.createSync(recursive: true);

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

  void copySchoolNoteDir(
    SchoolNote schoolNote, {
    required String toPath,
  }) {
    try {
      schoolNote.title = schoolNote.title.trim();

      final schoolNoteDirPath = join(
        getSchoolNotesDir().path,
        schoolNote.saveFileName,
      );

      Directory schoolNoteDir = Directory(schoolNoteDirPath);

      if (!schoolNoteDir.existsSync()) {
        throw Exception(
          "school note dir could not be created: ${schoolNoteDir.path}",
        );
      }

      BackupManager.copyDirectorySync(
        source: schoolNoteDir,
        destination: Directory(toPath),
      );
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

  void saveTodoEventWithNote(
    TodoEvent todoEvent, {
    required String todoEventDirPath,
  }) {
    Directory todoEventDir = Directory(todoEventDirPath);
    todoEventDir.createSync();

    File todoEventFile = File(join(todoEventDirPath, todoEventFileName));

    if (!todoEventDir.existsSync()) {
      throw Exception(
        "todoevent dir could not be created: ${todoEventDir.path}",
      );
    }

    String jsonString = json.encode(todoEvent.toJson());

    todoEventFile.writeAsStringSync(jsonString);

    final linkedNote = todoEvent.linkedSchoolNote;
    if (linkedNote == null) {
      return;
    }

    final schoolNote = SchoolNotesManager().getSchoolNoteBySaveName(
      linkedNote,
    );

    if (schoolNote == null) {
      return;
    }

    SaveManager().copySchoolNoteDir(
      schoolNote,
      toPath: todoEventDirPath,
    );
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

  List<
      ({
        TodoEvent event,
        SchoolNote? note,
        Directory? filesDirForNote,
      })> importTodoEvents(List<File> todoEventExportFiles) {
    getImportDir().deleteSync(recursive: true);
    List<
        ({
          TodoEvent event,
          SchoolNote? note,
          Directory? filesDirForNote,
        })> todoEvents = [];

    for (var file in todoEventExportFiles) {
      if (!file.existsSync()) continue;

      final exportDir =
          Directory(join(getImportDir().path, basename(file.path)));

      ZipManager.zipToFolder(
        file,
        exportDir,
      );

      String todoEventFilePath =
          join(exportDir.path, SaveManager.todoEventFileName);
      String schoolNoteFilePath =
          join(exportDir.path, SaveManager.schoolNoteFileName);
      String schoolNoteFilesDirPath = join(
        exportDir.path,
        SaveManager.schoolNoteAddedFilesSaveDirName,
      );

      final todoEventFile = File(todoEventFilePath);
      final schoolNoteFile = File(schoolNoteFilePath);
      final schoolNoteFilesDir = Directory(schoolNoteFilesDirPath);

      String todoEventJsonString = todoEventFile.readAsStringSync();
      String? schoolNoteJsonString = schoolNoteFile.existsSync()
          ? schoolNoteFile.readAsStringSync()
          : null;

      Map<String, dynamic> todoEventJson = jsonDecode(todoEventJsonString);
      Map<String, dynamic>? schoolNoteJson = schoolNoteJsonString == null
          ? null
          : jsonDecode(schoolNoteJsonString);

      final ({
        TodoEvent event,
        SchoolNote? note,
        Directory? filesDirForNote,
      }) todoEvent = (
        event: TodoEvent.fromJson(todoEventJson)..finished = false,
        note: schoolNoteJson == null
            ? null
            : SchoolNote.fromJson(
                schoolNoteJson,
                isImporting: true,
                noteImportDirectory: exportDir,
              ),
        filesDirForNote:
            schoolNoteFilesDir.existsSync() ? schoolNoteFilesDir : null,
      );

      todoEvents.add(todoEvent);
    }

    return todoEvents;
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

  Future<String> shareTimetable(Timetable timetable) async {
    final exportFile = await SaveManager().exportTimetable(
      timetable,
      SaveManager().getTempDir().path,
    );

    final code = await GoFileIoManager().uploadFiles(
      [exportFile],
      returnSaveCode: true,
    );

    SaveManager().deleteTempDir();

    return code;
  }

  Future<String> shareTodoEvents(List<TodoEvent> todoEvents) async {
    SaveManager().deleteTempDir();
    List<File> files = [];

    for (var todoEvent in todoEvents) {
      final path = await shareTodoEvent(todoEvent, upload: false);
      files.add(File(path));
    }

    final code = await GoFileIoManager().uploadFiles(
      files,
      returnSaveCode: true,
    );

    SaveManager().deleteTempDir();

    return code;
  }

  /// returns the saveCode for GoFileIo if upload is true
  /// otherwise it just returns the path to the exported file
  Future<String> shareTodoEvent(
    TodoEvent todoEvent, {
    bool upload = true,
  }) async {
    final exportFile = await SaveManager().exportTodoEvent(
      todoEvent,
      SaveManager().getTempDir().path,
    );

    if (upload == false) {
      return exportFile.path;
    }

    final code = await GoFileIoManager().uploadFiles(
      [exportFile],
      returnSaveCode: true,
    );

    SaveManager().deleteTempDir();

    return code;
  }

  Future<File> exportTodoEvent(TodoEvent todoEvent, String path) async {
    final now = DateTime.now();
    final exportName = " ${now.day}.${now.month}.${now.year}";

    final dirSavePath = join(
      getExportDir().path,
      todoEvent.key.toString() + exportName,
    );

    final zipExportPath = join(
      path,
      todoEvent.key.toString() + exportName + todoEventExportExtension,
    );

    saveTodoEventWithNote(
      todoEvent,
      todoEventDirPath: dirSavePath,
    );

    await ZipManager.folderToZip(
      Directory(dirSavePath),
      File(zipExportPath),
    );

    Directory(dirSavePath).deleteSync(recursive: true);

    return File(zipExportPath);
  }

  Future<File> exportTimetable(Timetable timetable, String path) async {
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

    await ZipManager.folderToZip(
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

  bool renameTimetable(Timetable timetable, String originalName) {
    if (timetable.name == originalName) return true;

    Directory timetableDir = getTimetableDir(
      Timetable.placeholderName(originalName),
    );

    Directory targetDir = Directory(
      join(
        getTimetablesDir().path,
        timetable.name,
      ),
    );

    try {
      if (targetDir.existsSync()) {
        targetDir.deleteSync(recursive: true);
      }
      timetableDir.renameSync(targetDir.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool renameSemester(SchoolSemester semester, String originalName) {
    if (semester.name == originalName) return true;
    String semesterDirPath = join(getSemestersDir().path, originalName);

    Directory semesterDir = Directory(semesterDirPath);

    Directory targetDir = Directory(
      join(
        getSemestersDir().path,
        semester.name,
      ),
    );

    try {
      if (targetDir.existsSync()) {
        targetDir.deleteSync(recursive: true);
      }
      semesterDir.renameSync(targetDir.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Directory getTimetableDir(Timetable tt) {
    String timetableDirPath = join(getTimetablesDir().path, tt.name);

    return Directory(timetableDirPath);
  }

  bool delteTimetable(Timetable timetable) {
    try {
      Directory timetableDir = getTimetableDir(timetable);

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
    Map<String, SchoolSemester> semestersMap = {};
    int errorCount = 0;

    for (var name in names) {
      try {
        SchoolSemester? semester = loadSemester(name);
        if (semester == null) {
          errorCount++;
          continue;
        }

        //damit altes speichern nichts kaputt macht
        if (!RegExp(r'^\d+$').hasMatch(name)) {
          String semestersDirPath = join(getSemestersDir().path, name);

          Directory(semestersDirPath).deleteSync(recursive: true);
          saveSemester(semester);
        }

        if (semestersMap.containsKey(semester.name)) {
          String semestersDirPath = join(getSemestersDir().path, name);

          Directory(semestersDirPath).deleteSync(recursive: true);
          continue;
        }

        semestersMap[semester.name] = semester;
      } catch (e) {
        debugPrint('Error reading or parsing the JSON file: $e');
      }
    }

    if (errorCount != 0) {
      debugPrint("Errorcount while loading: $errorCount");
    }

    final semesters = semestersMap.values.toList();

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
    String semestersDirPath = join(
      getSemestersDir().path,
      semester.uniqueKey.toString(),
    );

    Directory semesterDir = Directory(semestersDirPath);
    semesterDir.createSync();

    File semesterFile = File(join(semestersDirPath, semesterFileName));

    if (!semesterDir.existsSync()) {
      throw Exception(
        AppLocalizationsManager.localizations.strTimetableDirNotCreated(
          semesterDir.path,
        ),
      );
    }

    String jsonString = json.encode(semester.toJson());

    semesterFile.writeAsStringSync(jsonString);
    return true;
  }

  bool deleteSemester(SchoolSemester semester) {
    try {
      String semestersDirPath =
          join(getSemestersDir().path, semester.uniqueKey.toString());

      Directory semesterDir = Directory(semestersDirPath);

      if (semesterDir.existsSync()) {
        semesterDir.deleteSync(recursive: true);
      }

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Map<String, dynamic> todoEventsToJson(List<TodoEvent> todoEvents) {
    return {
      todosKey: List<Map<String, dynamic>>.generate(
        todoEvents.length,
        (index) => todoEvents[index].toJson(),
      ),
    };
  }

  Map<String, dynamic> deletedTodoEventsToJson(
      List<DeletedTodoEvent> deletedTodoEvents) {
    return {
      todosKey: deletedTodoEvents.map((e) => e.toJson()).toList(),
    };
  }

  bool saveTodoEvents(List<TodoEvent> todoEvents) {
    Directory eventDir = getTodosDir();
    String pathToFile = join(eventDir.path, todoEventSaveName);
    Map<String, dynamic> json = todoEventsToJson(todoEvents);

    String fileContent = jsonEncode(json);
    try {
      File(pathToFile).writeAsStringSync(fileContent);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool saveDeletedTodoEvents(List<DeletedTodoEvent> deletedTodoEvents) {
    Directory eventDir = getTodosDir();
    String pathToFile = join(eventDir.path, deletedTodoEventSaveName);

    Map<String, dynamic> json = deletedTodoEventsToJson(deletedTodoEvents);

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
      String fileContent = File(pathToFile).readAsStringSync();
      Map<String, dynamic> json = jsonDecode(fileContent);
      return todoEventsFromJson(json);
    } catch (e) {
      return [];
    }
  }

  List<DeletedTodoEvent> loadAllDeletedTodoEvents() {
    Directory eventDir = getTodosDir();
    String pathToFile = join(eventDir.path, deletedTodoEventSaveName);
    try {
      String fileContent = File(pathToFile).readAsStringSync();
      Map<String, dynamic> json = jsonDecode(fileContent);
      final list = deletedTodoEventsFromJson(json);

      final deleteDateTime = DateTime.now().subtract(
        Duration(
          days: DeletedTodoEvent.daysToKeepDeletedEvents,
        ),
      );

      list.removeWhere(
        (element) => element.time.isBefore(deleteDateTime),
      );

      return list;
    } catch (e) {
      return [];
    }
  }

  List<DeletedTodoEvent> deletedTodoEventsFromJson(Map<String, dynamic> json) {
    try {
      List<dynamic> todos = (json[todosKey] as List).cast();
      List<DeletedTodoEvent> deletedTodos = [];

      for (int i = 0; i < todos.length; i++) {
        final todo = DeletedTodoEvent.fromJson(todos[i]);
        if (todo != null) {
          deletedTodos.add(todo);
        }
      }

      return deletedTodos;
    } catch (e) {
      return [];
    }
  }

  List<TodoEvent> todoEventsFromJson(Map<String, dynamic> json) {
    try {
      List<Map<String, dynamic>> todos = (json[todosKey] as List).cast();

      return List.generate(
        todos.length,
        (index) => TodoEvent.fromJson(
          todos[index],
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
      } else if (type == SubstituteSpecialLesson.type) {
        specialLessons.add(
          SubstituteSpecialLesson.fromJson(json),
        );
      } else if (type == SickSpecialLesson.type) {
        specialLessons.add(
          SickSpecialLesson.fromJson(json),
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
        timetable.currSpecialLessonsWeek == null) {
      return false;
    }

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

  File? saveTempImage(Uint8List imageBytes, String fileName) {
    try {
      final tempDir = getTempDir();
      final tempImagePath = join(
        tempDir.path,
        fileName,
      );

      final file = File(tempImagePath);
      file.writeAsBytesSync(imageBytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  File getAbiCalculatorFile() {
    String mainDirPath = getMainSaveDir().path;

    return File(
      join(mainDirPath, abiCalculatorFileName),
    );
  }

  AbiCalculator loadAbiCalculator() {
    try {
      final file = getAbiCalculatorFile();

      if (!file.existsSync()) {
        return AbiCalculator();
      }

      String jsonString = file.readAsStringSync();

      Map<String, dynamic> jsonData = json.decode(jsonString);

      return AbiCalculator.fromJson(jsonData);
    } catch (_) {
      return AbiCalculator();
    }
  }

  void saveAbiCalculator(AbiCalculator calculator) {
    try {
      final file = getAbiCalculatorFile();

      String jsonString = json.encode(calculator.toJson());

      file.writeAsStringSync(jsonString);
    } catch (_) {}
  }

  void saveLessonReminders(
      List<SchoolLessonNotification> notificationsToSchedule) {
    try {
      final file = File(
        join(getMainSaveDir().path, lessonRemindersFileName),
      );

      final Map<String, dynamic> jsonMap = {
        notificationsKey: List<Map<String, dynamic>>.generate(
          notificationsToSchedule.length,
          (index) => notificationsToSchedule[index].toJson(),
        ),
      };

      final jsonString = jsonEncode(jsonMap);

      file.writeAsStringSync(jsonString);
    } catch (e) {
      debugPrint("Error saving lesson reminders: $e");
    }
  }

  (DateTime?, DateTime?) loadLastOnlineSyncTimeAndTry() {
    try {
      final file = File(
        join(
          getMainSaveDir().path,
          onlineSyncManagerFile,
        ),
      );

      if (!file.existsSync()) {
        return (null, null);
      }

      final content = file.readAsStringSync();

      Map<String, dynamic> jsonMap = jsonDecode(content);

      final lastOnlineSyncTime = DateTime.tryParse(
        jsonMap[lastSyncTimeKey] ?? "",
      )?.toUtc();
      final lastOnlineSyncTryTime = DateTime.tryParse(
        jsonMap[lastSyncTimeTryKey] ?? "",
      )?.toUtc();

      return (lastOnlineSyncTime, lastOnlineSyncTryTime);
    } catch (e) {
      debugPrint("Error loading last online sync time: $e");
      return (null, null);
    }
  }

  void saveLastOnlineSyncTimeAndTry(
      DateTime? lastSyncTime, DateTime? lastSyncTimeTry) {
    try {
      final file = File(
        join(
          getMainSaveDir().path,
          onlineSyncManagerFile,
        ),
      );

      Map<String, dynamic> jsonMap = {
        lastSyncTimeKey: lastSyncTime?.toIso8601String(),
        lastSyncTimeTryKey: lastSyncTimeTry?.toIso8601String(),
      };

      file.writeAsStringSync(
        jsonEncode(jsonMap),
      );
    } catch (e) {
      debugPrint("Error saving last online sync time: $e");
    }
  }

  List<SchoolLessonNotification> loadLessonReminders() {
    try {
      final file = File(
        join(getMainSaveDir().path, lessonRemindersFileName),
      );

      if (!file.existsSync()) {
        return [];
      }

      final jsonString = file.readAsStringSync();

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      final List<Map<String, dynamic>> notificationsListMap =
          (jsonMap[notificationsKey] as List).cast();

      return notificationsListMap.map(
        (e) {
          return SchoolLessonNotification.fromJson(e);
        },
      ).toList();
    } catch (e) {
      debugPrint("Error saving lesson reminders: $e");
      return [];
    }
  }

  //Könnte man auch für ein Backup verwenden,
  //wird alle Datein aus der App zurückeben
  //es gibt lokale datein zurück, also enthalten die Datein keine Drive ID
  List<SchoolFileBase> getAllSchoolFiles() {
    SchoolDirectory todoEventDir = SchoolDirectory(
      todoEventSaveDirName,
    );

    SchoolFile todoEventsFile = SchoolFile(
      todoEventSaveName,
      driveId: null,
      modifiedTime: DateTime.now(), //TODO!!!
      // modifiedTime: TimetableManager().todoEvents.sort((a, b) => a.lastModifiedTime...,),
      contentGenerator: () {
        final events = TimetableManager().todoEvents;

        Map<String, dynamic> todos = SaveManager().todoEventsToJson(events);

        return utf8.encode(jsonEncode(todos));
      },
    );

    todoEventDir.addChild(todoEventsFile);

    SchoolDirectory semestersDir = SchoolDirectory(
      semestersSaveDirName,
    );

    for (var semester in TimetableManager().semesters) {
      SchoolDirectory semesterDir = SchoolDirectory(
        semester.uniqueKey.toString(),
        children: [
          SchoolFile(
            semesterFileName,
            driveId: null,
            modifiedTime: DateTime.now(), // TODO!!
            contentGenerator: () {
              return utf8.encode(
                jsonEncode(
                  semester.toJson(),
                ),
              );
            },
          ),
        ],
      );

      semestersDir.addChild(semesterDir);
    }

    return [
      todoEventDir,
      semestersDir,
    ];
  }

  // List<SchoolFileBase> getTodoEventSchoolFiles() {

  //   return dir;
  // }

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
