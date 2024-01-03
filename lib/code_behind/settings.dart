import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';

class Settings {
  static const mainTimetableNameKey = "mainTimetable";
  static const defaultGradeGroupsKey = "defaultGradeGroups";

  ///if [null] firstTimetable shown
  String? _mainTimetableName;

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
        name: "Written grades",
        percent: 60,
        grades: [],
      ),
      GradeGroup(
        name: "Verbal grades",
        percent: 40,
        grades: [],
      ),
    ];
  }

  Settings({
    String? mainTimetableName,
  }) : _mainTimetableName = mainTimetableName;

  Map<String, dynamic> toJson() {
    return {
      mainTimetableNameKey: _mainTimetableName,
      // defaultGradeGroupsKey: _defaultGradeGroups != null
      //     ? List.generate(
      //         _defaultGradeGroups!.length,
      //         (index) => _defaultGradeGroups![index].toJson(),
      //       )
      //     : null,
    };
  }

  static Settings fromJson(Map<String, dynamic> json) {
    String? mtn = json[mainTimetableNameKey];
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
      mainTimetableName: mtn,
      // defaultGradeGroups: gradeGroups,
    );
  }
}
