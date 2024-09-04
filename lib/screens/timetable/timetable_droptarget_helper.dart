import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';

void onLessonWidgetTap(
  BuildContext context, {
  required Timetable timetable,
  required SchoolLesson lesson,
  required SchoolDay day,
  required SchoolTime schoolTime,
  required String heroString,
  required void Function() setState,
}) async {
  await Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) => CustomPopUpCreateTimetable(
        heroString: heroString,
        schoolDay: day,
        schoolLesson: lesson,
        schoolTime: schoolTime,
      ),
      barrierDismissible: true,
      fullscreenDialog: true,
    ),
  );

  timetable.changeLessonNumberVisibility(
    TimetableManager().settings.getVar(Settings.showLessonNumbersKey),
  );

  setState.call();
}

// ignore: must_be_immutable
class CustomPopUpCreateTimetable extends StatefulWidget {
  SchoolTime schoolTime;
  SchoolLesson schoolLesson;
  SchoolDay schoolDay;
  String heroString;

  CustomPopUpCreateTimetable({
    super.key,
    required this.heroString,
    required this.schoolDay,
    required this.schoolLesson,
    required this.schoolTime,
  });

  @override
  State<CustomPopUpCreateTimetable> createState() =>
      _CustomPopUpCreateTimetableState();
}

class _CustomPopUpCreateTimetableState
    extends State<CustomPopUpCreateTimetable> {
  String _name = "";
  String _room = "";
  String _teacher = "";
  Color _color = Colors.black;

  // TimeOfDay _start = const TimeOfDay(hour: 0, minute: 0);
  // TimeOfDay _end = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    _name = widget.schoolLesson.name;
    _room = widget.schoolLesson.room;
    _teacher = widget.schoolLesson.teacher;
    _color = Color.fromARGB(
      widget.schoolLesson.color.alpha,
      widget.schoolLesson.color.red,
      widget.schoolLesson.color.green,
      widget.schoolLesson.color.blue,
    );

    // _start = TimeOfDay(
    //   hour: widget.schoolTime.start.hour,
    //   minute: widget.schoolTime.start.minute,
    // );
    // _end = TimeOfDay(
    //   hour: widget.schoolTime.end.hour,
    //   minute: widget.schoolTime.end.minute,
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopUp(
      heroObject: widget.heroString,
      color: Theme.of(context).cardColor,
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () {
              SchoolLesson defaultSchoolLesson =
                  SchoolLesson.defaultSchoolLesson;
              widget.schoolLesson.name = defaultSchoolLesson.name;
              widget.schoolLesson.room = defaultSchoolLesson.room;
              widget.schoolLesson.teacher = defaultSchoolLesson.teacher;
              widget.schoolLesson.color = defaultSchoolLesson.color;

              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 32,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            String? input = await Utils.showStringInputDialog(
              context,
              hintText: AppLocalizationsManager.localizations.strSubjectName,
              initText: _name,
              autofocus: true,
              maxInputLength: SchoolLesson.maxNameLength,
            );

            if (input == null) return;
            input = input.trim(); //mach so leerzeichen weg und so

            if (input.isEmpty) {
              if (mounted) {
                Utils.showInfo(
                  context,
                  msg: AppLocalizationsManager
                      .localizations.strNameCanNotBeEmpty,
                  type: InfoType.error,
                );
              }
              return;
            }

            _name = input;
            setState(() {});
          },
          child: Text(
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
              // decoration: TextDecoration.underline,
              fontSize: 42.0,
              fontWeight: FontWeight.bold,
            ),
            _name,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        InkWell(
          onTap: () async {
            Color? input = await Utils.showColorInputDialog(
              context,
              pickerColor: _color,
            );

            if (input == null) return;

            _color = input;
            setState(() {});
          },
          child: Container(
            width: 150,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _color,
            ),
          ),
        ),
        // const SizedBox(
        //   height: 12,
        // ),
        const Spacer(),
        // FittedBox(
        //   fit: BoxFit.fitWidth,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       InkWell(
        //         onTap: () async {
        //           TimeOfDay? input = await showTimePicker(
        //               context: context, initialTime: widget.schoolTime.start);

        //           if (input == null) return;

        //           _start = input;
        //           setState(() {});
        //         },
        //         child: Text(
        //           _start.format(context),
        //           style: TextStyle(
        //             color: Theme.of(context).textTheme.bodyLarge?.color ??
        //                 Colors.white,
        //             fontSize: 64.0,
        //             // decoration: TextDecoration.underline,
        //           ),
        //         ),
        //       ),
        //       Text(
        //         " - ",
        //         style: TextStyle(
        //           color: Theme.of(context).textTheme.bodyLarge?.color ??
        //               Colors.white,
        //           fontSize: 64.0,
        //         ),
        //       ),
        //       InkWell(
        //         onTap: () async {
        //           TimeOfDay? input = await showTimePicker(
        //               context: context, initialTime: widget.schoolTime.end);

        //           if (input == null) return;

        //           _end = input;
        //           setState(() {});
        //         },
        //         child: Text(
        //           _end.format(context),
        //           style: TextStyle(
        //             color: Theme.of(context).textTheme.bodyLarge?.color ??
        //                 Colors.white,
        //             fontSize: 64.0,
        //             // decoration: TextDecoration.underline,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          height: 12,
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: InkWell(
            onTap: () async {
              String? input = await Utils.showStringInputDialog(
                context,
                hintText: AppLocalizationsManager.localizations.strRoom,
                initText: _room,
                maxInputLength: SchoolLesson.maxRoomLength,
                autofocus: true,
              );

              if (input == null) return;
              input = input.trim();

              if (input.isEmpty && mounted) {
                bool? update = await Utils.showBoolInputDialog(
                  context,
                  question: AppLocalizationsManager.localizations
                      .strWarningXIsEmptyContinue(
                    AppLocalizationsManager.localizations.strRoom,
                  ),
                );
                if (!update) {
                  return;
                }
              }

              _room = input;
              setState(() {});
            },
            child: Text(
              AppLocalizationsManager.localizations.strRoomX(_room),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
                fontSize: 42.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            String? input = await Utils.showStringInputDialog(
              context,
              hintText: AppLocalizationsManager.localizations.strTeacher,
              initText: _teacher,
              autofocus: true,
            );

            if (input == null) return;
            input = input.trim(); //mach so leerzeichen weg und so

            if (input.isEmpty && mounted) {
              bool? update = await Utils.showBoolInputDialog(
                context,
                question: AppLocalizationsManager.localizations
                    .strWarningXIsEmptyContinue(
                  AppLocalizationsManager.localizations.strTeacher,
                ),
              );
              if (!update) {
                return;
              }
            }

            _teacher = input;
            setState(() {});
          },
          child: Text(
            _teacher.isEmpty ? "   " : _teacher,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: 42.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(
          flex: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close,
                size: 42,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _save();
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.check,
                size: 42,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _save() {
    widget.schoolLesson.name = _name;
    widget.schoolLesson.room = _room;
    widget.schoolLesson.teacher = _teacher;
    widget.schoolLesson.color = _color;
    // widget.schoolTime.start = _start;
    // widget.schoolTime.end = _end;
  }
}

// just for the time
// ignore: must_be_immutable
class CustomPopUpChangeSubjectTime extends StatefulWidget {
  SchoolTime schoolTime;

  CustomPopUpChangeSubjectTime({super.key, required this.schoolTime});

  @override
  State<CustomPopUpChangeSubjectTime> createState() =>
      _CustomPopUpChangeSubjectTimeState();
}

class _CustomPopUpChangeSubjectTimeState
    extends State<CustomPopUpChangeSubjectTime> {
  TimeOfDay _start = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    _start = TimeOfDay(
      hour: widget.schoolTime.start.hour,
      minute: widget.schoolTime.start.minute,
    );
    _end = TimeOfDay(
      hour: widget.schoolTime.end.hour,
      minute: widget.schoolTime.end.minute,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  TimeOfDay? input = await showTimePicker(
                      context: context, initialTime: _start);

                  if (input == null) return;

                  _start = input;
                  setState(() {});
                },
                child: Text(
                  _start.format(context),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.white,
                    fontSize: 64.0,
                    // decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                " - ",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  fontSize: 64.0,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? input =
                      await showTimePicker(context: context, initialTime: _end);

                  if (input == null) return;

                  _end = input;
                  setState(() {});
                },
                child: Text(
                  _end.format(context),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.white,
                    fontSize: 64.0,
                    // decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(
          flex: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close,
                size: 42,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_start.isBefore(_end)) {
                  _save();
                  Navigator.of(context).pop();
                } else {
                  Utils.showInfo(
                    context,
                    msg: AppLocalizationsManager.localizations.strTimeNotValid,
                    type: InfoType.error,
                  );
                }
              },
              child: const Icon(
                Icons.check,
                size: 42,
              ),
            ),
          ],
        ),
        const Spacer()
      ],
    );
  }

  void _save() {
    widget.schoolTime.start = _start;
    widget.schoolTime.end = _end;
  }
}
