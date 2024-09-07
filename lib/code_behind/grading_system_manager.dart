import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';

///Alle Noten werden in GradingSystem.grade_0_15 gespeichert und für die Anzeige umgerechnet
///Siehe enum GradingSystem um geneuere beschreibung zu sehen
class GradingSystemManager {
  GradingSystemManager._privateConstructor();

  static const _converterMap = <GradingSystem, String Function(int grade)>{
    GradingSystem.grade_0_15: _convertGrade_0_15,
    GradingSystem.grade_1_6: _convertGrade_1_6,
    GradingSystem.grade_6_1: _convertGrade_6_1,
    GradingSystem.grade_A_F: _convertGrade_A_F,
  };

  static const _averageConverterMap =
      <GradingSystem, String Function(double grade)>{
    GradingSystem.grade_0_15: _convertGradeAverage_0_15,
    GradingSystem.grade_1_6: _convertGradeAverage_1_6,
    GradingSystem.grade_6_1: _convertGradeAverage_6_1,
    GradingSystem.grade_A_F: _convertGradeAverage_A_F,
  };

  static String convertGradeToSelectedSystem(int grade) {
    if (grade.isNaN || grade.isInfinite) {
      return "-";
    }

    final GradingSystem currGradeSystem = TimetableManager().settings.getVar(
          Settings.selectedGradeSystemKey,
        );

    return convertGradeToSystem(grade, currGradeSystem);
  }

  static String convertGradeAverageToSelectedSystem(double grade) {
    if (grade.isNaN || grade.isInfinite) {
      return "-";
    }
    if (grade == -1) {
      return "-";
    }

    final GradingSystem currGradeSystem = TimetableManager().settings.getVar(
          Settings.selectedGradeSystemKey,
        );

    return convertGradeAverageToSystem(grade, currGradeSystem);
  }

  static String convertGradeToSystem(int grade, GradingSystem system) {
    return _converterMap[system]?.call(grade) ?? _convertGrade_0_15(grade);
  }

  static String convertGradeAverageToSystem(
      double grade, GradingSystem system) {
    return _averageConverterMap[system]?.call(grade) ??
        _convertGradeAverage_0_15(grade);
  }

  static String _convertGradeAverage_0_15(double grade) {
    return grade.toStringAsFixed(Settings.decimalPlaces);
  }

  static String _convertGrade_0_15(int grade) {
    if (grade < 10) {
      return "0$grade";
    }
    return grade.toString();
  }

  static String _convertGradeAverage_1_6(double grade) {
    return gradeAverageTo_1_6_average(grade);
  }

  static String _convertGrade_1_6(int grade) {
    if (grade == 15) {
      return "1+";
    }
    if (grade == 14) {
      return "1 ";
    }
    if (grade == 13) {
      return "1-";
    }

    if (grade == 12) {
      return "2+";
    }
    if (grade == 11) {
      return "2 ";
    }
    if (grade == 10) {
      return "2-";
    }

    if (grade == 9) {
      return "3+";
    }
    if (grade == 8) {
      return "3 ";
    }
    if (grade == 7) {
      return "3-";
    }

    if (grade == 6) {
      return "4+";
    }
    if (grade == 5) {
      return "4 ";
    }
    if (grade == 4) {
      return "4-";
    }

    if (grade == 3) {
      return "5+";
    }
    if (grade == 2) {
      return "5 ";
    }
    if (grade == 1) {
      return "5-";
    }

    if (grade == 0) {
      return "6 ";
    }

    return "";
  }

  static String _convertGradeAverage_6_1(double grade) {
    return gradeAverageTo_1_6_average(grade);
  }

  static String _convertGrade_6_1(int grade) {
    if (grade == 15) {
      return "6+";
    }
    if (grade == 14) {
      return "6 ";
    }
    if (grade == 13) {
      return "6-";
    }

    if (grade == 12) {
      return "5+";
    }
    if (grade == 11) {
      return "5 ";
    }
    if (grade == 10) {
      return "5-";
    }

    if (grade == 9) {
      return "4+";
    }
    if (grade == 8) {
      return "4 ";
    }
    if (grade == 7) {
      return "4-";
    }

    if (grade == 6) {
      return "3+";
    }
    if (grade == 5) {
      return "3 ";
    }
    if (grade == 4) {
      return "3-";
    }

    if (grade == 3) {
      return "2+";
    }
    if (grade == 2) {
      return "2 ";
    }
    if (grade == 1) {
      return "2-";
    }

    if (grade == 0) {
      return "1 ";
    }

    return "";
  }

  // ignore: non_constant_identifier_names
  static String _convertGradeAverage_A_F(double grade) {
    final roundedGrade = grade.round();

    return _convertGrade_A_F(roundedGrade);
  }

  // ignore: non_constant_identifier_names
  static String _convertGrade_A_F(int grade) {
    if (grade == 15) {
      return "A+";
    }
    if (grade == 14) {
      return "A ";
    }
    if (grade == 13) {
      return "A-";
    }

    if (grade == 12) {
      return "B+";
    }
    if (grade == 11) {
      return "B ";
    }
    if (grade == 10) {
      return "B-";
    }

    if (grade == 9) {
      return "C+";
    }
    if (grade == 8) {
      return "C ";
    }
    if (grade == 7) {
      return "C-";
    }

    if (grade == 6) {
      return "D+";
    }
    if (grade == 5) {
      return "D ";
    }
    if (grade == 4) {
      return "D-";
    }

    if (grade == 3) {
      return "E+";
    }
    if (grade == 2) {
      return "E ";
    }
    if (grade == 1) {
      return "E-";
    }

    if (grade == 0) {
      return "F ";
    }

    return "";
  }

  // ignore: non_constant_identifier_names
  static String gradeAverageTo_1_6_average(double grade) {
    final newGradeAverage = (17 - grade) / 3;
    return newGradeAverage.toStringAsFixed(Settings.decimalPlaces);
  }
}

enum GradingSystem {
  grade_0_15, //Oberstufe deutschland
  grade_1_6, //1 - 10 klasse deutschland
  grade_6_1, //Schweiz oder so
  // ignore: constant_identifier_names
  grade_A_F,
}
