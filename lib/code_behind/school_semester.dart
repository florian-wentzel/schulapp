import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/utils.dart';

class SchoolSemester {
  static const nameKey = "name";
  static const subjectsKey = "subjects";

  static const maxNameLength = 25;

  String name;
  List<SchoolGradeSubject> _subjects; //Deutsch Mathe Englisch

  List<SchoolGradeSubject> get subjects {
    return _subjects;
  }

  List<SchoolGradeSubject> get sortedSubjects {
    //vielleicht sollte man eine kopie von der Liste machen und diese Kopieren, sortieren und zurückgeben
    _subjects.sort(
      (a, b) {
        double averageA = double.parse(
            a.getGradeAverage().toStringAsFixed(Settings.decimalPlaces));
        double averageB = double.parse(
            b.getGradeAverage().toStringAsFixed(Settings.decimalPlaces));

        if (averageA == -1 && averageB == -1) {
          return a.name.compareTo(b.name);
        }

        if (averageA == -1) {
          return 1;
        }

        if (averageB == -1) {
          return -1;
        }
        if (averageA == averageB) return a.name.compareTo(b.name);
        if (averageA > averageB) return -1;
        return 1;
      },
    );
    return _subjects;
  }

  set subject(value) {
    _subjects = value;
  }

  SchoolSemester({
    required this.name,
    required List<SchoolGradeSubject> subjects,
  }) : _subjects = subjects;

  double getGradeAverage() {
    double average = 0;
    int count = 0;

    for (var subject in _subjects) {
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

    return gradeAverage.toStringAsFixed(Settings.decimalPlaces);
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      subjectsKey: List.generate(
        _subjects.length,
        (index) => _subjects[index].toJson(),
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

  bool removeSubject(SchoolGradeSubject subject) {
    return _subjects.remove(subject);
  }

  SchoolGradeSubject? getSubjectByName(String name) {
    if (subjects.any((element) => element.name == name)) {
      return subjects.firstWhere(
        (element) => element.name == name,
      );
    }
    return null;
  }
}

class SchoolGradeSubject {
  static const String nameKey = "name";
  static const String gradeGroupsKey = "gradeGroups";
  static const endSetGradeKey = "endSetGrade";

  static const int maxNameLength = 15;

  String name;

  List<GradeGroup> gradeGroups; //Schriftliche und Mündliche Noten etc.

  Grade? endSetGrade; //die note welche alle anderen überschreibt

  SchoolGradeSubject({
    required this.name,
    required this.gradeGroups,
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

    return SchoolGradeSubject(
      name: name,
      endSetGrade: endSetGrade,
      gradeGroups: gradeGroups,
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

    return getGradeAverageStringStatic(gradeAverage);
  }

  static String getGradeAverageStringStatic(double grade) {
    if (grade == -1) {
      return "-";
    }
    return grade.toStringAsFixed(Settings.decimalPlaces);
  }
}

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
    if (grade < 10) {
      return "0$grade";
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
