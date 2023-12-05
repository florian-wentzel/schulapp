import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_event.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';

class SchoolLesson {
  final List<SchoolEvent> _events;
  String _name;
  String _room;
  String _teacher;
  final TimeOfDay _start;
  final TimeOfDay _end;
  Color _color;

  String get name => _name;
  String get room => _room;
  String get teacher => _teacher;
  Color get color => _color;
  TimeOfDay get start => _start;
  TimeOfDay get end => _end;
  // List<SchoolEvent> get events => _events;

  // void set name (String value){
  //   _name = value;
  //   save..
  // }

  SchoolLesson({
    required String name,
    required String room,
    required String teacher,
    required Color color,
    required TimeOfDay start,
    required TimeOfDay end,
    required List<SchoolEvent> events,
  })  : _name = name,
        _room = room,
        _teacher = teacher,
        _color = color,
        _start = start,
        _end = end,
        _events = events;

  void setFromPrefab(SchoolLessonPrefab prefab) {
    _name = prefab.name;
    _room = prefab.room;
    _teacher = prefab.teacher;
    _color = prefab.color;
  }
}
