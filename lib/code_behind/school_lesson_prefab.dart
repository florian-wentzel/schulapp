import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

///Prefab welches in der Horizontalen Leiste über dem Stundenplan beim erstellen angezeigt wird
class SchoolLessonPrefab {
  static const String _nameKey = "name";
  static const String _shortNameKey = "shortName";
  static const String _roomKey = "room";
  static const String _teacherKey = "teacher";
  static const String _colorKey = "color";
  static const String _localizationKeyKey = "localizationKey";

  final String _name;
  final String _shortName;
  final String? _localizationKey;
  String room;
  final String _teacher;
  Color color;

  String get name {
    if (_localizationKey != null) {
      try {
        // Use reflection-like access to get the localized string
        final localizations = AppLocalizationsManager.localizations;
        switch (_localizationKey) {
          case 'subject_Altgriechisch':
            return localizations.subject_Altgriechisch;
          case 'subject_Astronomie':
            return localizations.subject_Astronomie;
          case 'subject_Biologie':
            return localizations.subject_Biologie;
          case 'subject_Chemie':
            return localizations.subject_Chemie;
          case 'subject_Chinesisch':
            return localizations.subject_Chinesisch;
          case 'subject_Deutsch':
            return localizations.subject_Deutsch;
          case 'subject_DtGebardensprache':
            return localizations.subject_DtGebardensprache;
          case 'subject_Englisch':
            return localizations.subject_Englisch;
          case 'subject_Ethik':
            return localizations.subject_Ethik;
          case 'subject_Franzosisch':
            return localizations.subject_Franzosisch;
          case 'subject_Geographie':
            return localizations.subject_Geographie;
          case 'subject_Erdkunde':
            return localizations.subject_Erdkunde;
          case 'subject_Geschichte':
            return localizations.subject_Geschichte;
          case 'subject_Sozialkunde':
            return localizations.subject_Sozialkunde;
          case 'subject_Sozialpadagogik':
            return localizations.subject_Sozialpadagogik;
          case 'subject_Sozialwissenschaften':
            return localizations.subject_Sozialwissenschaften;
          case 'subject_Hebraisch':
            return localizations.subject_Hebraisch;
          case 'subject_Informatik':
            return localizations.subject_Informatik;
          case 'subject_Italienisch':
            return localizations.subject_Italienisch;
          case 'subject_Japanisch':
            return localizations.subject_Japanisch;
          case 'subject_Kunst':
            return localizations.subject_Kunst;
          case 'subject_Latein':
            return localizations.subject_Latein;
          case 'subject_LER':
            return localizations.subject_LER;
          case 'subject_Mathematik':
            return localizations.subject_Mathematik;
          case 'subject_Musik':
            return localizations.subject_Musik;
          case 'subject_Naturwissenschaften':
            return localizations.subject_Naturwissenschaften;
          case 'subject_Neugriechisch':
            return localizations.subject_Neugriechisch;
          case 'subject_Philosophie':
            return localizations.subject_Philosophie;
          case 'subject_Physik':
            return localizations.subject_Physik;
          case 'subject_PolitischeBildung':
            return localizations.subject_PolitischeBildung;
          case 'subject_Polnisch':
            return localizations.subject_Polnisch;
          case 'subject_Portugiesisch':
            return localizations.subject_Portugiesisch;
          case 'subject_Psychologie':
            return localizations.subject_Psychologie;
          case 'subject_Russisch':
            return localizations.subject_Russisch;
          case 'subject_Sachunterricht':
            return localizations.subject_Sachunterricht;
          case 'subject_SorbischWendisch':
            return localizations.subject_SorbischWendisch;
          case 'subject_SozWirtschaftswissenschaften':
            return localizations.subject_SozWirtschaftswissenschaften;
          case 'subject_Wirtschaftskunde':
            return localizations.subject_Wirtschaftskunde;
          case 'subject_Spanisch':
            return localizations.subject_Spanisch;
          case 'subject_Sport':
            return localizations.subject_Sport;
          case 'subject_Theater':
            return localizations.subject_Theater;
          case 'subject_Turkisch':
            return localizations.subject_Turkisch;
          case 'subject_WAT':
            return localizations.subject_WAT;
          case 'subject_DarstellendesSpiel':
            return localizations.subject_DarstellendesSpiel;
          case 'subject_Politikwissenschaft':
            return localizations.subject_Politikwissenschaft;
          case 'subject_Recht':
            return localizations.subject_Recht;
          case 'subject_Relogion':
            return localizations.subject_Relogion;
          case 'subject_Werken':
            return localizations.subject_Werken;
          case 'subject_Weltkunde':
            return localizations.subject_Weltkunde;
          case 'subject_Gesellschaftswissenschaften':
            return localizations.subject_Gesellschaftswissenschaften;
          case 'subject_Literatur':
            return localizations.subject_Literatur;
          case 'subject_Astrophysik':
            return localizations.subject_Astrophysik;
          case 'subject_Staatsburgerkunde':
            return localizations.subject_Staatsburgerkunde;
          case 'subject_Hauswirtschaft':
            return localizations.subject_Hauswirtschaft;
          case 'subject_TechnikWerken':
            return localizations.subject_TechnikWerken;
          case 'subject_IslamischeReligion':
            return localizations.subject_IslamischeReligion;
          case 'subject_EvangelischeReligion':
            return localizations.subject_EvangelischeReligion;
          case 'subject_KatholischeReligion':
            return localizations.subject_KatholischeReligion;
          case 'subject_Medien':
            return localizations.subject_Medien;
          case 'subject_Niederlandisch':
            return localizations.subject_Niederlandisch;
          case 'subject_OrthodoxeReligion':
            return localizations.subject_OrthodoxeReligion;
          default:
            return _name;
        }
      } catch (e) {
        return _name;
      }
    }
    return _name;
  }

  String get shortName {
    final currentName = name;
    if (_shortName.isEmpty) {
      if (currentName.length > SchoolLesson.maxShortNameLength) {
        return currentName.substring(0, SchoolLesson.maxShortNameLength);
      } else {
        return currentName;
      }
    }

    return _shortName;
  }

  String get teacher => _teacher;

  SchoolLessonPrefab.fromSchoolLesson({
    required SchoolLesson lesson,
  })  : _name = lesson.name,
        _shortName = lesson.shortName,
        _localizationKey = null,
        room = lesson.room,
        _teacher = lesson.teacher,
        color = lesson.color;

  SchoolLessonPrefab({
    required String name,
    this.room = "",
    String shortName = "",
    String teacher = "",
    required this.color,
    String? localizationKey,
  })  : _name = name,
        _shortName = shortName,
        _localizationKey = localizationKey,
        _teacher = teacher;

  Map<String, dynamic> toJson() {
    return {
      _nameKey: _name,
      if (_shortName.isNotEmpty) _shortNameKey: _shortName,
      if (_localizationKey != null) _localizationKeyKey: _localizationKey,
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
        localizationKey: json[_localizationKeyKey],
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
      localizationKey: _localizationKey,
      room: room,
      teacher: _teacher,
      color: color.withValues(),
    );
  }

  List<SchoolLessonPrefab> get allLessonPrefabs {
    return [];
  }
}
