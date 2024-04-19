import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:schulapp/widgets/timetable_widget.dart';

Future<SchoolSemester?> createNewSemester(BuildContext context) async {
  SchoolSemester? schoolSemester = await showCreateSemesterSheet(context);

  return schoolSemester;
}

Future<SchoolSemester?> showCreateSemesterSheet(
  BuildContext context, {
  String? headingText,
  String? initalNameValue,
}) async {
  const maxNameLength = SchoolSemester.maxNameLength;

  headingText ??= AppLocalizationsManager.localizations.strCreateSemester;

  final textColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

  TextEditingController nameController = TextEditingController();
  if (initalNameValue != null) {
    nameController.text = initalNameValue;
  }

  bool createPressed = false;

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              headingText!,
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
              decoration: InputDecoration(
                hintText: AppLocalizationsManager.localizations.strName,
              ),
              autofocus: true,
              maxLines: 1,
              maxLength: maxNameLength,
              textAlign: TextAlign.center,
              controller: nameController,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                createPressed = true;
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizationsManager.localizations.strCreate),
            ),
          ],
        ),
      );
    },
  );

  if (!createPressed) return null;

  if (nameController.text.trim().isEmpty) {
    //show error
    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strSemesterNameCanNotBeEmpty,
      type: InfoType.error,
    );
    return null;
  }

  return SchoolSemester(
    name: nameController.text.trim(),
    subjects: [],
  );
}

///set State after calling
Future<bool?> createNewTimetable(BuildContext context) async {
  Timetable? tt = await showCreateTimetableSheet(context);
  if (tt == null) return null;

  // bool? createdNewTimetable =
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) => CreateTimeTableScreen(timetable: tt),
    ),
  );
}

Future<Timetable?> showCreateTimetableSheet(BuildContext context) async {
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
              AppLocalizationsManager.localizations.strCreateTimetable,
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
              decoration: InputDecoration(
                hintText: AppLocalizationsManager.localizations.strName,
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
              decoration: InputDecoration(
                hintText: AppLocalizationsManager.localizations.strLessonCount,
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
              child: Text(AppLocalizationsManager.localizations.strCreate),
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
    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strTimetableNameCanNotBeEmpty,
      type: InfoType.error,
    );
    return null;
  }
  if (lessonCount == -1) {
    //also nicht gesetzt
    lessonCount = defaultLessonCountValue;
  }
  if (lessonCount < minLessonCount || lessonCount > maxLessonCount) {
    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strLessonCountMustBeInRange(
        maxLessonCount,
        minLessonCount,
      ),
      type: InfoType.error,
    );
    return null;
  }

  return Timetable(
    name: ttName,
    maxLessonCount: lessonCount,
    schoolDays: Timetable.defaultSchoolDays(lessonCount),
    schoolTimes: Timetable.defaultSchoolTimes(lessonCount),
  );
}

///setState after calling this method
Future<bool?> showSchoolLessonHomePopUp(
  BuildContext context,
  SchoolLesson lesson,
  SchoolDay day,
  SchoolTime schoolTime,
  TodoEvent? event,
  String heroString,
) async {
  return Navigator.push<bool>(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) => CustomPopUpShowLesson(
        heroString: heroString,
        lesson: lesson,
        day: day,
        schoolTime: schoolTime,
        event: event,
      ),
      barrierDismissible: true,
      fullscreenDialog: true,
    ),
  );
}

Future<String?> showSelectSubjectNameSheet(
  BuildContext context, {
  required String title,
  bool allowCustomNames = false,
}) async {
  Timetable? selectedTimetable = Utils.getHomescreenTimetable();
  if (selectedTimetable == null) return null;

  List<SchoolLessonPrefab> selectedTimetablePrefabs =
      Utils.createLessonPrefabsFromTt(selectedTimetable);

  selectedTimetablePrefabs.sort(
    (a, b) => a.name.compareTo(b.name),
  );

  selectedTimetablePrefabs.add(
    SchoolLessonPrefab(
      name: AppLocalizationsManager.localizations.strCustomSubject,
      room: "",
      teacher: "",
      color: Colors.transparent,
    ),
  );

  String? selectdSubjectName;

  await Utils.showListSelectionBottomSheet(
    context,
    title: title,
    items: selectedTimetablePrefabs,
    itemBuilder: (context, index) => ListTile(
      title: Text(selectedTimetablePrefabs[index].name),
      onTap: () {
        selectdSubjectName = selectedTimetablePrefabs[index].name;
        Navigator.of(context).pop();
      },
    ),
  );

  return selectdSubjectName;
}

Future<Timetable?> showSelectTimetableSheet(
  BuildContext context, {
  required String title,
}) async {
  List<Timetable> timetables = TimetableManager().timetables;

  Timetable? selectedTimetable;

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
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: timetables.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(timetables[index].name),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TimetableScreen(
                            title: AppLocalizationsManager.localizations
                                .strTimetableWithName(
                              timetables[index].name,
                            ),
                            timetable: timetables[index],
                          ),
                        ));
                      },
                      icon: const Icon(Icons.info),
                    ),
                    onTap: () {
                      selectedTimetable = timetables[index];
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  return selectedTimetable;
}
