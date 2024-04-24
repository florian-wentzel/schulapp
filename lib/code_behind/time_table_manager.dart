import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
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
  List<TodoEvent>? _todoEvents;
  Settings? _settings;

  List<Timetable> get timetables {
    _timetables ??= SaveManager().loadAllTimetables(); //load timetable
    return _timetables!;
  }

  List<SchoolSemester> get semesters {
    _semesters ??= SaveManager().loadAllSemesters();
    return _semesters!;
  }

  List<TodoEvent> get todoEvents {
    _todoEvents ??= SaveManager().loadAllTodoEvents();
    return _todoEvents!;
  }

  List<TodoEvent> get sortedTodoEvents {
    todoEvents.sort(
      (a, b) {
        if (a.finished && b.finished) {
          return a.endTime.compareTo(b.endTime);
          //TodoEvent.compareType(a.type, b.type);
        }
        if (a.finished) {
          return 1;
        }
        if (b.finished) {
          return -1;
        }
        return a.endTime.compareTo(b.endTime);
      },
    );

    for (int i = 0; i < todoEvents.length; i++) {
      todoEvents[i].cancleNotification().then((value) {
        todoEvents[i].key = i;
        todoEvents[i].addNotification();
      });
    }

    return todoEvents;
  }

  Settings get settings {
    _settings ??= SaveManager().loadSettings();
    return _settings!;
  }

  int getNextSchoolEventKey() {
    //sortieren und neu nummerieren damit es keine Fehler gibt
    sortedTodoEvents;
    return todoEvents.length;
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
          debugPrint("timetable ${tt.name} could not be removed");
        }
      }
    }

    if (timetables.any((element) => element.name == timetable.name)) {
      // throw Exception("there is already a timetable called: ${timetable.name}");
      final tt =
          timetables.firstWhere((element) => element.name == timetable.name);

      bool removed = _timetables!.remove(tt);

      if (!removed) {
        debugPrint("timetable ${tt.name} could not be removed");
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
          debugPrint("Semester ${semester.name} could not be removed");
        }
      }
    }

    if (semesters.any((element) => element.name == semester.name)) {
      final sem =
          semesters.firstWhere((element) => element.name == semester.name);

      bool removed = semesters.remove(sem);

      if (!removed) {
        debugPrint("semester ${sem.name} could not be removed");
      }
    }

    _semesters!.add(semester);

    SaveManager().saveSemester(semester);
  }

  void addOrChangeTodoEvent(TodoEvent event) {
    if (event.key >= todoEvents.length) {
      //neues element
      todoEvents.add(event);
      //notification hinzufügen
      event.addNotification();
    } else {
      //wurde geändert
      todoEvents[event.key] = event.copy();
      event.cancleNotification().then(
            (value) => event.addNotification(),
          );
    }
    SaveManager().saveTodoEvents(todoEvents);
  }

  bool removeTodoEvent(TodoEvent event) {
    if (event.key < 0 || event.key >= todoEvents.length) return false;
    event.cancleNotification();

    todoEvents.remove(event);

    for (int i = 0; i < todoEvents.length; i++) {
      todoEvents[i].cancleNotification().then((value) {
        todoEvents[i].key = i;
        todoEvents[i].addNotification();
      });
    }

    return SaveManager().saveTodoEvents(todoEvents);
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

  TodoEvent? getRunningTodoEvent({
    required String linkedSubjectName,
    required DateTime lessonDayTime,
  }) {
    for (int i = 0; i < todoEvents.length; i++) {
      TodoEvent event = todoEvents[i];
      // if (event.finished) continue;
      // if (event.customEvent) continue;
      if (event.linkedSubjectName != linkedSubjectName) continue;
      if (event.endTime.year != lessonDayTime.year ||
          event.endTime.month != lessonDayTime.month ||
          event.endTime.day != lessonDayTime.day) {
        continue;
      }

      return event;
    }
    return null;
  }

  TodoEvent? getCustomTodoEventForDay({
    required DateTime day,
  }) {
    for (int i = 0; i < todoEvents.length; i++) {
      TodoEvent event = todoEvents[i];

      // if (event.finished) continue;
      if (!event.isCustomEvent) continue;

      if (event.endTime.year != day.year ||
          event.endTime.month != day.month ||
          event.endTime.day != day.day) {
        continue;
      }

      return event;
    }
    return null;
  }
}
