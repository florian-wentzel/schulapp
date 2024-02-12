import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/school_grade_subject_widget.dart';
import 'package:schulapp/widgets/time_to_next_lesson_widget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';

// ignore: must_be_immutable
class TimetableWidget extends StatefulWidget {
  Timetable timetable;

  TimetableWidget({super.key, required this.timetable});

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  @override
  Widget build(BuildContext context) {
    const double minLessonWidth = 100;
    const double minLessonHeight = 50;
    double lessonWidth = (MediaQuery.of(context).size.width * 0.8) /
        (widget.timetable.schoolDays.length + 1);
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }

    double lessonHeight = (MediaQuery.of(context).size.height * 0.8) /
        (widget.timetable.maxLessonCount);
    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }

    final selectedColor = Theme.of(context)
        .colorScheme
        .secondary
        .withAlpha(30); // Color.fromARGB(30, 255, 255, 255);

    const unselectedColor = Colors.transparent;

    DateTime currMonday = Utils.getWeekDay(DateTime.now(), DateTime.monday);

    Timetable tt = widget.timetable;

    return Center(
      child: Row(
        children: List.generate(
          tt.schoolDays.length + 1,
          (dayIndex) {
            if (dayIndex == 0) {
              return Column(
                children: List.generate(
                  tt.schoolTimes.length + 1,
                  (lessonIndex) {
                    if (lessonIndex == 0) {
                      return SizedBox(
                        width: lessonWidth,
                        height: lessonHeight,
                        child: Center(
                          child: TimeToNextLessonWidget(
                            timetable: tt,
                            onNewLessonCB: () {
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      );
                    }
                    final schoolTime = tt.schoolTimes[lessonIndex - 1];
                    String startString = schoolTime.getStartString();
                    String endString = schoolTime.getEndString();
                    return Container(
                      color: schoolTime.isCurrentlyRunning()
                          ? selectedColor
                          : unselectedColor,
                      width: lessonWidth,
                      height: lessonHeight,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Column(
                            children: [
                              Text(
                                startString,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                endString,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            final day = tt.schoolDays[dayIndex - 1];

            return Column(
              children: List.generate(
                day.lessons.length + 1,
                (lessonIndex) {
                  if (lessonIndex == 0) {
                    return Container(
                      color: dayIndex == DateTime.now().weekday
                          ? selectedColor
                          : unselectedColor,
                      width: lessonWidth,
                      height: lessonHeight,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            day.name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  final schoolTime = tt.schoolTimes[lessonIndex - 1];
                  final lesson = day.lessons[lessonIndex - 1];
                  final heroString = "$lessonIndex:$dayIndex";

                  TodoEvent? currEvent = TimetableManager().getRunningTodoEvent(
                    linkedSubjectName: lesson.name,
                    lessonDayTime: currMonday.add(Duration(days: dayIndex - 1)),
                    endTime: schoolTime.end,
                  );

                  return InkWell(
                    onTap: lesson.name == SchoolLesson.emptyLessonName
                        ? null
                        : () async {
                            await showSchoolLessonHomePopUp(
                              context,
                              lesson,
                              day,
                              schoolTime,
                              heroString,
                            );
                            if (!mounted) return;
                            setState(() {});
                          },
                    child: Container(
                      color: dayIndex == DateTime.now().weekday ||
                              schoolTime.isCurrentlyRunning()
                          ? selectedColor
                          : unselectedColor,
                      width: lessonWidth,
                      height: lessonHeight,
                      child: Center(
                        child: Hero(
                          tag: heroString,
                          flightShuttleBuilder:
                              (context, animation, __, ___, ____) {
                            const targetAlpha = 220;

                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, _) {
                                return Container(
                                  width: lessonWidth * 0.8,
                                  height: lessonHeight * 0.8,
                                  decoration: BoxDecoration(
                                    color: ColorTween(
                                      begin: lesson.color,
                                      end: Theme.of(context)
                                          .cardColor
                                          .withAlpha(targetAlpha),
                                    ).lerp(animation.value),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: lessonWidth * 0.8,
                            height: lessonHeight * 0.8,
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            // padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: lesson.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        lesson.name,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      Text(
                                        lesson.room,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: currEvent != null,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "!",
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.dmSerifDisplay(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 4
                                                ..color = Theme.of(context)
                                                    .canvasColor,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: currEvent != null,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "!",
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.dmSerifDisplay(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: currEvent?.getColor(),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomPopUpShowLesson extends StatefulWidget {
  SchoolLesson lesson;
  SchoolDay day;
  SchoolTime schoolTime;
  String heroString;

  CustomPopUpShowLesson({
    super.key,
    required this.heroString,
    required this.day,
    required this.lesson,
    required this.schoolTime,
  });

  @override
  State<CustomPopUpShowLesson> createState() => _CustomPopUpShowLessonState();
}

class _CustomPopUpShowLessonState extends State<CustomPopUpShowLesson> {
  @override
  Widget build(BuildContext context) {
    return CustomPopUp(
      heroObject: widget.heroString,
      color: Theme.of(context).cardColor,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final selectedSemester = Utils.getMainSemester();
    final selectedSubject =
        selectedSemester?.getSubjectByName(widget.lesson.name);

    return Column(
      children: [
        Text(
          widget.lesson.name,
          style: TextStyle(
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
            // decoration: TextDecoration.underline,
            fontSize: 42.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
          width: 150,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.lesson.color,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        FittedBox(
          // fit: BoxFit.fitWidth,
          child: Text(
            "Room: ${widget.lesson.room}",
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: 42.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          widget.lesson.teacher,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            fontSize: 42.0,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        _showGradesWidget(
          context,
          lesson: widget.lesson,
          selectedSemester: selectedSemester,
          selectedSubject: selectedSubject,
        ),
        const Spacer(
          flex: 2,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: const Icon(
              Icons.close,
              size: 42,
            ),
          ),
        ),
      ],
    );
  }

  Widget _showGradesWidget(
    BuildContext context, {
    required SchoolLesson lesson,
    SchoolSemester? selectedSemester,
    SchoolGradeSubject? selectedSubject,
  }) {
    if (selectedSemester != null && selectedSubject != null) {
      return InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SchoolGradeSubjectScreen(
                subject: selectedSubject,
                semester: selectedSemester,
              ),
            ),
          );
          if (mounted) {
            setState(() {});
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).canvasColor,
          ),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          child: SchoolGradeSubjectWidget(
            subject: selectedSubject,
            semester: selectedSemester,
          ),
        ),
      );
    }
    String errorMsg = "";
    String buttonText = "";
    void Function() buttonFunc = () {};

    if (selectedSubject == null) {
      errorMsg =
          "Your Selected Semester does not\n contain a Subject named: ${lesson.name}";
      buttonText = "Create a Subject named: ${lesson.name}";
      buttonFunc = () {
        selectedSemester!.subjects.add(
          SchoolGradeSubject(
            name: lesson.name,
            gradeGroups: TimetableManager().settings.defaultGradeGroups,
          ),
        );
        if (mounted) {
          setState(() {});
        }
        SaveManager().saveSemester(selectedSemester);
      };
    }
    if (selectedSemester == null) {
      errorMsg =
          "You did not select a Semester\n to show on homescreen.\nGo to the Grades page\nand select a Semester:)";
      buttonText = "Go to Grades screen";
      buttonFunc = () {
        context.go(GradesScreen.route);
      };
    }
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).canvasColor,
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              errorMsg,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: buttonFunc,
            child: Text(
              buttonText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
