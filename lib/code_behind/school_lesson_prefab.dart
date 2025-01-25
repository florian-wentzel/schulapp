import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schulapp/extensions.dart';

///Prefab welches in der Horizontalen Leiste über dem Stundenplan beim erstellen angezeigt wird
class SchoolLessonPrefab {
  static const String _nameKey = "name";
  static const String _roomKey = "room";
  static const String _teacherKey = "teacher";
  static const String _colorKey = "color";

  final String _name;
  final String _room;
  final String _teacher;
  final Color _color;

  String get name => _name;
  String get room => _room;
  String get teacher => _teacher;
  Color get color => _color;

  SchoolLessonPrefab({
    required String name,
    required String room,
    required String teacher,
    required Color color,
  })  : _name = name,
        _room = room,
        _teacher = teacher,
        _color = color;

  Map<String, dynamic> toJson() {
    return {
      _nameKey: _name,
      _roomKey: _room,
      _teacherKey: _teacher,
      _colorKey: _color.toJson(),
    };
  }

  static SchoolLessonPrefab? fromJson(Map<String, dynamic> json) {
    try {
      return SchoolLessonPrefab(
        name: json[_nameKey],
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
      room: _room,
      teacher: _teacher,
      color: _color.withValues(),
    );
  }
}
