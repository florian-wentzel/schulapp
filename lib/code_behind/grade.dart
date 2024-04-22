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
