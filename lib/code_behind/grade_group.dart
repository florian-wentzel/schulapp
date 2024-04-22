import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

import 'grade.dart';

class GradeGroup {
  static const maxNameLength = 15;

  static const nameKey = "name";
  static const percentKey = "percent";
  static const gradesKey = "grades";

  //Icon icon in der Zukunft vielleicht
  String name;
  int percent;
  List<Grade> grades;

  GradeGroup({
    required this.name,
    required this.percent,
    required this.grades,
  });

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      percentKey: percent,
      gradesKey: List.generate(
        grades.length,
        (index) => grades[index].toJson(),
      ),
    };
  }

  static GradeGroup fromJson(Map<String, dynamic> json) {
    String name = json[nameKey];
    int percent = json[percentKey];
    List<Map<String, dynamic>> gradesJson = (json[gradesKey] as List).cast();

    return GradeGroup(
      name: name,
      percent: percent,
      grades: List.generate(
        gradesJson.length,
        (index) => Grade.fromJson(gradesJson[index]),
      ),
    );
  }

  Color? getGradeColor(int gradeIndex) {
    if (gradeIndex < 0 || gradeIndex >= grades.length) return null;

    return Utils.getGradeColor(grades[gradeIndex].grade);
  }

  double getGradeAverage() {
    if (grades.isEmpty) {
      return -1;
    }

    double average = 0;

    for (Grade grade in grades) {
      average += grade.grade;
    }

    average /= grades.length;

    return average;
  }

  int getPercentageForCalculation() {
    if (grades.isEmpty) return -1;
    return percent;
  }
}
