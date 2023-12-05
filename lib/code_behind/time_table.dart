import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/extensions.dart';

class TimeTable {
  static List<SchoolDay> defaultSchoolDays(int hoursCount) {
    const startTime = TimeOfDay(hour: 7, minute: 45);

    final lessons = List.generate(
      hoursCount,
      (index) => SchoolLesson(
        name: "---",
        room: "---",
        teacher: "---",
        color: const Color.fromARGB(255, 127, 127, 127),
        start: startTime.add(minutes: index * 45),
        end: startTime.add(minutes: 45 + index * 45),
        events: [],
      ),
    );
    return [
      SchoolDay(name: "Monday", lessons: lessons),
      SchoolDay(name: "Tuesday", lessons: lessons),
      SchoolDay(name: "Wednesday", lessons: lessons),
      SchoolDay(name: "Thursday", lessons: lessons),
      SchoolDay(name: "Friday", lessons: lessons),
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
