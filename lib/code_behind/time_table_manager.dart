import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/timetable_saver.dart';

///singelton damit es immer nur eine instanz gibt
class TimetableManager {
  static final TimetableManager _instance =
      TimetableManager._privateConstructor();
  TimetableManager._privateConstructor();

  factory TimetableManager() {
    return _instance;
  }

  List<Timetable>? _timetables;

  List<Timetable> get timetables {
    _timetables ??= TimetableSaver().loadAllTimetables(); //load timetable
    return _timetables!;
  }

  ///Adds the [Timetable] and saves it to lokal storage
  ///throws an [Exception] when the [Timetable] already exists
  void addTimetable(Timetable timetable) {
    if (timetables.any((element) => element.name == timetable.name)) {
      throw Exception("there is already a timetable called: ${timetable.name}");
    }

    _timetables!.add(timetable);
    TimetableSaver().saveTimeTable(timetable);
  }
}
