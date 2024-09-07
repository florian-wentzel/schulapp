import 'package:schulapp/code_behind/grading_system_manager.dart';

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
    return GradingSystemManager.convertGradeToSelectedSystem(grade);
  }

  Map<String, dynamic> toJson() {
    return {
      infoKey: info,
      gradeKey: grade,
      dateKey: date.millisecondsSinceEpoch,
    };
  }
}
