// import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';

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

  static List<SchoolDay> defaultSchoolDays(int hoursCount) {
    // final lessons = List.generate(
    //   hoursCount,
    //   (index) => SchoolLesson(
    //     name: "-${index + 1}-",
    //     room: "---",
    //     teacher: "---",
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
        name: "Monday",
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: "---",
            teacher: "---",
            color: color,
            events: [],
          ),
        ),
      ),
      SchoolDay(
        name: "Tuesday",
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: "---",
            teacher: "---",
            color: color,
            events: [],
          ),
        ),
      ),
      SchoolDay(
        name: "Wednesday",
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: "---",
            teacher: "---",
            color: color,
            events: [],
          ),
        ),
      ),
      SchoolDay(
        name: "Thursday",
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: "---",
            teacher: "---",
            color: color,
            events: [],
          ),
        ),
      ),
      SchoolDay(
        name: "Friday",
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: "---",
            teacher: "---",
            color: color,
            events: [],
          ),
        ),
      ),
    ];
  }

  String _name;
  final int _maxLessonCount;
  final List<SchoolDay> _schoolDays;
  final List<SchoolTime> _schoolTimes;

  String get name => _name;
  int get maxLessonCount => _maxLessonCount;
  List<SchoolDay> get schoolDays => _schoolDays;
  List<SchoolTime> get schoolTimes => _schoolTimes;

  set name(String value) {
    value = value.trim();

    if (value.isEmpty) {
      throw Exception("Name can not be empty!");
    }
    if (value.length > maxNameLength) {
      throw Exception("Name is to long!");
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
      print(e);
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

  changeLessonNumberVisibility(bool isVisalbe) {
    if (isVisalbe) {
      Utils.changeLessonNumberToVisible(this);
    } else {
      Utils.changeLessonNumberToNonVisible(this);
    }
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
}
