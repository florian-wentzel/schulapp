// import 'package:fluent_ui/fluent_ui.dart';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class WeekTimetable extends Timetable {
  WeekTimetable({
    required super.name,
    required super.maxLessonCount,
    required super.schoolDays,
    required super.schoolTimes,
  }) : super(
          weekTimetables: null,
        );

  static WeekTimetable fromTimetable({
    required String name,
    required Timetable timetable,
  }) {
    return WeekTimetable(
      name: name,
      maxLessonCount: timetable.maxLessonCount,
      schoolTimes: timetable.copy().schoolTimes,
      schoolDays: timetable.copy().schoolDays,
    );
  }

  @override
  WeekTimetable copy() {
    return WeekTimetable(
      name: name,
      maxLessonCount: maxLessonCount,
      schoolDays: List.generate(
        schoolDays.length,
        (index) => schoolDays[index].clone(),
      ),
      schoolTimes: List.generate(
        schoolTimes.length,
        (index) => schoolTimes[index].clone(),
      ),
    );
  }

  static WeekTimetable? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    WeekTimetable? timetable;

    try {
      String n = json[Timetable.nameKey];
      int mlc = json[Timetable.maxLessonCountKey]; //maxLessonCount
      List<Map<String, dynamic>> ds =
          (json[Timetable.schoolDaysKey] as List).cast();
      List<Map<String, dynamic>> ts =
          (json[Timetable.schoolTimesKey] as List).cast();

      timetable = WeekTimetable(
        name: n,
        maxLessonCount: mlc,
        schoolDays: List.generate(
          ds.length,
          (index) => SchoolDay.fromJson(ds[index]),
        ),
        schoolTimes: List.generate(
          ts.length,
          (index) => SchoolTime.fromJson(ts[index]),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return timetable;
  }
}

class Timetable {
  //TODO: Wieviele?!
  static final weekNames = UnmodifiableListView<String>(
    <String>[
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
    ],
  );

  static const maxNameLength = 15;
  static const minMaxLessonCount = 5;
  static const maxMaxLessonCount = 12;

  static const nameKey = "name";
  static const maxLessonCountKey = "maxLessonCount";
  static const schoolDaysKey = "days";
  static const schoolTimesKey = "times";
  static const weekTimetablesKey = "bWeekTimetable";

  static final defaultPaulDessauTimetable = [
    SchoolTime(
      start: const TimeOfDay(hour: 7, minute: 45),
      end: const TimeOfDay(hour: 8, minute: 30),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 8, minute: 40),
      end: const TimeOfDay(hour: 9, minute: 25),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 9, minute: 45),
      end: const TimeOfDay(hour: 10, minute: 30),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 10, minute: 40),
      end: const TimeOfDay(hour: 11, minute: 25),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 11, minute: 35),
      end: const TimeOfDay(hour: 12, minute: 20),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 12, minute: 50),
      end: const TimeOfDay(hour: 13, minute: 35),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 13, minute: 45),
      end: const TimeOfDay(hour: 14, minute: 30),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 14, minute: 40),
      end: const TimeOfDay(hour: 15, minute: 25),
    ),
    SchoolTime(
      start: const TimeOfDay(hour: 15, minute: 30),
      end: const TimeOfDay(hour: 16, minute: 15),
    ),
  ];

  static List<SchoolTime> defaultSchoolTimes(int hoursCount) {
    if (hoursCount == 9) {
      return defaultPaulDessauTimetable;
    }

    TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 45);

    return List.generate(
      hoursCount,
      (index) {
        TimeOfDay endTime = startTime.add(minutes: 45);

        final schoolTime = SchoolTime(
          start: startTime,
          end: endTime,
        );

        startTime = endTime.add(minutes: 10);

        return schoolTime;
      },
    );
  }

  static List<String> get weekDayNames => [
        AppLocalizationsManager.localizations.strMonday,
        AppLocalizationsManager.localizations.strTuesday,
        AppLocalizationsManager.localizations.strWednesday,
        AppLocalizationsManager.localizations.strThursday,
        AppLocalizationsManager.localizations.strFriday,
        AppLocalizationsManager.localizations.strSaturday,
        AppLocalizationsManager.localizations.strSunday,
      ];

  static List<SchoolDay> defaultSchoolDays(int hoursCount) {
    // final lessons = List.generate(
    //   hoursCount,
    //   (index) => SchoolLesson(
    //     name: "-${index + 1}-",
    //     room: emptyLessonName,
    //     teacher: emptyLessonName,
    //     color: const Color.fromARGB(255, 127, 127, 127),
    //     events: [],
    //   ),
    // );

    //Ursprünglich hatte ich die eine Liste erstellt und wollte dann mit List.from(lessons) eine copy erstellen
    //aber das hat nicht funktioniert es gab dann den bug das sich alle Tage die gleichen Stunden geteilt haben.
    //Deswegen werden die Listen jetzt einzeln erstellt...

    return [
      SchoolDay(
        name: AppLocalizationsManager.localizations.strMonday,
        lessons: List.generate(
          hoursCount,
          (index) => EmptySchoolLesson(lessonIndex: index),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strTuesday,
        lessons: List.generate(
          hoursCount,
          (index) => EmptySchoolLesson(lessonIndex: index),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strWednesday,
        lessons: List.generate(
          hoursCount,
          (index) => EmptySchoolLesson(lessonIndex: index),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strThursday,
        lessons: List.generate(
          hoursCount,
          (index) => EmptySchoolLesson(lessonIndex: index),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strFriday,
        lessons: List.generate(
          hoursCount,
          (index) => EmptySchoolLesson(lessonIndex: index),
        ),
      ),
    ];
  }

  List<WeekTimetable>? _weekTimetables;
  UnmodifiableListView<WeekTimetable>? get weekTimetables {
    final weekTimetables = _weekTimetables;
    if (weekTimetables == null) return null;
    return UnmodifiableListView(weekTimetables);
  }

  String _name;
  int _maxLessonCount;
  List<SchoolDay> _schoolDays;
  List<SchoolTime> _schoolTimes;

  String get name => _name;
  int get maxLessonCount => _maxLessonCount;
  List<SchoolDay> get schoolDays => _schoolDays;
  List<SchoolTime> get schoolTimes => _schoolTimes;

  //year-weekIndex um zu wissen welche woche gespeichert wird
  String? currSpecialLessonsWeekKey;
  List<SpecialLesson>? currSpecialLessonsWeek;

  List<SchoolLessonPrefab> get lessonPrefabs {
    Map<String, SchoolLessonPrefab> lessonPrefabsMap = {};

    for (int schoolDayIndex = 0;
        schoolDayIndex < schoolDays.length;
        schoolDayIndex++) {
      for (int schoolLessonIndex = 0;
          schoolLessonIndex < maxLessonCount;
          schoolLessonIndex++) {
        SchoolLesson lesson =
            schoolDays[schoolDayIndex].lessons[schoolLessonIndex];

        if (lesson is EmptySchoolLesson) {
          continue;
        }

        bool exists = lessonPrefabsMap.containsKey(lesson.name);

        if (exists) continue;

        SchoolLessonPrefab prefab = SchoolLessonPrefab(
          name: lesson.name,
          room: lesson.room,
          teacher: lesson.teacher,
          color: lesson.color,
        );

        lessonPrefabsMap[lesson.name] = prefab;
      }
    }

    return lessonPrefabsMap.values.toList();
  }

  set name(String value) {
    value = value.trim();

    if (value.isEmpty) {
      throw Exception(
        AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
      );
    }
    if (value.length > maxNameLength) {
      throw Exception(
        AppLocalizationsManager.localizations.strNameIsToLong,
      );
    }
    _name = value;
  }

  Timetable({
    required String name,
    required int maxLessonCount,
    required List<SchoolDay> schoolDays,
    required List<SchoolTime> schoolTimes,
    required List<WeekTimetable>? weekTimetables,
  })  : _name = name,
        _maxLessonCount = maxLessonCount,
        _schoolDays = schoolDays,
        _schoolTimes = schoolTimes,
        _weekTimetables = weekTimetables;

  DateTime getNextLessonDate(
    String subjectName,
  ) {
    //-1 kann man weglassen weil die Stude am heutigen Tag ruhig ignoriert werden kann
    int currDayIndex = DateTime.now().weekday.clamp(0, _schoolDays.length);

    int nextDayIndex = -1;
    int nextLessonIndex = -1;

    outerLoop:
    for (int i = 0; i < _schoolDays.length; i++) {
      int index = (i + currDayIndex) % (_schoolDays.length);
      final schoolDay = _schoolDays[index];
      for (int j = 0; j < schoolDay.lessons.length; j++) {
        final schoolLesson = schoolDay.lessons[j];
        if (schoolLesson.name == subjectName) {
          nextDayIndex = index;
          nextLessonIndex = j;
          break outerLoop;
        }
      }
    }

    if (nextDayIndex == -1 || nextLessonIndex == -1) return DateTime.now();

    final schoolTime = schoolTimes[nextLessonIndex].start;

    if (nextDayIndex < currDayIndex) {
      //es ist erst nächste woche
      final lessonDate = DateTime.now().add(
        Duration(
          days: nextDayIndex - (DateTime.now().weekday - 1) + 7,
        ),
      );

      return DateTime(
        lessonDate.year,
        lessonDate.month,
        lessonDate.day,
        schoolTime.hour,
        schoolTime.minute,
      );
    }
    //diese woche
    final lessonDate = DateTime.now().add(
      Duration(
        days: (nextDayIndex - (currDayIndex - 1).abs()),
      ),
    );

    return DateTime(
      lessonDate.year,
      lessonDate.month,
      lessonDate.day,
      schoolTime.hour,
      schoolTime.minute,
    );
  }

  SchoolTime? getCurrentlyRunningLesson() {
    for (var time in _schoolTimes) {
      if (time.isCurrentlyRunning()) {
        return time;
      }
    }
    return null;
  }

  static Timetable? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    Timetable? timetable;

    try {
      String n = json[nameKey];
      int mlc = json[maxLessonCountKey]; //maxLessonCount
      List<Map<String, dynamic>> ds = (json[schoolDaysKey] as List).cast();
      List<Map<String, dynamic>> ts = (json[schoolTimesKey] as List).cast();
      List<Map<String, dynamic>>? ws =
          (json[weekTimetablesKey] as List?)?.cast();

      List<WeekTimetable>? weeks;

      if (ws != null) {
        weeks = [];
        for (int i = 0; i < ws.length; i++) {
          final tt = WeekTimetable.fromJson(ws[i]);

          if (tt == null) continue;

          weeks.add(tt);
        }
      }

      timetable = Timetable(
        name: n,
        maxLessonCount: mlc,
        schoolDays: List.generate(
          ds.length,
          (index) => SchoolDay.fromJson(ds[index]),
        ),
        schoolTimes: List.generate(
          ts.length,
          (index) => SchoolTime.fromJson(ts[index]),
        ),
        weekTimetables: weeks,
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return timetable;
  }

  Map<String, dynamic> toJson() {
    final weeks = _weekTimetables;

    return {
      nameKey: name,
      maxLessonCountKey: maxLessonCount,
      schoolTimesKey: List<Map<String, dynamic>>.generate(
        schoolTimes.length,
        (index) => schoolTimes[index].toJson(),
      ),
      schoolDaysKey: List<Map<String, dynamic>>.generate(
        schoolDays.length,
        (index) => schoolDays[index].toJson(),
      ),
      weekTimetablesKey: weeks == null
          ? null
          : List<Map<String, dynamic>>.generate(
              weeks.length,
              (index) => weeks[index].toJson(),
            ),
    };
  }

  ///saves name and room for "freistunden"
  Map<String, dynamic> toJsonOld() {
    return {
      nameKey: name,
      maxLessonCountKey: maxLessonCount,
      schoolTimesKey: List<Map<String, dynamic>>.generate(
        schoolTimes.length,
        (index) => schoolTimes[index].toJson(),
      ),
      schoolDaysKey: List<Map<String, dynamic>>.generate(
        schoolDays.length,
        (index) => schoolDays[index].toJsonOld(),
      ),
    };
  }

  void translateDayNames() {
    List<SchoolDay> defaultSchoolDays = Timetable.defaultSchoolDays(0);
    for (int i = 0; i < defaultSchoolDays.length; i++) {
      if (i >= _schoolDays.length) continue;

      _schoolDays[i].name = defaultSchoolDays[i].name;
    }
    SaveManager().saveTimetable(this);
  }

  Timetable copy() {
    final weeks = _weekTimetables;

    return Timetable(
      name: name,
      maxLessonCount: maxLessonCount,
      schoolDays: List.generate(
        schoolDays.length,
        (index) => schoolDays[index].clone(),
      ),
      schoolTimes: List.generate(
        schoolTimes.length,
        (index) => schoolTimes[index].clone(),
      ),
      weekTimetables: weeks == null
          ? null
          : List.generate(
              weeks.length,
              (index) => weeks[index].copy(),
            ),
    );
  }

  void setValuesFrom(Timetable ttCopy) {
    _name = ttCopy.name;
    _maxLessonCount = ttCopy.maxLessonCount;
    _schoolDays = ttCopy.schoolDays;
    _schoolTimes = ttCopy.schoolTimes;
  }

  void addLesson() {
    if (maxLessonCount >= Timetable.maxMaxLessonCount) {
      return;
    }
    for (var day in _schoolDays) {
      day.addLesson();
    }
    final secondLastLesson = _schoolTimes[_schoolTimes.length - 2];
    final lastLesson = _schoolTimes.last;

    final breakLength =
        lastLesson.start.toMinutes() - secondLastLesson.end.toMinutes();
    final lessonLength =
        lastLesson.end.toMinutes() - lastLesson.start.toMinutes();

    final start = lastLesson.end.add(minutes: breakLength);
    final end = start.add(minutes: lessonLength);

    _schoolTimes.add(
      SchoolTime(start: start, end: end),
    );
    _maxLessonCount++;
  }

  void removeLesson() {
    if (maxLessonCount <= Timetable.minMaxLessonCount) {
      return;
    }
    for (var day in _schoolDays) {
      day.removeLesson();
    }
    _schoolTimes.removeLast();
    _maxLessonCount--;
  }

  bool isSpecialLesson({
    required int year,
    required int weekIndex,
    required int schoolDayIndex,
    required int schoolTimeIndex,
  }) {
    return TimetableManager().isSpecialLesson(
      timetable: this,
      year: year,
      weekIndex: weekIndex,
      schoolDayIndex: schoolDayIndex,
      schoolTimeIndex: schoolTimeIndex,
    );
  }

  void setSpecialLesson({
    required int weekIndex,
    required int year,
    required CancelledSpecialLesson specialLesson,
  }) {
    TimetableManager().setSpecialLesson(
      timetable: this,
      year: year,
      weekIndex: weekIndex,
      specialLesson: specialLesson,
    );
  }

  void removeSpecialLesson({
    required int year,
    required int weekIndex,
    required int dayIndex,
    required int timeIndex,
  }) {
    TimetableManager().removeSpecialLesson(
      timetable: this,
      year: year,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      timeIndex: timeIndex,
    );
  }

  bool canAddAnotherWeek() {
    final weekTts = _weekTimetables;
    if (weekTts == null) return true;

    return weekTts.length < weekNames.length - 1;
  }

  void addAnotherWeek() {
    if (!canAddAnotherWeek()) return;

    if (_weekTimetables == null) {
      _weekTimetables = [
        WeekTimetable.fromTimetable(
          name: weekNames[1],
          timetable: this,
        ),
      ];
      return;
    }

    _weekTimetables?.add(
      WeekTimetable.fromTimetable(
        name: weekNames[_weekTimetables!.length + 1],
        timetable: this,
      ),
    );
  }
}
