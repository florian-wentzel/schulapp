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
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class WeekTimetable extends Timetable {
  Timetable parent;

  @override
  UnmodifiableListView<WeekTimetable> get weekTimetables =>
      UnmodifiableListView([]);

  WeekTimetable({
    required super.name,
    required super.maxLessonCount,
    required super.schoolDays,
    required super.schoolTimes,
    required this.parent,
  }) : super(
          weekTimetables: null,
          yearStartedWithWeekIndex: -1,
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
      parent: timetable,
    );
  }

  @override
  WeekTimetable copy() {
    return WeekTimetable(
      name: name,
      parent: parent,
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

  @override
  void setSpecialLesson({
    required int weekIndex,
    required int year,
    required CancelledSpecialLesson specialLesson,
  }) {
    TimetableManager().setSpecialLesson(
      timetable: parent,
      year: year,
      weekIndex: weekIndex,
      specialLesson: specialLesson,
    );
  }

  @override
  bool isSpecialLesson({
    required int year,
    required int weekIndex,
    required int schoolDayIndex,
    required int schoolTimeIndex,
  }) {
    return TimetableManager().isSpecialLesson(
      timetable: parent,
      year: year,
      weekIndex: weekIndex,
      schoolDayIndex: schoolDayIndex,
      schoolTimeIndex: schoolTimeIndex,
    );
  }

  @override
  void removeSpecialLesson({
    required int year,
    required int weekIndex,
    required int dayIndex,
    required int timeIndex,
  }) {
    TimetableManager().removeSpecialLesson(
      timetable: parent,
      year: year,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      timeIndex: timeIndex,
    );
  }

  static WeekTimetable? fromJson(Map<String, dynamic>? json, Timetable parent) {
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
        parent: parent,
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
  static const exclamationMark = "!";
  static const tickMark = "✓";

  //immer einer mehr als man letztendlich einstellen kann
  //also 4
  static final weekNames = UnmodifiableListView<String>(
    <String>[
      "A",
      "B",
      "C",
      "D",
      "E",
    ],
  );

  static const maxNameLength = 15;
  static const minMaxLessonCount = 5;
  static const maxMaxLessonCount = 12;

  static const nameKey = "name";
  static const maxLessonCountKey = "maxLessonCount";
  static const yearStartedWithWeekIndexKey = "yearStartedWithWeekIndex";
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

  //index
  int _yearStartedWithWeekIndex;
  List<WeekTimetable>? _weekTimetables;
  UnmodifiableListView<WeekTimetable> get weekTimetables {
    final weekTimetables = _weekTimetables;
    if (weekTimetables == null) {
      return UnmodifiableListView(
        [],
      );
    }
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
    int yearStartedWithWeekIndex = -1,
  })  : _name = name,
        _maxLessonCount = maxLessonCount,
        _yearStartedWithWeekIndex = yearStartedWithWeekIndex,
        _schoolDays = schoolDays,
        _schoolTimes = schoolTimes,
        _weekTimetables = weekTimetables;

  DateTime getNextLessonDate(
    String subjectName,
  ) {
    //-1 kann man weglassen weil die Stude am heutigen Tag ruhig ignoriert werden kann
    int currDayIndex = DateTime.now().weekday.clamp(0, schoolDays.length);

    int nextWeekIndex = -1;
    int nextDayIndex = -1;
    int nextLessonIndex = -1;

    List<Timetable> allWeekTimetables = <Timetable>[this, ...weekTimetables];

    int currWeekTimetableIndex = getCurrWeekTimetableIndex();

    if (currWeekTimetableIndex != -1) {
      //allWeekTimetables sortieren also welche woche heute ist, muss ganz vorne sein
      allWeekTimetables = allWeekTimetables.sublist(
        currWeekTimetableIndex,
      )..addAll(
          allWeekTimetables.sublist(
            0,
            currWeekTimetableIndex,
          ),
        );
    }

    outerLoop:
    for (int weekIndex = 0; weekIndex < allWeekTimetables.length; weekIndex++) {
      final tt = allWeekTimetables[weekIndex];

      int startForI = 0;

      if (weekIndex == 0) {
        startForI = currDayIndex;
      }

      for (int i = startForI; i < tt.schoolDays.length; i++) {
        final schoolDay = tt.schoolDays[i];
        for (int j = 0; j < schoolDay.lessons.length; j++) {
          final schoolLesson = schoolDay.lessons[j];
          if (schoolLesson.name == subjectName) {
            nextDayIndex = i;
            nextLessonIndex = j;
            nextWeekIndex = weekIndex;
            break outerLoop;
          }
        }
      }
    }

    //falls nextDayIndex oder nextLessonIndex oder nextWeekIndex nicht gesetzt wurden sind gehen wir davon aus
    //dass vielleicht die Tage die wir oben überspringen mussten ein Match gewesen wären
    //also z.B. wenn sie keine B-Woche haben
    if (nextDayIndex == -1 || nextLessonIndex == -1 || nextWeekIndex == -1) {
      final tt = allWeekTimetables[0];
      outerLoop:
      for (int i = 0; i < tt.schoolDays.length; i++) {
        int index = (i + currDayIndex) % (tt.schoolDays.length);

        final schoolDay = tt.schoolDays[index];
        for (int j = 0; j < schoolDay.lessons.length; j++) {
          final schoolLesson = schoolDay.lessons[j];
          if (schoolLesson.name == subjectName) {
            nextDayIndex = index;
            nextLessonIndex = j;
            //wir müssen dann sagen, dass es die woche nach allen ist,
            //weil wir sonst die aufgabe in dergleichen machen würden
            //aber nur wenn wir AB-Wochen haben
            if (allWeekTimetables.length == 1) {
              nextWeekIndex = -1;
            } else {
              nextWeekIndex = allWeekTimetables.length;
            }
            break outerLoop;
          }
        }
      }
    }

    if (nextDayIndex == -1 ||
        nextLessonIndex == -1 ||
        (nextWeekIndex == -1 && currWeekTimetableIndex != -1)) {
      return DateTime.now();
    }

    if (nextWeekIndex == -1) {
      final schoolTime = schoolTimes[nextLessonIndex].start;

      if (nextDayIndex < currDayIndex) {
        //es ist erst nächste woche
        final lessonDate = DateTime.now().add(
          Duration(
            days: nextDayIndex -
                (DateTime.now().weekday - 1) +
                DateTime.daysPerWeek,
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

    //wenn wir AB-Wochen haben
    Timetable selectedTT;
    if (nextWeekIndex == allWeekTimetables.length) {
      selectedTT = allWeekTimetables.first;
    } else {
      selectedTT = allWeekTimetables[nextWeekIndex];
    }
    final schoolTime = selectedTT.schoolTimes[nextLessonIndex].start;

    //diese woche
    final lessonDate = DateTime.now().add(
      Duration(
        days: nextDayIndex -
            (DateTime.now().weekday - 1) +
            DateTime.daysPerWeek * nextWeekIndex,
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
      int yearStartedWithWeekIndex = json[yearStartedWithWeekIndexKey] ?? -1;
      List<Map<String, dynamic>> ds = (json[schoolDaysKey] as List).cast();
      List<Map<String, dynamic>> ts = (json[schoolTimesKey] as List).cast();
      List<Map<String, dynamic>>? ws =
          (json[weekTimetablesKey] as List?)?.cast();

      List<WeekTimetable>? weeks;

      timetable = Timetable(
        name: n,
        maxLessonCount: mlc,
        yearStartedWithWeekIndex: yearStartedWithWeekIndex,
        schoolDays: List.generate(
          ds.length,
          (index) => SchoolDay.fromJson(ds[index]),
        ),
        schoolTimes: List.generate(
          ts.length,
          (index) => SchoolTime.fromJson(ts[index]),
        ),
        weekTimetables: null,
      );

      if (ws != null) {
        weeks = [];
        for (int i = 0; i < ws.length; i++) {
          final tt = WeekTimetable.fromJson(ws[i], timetable);

          if (tt == null) continue;

          weeks.add(tt);
        }
      }

      timetable.setWeekTimetables(weeks);
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
      yearStartedWithWeekIndexKey: _yearStartedWithWeekIndex,
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
      yearStartedWithWeekIndex: _yearStartedWithWeekIndex,
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
    _weekTimetables = ttCopy._weekTimetables;
    _yearStartedWithWeekIndex = ttCopy._yearStartedWithWeekIndex;
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

    for (final tt in weekTimetables) {
      tt.addLesson();
    }
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

    for (final tt in weekTimetables) {
      tt.removeLesson();
    }
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

    return weekTts.length < weekNames.length - 2;
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

      setCurrWeekTimetableIndex(0);
      return;
    }

    _weekTimetables?.add(
      WeekTimetable.fromTimetable(
        name: weekNames[_weekTimetables!.length + 1],
        timetable: this,
      ),
    );
    setCurrWeekTimetableIndex(0);
  }

  static Timetable placeholderName(String originalName) => Timetable(
        name: originalName,
        maxLessonCount: 0,
        schoolDays: [],
        schoolTimes: [],
        weekTimetables: null,
      );

  void removeWeekX(int index) {
    if (index < 0 || index > (_weekTimetables?.length ?? 0)) {
      return;
    }

    _weekTimetables?.removeAt(
      index,
    );

    if (_weekTimetables?.isEmpty ?? true) {
      _yearStartedWithWeekIndex = -1;
    }
  }

  int getCurrWeekTimetableIndex() {
    return getWeekTimetableIndexForDateTime(
      DateTime.now(),
    );
  }

  int getWeekTimetableIndexForDateTime(DateTime date) {
    if (_yearStartedWithWeekIndex == -1) {
      return -1;
    }

    //get first week index
    int currWeekIndex = Utils.getWeekIndex(
          date,
        ) -
        1;

    int correctedWeekIndex = (currWeekIndex + _yearStartedWithWeekIndex) %
        (weekTimetables.length + 1);

    return correctedWeekIndex;
  }

  void setCurrWeekTimetableIndex(int currWeekTimetableIndex) {
    //get first week index
    int currWeekIndex = Utils.getWeekIndex(
          DateTime.now(),
        ) -
        1;

    //wir gehen davon aus, dass _yearStartedWithWeekIndex = 0 ist um es dann später zu bestimmen
    int correctedIndex = (currWeekIndex + 0) % (weekTimetables.length + 1);

    if (currWeekTimetableIndex < correctedIndex) {
      _yearStartedWithWeekIndex = (weekTimetables.length + 1) -
          (currWeekTimetableIndex - correctedIndex).abs();
      return;
    }

    if (currWeekTimetableIndex > correctedIndex) {
      _yearStartedWithWeekIndex =
          (currWeekTimetableIndex - correctedIndex).abs();
      return;
    }

    //wenn schon beide indecies gleich sind wissen wir dass _yearStartedWithWeekIndex = 0 ist
    _yearStartedWithWeekIndex = 0;
  }

  Timetable getCurrWeekTimetable() {
    return getWeekTimetableForDateTime(
      DateTime.now(),
    );
  }

  Timetable getWeekTimetableForDateTime(DateTime date) {
    int index = getWeekTimetableIndexForDateTime(date);

    //wenn _yearStartedWithWeekIndex nicht gesetzt ist, dann ist index = -1
    if (index <= 0) {
      return this;
    }

    return weekTimetables[index - 1];
  }

  void setWeekTimetables(List<WeekTimetable>? weeks) {
    _weekTimetables = weeks;
  }
}
