import 'dart:ui';

import 'package:schulapp/code_behind/grading_system_manager.dart';

import 'grade.dart';
import 'grade_group.dart';

class SchoolGradeSubject {
  static const String nameKey = "name";
  static const String gradeGroupsKey = "gradeGroups";
  static const String endSetGradeKey = "endSetGrade";
  static const String weightKey = "weight";

  static const int maxNameLength = 15;

  String name;
  Color? color;

  List<GradeGroup> gradeGroups; //Schriftliche und Mündliche Noten etc.

  Grade? endSetGrade; //die note welche alle anderen überschreibt

  double weight;

  SchoolGradeSubject({
    required this.name,
    required this.gradeGroups,
    required this.color,
    this.weight = 1,
    this.endSetGrade,
  });

  double getGradeAverage() {
    if (endSetGrade != null) return endSetGrade!.grade.toDouble();

    int percent = 0;
    int count = 0;

    for (var gradeGroup in gradeGroups) {
      final percentage = gradeGroup.getPercentageForCalculation();
      if (percentage == -1) continue;

      percent += percentage;
      count++;
    }

    if (count == 0) return -1;

    double correctorVal = (100 - percent) / count;
    int correctorValInt = correctorVal.toInt();

    double average = 0;

    for (var gradeGroup in gradeGroups) {
      double gradeGroupAverage = gradeGroup.getGradeAverage();

      if (gradeGroupAverage == -1) continue;

      average +=
          gradeGroupAverage * (gradeGroup.percent + correctorValInt) / 100;
    }

    return average;
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      endSetGradeKey: endSetGrade?.toJson(),
      weightKey: weight,
      gradeGroupsKey: List.generate(
        gradeGroups.length,
        (index) => gradeGroups[index].toJson(),
      ),
    };
  }

  static SchoolGradeSubject fromJson(Map<String, dynamic> json) {
    String name = json[nameKey];
    Grade? endSetGrade = json[endSetGradeKey] == null
        ? null
        : Grade.fromJson(json[endSetGradeKey]);

    List<Map<String, dynamic>> gradeGroupsJsons =
        (json[gradeGroupsKey] as List).cast();

    List<GradeGroup> gradeGroups = List.generate(
      gradeGroupsJsons.length,
      (index) => GradeGroup.fromJson(
        gradeGroupsJsons[index],
      ),
    );

    double weight = json[weightKey] ?? 1;

    return SchoolGradeSubject(
      name: name,
      weight: weight,
      endSetGrade: endSetGrade,
      gradeGroups: gradeGroups,
      color: null,
    );
  }

  void adaptPercentage(GradeGroup from, int toIndex) {
    if (toIndex < 0 || toIndex >= gradeGroups.length) return;
    if (gradeGroups.length - 1 == 0) return;
    if (gradeGroups.length == 2) {
      gradeGroups[toIndex].percent = 100 - from.percent;
      return;
    }

    int percentage = 0;

    for (var gradeGroup in gradeGroups) {
      percentage += gradeGroup.percent;
    }

    if (percentage == 100) return;

    int diff = 100 - percentage;

    for (int i = 0; i < gradeGroups.length; i++) {
      int index = (i + toIndex) % gradeGroups.length;
      if (index == gradeGroups.indexOf(from)) continue;
      final currGroup = gradeGroups[index];

      if (currGroup.percent + diff >= 0) {
        currGroup.percent += diff;
        diff = 0;
        break;
      } else {
        currGroup.percent = 0;
        diff += currGroup.percent;
      }
    }
  }

  bool removeGradegroup(GradeGroup gg) {
    bool removed = gradeGroups.remove(gg);
    if (gradeGroups.isNotEmpty) {
      adaptPercentage(gradeGroups[0], 1);
    }
    return removed;
  }

  void addGradeGroup(GradeGroup gradeGroup) {
    gradeGroups.add(gradeGroup);

    adaptPercentage(gradeGroup, 0);
  }

  String getGradeAverageString() {
    final gradeAverage = getGradeAverage();

    return GradingSystemManager.convertGradeAverageToSelectedSystem(
      gradeAverage,
    );
  }
}
