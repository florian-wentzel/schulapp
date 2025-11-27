import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/extensions.dart';

class SchoolLesson {
  static const typeKey = "type";
  static const nameKey = "name";
  static const shortNameKey = "shortName";
  static const roomKey = "room";
  static const teacherKey = "teacher";
  static const colorKey = "color";

  static const maxNameLength = 30;
  static const maxShortNameLength = 3;
  static const maxShortWeekNameLength = 2;
  static const maxRoomLength = 20;
  static const maxTeacherLength = 15;

  static const String emptyLessonName = "---";

  String name;
  String shortName;
  String room;
  String teacher;
  Color color;

  SchoolLesson({
    required this.name,
    required this.shortName,
    required this.room,
    required this.teacher,
    required this.color,
  });

  static SchoolLesson fromPrefab(SchoolLessonPrefab prefab) {
    return SchoolLesson(
      name: prefab.name,
      shortName: prefab.shortName,
      room: prefab.room,
      teacher: prefab.teacher,
      color: prefab.color.withRed(prefab.color.red),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      if (shortName.isNotEmpty) shortNameKey: shortName,
      roomKey: room,
      teacherKey: teacher,
      colorKey: color.toJson(),
    };
  }

  ///saves name and room for "freistunden" wird nicht von
  ///[EmptySchoolLesson] überschrieben
  Map<String, dynamic> toJsonOld() {
    return {
      nameKey: name,
      roomKey: room,
      teacherKey: teacher,
      colorKey: color.toJson(),
    };
  }

  static SchoolLesson fromJson(Map<String, dynamic> json, int lessonIndex) {
    String? type = json[typeKey];

    String n = json[nameKey] ?? "";
    String s = json[shortNameKey] ?? "";
    String t = json[teacherKey] ?? "";
    String r = json[roomKey] ?? "";
    Color c = ColorExtension.fromJson(json[colorKey]);

    if (type != null) {
      if (type == EmptySchoolLesson.type) {
        return EmptySchoolLesson(
          lessonIndex: lessonIndex,
        );
      }
    } else if (n == SchoolLesson.emptyLessonName ||
        (n.startsWith("-") && n.endsWith("-"))) {
      //old version but is empty lesson
      return EmptySchoolLesson(
        lessonIndex: lessonIndex,
      );
    }

    return SchoolLesson(
      name: n,
      shortName: s,
      teacher: t,
      room: r,
      color: c,
    );
  }

  static bool isEmptyLesson(SchoolLesson lesson) {
    return lesson is EmptySchoolLesson;
  }

  SchoolLesson clone() {
    return SchoolLesson(
      name: name,
      shortName: shortName,
      room: room,
      teacher: teacher,
      color: color.withRed(color.red),
    );
  }
}

class EmptySchoolLesson extends SchoolLesson {
  static const String type = "EmptySchoolLesson";
  int lessonIndex = -1;

  EmptySchoolLesson({
    required this.lessonIndex,
  }) : super(
          name: "",
          shortName: "",
          room: "",
          teacher: "",
          color: Colors.transparent,
        );

  @override
  String get name {
    final showLessonNumbers = TimetableManager().settings.getVar<bool>(
          Settings.showLessonNumbersKey,
        );

    if (showLessonNumbers) {
      return "-${lessonIndex + 1}-";
    }
    return SchoolLesson.emptyLessonName;
  }

  @override
  String get room => "";

  @override
  Color get color => Colors.transparent;

  @override
  String get teacher => "";

  @override
  Map<String, dynamic> toJson() {
    return {
      SchoolLesson.typeKey: type,
    };
  }

  @override
  SchoolLesson clone() {
    return EmptySchoolLesson(
      lessonIndex: lessonIndex,
    );
  }
}
