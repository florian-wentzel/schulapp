import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';

class SaveManager {
  static final SaveManager _instance = SaveManager._privateConstructor();
  SaveManager._privateConstructor();

  factory SaveManager() {
    return _instance;
  }
  static const String mainDirName = "Schulapp";
  static const String settingsFileName = "settings.json";
  static const String timetableSaveDirName = "timetables";
  static const String timetableFileName = "timetable.json";

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

  void saveTimeTable(Timetable timetable) {
    String timetableDirPath = join(getTimetablesDir().path, timetable.name);

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

  Directory getTimetablesDir() {
    String mainDirPath = getMainSaveDir().path;

    final dir = Directory(
      join(mainDirPath, timetableSaveDirName),
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
}
