// import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/extensions.dart';

class TimeTable {
  static List<SchoolDay> defaultSchoolDays(int hoursCount) {
    const startTime = TimeOfDay(hour: 7, minute: 45);

    // final lessons = List.generate(
    //   hoursCount,
    //   (index) => SchoolLesson(
    //     name: "-${index + 1}-",
    //     room: "---",
    //     teacher: "---",
    //     color: const Color.fromARGB(255, 127, 127, 127),
    //     start: startTime.add(minutes: index * 45),
    //     end: startTime.add(minutes: 45 + index * 45),
    //     events: [],
    //   ),
    // );

    //Ursprünglich hatte ich die eine Liste erstellt und wollte dann mit List.from(lessons) eine copy erstellen
    //aber das hat nicht funktioniert es gab dann den bug das sich alle Tage die gleichen Stunden geteilt haben.
    //Deswegen werden die Listen jetzt einzeln erstellt...
    return [
      SchoolDay(
        name: "Monday",
        lessons: List.generate(
          hoursCount,
          (index) => SchoolLesson(
            name: "-${index + 1}-",
            room: "---",
            teacher: "---",
            color: const Color.fromARGB(255, 127, 127, 127),
            start: startTime.add(minutes: index * 45),
            end: startTime.add(minutes: 45 + index * 45),
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
            color: const Color.fromARGB(255, 127, 127, 127),
            start: startTime.add(minutes: index * 45),
            end: startTime.add(minutes: 45 + index * 45),
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
            color: const Color.fromARGB(255, 127, 127, 127),
            start: startTime.add(minutes: index * 45),
            end: startTime.add(minutes: 45 + index * 45),
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
            color: const Color.fromARGB(255, 127, 127, 127),
            start: startTime.add(minutes: index * 45),
            end: startTime.add(minutes: 45 + index * 45),
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
            color: const Color.fromARGB(255, 127, 127, 127),
            start: startTime.add(minutes: index * 45),
            end: startTime.add(minutes: 45 + index * 45),
            events: [],
          ),
        ),
      ),
    ];
  }

  final String _name;
  final int _maxLessonCount;
  final List<SchoolDay> _schoolDays;

  String get name => _name;
  int get maxLessonCount => _maxLessonCount;
  List<SchoolDay> get schoolDays => _schoolDays;

  TimeTable({
    required String name,
    required int maxLessonCount,
    required List<SchoolDay> schoolDays,
  })  : _name = name,
        _maxLessonCount = maxLessonCount,
        _schoolDays = schoolDays;
}
