import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

import 'grade_group.dart';

class SettingsVar<T> {
  String key;

  T? _value;
  T Function() defaultValue;

  T? Function(dynamic value)? loadCustomType;
  String Function(T type)? saveCustomType;

  //für settings die noch nicht gespeichert werden aber übersetzt werden müssen
  final bool _alwaysReturnDefaultValue;

  SettingsVar({
    required this.key,
    required this.defaultValue,
    this.loadCustomType,
    this.saveCustomType,
    T? value,
    bool alwaysReturnDefaultValue = false,
  })  : _value = value,
        _alwaysReturnDefaultValue = alwaysReturnDefaultValue;

  T get value {
    if (_alwaysReturnDefaultValue) {
      return defaultValue.call();
    }
    return _value ?? defaultValue.call();
  }

  set value(T value) {
    _value = value ?? defaultValue.call();
  }

  dynamic toNormalType() {
    try {
      return saveCustomType?.call(value) ?? value;
    } catch (e) {
      return value;
    }
  }

  void fromNormalType(dynamic type) {
    try {
      value = loadCustomType?.call(type) ?? type ?? defaultValue;
    } catch (e) {
      value = defaultValue.call();
    }
  }
}

class Settings {
  static const mainTimetableNameKey = "mainTimetable";
  static const mainSemesterNameKey = "mainSemester";
  static const defaultGradeGroupsKey = "defaultGradeGroups";
  static const showLessonNumbersKey = "showLessonNumbers";
  static const timetableLessonWidthKey = "timetableLessonWidth";
  static const openMainSemesterAutomaticallyKey =
      "openMainSemesterAutomatically";
  static const themeModeKey = "theme";
  static const languageCodeKey = "language";
  static const hiddenDebugModeKey = "hiddenDebugMode";
  static const selectedFederalStateCodeKey = "selectedFederalState";
  static const lastUsedVersionKey = "lastUsedVersion";
  static const customHolidaysKey = "customHolidays";

  static int decimalPlaces = 1;

  final List<SettingsVar> _variablesList = [
    ///if [null] firstTimetable shown
    SettingsVar<String?>(
      key: mainTimetableNameKey,
      defaultValue: () => null,
    ),
    SettingsVar<String?>(
      key: selectedFederalStateCodeKey,
      defaultValue: () => null,
    ),
    SettingsVar<String?>(
      key: mainSemesterNameKey,
      defaultValue: () => null,
    ),
    SettingsVar<String>(
      key: customHolidaysKey,
      defaultValue: () => "[]",
    ),
    SettingsVar<ThemeMode>(
      key: themeModeKey,
      defaultValue: () => ThemeMode.system,
      saveCustomType: (type) {
        return type.toString();
      },
      loadCustomType: (value) {
        if (value == ThemeMode.light.toString()) {
          return ThemeMode.light;
        }
        if (value == ThemeMode.system.toString()) {
          return ThemeMode.system;
        }
        if (value == ThemeMode.dark.toString()) {
          return ThemeMode.dark;
        }
        return null;
      },
    ),
    // SettingsVar<>(key: key, defaultValue: defaultValue,),
    //for now we only save the api key
    SettingsVar<String?>(
      key: languageCodeKey,
      defaultValue: () => null,
    ),
    SettingsVar<String?>(
      key: lastUsedVersionKey,
      defaultValue: () => null,
    ),
    SettingsVar<double>(
      key: timetableLessonWidthKey,
      defaultValue: () => 100,
    ),
    SettingsVar<bool>(
      key: showLessonNumbersKey,
      defaultValue: () => false,
    ),
    SettingsVar<bool>(
      key: openMainSemesterAutomaticallyKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: hiddenDebugModeKey,
      defaultValue: () => false,
    ),
    SettingsVar<List<GradeGroup>>(
      key: defaultGradeGroupsKey,
      defaultValue: () => _defaultGradeGroups,
      alwaysReturnDefaultValue: true,
    ),
  ];

  static List<GradeGroup> get _defaultGradeGroups {
    return [
      GradeGroup(
        name: AppLocalizationsManager.localizations.strWrittenAndVerbalGrades,
        percent: 67,
        grades: [],
      ),
      GradeGroup(
        name: AppLocalizationsManager.localizations.strExamGrades,
        percent: 33,
        grades: [],
      ),
    ];
  }

  final Map<String, SettingsVar> _variables = {};

  Settings() {
    _initVariables();
  }

  Settings.fromJson(Map<String, dynamic> json) {
    _initVariables();

    for (String key in _variables.keys) {
      final settingsVar = _variables[key];

      if (settingsVar == null) continue;

      if (!json.containsKey(key)) continue;

      settingsVar.fromNormalType(json[key]);
    }
  }

  void _initVariables() {
    for (SettingsVar settingsVar in _variablesList) {
      _variables[settingsVar.key] = settingsVar;
    }
  }

  T getVar<T>(String key) {
    if (_variables[key] == null) {
      throw Exception("$key does not exist in settings!");
    }
    return _variables[key]!.value;
  }

  bool setVar<T>(String key, T value) {
    if (_variables[key] == null) {
      return false;
    }
    _variables[key]!.value = value;

    SaveManager().saveSettings(this);

    return true;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    for (String key in _variables.keys) {
      SettingsVar? settingsVar = _variables[key];

      if (settingsVar == null) continue;

      json[key] = settingsVar.toNormalType();
    }

    return json;

    // List<Map<String, dynamic>>? defaultGradeGroupsJson =
    //     json[defaultGradeGroupsKey];

    // List<GradeGroup>? gradeGroups = defaultGradeGroupsJson == null
    //     ? null
    //     : List.generate(
    //         defaultGradeGroupsJson.length,
    //         (index) => GradeGroup.fromJson(
    //           defaultGradeGroupsJson[index],
    //         ),
    //       );

    // defaultGradeGroupsKey: _defaultGradeGroups != null
    //     ? List.generate(
    //         _defaultGradeGroups!.length,
    //         (index) => _defaultGradeGroups![index].toJson(),
    //       )
    //     : null,
  }
}
