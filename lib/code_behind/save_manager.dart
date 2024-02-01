import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schulapp/code_behind/school_event.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/zip_manager.dart';

class SaveManager {
  static final SaveManager _instance = SaveManager._privateConstructor();
  SaveManager._privateConstructor();

  factory SaveManager() {
    return _instance;
  }

  static const String mainDirName = "Schulapp";
  static const String settingsFileName = "settings.json";
  static const String timetableSaveDirName = "timetables";
  static const String exportDirName = "exports";
  static const String importDirName = "imports";
  static const String semestersSaveDirName = "semesters";
  static const String todoEventSaveDirName = "todos";
  static const String finishedEventSaveName = "finsihedTodos.json";
  static const String todoEventSaveName = "todos.json";
  static const String timetableFileName = "timetable.json";
  static const String semesterFileName = "semester.json";
  static const String timetableExportExtension = ".zip"; //".timetable";
  static const String todosKey = "todos";

  Directory? applicationDocumentsDirectory;

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
    List<Timetable> timeTables = [];
    int errorCount = 0;
    for (var name in names) {
      try {
        Timetable? tt = loadTimetable(name);
        if (tt == null) {
          errorCount++;
          continue;
        }
        timeTables.add(tt);
      } catch (e) {
        print('Error reading or parsing the JSON file: $e');
      }
    }

    if (errorCount != 0) {
      print("Errorcount while loading: $errorCount");
    }

    return timeTables;
  }

  Timetable? loadTimetable(String name) {
    String timetbaleDirPath = join(getTimetablesDir().path, name);

    //load timetable
    final timetableFile = File(join(timetbaleDirPath, timetableFileName));
    //TODO: test if it Exsits
    // Read the contents of the file
    String jsonString = timetableFile.readAsStringSync();

    // Parse the JSON string into a Dart object
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // Now you can work with the loaded JSON data
    print(jsonData);

    return Timetable.fromJson(jsonData);
  }

  void saveAllTimetables() {
    final timetables = TimetableManager().timetables;
    saveTimetables(timetables);
  }

  void saveTimetables(List<Timetable> timetables) {
    for (var timetable in timetables) {
      saveTimeTable(timetable);
    }
  }

  void saveTimeTable(
    Timetable timetable, {
    String? timetableDirPath,
  }) {
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

  File exportTimetable(Timetable timetable) {
    final now = DateTime.now();
    final exportName = " ${now.day}.${now.month}.${now.year}";

    final dirSavePath = join(
      getExportDir().path,
      timetable.name + exportName,
    );
    final zipExportPath = join(
      getExportDir().path,
      timetable.name + exportName + timetableExportExtension,
    );

    saveTimeTable(
      timetable,
      timetableDirPath: dirSavePath,
    );

    ZipManager.folderToZip(
      Directory(dirSavePath),
      File(zipExportPath),
    );

    Directory(dirSavePath).deleteSync(recursive: true);

    if (Platform.isAndroid || Platform.isIOS) {
      DocumentFileSavePlus().saveFile(
        File(zipExportPath).readAsBytesSync(),
        basename(zipExportPath),
        "application/zip",
      );
    }

    return File(zipExportPath);
  }

  Future<void> loadApplicationDocumentsDirectory() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      applicationDocumentsDirectory = dir;
    } catch (e) {
      applicationDocumentsDirectory = null;
      print(e);
    }
  }

  Directory getMainSaveDir() {
    if (applicationDocumentsDirectory == null) {
      loadApplicationDocumentsDirectory();
      throw Exception("document dir not loaded");
    }

    final dir =
        Directory(join(applicationDocumentsDirectory!.path, mainDirName));

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
        print('Error reading or parsing the JSON file: $e');
      }
    }

    if (errorCount != 0) {
      print("Errorcount while loading: $errorCount");
    }

    return semesters;
  }

  SchoolSemester? loadSemester(String name) {
    String semesterDirPath = join(getSemestersDir().path, name);

    final semesterFile = File(join(semesterDirPath, semesterFileName));

    if (!semesterFile.existsSync()) return null;

    String jsonString = semesterFile.readAsStringSync();

    Map<String, dynamic> jsonData = json.decode(jsonString);

    print(jsonData);

    return SchoolSemester.fromJson(jsonData);
  }

  bool saveSemester(SchoolSemester semester) {
    String semestersDirPath = join(getSemestersDir().path, semester.name);

    Directory timetableDir = Directory(semestersDirPath);
    timetableDir.createSync();

    File semesterFile = File(join(semestersDirPath, semesterFileName));

    if (!timetableDir.existsSync()) {
      throw Exception(
        "timetable dir could not be created: ${timetableDir.path}",
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
