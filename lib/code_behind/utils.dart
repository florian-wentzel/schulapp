import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';

class Utils {
  static const hourKey = "hour";
  static const minuteKey = "minute";

  static const aKey = "a";
  static const rKey = "r";
  static const gKey = "g";
  static const bKey = "b";

  static bool get isMobile {
    return /*!kIsWeb && */ (Platform.isAndroid || Platform.isIOS);
  }

  static bool get isDesktop {
    return /*!kIsWeb && */
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  static void removeEmptySchoolLessons(
    Timetable timetable, {
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

        if (!lesson.name.startsWith("-") ||
            lesson.room != "---" ||
            lesson.teacher != "---") {
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

  static Future<bool> showBoolInputDialog(
    BuildContext context, {
    required String question,
    String? description,
    bool autofocus = false,
  }) async {
    bool? value = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(question),
          content: description == null ? null : Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    return value ?? false;
  }

  static Future<String?> showStringInputDialog(
    BuildContext context, {
    required String hintText,
    String? title,
    bool autofocus = false,
    int? maxInputLength,
  }) async {
    TextEditingController textController = TextEditingController();

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
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<Color?> showColorInputDialog(
    BuildContext context, {
    required String hintText,
    String? title,
    Color? pickerColor,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: const Text("Colorpicker"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, Colors.red);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
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

  static void showInfo(BuildContext context,
      {required String msg, InfoType type = InfoType.normal}) {
    Color backgroundColor;
    switch (type) {
      case InfoType.success:
        backgroundColor = Colors.green;
        break;
      case InfoType.normal:
        backgroundColor = Colors.white;
        break;
      case InfoType.warning:
        backgroundColor = Colors.yellow;
        break;
      case InfoType.error:
        backgroundColor = Colors.red;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          msg,
        ),
      ),
    );
  }

  static Color jsonToColor(Map<String, dynamic> json) {
    int a = json[aKey];
    int r = json[rKey];
    int g = json[gKey];
    int b = json[bKey];
    return Color.fromARGB(a, r, g, b);
  }

  static Timetable? getHomescreenTimetable() {
    if (TimetableManager().timetables.isEmpty) {
      return null;
    }

    try {
      if (TimetableManager().settings.mainTimetableName != null) {
        return TimetableManager().timetables.firstWhere(
              (element) =>
                  element.name == TimetableManager().settings.mainTimetableName,
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
}

enum InfoType {
  normal,
  success,
  warning,
  error,
}
