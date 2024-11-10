import 'dart:collection';

import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';

class SchoolDay {
  static const nameKey = "name";
  static const lessonsKey = "lessons";

  String _name;

  final List<SchoolLesson> _lessons;

  String get name => _name;
  UnmodifiableListView<SchoolLesson> get lessons => UnmodifiableListView(
        _lessons,
      );

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

  ///saves name and room for "freistunden"
  Map<String, dynamic> toJsonOld() {
    return {
      nameKey: name,
      lessonsKey: List<Map<String, dynamic>>.generate(
        lessons.length,
        (index) => lessons[index].toJsonOld(),
      ),
    };
  }

  static SchoolDay fromJson(Map<String, dynamic> json) {
    String name = json[nameKey];
    List<Map<String, dynamic>> lsJson = (json[lessonsKey] as List).cast();
    List<SchoolLesson> ls = List.generate(
      lsJson.length,
      (index) => SchoolLesson.fromJson(
        lsJson[index],
        index,
      ),
    );
    return SchoolDay(
      name: name,
      lessons: ls,
    );
  }

  SchoolDay clone() {
    return SchoolDay(
      name: name,
      lessons: List.generate(
        lessons.length,
        (index) => lessons[index].clone(),
      ),
    );
  }

  void addLesson() {
    _lessons.add(
      EmptySchoolLesson(lessonIndex: _lessons.length),
    );
  }

  void removeLesson() {
    _lessons.removeLast();
  }

  ///if prefab is null lesson gets replaced with [EmptySchoolLesson]
  void setLessonFromPrefab(int lessonIndex, SchoolLessonPrefab? prefab) {
    if (prefab == null) {
      _lessons[lessonIndex] = EmptySchoolLesson(lessonIndex: lessonIndex);
      return;
    }
    _lessons[lessonIndex] = SchoolLesson.fromPrefab(prefab);
  }
}
