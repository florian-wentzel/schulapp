import 'package:schulapp/code_behind/school_lesson.dart';

class SchoolDay {
  final String _name;

  final List<SchoolLesson> _lessons;

  String get name => _name;
  List<SchoolLesson> get lessons => _lessons;

  SchoolDay({
    required String name,
    required List<SchoolLesson> lessons,
  })  : _name = name,
        _lessons = lessons;
}
