import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/save_manager.dart';

///singelton damit es immer nur eine instanz gibt
class TimetableManager {
  static final TimetableManager _instance =
      TimetableManager._privateConstructor();
  TimetableManager._privateConstructor();

  factory TimetableManager() {
    return _instance;
  }

  List<Timetable>? _timetables;
  List<SchoolSemester>? _semesters;
  Settings? _settings;

  List<Timetable> get timetables {
    _timetables ??= SaveManager().loadAllTimetables(); //load timetable
    return _timetables!;
  }

  List<SchoolSemester> get semesters {
    _semesters ??= SaveManager().loadAllSemesters();
    return _semesters!;
  }

  Settings get settings {
    _settings ??= SaveManager().loadSettings();
    return _settings!;
  }

  ///Adds the [Timetable] and saves it to lokal storage
  ///replaces the [Timetable] when it already exists
  void addOrChangeTimetable(Timetable timetable, {String? originalName}) {
    if (originalName != null) {
      //um sicher zu gehen das er wirklich gelöscht wird
      SaveManager().delteTimetable(
        Timetable(
          name: originalName,
          maxLessonCount: 0,
          schoolDays: [],
          schoolTimes: [],
        ),
      );

      if (timetables.any((element) => element.name == originalName)) {
        // throw Exception("there is already a timetable called: ${timetable.name}");
        final tt =
            timetables.firstWhere((element) => element.name == originalName);

        bool removed = removeTimetable(tt);

        if (!removed) {
          print("timetable ${tt.name} could not be removed");
        }
      }
    }

    if (timetables.any((element) => element.name == timetable.name)) {
      // throw Exception("there is already a timetable called: ${timetable.name}");
      final tt =
          timetables.firstWhere((element) => element.name == timetable.name);

      bool removed = _timetables!.remove(tt);

      if (!removed) {
        print("timetable ${tt.name} could not be removed");
      }
    }

    _timetables!.add(timetable);

    SaveManager().saveTimeTable(timetable);
  }

  bool removeTimetableAt(int index) {
    if (index < 0 || index >= timetables.length) return false;

    Timetable timetable = _timetables!.removeAt(index);

    return SaveManager().delteTimetable(timetable);
  }

  bool removeTimetable(Timetable timetable) {
    try {
      int index = timetables.indexOf(
        timetables.firstWhere(
          (element) => element.name == timetable.name,
        ),
      );
      return removeTimetableAt(index);
    } catch (e) {
      return false;
    }
  }

  void addOrChangeSemester(SchoolSemester semester, {String? originalName}) {
    if (originalName != null) {
      //um sicher zu gehen das er wirklich gelöscht wird
      SaveManager().deleteSemester(
        SchoolSemester(
          name: originalName,
          subjects: [],
        ),
      );

      if (semesters.any((element) => element.name == originalName)) {
        // throw Exception("there is already a timetable called: ${timetable.name}");
        final semester =
            semesters.firstWhere((element) => element.name == originalName);

        bool removed = removeSemester(semester);

        if (!removed) {
          print("Semester ${semester.name} could not be removed");
        }
      }
    }

    if (semesters.any((element) => element.name == semester.name)) {
      final sem =
          semesters.firstWhere((element) => element.name == semester.name);

      bool removed = semesters.remove(sem);

      if (!removed) {
        print("semester ${sem.name} could not be removed");
      }
    }

    _semesters!.add(semester);

    SaveManager().saveSemester(semester);
  }

  bool removeSemesterAt(int index) {
    if (index < 0 || index >= semesters.length) return false;

    SchoolSemester semester = semesters.removeAt(index);

    return SaveManager().deleteSemester(semester);
  }

  bool removeSemester(SchoolSemester semester) {
    try {
      int index = semesters.indexOf(
        semesters.firstWhere(
          (element) => element.name == semester.name,
        ),
      );
      return removeSemesterAt(index);
    } catch (e) {
      return false;
    }
  }
}
