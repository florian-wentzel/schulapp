library;

import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/strike_through_container.dart';
import 'package:schulapp/widgets/timetable/time_to_next_lesson_widget.dart';
import 'package:schulapp/widgets/timetable/timetable_lesson_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/todo_events_screen.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/high_contrast_text.dart';
import 'package:schulapp/widgets/semester/school_grade_subject_widget.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';
import 'package:schulapp/widgets/task/todo_event_list_item_widget.dart';

part '../widgets/timetable/timetable_one_day_widget.dart';
part '../widgets/timetable/timetable_widget.dart';

class TimetableController {
  GlobalKey timeLeftKey = GlobalKey();
  GlobalKey firstLessonKey = GlobalKey();
  GlobalKey dayNameKey = GlobalKey();

  //"_[...]Day" werden erst gesetzt, wenn das widget geladen ist
  //[TimetableWidget] oder [TimetableOneDayWidget]
  DateTime? _firstDay;
  DateTime? _lastDay;
  //der Tag der gerade angezeigt wird
  DateTime? _currDay;

  DateTime? get firstDay => _firstDay;
  DateTime? get lastDay => _lastDay;
  //der Tag der gerade angezeigt wird
  DateTime? get currDay => _currDay;

  bool Function(DateTime)? _onGoToDay;

  bool goToDay(DateTime day) {
    return _onGoToDay?.call(day) ?? false;
  }
}
