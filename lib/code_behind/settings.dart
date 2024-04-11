import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/federal_state.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

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

  static int decimalPlaces = 1;

  ///if [null] firstTimetable shown
  String? _mainTimetableName;
  //for now we only save the api key
  String? _selectedFederalStateCode;
  String? _mainSemesterName;
  String? _themeMode;
  String? _languageCode;
  double? _timetableLessonWidth;
  bool? _showLessonNumbers;
  bool? _openMainSemesterAutomatically;
  bool? _hiddenDebugMode;

  ThemeMode get themeMode {
    if (_themeMode == ThemeMode.dark.toString()) {
      return ThemeMode.dark;
    }
    if (_themeMode == ThemeMode.light.toString()) {
      return ThemeMode.light;
    }
    // if (_themeMode == ThemeMode.system.toString()) {
    //   return ThemeMode.system;
    // } kann man weglassen
    return ThemeMode.system;
  }

  set themeMode(ThemeMode mode) {
    _themeMode = mode.toString();
    SaveManager().saveSettings(this);
  }

  String? get languageCode {
    return _languageCode;
  }

  set languageCode(String? languageCode) {
    _languageCode = languageCode;
    SaveManager().saveSettings(this);
  }

  bool get showLessonNumbers {
    return _showLessonNumbers ?? false;
  }

  set showLessonNumbers(bool? value) {
    _showLessonNumbers = value;
    SaveManager().saveSettings(this);
  }

  bool get hiddenDebugMode {
    return _hiddenDebugMode ?? false;
  }

  set hiddenDebugMode(bool? value) {
    _hiddenDebugMode = value;
    SaveManager().saveSettings(this);
  }

  bool get openMainSemesterAutomatically {
    return _openMainSemesterAutomatically ?? true;
  }

  set openMainSemesterAutomatically(bool? value) {
    _openMainSemesterAutomatically = value;
    SaveManager().saveSettings(this);
  }

  double get timetableLessonWidth {
    const double defaultValue = 100;

    _timetableLessonWidth ??= defaultValue;

    return _timetableLessonWidth!;
  }

  set timetableLessonWidth(double? width) {
    _timetableLessonWidth = width;
    SaveManager().saveSettings(this);
  }

  String? get mainSemesterName {
    return _mainSemesterName;
  }

  set mainSemesterName(String? value) {
    _mainSemesterName = value;
    SaveManager().saveSettings(this);
  }

  String? get selectedFederalStateCode {
    return _selectedFederalStateCode;
  }

  void setSelectedFederalStateCode(FederalState? state) {
    _selectedFederalStateCode = state?.apiCode;
    SaveManager().saveSettings(this);
  }

  String? get mainTimetableName {
    return _mainTimetableName;
  }

  set mainTimetableName(String? value) {
    _mainTimetableName = value;
    SaveManager().saveSettings(this);
  }

  List<GradeGroup> get defaultGradeGroups {
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

  Settings({
    String? mainTimetableName,
    String? mainSemesterName,
    String? selectedFederalState,
    String? themeMode,
    String? languageCode,
    double? timetableLessonWidth,
    bool? showLessonNumbers,
    bool? openMainSemesterAutomatically,
    bool? hiddenDebugMode,
  })  : _mainTimetableName = mainTimetableName,
        _mainSemesterName = mainSemesterName,
        _selectedFederalStateCode = selectedFederalState,
        _themeMode = themeMode,
        _languageCode = languageCode,
        _timetableLessonWidth = timetableLessonWidth,
        _showLessonNumbers = showLessonNumbers,
        _openMainSemesterAutomatically = openMainSemesterAutomatically,
        _hiddenDebugMode = hiddenDebugMode;

  Map<String, dynamic> toJson() {
    return {
      mainTimetableNameKey: _mainTimetableName,
      mainSemesterNameKey: _mainSemesterName,
      selectedFederalStateCodeKey: _selectedFederalStateCode,
      themeModeKey: _themeMode,
      languageCodeKey: _languageCode,
      showLessonNumbersKey: _showLessonNumbers,
      timetableLessonWidthKey: _timetableLessonWidth,
      openMainSemesterAutomaticallyKey: _openMainSemesterAutomatically,
      hiddenDebugModeKey: _hiddenDebugMode,
      // defaultGradeGroupsKey: _defaultGradeGroups != null
      //     ? List.generate(
      //         _defaultGradeGroups!.length,
      //         (index) => _defaultGradeGroups![index].toJson(),
      //       )
      //     : null,
    };
  }

  static Settings fromJson(Map<String, dynamic> json) {
    String? mainTimetableName = json[mainTimetableNameKey];
    String? mainSemesterName = json[mainSemesterNameKey];
    String? selectedFederalState = json[selectedFederalStateCodeKey];
    String? themeMode = json[themeModeKey];
    String? languageCode = json[languageCodeKey];
    double? timetableLessonWidth = json[timetableLessonWidthKey];
    bool? showLessonNumbers = json[showLessonNumbersKey];
    bool? openMainSemesterAutomatically =
        json[openMainSemesterAutomaticallyKey];
    bool? hiddenDebugMode = json[hiddenDebugModeKey];
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

    return Settings(
      mainTimetableName: mainTimetableName,
      mainSemesterName: mainSemesterName,
      selectedFederalState: selectedFederalState,
      themeMode: themeMode,
      languageCode: languageCode,
      timetableLessonWidth: timetableLessonWidth,
      showLessonNumbers: showLessonNumbers,
      openMainSemesterAutomatically: openMainSemesterAutomatically,
      hiddenDebugMode: hiddenDebugMode,
      // defaultGradeGroups: gradeGroups,
    );
  }
}
