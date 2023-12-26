import 'package:schulapp/code_behind/timetable_saver.dart';

class Settings {
  static const mainTimetableNameKey = "mainTimetable";

  ///if [null] firstTimetable shown
  String? _mainTimetableName;

  String? get mainTimetableName {
    return _mainTimetableName;
  }

  set mainTimetableName(String? value) {
    _mainTimetableName = value;
    SaveManager().saveSettings(this);
  }

  Settings({String? mainTimetableName})
      : _mainTimetableName = mainTimetableName;

  Map<String, dynamic> toJson() {
    return {
      mainTimetableNameKey: _mainTimetableName,
    };
  }

  static Settings fromJson(Map<String, dynamic> json) {
    String mtn = json[mainTimetableNameKey];
    return Settings(
      mainTimetableName: mtn,
    );
  }
}
