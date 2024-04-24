import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';

import 'grade_group.dart';
import 'school_grade_subject.dart';

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

  set subjects(value) {
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
      debugPrint(e.toString());
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

  void translateGradeGroups() {
    List<GradeGroup> defaultGradeGroups = TimetableManager().settings.getVar(
          Settings.defaultGradeGroupsKey,
        );

    for (final subject in _subjects) {
      for (int i = 0; i < defaultGradeGroups.length; i++) {
        if (i >= subject.gradeGroups.length) continue;

        final gradeGroup = subject.gradeGroups[i];
        gradeGroup.name = defaultGradeGroups[i].name;
      }
    }

    SaveManager().saveSemester(this);
  }
}
