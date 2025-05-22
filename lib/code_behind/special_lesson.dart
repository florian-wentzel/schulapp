import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/extensions.dart';

abstract class SpecialLesson {
  static const typeKey = "type";

  static const nameKey = "name";
  static const roomKey = "room";
  static const teacherKey = "teacher";
  static const colorKey = "color";
  static const dayIndexKey = "dayIndex";
  static const timeIndexKey = "timeIndex";

  final String _name;
  final String _room;
  final String _teacher;
  final Color _color;
  //which week day..
  final int _dayIndex;
  //which lesson..
  final int _timeIndex;

  String get name => _name;
  String get room => _room;
  String get teacher => _teacher;
  Color get color => _color;

  int get dayIndex => _dayIndex;
  int get timeIndex => _timeIndex;

  SpecialLesson({
    required String name,
    required String room,
    required String teacher,
    required Color color,
    required int dayIndex,
    required int timeIndex,
  })  : _name = name,
        _room = room,
        _teacher = teacher,
        _color = color,
        _dayIndex = dayIndex,
        _timeIndex = timeIndex;

  static void sortSpecialLessons(List<SpecialLesson> specialLessons) {
    specialLessons.sort((a, b) {
      int dayDiff = a.dayIndex - b.dayIndex;
      if (dayDiff == 0) {
        int timeDiff = a.timeIndex - b.timeIndex;
        return timeDiff;
      }
      return dayDiff;
    });
  }

  Map<String, dynamic> toJson();
}

class SickSpecialLesson extends SpecialLesson {
  static const type = "Sick";

  SickSpecialLesson({
    required super.dayIndex,
    required super.timeIndex,
  }) : super(
          name: "",
          room: "",
          teacher: "",
          color: Colors.black,
        );

  @override
  Map<String, dynamic> toJson() {
    final map = {
      SpecialLesson.typeKey: type,
      SpecialLesson.dayIndexKey: _dayIndex,
      SpecialLesson.timeIndexKey: _timeIndex,
    };

    return map;
  }

  static SpecialLesson fromJson(Map<String, dynamic> json) {
    final dayIndex = json[SpecialLesson.dayIndexKey];
    final timeIndex = json[SpecialLesson.timeIndexKey];

    return SickSpecialLesson(
      dayIndex: dayIndex,
      timeIndex: timeIndex,
    );
  }
}

class CancelledSpecialLesson extends SpecialLesson {
  static const type = "Cancelled";

  CancelledSpecialLesson({
    required super.dayIndex,
    required super.timeIndex,
  }) : super(
          name: "",
          room: "",
          teacher: "",
          color: Colors.black,
        );

  @override
  Map<String, dynamic> toJson() {
    final map = {
      SpecialLesson.typeKey: type,
      SpecialLesson.dayIndexKey: _dayIndex,
      SpecialLesson.timeIndexKey: _timeIndex,
    };

    return map;
  }

  static SpecialLesson fromJson(Map<String, dynamic> json) {
    final dayIndex = json[SpecialLesson.dayIndexKey];
    final timeIndex = json[SpecialLesson.timeIndexKey];

    return CancelledSpecialLesson(
      dayIndex: dayIndex,
      timeIndex: timeIndex,
    );
  }
}

class SubstituteSpecialLesson extends SpecialLesson {
  static const type = "Substitute";

  SubstituteSpecialLesson({
    required super.dayIndex,
    required super.timeIndex,
    required SchoolLessonPrefab prefab,
  }) : super(
          name: prefab.name,
          room: prefab.room,
          teacher: prefab.teacher,
          color: prefab.color,
        );

  @override
  Map<String, dynamic> toJson() {
    final map = {
      SpecialLesson.typeKey: type,
      SpecialLesson.dayIndexKey: _dayIndex,
      SpecialLesson.timeIndexKey: _timeIndex,
      SpecialLesson.nameKey: _name,
      SpecialLesson.roomKey: _room,
      SpecialLesson.teacherKey: _teacher,
      SpecialLesson.colorKey: _color.toJson(),
    };

    return map;
  }

  static SpecialLesson fromJson(Map<String, dynamic> json) {
    final dayIndex = json[SpecialLesson.dayIndexKey];
    final timeIndex = json[SpecialLesson.timeIndexKey];
    final name = json[SpecialLesson.nameKey];
    final room = json[SpecialLesson.roomKey];
    final teacher = json[SpecialLesson.teacherKey];
    final color = ColorExtension.fromJson(json[SpecialLesson.colorKey]);

    return SubstituteSpecialLesson(
      dayIndex: dayIndex,
      timeIndex: timeIndex,
      prefab: SchoolLessonPrefab(
        name: name,
        room: room,
        teacher: teacher,
        color: color,
      ),
    );
  }
}
