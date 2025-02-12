import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/save_manager.dart';

///Contains, timetables, semesters, todoEvents and settings
class TimetableManager {
  static final TimetableManager _instance =
      TimetableManager._privateConstructor();
  TimetableManager._privateConstructor();

  factory TimetableManager() {
    return _instance;
  }

  //TODO: Semesters, todoEvents and Settings eigenes singelton geben
  List<Timetable>? _timetables;
  List<SchoolSemester>? _semesters;
  List<TodoEvent>? _todoEvents;
  Settings? _settings;

  List<Timetable> get timetables {
    _timetables ??= SaveManager().loadAllTimetables(); //load timetable

    _timetables?.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return _timetables!;
  }

  List<SchoolSemester> get semesters {
    _semesters ??= SaveManager().loadAllSemesters();
    return _semesters!;
  }

  List<TodoEvent> get todoEvents {
    if (_todoEvents == null) {
      _todoEvents = SaveManager().loadAllTodoEvents();
      _setTodoEventsNotifications();
    }
    return _todoEvents!;
  }

  Future<void> _setTodoEventsNotifications() async {
    for (int i = 0; i < todoEvents.length; i++) {
      await todoEvents[i].cancleNotification();
      await todoEvents[i].addNotification();
    }
  }

  List<TodoEvent> get sortedUnfinishedTodoEvents {
    return sortedTodoEvents.where((element) => !element.finished).toList();
  }

  List<TodoEvent> get sortedFinishedTodoEvents {
    return sortedTodoEvents.where((element) => element.finished).toList();
  }

  List<TodoEvent> get sortedTodoEvents {
    todoEvents.sort(
      (a, b) {
        if (a.finished && b.finished) {
          if (a.endTime == null && b.endTime == null) {
            return TodoEvent.typeToInt(b.type)
                .compareTo(TodoEvent.typeToInt(a.type));
          }
          if (a.endTime == null) {
            return -1;
          }
          if (b.endTime == null) {
            return 1;
          }

          return b.endTime!.compareTo(a.endTime!);
          //TodoEvent.compareType(a.type, b.type);
        }
        if (a.finished) {
          return 1;
        }
        if (b.finished) {
          return -1;
        }
        if (a.endTime == null && b.endTime == null) {
          return TodoEvent.typeToInt(b.type)
              .compareTo(TodoEvent.typeToInt(a.type));
        }
        if (a.endTime == null) {
          return -1;
        }
        if (b.endTime == null) {
          return 1;
        }
        return a.endTime!.compareTo(b.endTime!);
      },
    );

    return todoEvents;
  }

  Settings get settings {
    _settings ??= SaveManager().loadSettings();
    return _settings!;
  }

  ///Adds the [Timetable] and saves it to lokal storage
  ///replaces the [Timetable] when it already exists and [onAlreadyExists] returns true
  Future<bool> addOrChangeTimetable(
    Timetable timetable, {
    required String? originalName,
    Future<bool> Function()? onAlreadyExists,
  }) async {
    try {
      final alreadyExists = timetables.any(
        (element) => element.name == timetable.name,
      );
      //wenn original name null ist dann wurde der stundenplan neu erstellt
      //das heißt dass man ihn nicht kopieren muss
      if (originalName == null) {
        //testen ob es den neuen namen schon gibt
        if (alreadyExists) {
          final replace = await onAlreadyExists?.call() ?? false;
          if (!replace) {
            return false;
          }

          final tt = timetables.cast<Timetable?>().firstWhere(
                (element) => element?.name == timetable.name,
              );

          if (tt != null) {
            removeTimetable(tt);
          }

          _timetables?.add(timetable);

          SaveManager().saveTimetable(timetable);

          return true;
        }
        //muss erstellt werden
        _timetables?.add(timetable);
        SaveManager().saveTimetable(timetable);
        return true;
      }

      //fragen ob man überschreiben möchte
      if (timetable.name != originalName && alreadyExists) {
        final replace = await onAlreadyExists?.call() ?? false;
        if (!replace) {
          return false;
        }
      }

      SaveManager().renameTimetable(timetable, originalName);

      final mainTimetableName = TimetableManager().settings.getVar(
            Settings.mainTimetableNameKey,
          );

      if (mainTimetableName == originalName) {
        TimetableManager().settings.setVar(
              Settings.mainTimetableNameKey,
              timetable.name,
            );
      }

      final tt = timetables.cast<Timetable?>().firstWhere(
            (element) => element?.name == originalName,
            orElse: () => null,
          );

      if (tt == null) {
        _timetables!.add(timetable);
      } else {
        tt.setValuesFrom(timetable);
      }

      SaveManager().saveTimetable(timetable);

      return true;
    } catch (_) {
      return false;
    }
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
    final index = todoEvents.indexWhere((element) => element.key == event.key);
    if (index != -1) {
      todoEvents[index].cancleNotification().then(
            (value) => event.addNotification(),
          );
      todoEvents[index] = event;
    } else {
      todoEvents.add(event);
      event.addNotification();
    }

    SaveManager().saveTodoEvents(todoEvents);
  }

  bool removeTodoEvent(TodoEvent event, {bool deleteLinkedSchoolNote = false}) {
    event.cancleNotification();

    if (deleteLinkedSchoolNote) {
      final note =
          SchoolNotesManager().getSchoolNoteBySaveName(event.linkedSchoolNote);

      if (note != null) {
        SchoolNotesManager().removeSchoolNote(note);
      }
    }

    final removed = todoEvents.remove(event);

    if (!removed) {
      final index =
          todoEvents.indexWhere((element) => element.key == event.key);
      if (index != -1) {
        todoEvents[index].cancleNotification();
        todoEvents.removeAt(index);
      } else {
        return false;
      }
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
      if (event.endTime == null) continue;
      if (event.linkedSubjectName != linkedSubjectName) continue;
      if (event.endTime!.year != lessonDayTime.year ||
          event.endTime!.month != lessonDayTime.month ||
          event.endTime!.day != lessonDayTime.day) {
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
      if (event.endTime == null) continue;

      if (event.endTime!.year != day.year ||
          event.endTime!.month != day.month ||
          event.endTime!.day != day.day) {
        continue;
      }

      return event;
    }
    return null;
  }

  bool isSpecialLesson({
    required Timetable timetable,
    required int year,
    required int weekIndex,
    required int schoolDayIndex,
    required int schoolTimeIndex,
  }) {
    final currSpecialLessonsKey =
        SaveManager().getSpecialLessonsFileName(year, weekIndex);
    if (timetable.currSpecialLessonsWeekKey != currSpecialLessonsKey) {
      timetable.currSpecialLessonsWeek = SaveManager().getSpecialLessonsForWeek(
        timetable: timetable,
        year: year,
        weekIndex: weekIndex,
      );
      timetable.currSpecialLessonsWeekKey = currSpecialLessonsKey;
    }

    final specialLesson = timetable.currSpecialLessonsWeek?.any(
          (element) =>
              element.dayIndex == schoolDayIndex &&
              element.timeIndex == schoolTimeIndex,
        ) ??
        false;

    return specialLesson;
  }

  void setSpecialLesson({
    required Timetable timetable,
    required int year,
    required int weekIndex,
    required SpecialLesson specialLesson,
  }) {
    final currSpecialLessonsKey =
        SaveManager().getSpecialLessonsFileName(year, weekIndex);

    if (timetable.currSpecialLessonsWeekKey != currSpecialLessonsKey) {
      timetable.currSpecialLessonsWeek = SaveManager().getSpecialLessonsForWeek(
        timetable: timetable,
        year: year,
        weekIndex: weekIndex,
      );
      timetable.currSpecialLessonsWeekKey = currSpecialLessonsKey;
    }

    final alreadyInList = timetable.currSpecialLessonsWeek?.any(
          (element) =>
              element.dayIndex == specialLesson.dayIndex &&
              element.timeIndex == specialLesson.timeIndex,
        ) ??
        false;

    if (alreadyInList) {
      return;
    }

    timetable.currSpecialLessonsWeek?.add(specialLesson);

    SaveManager().saveCurrSpecialLessonsWeek(
      timetable: timetable,
    );
  }

  void removeSpecialLesson({
    required Timetable timetable,
    required int year,
    required int weekIndex,
    required int dayIndex,
    required int timeIndex,
  }) {
    final currSpecialLessonsKey =
        SaveManager().getSpecialLessonsFileName(year, weekIndex);

    if (timetable.currSpecialLessonsWeekKey != currSpecialLessonsKey) {
      timetable.currSpecialLessonsWeek = SaveManager().getSpecialLessonsForWeek(
        timetable: timetable,
        year: year,
        weekIndex: weekIndex,
      );
      timetable.currSpecialLessonsWeekKey = currSpecialLessonsKey;
    }

    try {
      final specialLesson = timetable.currSpecialLessonsWeek?.firstWhere(
        (element) =>
            element.dayIndex == dayIndex && element.timeIndex == timeIndex,
      );
      timetable.currSpecialLessonsWeek?.remove(specialLesson);
    } catch (e) {
      //
    }

    SaveManager().saveCurrSpecialLessonsWeek(
      timetable: timetable,
    );
  }

  void markAllDataToBeReloaded() {
    _timetables = null;
    _semesters = null;
    _todoEvents = null;
    _settings = null;
  }

  Future<void> removeTodoEventNotifications() async {
    for (int i = 0; i < todoEvents.length; i++) {
      await todoEvents[i].cancleNotification();
    }
  }
}
