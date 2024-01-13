import 'dart:ui';

import 'package:flutter/material.dart';

///Prefab welches in der Horizontalen Leiste über dem Stundenplan beim erstellen angezeigt wird
class SchoolLessonPrefab {
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
}
