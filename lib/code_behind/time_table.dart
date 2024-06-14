// import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class Timetable {
  static const maxNameLength = 15;
  static const minMaxLessonCount = 5;
  static const maxMaxLessonCount = 12;

  static const nameKey = "name";
  static const maxLessonCountKey = "maxLessonCount";
  static const schoolDaysKey = "days";
  static const schoolTimesKey = "times";

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

  static final List<String> weekNames = [
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
    const color = Colors.transparent;

    return [
      SchoolDay(
        name: AppLocalizationsManager.localizations.strMonday,
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: SchoolLesson.emptyLessonName,
            teacher: SchoolLesson.emptyLessonName,
            color: color,
          ),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strTuesday,
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: SchoolLesson.emptyLessonName,
            teacher: SchoolLesson.emptyLessonName,
            color: color,
          ),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strWednesday,
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: SchoolLesson.emptyLessonName,
            teacher: SchoolLesson.emptyLessonName,
            color: color,
          ),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strThursday,
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: SchoolLesson.emptyLessonName,
            teacher: SchoolLesson.emptyLessonName,
            color: color,
          ),
        ),
      ),
      SchoolDay(
        name: AppLocalizationsManager.localizations.strFriday,
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: SchoolLesson.emptyLessonName,
            teacher: SchoolLesson.emptyLessonName,
            color: color,
          ),
        ),
      ),
    ];
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
  })  : _name = name,
        _maxLessonCount = maxLessonCount,
        _schoolDays = schoolDays,
        _schoolTimes = schoolTimes;

  void changeLessonNumberVisibility(bool isVisalbe) {
    if (isVisalbe) {
      Utils.changeLessonNumberToVisible(this);
    } else {
      Utils.changeLessonNumberToNonVisible(this);
    }
  }

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

  SchoolTime? getCurrentLessonOrBreakTime() {
    final timeBeforeFirstLessonStartInt =
        const TimeOfDay(hour: 0, minute: 10).toSeconds();

    final int nowInt = Utils.nowInSeconds();
    final int firstInt = _schoolTimes.first.start.toSeconds();
    final int lastInt = _schoolTimes.last.end.toSeconds();

    //TODO: wenn firstDouble = 0 dann kommt bestimm nur trash bei raus
    if (nowInt < firstInt - timeBeforeFirstLessonStartInt || nowInt > lastInt) {
      return null;
    }

    SchoolTime? currTime;

    for (int i = _schoolTimes.length - 1; i >= 0; i--) {
      SchoolTime time = _schoolTimes[i];
      if (nowInt > time.end.toSeconds()) {
        continue;
      }
      currTime = time;
      if (nowInt > time.start.toSeconds()) {
        continue;
      }
      if (i - 1 < 0) continue;

      currTime = SchoolTime(
        start: _schoolTimes[i - 1].end,
        end: time.start,
      );
    }

    return currTime;
  }

  SchoolTime? getCurrentlyRunningLesson() {
    for (var time in _schoolTimes) {
      if (time.isCurrentlyRunning()) {
        return time;
      }
    }
    return null;
  }

  static Timetable? fromJson(Map<String, dynamic> json) {
    Timetable? timetable;
    try {
      String n = json[nameKey];
      int mlc = json[maxLessonCountKey]; //maxLessonCount
      List<Map<String, dynamic>> ds = (json[schoolDaysKey] as List).cast();
      List<Map<String, dynamic>> ts = (json[schoolTimesKey] as List).cast();

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
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return timetable;
  }

  Map<String, dynamic> toJson() {
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
    };
  }

  void translateDayNames() {
    List<SchoolDay> defaultSchoolDays = Timetable.defaultSchoolDays(0);
    for (int i = 0; i < defaultSchoolDays.length; i++) {
      if (i >= _schoolDays.length) continue;

      _schoolDays[i].name = defaultSchoolDays[i].name;
    }
    SaveManager().saveTimeTable(this);
  }

  Timetable copy() {
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
}
