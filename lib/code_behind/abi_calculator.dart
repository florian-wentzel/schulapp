import 'dart:math';

import 'package:schulapp/code_behind/grade.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

//TODO: Automatische Gewichtung hinzufügen, die Formel ist die Folgende:
//autoWeight = maxSectionIIPoints / (15 * subjectCount)

class AbiCalculator {
  static const abiExamSubjectsKey = "abiExamSubjects";
  static const advancedSubjectsKey = "advancedSubjects";
  static const simulatedSemestersKey = "simulatedSemesters";
  static String semesterNamesKey = "semesers";
  static String maxSectionIPointsKey = "maxSectionIPoints";
  static String maxSectionIIPointsKey = "maxSectionIIPoints";

  //can not be shown to users and not inputted
  //thats how I check if the semester is a _testingSemester
  static final nullchar = String.fromCharCode(0);

  static bool isSimulatedSemester(SchoolSemester semester) =>
      semester.name.contains(nullchar);
  final List<SchoolSemester> _simulatedSemesters = List.generate(
    4,
    (index) => SchoolSemester(
      name: index.toString() + nullchar,
      year: null,
      semester: null,
      subjects: [],
      connectedTimetableName: null,
      uniqueKey: null,
    ),
    growable: false,
  );

  final List<SchoolSemester?> _semesters = List.generate(
    4,
    (index) => null,
    growable: false,
  );

  final List<String?> _semesterNames = List.generate(
    4,
    (index) => null,
    growable: false,
  );

  int _maxSectionIPoints = 600;
  int _maxSectionIIPoints = 300;

  int get maxSectionIPoints => _maxSectionIPoints;
  int get maxSectionIIPoints => _maxSectionIIPoints;

  set maxSectionIPoints(int value) {
    _maxSectionIPoints = value;
    save();
  }

  set maxSectionIIPoints(int value) {
    _maxSectionIIPoints = value;
    save();
  }

  double? getSimulatedSubjectWeight(
    int semesterIndex,
    String subjectName,
  ) {
    final subject = getSimulatedSubject(semesterIndex, subjectName);

    return subject?.weight;
  }

  Grade? getSimulatedSubjectGrade(
    int semesterIndex,
    String subjectName,
  ) {
    final subject = getSimulatedSubject(semesterIndex, subjectName);

    return subject?.endSetGrade;
  }

  SchoolGradeSubject? getSimulatedSubject(
    int semesterIndex,
    String subjectName,
  ) {
    final semester = _simulatedSemesters[semesterIndex];

    return semester.subjects.cast<SchoolGradeSubject?>().firstWhere(
          (element) => element?.name == subjectName,
          orElse: () => null,
        );
  }

  void setSimulatedSubjectWeight(
    int semesterIndex,
    String subjectName,
    double? weight,
  ) {
    final semester = _simulatedSemesters[semesterIndex];

    SchoolGradeSubject? subject =
        semester.subjects.cast<SchoolGradeSubject?>().firstWhere(
              (element) => element?.name == subjectName,
              orElse: () => null,
            );

    if (subject == null) {
      if (weight == null) return;

      final newSubject = SchoolGradeSubject(
        name: subjectName,
        gradeGroups: [],
        weight: weight,
        color: null,
      );

      semester.subjects.add(newSubject);
    } else {
      if (weight == null) {
        semester.subjects.remove(subject);
      } else {
        subject.weight = weight;
      }
    }

    save();
  }

  void setSimulatedSubjectGrade(
    int semesterIndex,
    String subjectName,
    Grade? grade,
  ) {
    final semester = _simulatedSemesters[semesterIndex];

    SchoolGradeSubject? subject =
        semester.subjects.cast<SchoolGradeSubject?>().firstWhere(
              (element) => element?.name == subjectName,
              orElse: () => null,
            );

    if (subject == null) {
      if (grade == null) return;

      final newSubject = SchoolGradeSubject(
        name: subjectName,
        gradeGroups: [],
        endSetGrade: grade,
        color: null,
      );

      semester.subjects.add(newSubject);
    } else {
      if (grade == null) {
        semester.subjects.remove(subject);
      } else {
        subject.endSetGrade = grade;
      }
    }

    save();
  }

  void setSemesterName(int index, String? name) {
    if (index < 0 || index >= _semesterNames.length) {
      return;
    }

    _semesterNames[index] = name;
    if (name == null) {
      _semesters[index] = null;
    }

    int nullSemesters = 0;
    for (var semester in _semesterNames) {
      if (semester == null) {
        nullSemesters++;
      }
    }

    //delete all simulated semesters
    if (nullSemesters == _semesterNames.length) {
      for (int i = 0; i < _simulatedSemesters.length; i++) {
        _simulatedSemesters[i].subjects.clear();
      }
    }
  }

  SchoolSemester? getSemester(int index) {
    if (index < 0 ||
        index >= _semesterNames.length ||
        index >= _semesters.length) {
      return null;
    }

    final semesterName = _semesterNames[index];

    if (semesterName == null || semesterName.isEmpty) {
      return null;
    }

    final semester = _semesters[index];

    if (semester == null || semester.name != semesterName) {
      _semesters[index] =
          TimetableManager().semesters.cast<SchoolSemester?>().firstWhere(
                (element) => element?.name == semesterName,
                orElse: () => null,
              );
    }

    return _semesters[index];
  }

  List<String> get allSubjects {
    Map<String, String> map = {};

    for (int i = 0; i < 4; i++) {
      final s = getSemester(i);

      if (s == null) continue;

      for (var subject in s.subjects) {
        map[subject.name] = "";
      }
    }

    return map.keys.toList()
      ..sort(
        (a, b) => a.compareTo(b),
      );
  }

  final List<String> _advancedSubjects;
  final List<SchoolExamSubject> _abiExamSubjects = [];

  AbiCalculator({
    List<String?>? semesterNames,
    List<String> advancedSubjects = const [],
    List<SchoolExamSubject> abiExamSubjects = const [],
    List<SchoolSemester?> simulatedSemesters = const [],
    int maxSectionIPoints = 600,
    int maxSectionIIPoints = 300,
  })  : _advancedSubjects = advancedSubjects,
        _maxSectionIPoints = maxSectionIPoints,
        _maxSectionIIPoints = maxSectionIIPoints {
    if (semesterNames != null) {
      for (int i = 0;
          i < min(_semesterNames.length, semesterNames.length);
          i++) {
        _semesterNames[i] = semesterNames[i];
      }
    }
    for (int i = 0;
        i < min(simulatedSemesters.length, _simulatedSemesters.length);
        i++) {
      final semester = simulatedSemesters[i];

      if (semester == null) continue;

      _simulatedSemesters[i] = semester;
    }

    for (int i = 0; i < abiExamSubjects.length; i++) {
      _abiExamSubjects.add(abiExamSubjects[i]);
    }

    sortSubjects();
  }
  void sortSubjects() {}

  List<String> getAdvancedCourseSubjects() {
    return _advancedSubjects;
  }

  List<String> getBasicCourseSubjects() {
    List<String> list = [];
    for (var name in allSubjects) {
      if (!_advancedSubjects.contains(name)) {
        list.add(name);
      }
    }
    return list;
  }

  List<SchoolExamSubject> getAbiExamSubjects() {
    return _abiExamSubjects;
  }

  void removeAbiExamSubjects(SchoolExamSubject exam) {
    _abiExamSubjects.remove(exam);
    save();
  }

  void save() {
    SaveManager().saveAbiCalculator(this);
  }

  Map<String, dynamic> toJson() {
    return {
      semesterNamesKey: _semesterNames,
      abiExamSubjectsKey: List.generate(
        _abiExamSubjects.length,
        (index) => _abiExamSubjects[index].toJson(),
      ),
      maxSectionIPointsKey: maxSectionIPoints,
      maxSectionIIPointsKey: maxSectionIIPoints,
      advancedSubjectsKey: _advancedSubjects,
      simulatedSemestersKey: List.generate(
        _simulatedSemesters.length,
        (index) => _simulatedSemesters[index].toJson(),
      ),
    };
  }

  static AbiCalculator fromJson(Map<String, dynamic> jsonData) {
    final List<String?> semesterNames =
        (jsonData[semesterNamesKey] as List).cast();
    final List<Map<String, dynamic>> abiExamSubjectsJson =
        (jsonData[abiExamSubjectsKey] as List).cast();
    final List<String> advancedSubjects =
        (jsonData[advancedSubjectsKey] as List).cast();
    final List<Map<String, dynamic>> simulatedSemesterJsons =
        (jsonData[simulatedSemestersKey] as List).cast();

    final maxSectionIPoints = jsonData[maxSectionIPointsKey];
    final maxSectionIIPoints = jsonData[maxSectionIIPointsKey];

    return AbiCalculator(
      semesterNames: semesterNames,
      maxSectionIPoints: maxSectionIPoints,
      maxSectionIIPoints: maxSectionIIPoints,
      abiExamSubjects: List.generate(
        abiExamSubjectsJson.length,
        (index) => SchoolExamSubject.fromJson(
          abiExamSubjectsJson[index],
        ),
      ),
      advancedSubjects: advancedSubjects,
      simulatedSemesters: List.generate(
        simulatedSemesterJsons.length,
        (index) => SchoolSemester.fromJson(
          simulatedSemesterJsons[index],
        ),
      ),
    );
  }

  SchoolGradeSubject? getSubjectFromSemester(
    int semesterIndex,
    String subjectName,
  ) {
    return getSemester(semesterIndex)
        ?.subjects
        .cast<SchoolGradeSubject?>()
        .firstWhere(
          (element) => element?.name == subjectName,
          orElse: () => null,
        );
  }

  int getSectionIPoints({
    bool overrideIfSimulatedExists = true,
  }) {
    int maxPoints = 0;
    int points = 0;

    for (int i = 0; i < _semesterNames.length; i++) {
      SchoolSemester? semester = getSemester(i);

      if (semester == null) {
        if (overrideIfSimulatedExists) {
          //gibt es aber simulierte noten?
          final simSemester = _simulatedSemesters[i];

          for (int j = 0; j < simSemester.subjects.length; j++) {
            final sub = simSemester.subjects[j];

            maxPoints += 15 * sub.weight.round();
            final gradepoints = sub.getGradeAverage().round();
            points += gradepoints * sub.weight.round();
          }
        }
        continue;
      }

      for (int j = 0; j < semester.subjects.length; j++) {
        SchoolGradeSubject sub = semester.subjects[j];

        if (overrideIfSimulatedExists) {
          final simSub = getSimulatedSubject(i, sub.name);
          if (simSub != null) {
            sub = simSub;
          }
        }

        maxPoints += 15 * sub.weight.round();
        final gradepoints = sub.getGradeAverage().round();
        points += gradepoints * sub.weight.round();
      }
    }

    if (maxPoints == 0) return 0;
    return (points * maxSectionIPoints / maxPoints).round();
    //pukte / anzahl der fächer (ausgeklammerte abziehen) * 40
    // return (points / 48 * 40).round();
  }

  int getSectionIIPoints() {
    int points = 0;

    for (var exam in _abiExamSubjects) {
      points += exam.getWeightedPoints();
    }

    return points;
  }

  List<SchoolGradeSubject?> getSubjectsFromAllSemesters(
    String name, {
    bool overrideIfSimulatedExists = true,
  }) {
    List<SchoolGradeSubject?> subjects = [];

    for (int i = 0; i < _semesters.length; i++) {
      if (overrideIfSimulatedExists) {
        final simulatedSubject = getSimulatedSubject(i, name);

        if (simulatedSubject != null) {
          subjects.add(simulatedSubject);
          continue;
        }
      }

      final subject = getSubjectFromSemester(i, name);

      subjects.add(subject);
    }

    return subjects;
  }

  void addExamSubject(SchoolExamSubject examSubject) {
    if (_abiExamSubjects.any(
      (element) =>
          element.connectedSubjectName == examSubject.connectedSubjectName,
    )) {
      return;
    }

    _abiExamSubjects.add(examSubject);

    save();
  }

  double? getAbiAverage({
    bool overrideIfSimulatedExists = true,
  }) {
    int sectionIPoints = getSectionIPoints(
      overrideIfSimulatedExists: overrideIfSimulatedExists,
    );
    int sectionIIPoints = getSectionIIPoints(
        //brauch man nicht
        // overrideIfSimulatedExists: overrideIfSimulatedExists,
        );

    int totalPoints = sectionIPoints + sectionIIPoints;

    if (totalPoints == 0) {
      return null;
    }
    //Wenn man hier anpasst auch die
    //strAbiAverageNotAlwaysCorrectInfo Information anpassen
    return 5.66 - (totalPoints / 180); //Tabelle hinzufügen
  }
}

enum ExamType {
  written,
  verbal,

  ///5. PK
  presentation,
}

class SchoolExamSubject {
  static const connectedSubjectNameKey = "connectedSubjectName";
  static const examTypeKey = "examType";
  static const weightKey = "weight";
  static const gradeKey = "grade";

  Grade grade;
  String connectedSubjectName;
  ExamType examType;
  int weight;

  SchoolExamSubject({
    required this.grade,
    required this.connectedSubjectName,
    required this.examType,
    required this.weight,
  });

  static SchoolExamSubject fromJson(Map<String, dynamic> json) {
    Grade grade = Grade.fromJson(json[gradeKey]);
    String connectedSubjectName = json[connectedSubjectNameKey];
    String examType = json[examTypeKey];
    int weight = json[weightKey];

    return SchoolExamSubject(
      grade: grade,
      connectedSubjectName: connectedSubjectName,
      examType: examTypeFromString(examType) ?? ExamType.written,
      weight: weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      gradeKey: grade.toJson(),
      connectedSubjectNameKey: connectedSubjectName,
      examTypeKey: examType.toString(),
      weightKey: weight,
    };
  }

  int getWeightedPoints() {
    return grade.grade * weight;
  }

  static ExamType? examTypeFromString(String str) {
    if (str == ExamType.presentation.toString()) {
      return ExamType.presentation;
    }
    if (str == ExamType.verbal.toString()) {
      return ExamType.verbal;
    }
    if (str == ExamType.written.toString()) {
      return ExamType.written;
    }
    return null;
  }

  static String examTypeToTranslatedString(ExamType type) {
    switch (type) {
      case ExamType.written:
        return AppLocalizationsManager.localizations.strWrittenExamType;
      case ExamType.verbal:
        return AppLocalizationsManager.localizations.strVerbalExamType;
      case ExamType.presentation:
        return AppLocalizationsManager.localizations.strPresentationExamType;
    }
  }
}
