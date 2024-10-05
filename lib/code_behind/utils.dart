import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';

class Utils {
  static const hourKey = "hour";
  static const minuteKey = "minute";

  static const aKey = "a";
  static const rKey = "r";
  static const gKey = "g";
  static const bKey = "b";

  static final List<Color> _gradeColors = [
    const Color.fromARGB(255, 127, 127, 127),
    const Color.fromARGB(255, 237, 84, 71),
    const Color.fromARGB(255, 237, 84, 71),
    const Color.fromARGB(255, 247, 144, 49),
    const Color.fromARGB(255, 250, 166, 53),
    const Color.fromARGB(255, 248, 181, 63),
    const Color.fromARGB(255, 248, 196, 76),
    const Color.fromARGB(255, 215, 185, 61),
    const Color.fromARGB(255, 181, 176, 50),
    const Color.fromARGB(255, 159, 171, 45),
    const Color.fromARGB(255, 145, 171, 44),
    const Color.fromARGB(255, 131, 171, 43),
    const Color.fromARGB(255, 116, 171, 43),
    const Color.fromARGB(255, 101, 171, 42),
    const Color.fromARGB(255, 83, 170, 42),
    const Color.fromARGB(255, 53, 170, 41),
    const Color.fromARGB(255, 53, 170, 41),
  ];

  ///from -1 to 15
  static Color getGradeColor(int grade) {
    return _gradeColors[grade + 1];
  }

  static bool get isMobile {
    return /*!kIsWeb && */ (Platform.isAndroid || Platform.isIOS);
  }

  static bool get isDesktop {
    return /*!kIsWeb && */
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  static void removeEmptySchoolLessons(
    Timetable timetable, {
    required bool Function(SchoolLesson) shouldChangeLesson,
    required void Function(SchoolLesson, int) updateSchoolLesson,
  }) {
    for (int schoolDayIndex = 0;
        schoolDayIndex < timetable.schoolDays.length;
        schoolDayIndex++) {
      for (int lessonIndex = 0;
          lessonIndex < timetable.maxLessonCount;
          lessonIndex++) {
        SchoolLesson lesson =
            timetable.schoolDays[schoolDayIndex].lessons[lessonIndex];

        if (!shouldChangeLesson(lesson)) {
          continue;
        }

        updateSchoolLesson(lesson, lessonIndex);
      }
    }
  }

  static void changeLessonNumberToVisible(Timetable timetable) {
    removeEmptySchoolLessons(
      timetable,
      shouldChangeLesson: (schoolLesson) {
        return SchoolLesson.isEmptyLessonName(schoolLesson.name);
      },
      updateSchoolLesson: (schoolLesson, lessonIndex) {
        schoolLesson.name = "-${lessonIndex + 1}-";
        schoolLesson.room = "";
      },
    );
  }

  static void changeLessonNumberToNonVisible(Timetable timetable) {
    removeEmptySchoolLessons(
      timetable,
      shouldChangeLesson: (schoolLesson) {
        return schoolLesson.name.startsWith("-") &&
            schoolLesson.name.endsWith("-");
      },
      updateSchoolLesson: (schoolLesson, lessonIndex) {
        schoolLesson.name = SchoolLesson.emptyLessonName;
        schoolLesson.room = "";
      },
    );
  }

  static void updateTimetableLessons(
    Timetable timetable,
    SchoolLessonPrefab prefab, {
    String? newName,
    String? newTeacher,
    String? newRoom,
    Color? newColor,
  }) {
    for (int schoolDayIndex = 0;
        schoolDayIndex < timetable.schoolDays.length;
        schoolDayIndex++) {
      for (int lessonIndex = 0;
          lessonIndex < timetable.maxLessonCount;
          lessonIndex++) {
        SchoolLesson lesson =
            timetable.schoolDays[schoolDayIndex].lessons[lessonIndex];

        if (lesson.name != prefab.name) {
          continue;
        }

        if (newName != null) {
          lesson.name = newName;
        }
        if (newTeacher != null) {
          lesson.teacher = newTeacher;
        }
        if (newRoom != null) {
          lesson.room = newRoom;
        }
        if (newColor != null) {
          lesson.color = newColor;
        }
      }
    }
  }

  static bool isScreenOnTop(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent ?? false;
  }

  //TODO: update all showBoolInputDialog (showYesAndNoInsteadOfOK = true?)
  static Future<bool> showBoolInputDialog(
    BuildContext context, {
    required String question,
    String? description,
    bool autofocus = false,
    bool showYesAndNoInsteadOfOK = false,
    bool markTrueAsRed = false,
    bool markFalseAsRed = false,
  }) async {
    bool? value = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(question),
          content: description == null ? null : Text(description),
          actions: <Widget>[
            TextButton(
              style: markTrueAsRed
                  ? TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    )
                  : null,
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(showYesAndNoInsteadOfOK
                  ? AppLocalizationsManager.localizations.strYes
                  : AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              style: markFalseAsRed
                  ? TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    )
                  : null,
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                showYesAndNoInsteadOfOK
                    ? AppLocalizationsManager.localizations.strNo
                    : AppLocalizationsManager.localizations.strCancel,
              ),
            ),
          ],
        );
      },
    );

    return value ?? false;
  }

  static Future<double?> showRangeInputDialog(
    BuildContext context, {
    required double minValue,
    required double maxValue,
    required double startValue,
    String textAfterValue = "",
    double distToSnapToPoint = 2,
    int precision = 0,
    bool onlyIntegers = false,
    String? title,
    List<double>? snapPoints,
  }) async {
    double currValue = startValue;
    snapPoints ??= [];

    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: StatefulBuilder(builder: (context, snapshot) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Slider.adaptive(
                    value: currValue,
                    min: minValue,
                    max: maxValue,
                    onChanged: (value) {
                      for (double snapPoint in snapPoints ?? []) {
                        double dist = (snapPoint - value).abs();
                        if (dist < distToSnapToPoint) {
                          value = snapPoint;
                        }
                      }
                      snapshot.call(
                        () {
                          currValue = value;
                        },
                      );
                    },
                  ),
                ),
                Text(
                  "${currValue.toStringAsFixed(precision)} $textAfterValue",
                ),
              ],
            );
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, currValue);
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> showStringInputDialog(
    BuildContext context, {
    required String hintText,
    bool autofocus = true,
    String? title,
    String? initText,
    int maxInputLength = 20,
  }) async {
    TextEditingController textController = TextEditingController();
    textController.text = initText ?? "";

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: TextField(
            maxLength: maxInputLength,
            autofocus: autofocus,
            controller: textController,
            decoration: InputDecoration(
              hintText: hintText,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, textController.text);
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        );
      },
    );
  }

  static Future<Color?> showColorInputDialog(
    BuildContext context, {
    String? hintText,
    String? title,
    Color? pickerColor,
  }) {
    Color selectedColor = pickerColor ?? Colors.blue;

    return showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (value) {
              selectedColor = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedColor);
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        );
      },
    );
  }

  static Map<String, dynamic> timeToJson(TimeOfDay time) {
    return {
      hourKey: time.hour,
      minuteKey: time.minute,
    };
  }

  static TimeOfDay jsonToTime(Map<String, dynamic> json) {
    int hour = json[hourKey];
    int minute = json[minuteKey];
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Map<String, dynamic> colorToJson(Color c) {
    return {
      aKey: c.alpha,
      rKey: c.red,
      gKey: c.green,
      bKey: c.blue,
    };
  }

  static void showInfo(
    BuildContext context, {
    required String msg,
    InfoType type = InfoType.normal,
    Duration? duration,
    SnackBarAction? actionWidget,
  }) {
    duration ??= const Duration(seconds: 4);
    Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    Color backgroundColor;

    switch (type) {
      case InfoType.normal:
        backgroundColor = Colors.white;
        textColor = Colors.black;
        break;
      case InfoType.info:
        backgroundColor = Theme.of(context).cardColor.withAlpha(255);
        break;
      case InfoType.success:
        backgroundColor = Colors.green;
        break;
      case InfoType.warning:
        backgroundColor = Colors.yellow;
        textColor = Colors.black;
        break;
      case InfoType.error:
        backgroundColor = Colors.red;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: actionWidget,
        backgroundColor: backgroundColor,
        duration: duration,
        content: Text(
          msg,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }

  static void hideCurrInfo(
    BuildContext context, {
    SnackBarClosedReason closedReason = SnackBarClosedReason.hide,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(
      reason: closedReason,
    );
  }

  static Color jsonToColor(Map<String, dynamic> json) {
    int a = json[aKey];
    int r = json[rKey];
    int g = json[gKey];
    int b = json[bKey];
    return Color.fromARGB(a, r, g, b);
  }

  static SchoolSemester? getMainSemester() {
    if (TimetableManager().semesters.isEmpty) {
      return null;
    }

    try {
      String? mainTimetableName =
          TimetableManager().settings.getVar(Settings.mainSemesterNameKey);

      if (mainTimetableName != null) {
        return TimetableManager().semesters.firstWhere(
              (element) => element.name == mainTimetableName,
            );
      }
    } catch (_) {}

    // return TimetableManager().semesters.first;
    return null;
  }

  static Timetable? getHomescreenTimetable() {
    if (TimetableManager().timetables.isEmpty) {
      return null;
    }

    try {
      String? mainTimetableName =
          TimetableManager().settings.getVar(Settings.mainTimetableNameKey);

      if (mainTimetableName != null) {
        return TimetableManager().timetables.firstWhere(
              (element) => element.name == mainTimetableName,
            );
      }
    } catch (_) {}

    return TimetableManager().timetables.first;
  }

  static double getMobileRatio() => 9 / 16;

  static double getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return width / height;
  }

  static List<SchoolLessonPrefab> createLessonPrefabsFromTt(
      Timetable timetable) {
    Map<String, SchoolLessonPrefab> lessonPrefabsMap = {};

    for (int schoolDayIndex = 0;
        schoolDayIndex < timetable.schoolDays.length;
        schoolDayIndex++) {
      for (int schoolLessonIndex = 0;
          schoolLessonIndex < timetable.maxLessonCount;
          schoolLessonIndex++) {
        SchoolLesson lesson =
            timetable.schoolDays[schoolDayIndex].lessons[schoolLessonIndex];

        if (lesson.name.startsWith("-")) {
          continue;
        }

        bool exists = lessonPrefabsMap.containsKey(lesson.name);

        if (exists) continue;

        SchoolLessonPrefab prefab = SchoolLessonPrefab(
          name: lesson.name,
          room: lesson.room,
          teacher: lesson.teacher,
          color: lesson.color,
        );

        lessonPrefabsMap[lesson.name] = prefab;
      }
    }

    return lessonPrefabsMap.values.toList();
  }

  static String dateToString(DateTime date, {bool showYear = true}) {
    if (!showYear) {
      return "${date.day}.${date.month}";
    }
    return "${date.day}.${date.month}.${date.year}";
  }

  static String timeToString(DateTime date) {
    return "${date.hour} : ${date.minute}";
  }

  static Future<T?> showCustomPopUp<T>({
    required BuildContext context,
    required Object heroObject,
    required Widget body,
    int alpha = 220,
    Widget Function(BuildContext, Animation<double>, HeroFlightDirection,
            BuildContext, BuildContext)?
        flightShuttleBuilder,
    Color? color,
  }) async {
    color ??= Theme.of(context).cardColor.withAlpha(alpha);

    return await Navigator.push<T>(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => CustomPopUp(
          heroObject: heroObject,
          color: color!,
          body: body,
          flightShuttleBuilder: flightShuttleBuilder,
        ),
        barrierDismissible: true,
        fullscreenDialog: true,
      ),
    );
  }

  static int nowInSeconds() {
    final DateTime now = DateTime.now();

    return now.hour * 3600 + now.minute * 60 + now.second;
  }

  static int getCurrentWeekDayIndex() {
    int dayIndex = DateTime.now().weekday - 1;

    if (dayIndex == 5) return 4; //wenn samstag zeig Freitag
    if (dayIndex == 6) return 0; //wenn sonntag zeig Montag

    return dayIndex % 5;
  }

  static DateTime getWeekDay(DateTime dateTime, int targetDay) {
    int diff = dateTime.weekday - targetDay;

    if (diff < 0) {
      diff += 7;
    }

    DateTime dayOfCurrentWeek = dateTime.subtract(Duration(days: diff));

    return dayOfCurrentWeek;
  }

  static bool isMobileRatio(BuildContext context) {
    final aspectRatio = Utils.getAspectRatio(context);

    return (aspectRatio <= Utils.getMobileRatio());
  }

  static bool sameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static Future<T?> showListSelectionBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required Widget? Function(BuildContext context, int index) itemBuilder,
    String? underTitle,
    Widget? bottomAction,
  }) async {
    await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.6,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              underTitle == null
                  ? Container()
                  : Column(
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          underTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: itemBuilder,
                  ),
                ),
              ),
              bottomAction ?? Container(),
            ],
          ),
        );
      },
    );
    return null;
  }

  static bool isCustomTask({
    required String linkedSubjectName,
  }) {
    Timetable? selectedTimetable = Utils.getHomescreenTimetable();
    if (selectedTimetable == null) return false;

    List<SchoolLessonPrefab> selectedTimetablePrefabs =
        Utils.createLessonPrefabsFromTt(selectedTimetable);

    final isCustomTask = !selectedTimetablePrefabs.any(
      (element) => element.name == linkedSubjectName,
    );

    return isCustomTask;
  }

  static int getWeekIndex(DateTime date) {
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);

    int daysDifference = date.difference(firstDayOfYear).inDays;

    int weekIndex = daysDifference ~/ 7 + 1;

    return weekIndex;
  }

  static int todoTypeToInt(TodoType type) {
    switch (type) {
      case TodoType.homework:
        return 1;
      case TodoType.test:
        return 2;
      case TodoType.presentation:
        return 3;
      case TodoType.exam:
        return 4;
      default:
    }
    return 0;
  }
}

enum InfoType {
  normal,
  info,
  success,
  warning,
  error,
}
