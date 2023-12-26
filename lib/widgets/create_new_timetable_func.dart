import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';

///set State after calling
Future<void> createNewTimetable(BuildContext context) async {
  Timetable? tt = await showCreateTimeTableSheet(context);
  if (tt == null) return;

  // bool? createdNewTimetable =
  await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) => CreateTimeTableScreen(timetable: tt),
    ),
  );
}

Future<Timetable?> showCreateTimeTableSheet(BuildContext context) async {
  const defaultLessonCountValue = 9;
  const maxNameLength = Timetable.maxNameLength;
  const minLessonCount = Timetable.minMaxLessonCount;
  const maxLessonCount = Timetable.maxMaxLessonCount;

  final textColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

  TextEditingController nameController = TextEditingController();
  TextEditingController lessonCountController = TextEditingController();

  String ttName = "";
  int lessonCount = -1;

  bool createPressed = false;

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Create Timetable',
              style: TextStyle(
                color: textColor,
                fontSize: 24.0, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Name",
              ),
              autofocus: true,
              maxLines: 1,
              maxLength: maxNameLength,
              textAlign: TextAlign.center,
              controller: nameController,
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Lesson Count",
              ),
              autofocus: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: lessonCountController,
            ),
            //TODO: Auswählen ob man 5 tage woche hat oder 6/7 Tage Woche
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ttName = nameController.text.trim();
                //sollte immer funktionieren da man nur Zahlen eingebe kann
                if (lessonCountController.text.isNotEmpty) {
                  lessonCount = int.parse(lessonCountController.text.trim());
                }

                createPressed = true;

                Navigator.of(context).pop();
              },
              child: const Text("Create"),
            ),
          ],
        ),
      );
    },
  );

  if (!createPressed) {
    return null;
  }

  if (ttName.isEmpty) {
    //show error
    Utils.showInfo(context,
        msg: "Timetable name can not be empty!", type: InfoType.error);
    return null;
  }
  if (lessonCount == -1) {
    //also nicht gesetzt
    lessonCount = defaultLessonCountValue;
  }
  if (lessonCount < minLessonCount || lessonCount > maxLessonCount) {
    Utils.showInfo(
      context,
      msg:
          "Lesson count must be greater than: $minLessonCount and less than: $maxLessonCount",
      type: InfoType.error,
    );
    return null;
  }

  return Timetable(
    name: nameController.text,
    maxLessonCount: lessonCount,
    schoolDays: Timetable.defaultSchoolDays(lessonCount),
    schoolTimes: Timetable.defaultSchoolTimes(lessonCount),
  );
}
