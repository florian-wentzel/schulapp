import 'package:schulapp/code_behind/school_day.dart';

class TimeTable {
  static List<SchoolDay> defaultSchoolDays = [
    SchoolDay(name: "Monday", lessons: []),
    SchoolDay(name: "Tuesday", lessons: []),
    SchoolDay(name: "Wednesday", lessons: []),
    SchoolDay(name: "Thursday", lessons: []),
    SchoolDay(name: "Friday", lessons: []),
  ];

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
