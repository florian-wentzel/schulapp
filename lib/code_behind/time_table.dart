import 'package:schulapp/code_behind/school_day.dart';

class TimeTable {
  final String _name;
  final List<SchoolDay> _schoolDays;

  String get name => _name;
  List<SchoolDay> get schoolDays => _schoolDays;

  TimeTable({
    required String name,
    required List<SchoolDay> schoolDays,
  })  : _name = name,
        _schoolDays = schoolDays;
}
