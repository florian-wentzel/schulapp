import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';

import 'grade_group.dart';
import 'school_grade_subject.dart';

class SchoolSemester {
  static const sortByGradeValue = "sortByGrade";
  static const sortByNameValue = "sortByName";
  static const sortByCustomValue = "sortByCustom";

  static const nameKey = "name";
  static const subjectsKey = "subjects";
  static const yearKey = "year";
  static const semesterKey = "semester";

  static const maxNameLength = 25;

  int? _year;
  //wird nur gesetzt wenn year > 10 ist
  int? _semester; //1 = 1. Semester, 2 = 2. Semester
  String? _name;

  String get name => _name ?? "$_year.$_semester";
  void setName(String? newName) {
    if (newName == null && _year == null) {
      return;
    }
    _name = newName;
  }

  int? get year => _year;
  int? get semester => _semester;

  List<SchoolGradeSubject> _subjects; //Deutsch Mathe Englisch

  List<SchoolGradeSubject> get subjects {
    return _subjects;
  }

  List<SchoolGradeSubject> get sortedSubjects {
    final sortBy = TimetableManager().settings.getVar<String>(
          Settings.sortSubjectsByKey,
        );

    final pinWeightedSubjectsAtTop = TimetableManager().settings.getVar<bool>(
          Settings.pinWeightedSubjectsAtTopKey,
        );

    //vielleicht sollte man eine kopie von der Liste machen und diese sortieren und zurückgeben

    if (sortBy == sortByGradeValue) {
      _subjects.sort(
        (a, b) {
          double averageA = double.parse(
              a.getGradeAverage().toStringAsFixed(Settings.decimalPlaces));
          double averageB = double.parse(
              b.getGradeAverage().toStringAsFixed(Settings.decimalPlaces));

          if (!pinWeightedSubjectsAtTop || (a.weight != 1 && b.weight != 1)) {
            return _compareGradeAverage(averageA, averageB, a.name, b.name);
          }

          if (a.weight != 1) {
            return -1;
          }
          if (b.weight != 1) {
            return 1;
          }

          return _compareGradeAverage(averageA, averageB, a.name, b.name);
        },
      );
    } else if (sortBy == sortByNameValue) {
      _subjects.sort(
        (a, b) {
          if (!pinWeightedSubjectsAtTop || (a.weight != 1 && b.weight != 1)) {
            return a.name.compareTo(b.name);
          }

          if (a.weight != 1) {
            return -1;
          }
          if (b.weight != 1) {
            return 1;
          }

          return a.name.compareTo(b.name);
        },
      );
    } else if (sortBy == sortByCustomValue) {}

    return _subjects;
  }

  set subjects(value) {
    _subjects = value;
  }

  SchoolSemester({
    required int? year,
    required int? semester,
    required String? name,
    required List<SchoolGradeSubject> subjects,
  })  : _year = year,
        _semester = semester,
        _subjects = subjects,
        _name = name;

  double getGradeAverage() {
    double average = 0;
    double count = 0;

    for (var subject in _subjects) {
      double subjectAverage = subject.getGradeAverage();

      if (subjectAverage == -1) continue;

      subjectAverage *= subject.weight;

      average += subjectAverage;
      count += subject.weight;
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

  String getGradePointsAverageString() {
    double gradeAverage = getGradeAverage();

    return GradingSystemManager.convertGradeAverageToSelectedSystem(
      gradeAverage,
    );

    // if (gradeAverage.isNaN || gradeAverage.isInfinite || gradeAverage == -1) {
    //   return "-";
    // }

    // return gradeAverage.toStringAsFixed(Settings.decimalPlaces);
  }

  String getGradeAverageString() {
    // final system = TimetableManager()
    //     .settings
    //     .getVar<GradingSystem>(Settings.selectedGradeSystemKey);

    double gradeAverage = getGradeAverage();
    if (gradeAverage.isNaN || gradeAverage.isInfinite || gradeAverage == -1) {
      return "-";
    }

    //vielleicht muss man dass noch anpassen..

    return GradingSystemManager.convertGradeAverageToSystem(
      gradeAverage,
      GradingSystem.grade_1_6,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      nameKey: name,
      yearKey: _year,
      semesterKey: _semester,
      subjectsKey: List.generate(
        _subjects.length,
        (index) => _subjects[index].toJson(),
      ),
    };
  }

  static SchoolSemester? fromJson(Map<String, dynamic> json) {
    SchoolSemester? schoolSemester;
    try {
      String? name = json[nameKey];
      int? year = json[yearKey];
      int? semester = json[semesterKey];

      List<Map<String, dynamic>> subjectJsons =
          (json[subjectsKey] as List).cast();

      schoolSemester = SchoolSemester(
        name: name,
        year: year,
        semester: semester,
        subjects: List.generate(
          subjectJsons.length,
          (index) => SchoolGradeSubject.fromJson(subjectJsons[index]),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return schoolSemester;
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

  int _compareGradeAverage(
    double averageA,
    double averageB,
    String nameA,
    String nameB,
  ) {
    if (averageA == -1 && averageB == -1) {
      return nameA.compareTo(nameB);
    }

    if (averageA == -1) {
      return 1;
    }

    if (averageB == -1) {
      return -1;
    }
    if (averageA == averageB) return nameA.compareTo(nameB);
    if (averageA > averageB) return -1;
    return 1;
  }

  void setValuesFrom(SchoolSemester semester) {
    _name = semester.name;
    _year = semester.year;
    _semester = semester.semester;
    _subjects.clear();
    _subjects.addAll(semester.subjects);
  }
}
