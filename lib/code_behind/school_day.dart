import 'package:schulapp/code_behind/school_lesson.dart';

class SchoolDay {
  static const nameKey = "name";
  static const lessonsKey = "lessons";

  String _name;

  final List<SchoolLesson> _lessons;

  String get name => _name;
  List<SchoolLesson> get lessons => _lessons;

  set name(value) {
    _name = value;
  }

  SchoolDay({
    required String name,
    required List<SchoolLesson> lessons,
  })  : _name = name,
        _lessons = lessons;

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      lessonsKey: List<Map<String, dynamic>>.generate(
        lessons.length,
        (index) => lessons[index].toJson(),
      ),
    };
  }

  static SchoolDay fromJson(Map<String, dynamic> json) {
    String name = json[nameKey];
    List<Map<String, dynamic>> lsJson = (json[lessonsKey] as List).cast();
    List<SchoolLesson> ls = List.generate(
      lsJson.length,
      (index) => SchoolLesson.fromJson(lsJson[index]),
    );
    return SchoolDay(
      name: name,
      lessons: ls,
    );
  }
}
