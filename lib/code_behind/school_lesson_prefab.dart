import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/extensions.dart';

///Prefab welches in der Horizontalen Leiste über dem Stundenplan beim erstellen angezeigt wird
class SchoolLessonPrefab {
  static const String _nameKey = "name";
  static const String _shortNameKey = "shortName";
  static const String _roomKey = "room";
  static const String _teacherKey = "teacher";
  static const String _colorKey = "color";

  final String _name;
  final String _shortName;
  String room;
  final String _teacher;
  Color color;

  String get name => _name;
  String get shortName {
    if (_shortName.isEmpty) {
      if (_name.length > SchoolLesson.maxShortNameLength) {
        return _name.substring(0, SchoolLesson.maxShortNameLength);
      } else {
        return _name;
      }
    }

    return _shortName;
  }

  String get teacher => _teacher;

  SchoolLessonPrefab.fromSchoolLesson({
    required SchoolLesson lesson,
  })  : _name = lesson.name,
        _shortName = lesson.shortName,
        room = lesson.room,
        _teacher = lesson.teacher,
        color = lesson.color;

  SchoolLessonPrefab({
    required String name,
    this.room = "",
    String shortName = "",
    String teacher = "",
    required this.color,
  })  : _name = name,
        _shortName = shortName,
        _teacher = teacher;

  Map<String, dynamic> toJson() {
    return {
      _nameKey: _name,
      if (_shortName.isNotEmpty) _shortNameKey: _shortName,
      _roomKey: room,
      _teacherKey: _teacher,
      _colorKey: color.toJson(),
    };
  }

  static SchoolLessonPrefab? fromJson(Map<String, dynamic> json) {
    try {
      return SchoolLessonPrefab(
        name: json[_nameKey],
        shortName: json[_shortNameKey] ?? "",
        room: json[_roomKey],
        teacher: json[_teacherKey],
        color: ColorExtension.fromJson(json[_colorKey]),
      );
    } catch (e) {
      return null;
    }
  }

  SchoolLessonPrefab copy() {
    return SchoolLessonPrefab(
      name: _name,
      shortName: _shortName,
      room: room,
      teacher: _teacher,
      color: color.withValues(),
    );
  }

  List<SchoolLessonPrefab> get allLessonPrefabs {
    return [];
  }
}
