import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

class SchoolSemester {
  static const nameKey = "name";
  static const subjectsKey = "subjects";

  static const maxNameLength = 15;

  String name;
  List<SchoolGradeSubject> subjects; //Deutsch Mathe Englisch

  SchoolSemester({required this.name, required this.subjects});

  double getGradeAverage() {
    double average = 0;
    int count = 0;

    for (var subject in subjects) {
      double subjectAverage = subject.getGradeAverage();

      if (subjectAverage == -1) continue;

      average += subjectAverage;
      count++;
    }

    if (count == 0) return -1;

    average /= count;

    return average;
  }

  Color getColor() {
    double average = getGradeAverage();
    return Utils.getGradeColor(
      (average.isNaN || average.isInfinite) ? -1 : average.toInt(),
    );
  }

  String getGradeAverageString() {
    double gradeAverage = getGradeAverage();
    if (gradeAverage.isNaN || gradeAverage.isInfinite || gradeAverage == -1) {
      return "-";
    }
    return gradeAverage.toStringAsPrecision(2);
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      subjectsKey: List.generate(
        subjects.length,
        (index) => subjects[index].toJson(),
      ),
    };
  }

  static SchoolSemester? fromJson(Map<String, dynamic> json) {
    SchoolSemester? semester;
    try {
      String name = json[nameKey];
      List<Map<String, dynamic>> subjectJsons =
          (json[subjectsKey] as List).cast();

      semester = SchoolSemester(
        name: name,
        subjects: List.generate(
          subjectJsons.length,
          (index) => SchoolGradeSubject.fromJson(subjectJsons[index]),
        ),
      );
    } catch (e) {
      print(e);
    }

    return semester;
  }
}

class SchoolGradeSubject {
  static const String nameKey = "name";
  static const String colorKey = "color";
  static const String gradeGroupsKey = "gradeGroups";

  static const int maxNameLength = 15;

  String name;
  Color color;

  List<GradeGroup> gradeGroups; //Schriftliche und Mündliche Noten etc.

  SchoolGradeSubject({
    required this.name,
    required this.color,
    required this.gradeGroups,
  });

  double getGradeAverage() {
    double average = 0;
    int count = 0;

    for (var gradeGroup in gradeGroups) {
      double gradeGroupAverage = gradeGroup.getGradeAverage();

      if (gradeGroupAverage == -1) continue;

      average += gradeGroupAverage * gradeGroup.percent / 100;
      count++;
    }

    average /= count;
    return average;
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      colorKey: Utils.colorToJson(color),
      gradeGroupsKey: List.generate(
        gradeGroups.length,
        (index) => gradeGroups[index].toJson(),
      ),
    };
  }

  static SchoolGradeSubject fromJson(Map<String, dynamic> json) {
    String name = json[nameKey];
    Color color = Utils.jsonToColor(json[colorKey]);
    List<Map<String, dynamic>> gradeGroupsJsons =
        (json[gradeGroupsKey] as List).cast();

    List<GradeGroup> gradeGroups = List.generate(
      gradeGroupsJsons.length,
      (index) => GradeGroup.fromJson(
        gradeGroupsJsons[index],
      ),
    );

    return SchoolGradeSubject(
      name: name,
      color: color,
      gradeGroups: gradeGroups,
    );
  }
}

class GradeGroup {
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
}

class Grade {
  static const gradeKey = "grade";
  static const dateKey = "date";
  static const infoKey = "info";

  int grade;
  DateTime date;
  String info;

  Grade({required this.grade, required this.date, required this.info});

  static Grade fromJson(Map<String, dynamic> json) {
    return Grade(
      info: json[infoKey],
      grade: json[gradeKey],
      date: DateTime.fromMillisecondsSinceEpoch(json[dateKey]),
    );
  }

  @override
  String toString() {
    if (grade.isNaN || grade.isInfinite) {
      return "-";
    }
    return grade.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      infoKey: info,
      gradeKey: grade,
      dateKey: date.millisecondsSinceEpoch,
    };
  }
}
