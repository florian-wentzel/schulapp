import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/utils.dart';

class SchoolLesson {
  static const nameKey = "name";
  static const roomKey = "room";
  static const teacherKey = "teacher";
  static const colorKey = "color";
  // static const eventsKey = "events(coming soon)";

  static const maxNameLength = 10;
  static const maxRoomLength = 10;

  static const String emptyLessonName = "---";

  static SchoolLesson get defaultSchoolLesson {
    return SchoolLesson(
      name: emptyLessonName,
      room: emptyLessonName,
      teacher: emptyLessonName,
      color: Colors.transparent,
      // events: [],
    );
  }

  // final List<TodoEvent> _events;
  String _name;
  String _room;
  String _teacher;
  Color _color;

  String get name => _name;
  String get room => _room;
  String get teacher => _teacher;
  Color get color => _color;
  // List<SchoolEvent> get events => _events;

  set name(String value) {
    //darf gesetzt werden? also gucken ob zu lang etc
    _name = value;
    // TODO: save..
  }

  set room(String value) {
    //darf gesetzt werden? also gucken ob zu lang etc
    _room = value;
    // TODO: save..
  }

  set teacher(String value) {
    //darf gesetzt werden? also gucken ob zu lang etc
    _teacher = value;
    // TODO: save..
  }

  set color(Color value) {
    //darf gesetzt werden? also gucken ob zu lang etc
    _color = value;
    // TODO: save..
  }

  SchoolLesson({
    required String name,
    required String room,
    required String teacher,
    required Color color,
    // required List<SchoolEvent> events,
  })  : _name = name,
        _room = room,
        _teacher = teacher,
        _color = color;
  // _events = events;

  void setFromPrefab(SchoolLessonPrefab prefab) {
    _name = prefab.name;
    _room = prefab.room;
    _teacher = prefab.teacher;
    _color = prefab.color; //TODO: vielleicht Fehler weil keine Kopie
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: _name,
      roomKey: _room,
      teacherKey: _teacher,
      colorKey: Utils.colorToJson(_color),
      // eventsKey: _events,
    };
  }

  static SchoolLesson fromJson(Map<String, dynamic> json) {
    String n = json[nameKey];
    String t = json[teacherKey];
    String r = json[roomKey];
    Color c = Utils.jsonToColor(json[colorKey]);
    return SchoolLesson(
      name: n,
      teacher: t,
      room: r,
      color: c,
      // events: [],
    );
  }
}
