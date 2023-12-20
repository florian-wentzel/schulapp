// import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/extensions.dart';

class TimeTable {
  static List<SchoolTime> defaultSchoolTimes(int hoursCount) {
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

  final String _name;
  final int _maxLessonCount;
  final List<SchoolDay> _schoolDays;
  final List<SchoolTime> _schoolTimes;

  String get name => _name;
  int get maxLessonCount => _maxLessonCount;
  List<SchoolDay> get schoolDays => _schoolDays;
  List<SchoolTime> get schoolTimes => _schoolTimes;

  TimeTable({
    required String name,
    required int maxLessonCount,
    required List<SchoolDay> schoolDays,
    required List<SchoolTime> schoolTimes,
  })  : _name = name,
        _maxLessonCount = maxLessonCount,
        _schoolDays = schoolDays,
        _schoolTimes = schoolTimes;
}
