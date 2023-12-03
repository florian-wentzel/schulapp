import 'package:schulapp/code_behind/time_table.dart';

///singelton damit es immer nur eine instanz gibt
class TimeTableSaveManager {
  static final TimeTableSaveManager _instance =
      TimeTableSaveManager._privateConstructor();
  TimeTableSaveManager._privateConstructor();

  factory TimeTableSaveManager() {
    return _instance;
  }

  List<TimeTable>? _timeTables;

  List<TimeTable> get timeTables {
    _timeTables ??= []; //load timetable
    return _timeTables!;
  }
}
