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
import 'package:schulapp/screens/notes_screen.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/school_grade_subject_widget.dart';
import 'package:schulapp/widgets/time_to_next_lesson_widget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';
import 'package:schulapp/widgets/todo_event_list_item_widget.dart';
import 'package:schulapp/widgets/todo_event_util_functions.dart';

// ignore: must_be_immutable
class TimetableWidget extends StatefulWidget {
  Timetable timetable;
  bool showTodoEvents;

  TimetableWidget(
      {super.key, required this.timetable, required this.showTodoEvents});

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
                    DateTime lessonDayTime =
                        currMonday.add(Duration(days: dayIndex - 1));

                    if (lessonDayTime.isBefore(
                        DateTime.now().subtract(const Duration(days: 1)))) {
                      lessonDayTime = lessonDayTime.add(
                        const Duration(days: 7),
                      );
                    }

                    return Container(
                      color: dayIndex == DateTime.now().weekday
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
                                day.name,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                Utils.dateToString(
                                  lessonDayTime,
                                  showYear: false,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  final schoolTime = tt.schoolTimes[lessonIndex - 1];
                  final lesson = day.lessons[lessonIndex - 1];
                  final heroString = "$lessonIndex:$dayIndex";

                  TodoEvent? currEvent;

                  if (widget.showTodoEvents) {
                    DateTime lessonDayTime =
                        currMonday.add(Duration(days: dayIndex - 1)).copyWith(
                              hour: schoolTime.start.hour,
                              minute: schoolTime.start.minute,
                            );

                    if (lessonDayTime.isBefore(DateTime.now())) {
                      lessonDayTime = lessonDayTime.add(
                        const Duration(days: 7),
                      );
                    }

                    currEvent = TimetableManager().getRunningTodoEvent(
                      linkedSubjectName: lesson.name,
                      lessonDayTime: lessonDayTime,
                      endTime: schoolTime.end,
                    );
                  }

                  return InkWell(
                    onTap: SchoolLesson.isEmptyLessonName(lesson.name)
                        ? null
                        : () async {
                            bool? showNewTodoEvent =
                                await showSchoolLessonHomePopUp(
                              context,
                              lesson,
                              day,
                              schoolTime,
                              currEvent,
                              heroString,
                            );

                            if (!mounted) return;
                            setState(() {});

                            if (showNewTodoEvent == null) return;
                            if (!showNewTodoEvent) return;

                            DateTime dateTime = Utils.getWeekDay(
                              DateTime.now(),
                              DateTime.monday,
                            ).copyWith(
                              hour: schoolTime.start.hour,
                              minute: schoolTime.start.minute,
                            );

                            dateTime = dateTime.add(
                              Duration(days: dayIndex - 1),
                            );

                            if (dateTime.isBefore(DateTime.now())) {
                              dateTime = dateTime.add(const Duration(days: 7));
                            }

                            TodoEvent? event = TodoEvent(
                              key: TimetableManager().getNextSchoolEventKey(),
                              name: "",
                              linkedSubjectName: lesson.name,
                              endTime: dateTime,
                              type: TodoType.test,
                              desciption: "",
                              finished: false,
                            );

                            event = await createNewTodoEventSheet(
                              context,
                              linkedSubjectName: lesson.name,
                              event: event,
                            );

                            if (event == null) return;
                            TimetableManager().addOrChangeTodoEvent(event);

                            if (!mounted) return;
                            Utils.showInfo(
                              context,
                              type: InfoType.success,
                              msg:
                                  "Task successfully created:\n${event.linkedSubjectName}, ${TodoEvent.typeToString(event.type)}: ${event.name}\n on ${Utils.dateToString(event.endTime)}",
                            );

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
  TodoEvent? event;

  CustomPopUpShowLesson({
    super.key,
    required this.heroString,
    required this.day,
    required this.lesson,
    required this.schoolTime,
    this.event,
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
      padding: const EdgeInsets.all(0),
    );
  }

  Widget _body(BuildContext context) {
    final selectedSemester = Utils.getMainSemester();
    final selectedSubject =
        selectedSemester?.getSubjectByName(widget.lesson.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.center,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: widget.lesson.color,
          ),
        ),
        Column(
          children: [
            Text(
              widget.lesson.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.white,
                // decoration: TextDecoration.underline,
                fontSize: 42.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    widget.lesson.teacher,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.white,
                      fontSize: 42.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 10,
                  ),
                  Text(
                    widget.lesson.room,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.white,
                      fontSize: 42.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 4,
              ),
              _showGradesWidget(
                context,
                lesson: widget.lesson,
                selectedSemester: selectedSemester,
                selectedSubject: selectedSubject,
              ),
              _showTodoEventWidget(
                todoEvent: widget.event,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Icon(
                    Icons.close,
                    size: 42,
                  ),
                ),
              ),
              Visibility(
                visible: widget.event == null,
                replacement: ElevatedButton(
                  onPressed: widget.event == null
                      ? null
                      : () async {
                          bool removeTodoEvent =
                              await Utils.showBoolInputDialog(
                            context,
                            question:
                                "Are you sure that you want to delete the Task: ${widget.event!.linkedSubjectName}, ${TodoEvent.typeToString(widget.event!.type)}",
                            description:
                                "(on ${Utils.dateToString(widget.event!.endTime)})",
                          );
                          if (!removeTodoEvent) return;

                          TimetableManager().removeTodoEvent(widget.event!);

                          if (!mounted) return;

                          Navigator.of(context).pop();
                        },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 42,
                    ),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    //true damit danach das create new TodoEventSheet aufgerufen wird
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: const Icon(
                      Icons.add_box,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

//8.4
  Widget _showTodoEventWidget({
    TodoEvent? todoEvent,
  }) {
    if (todoEvent != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).canvasColor,
        ),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        child: TodoEventListItemWidget(
          event: todoEvent,
          showTimeLeft: false,
          removeHero: true,
          onDeleteSwipe: () {},
          onPressed: () {
            todoEvent.finished = !todoEvent.finished;
            //damit es gespeichert wird
            TimetableManager().addOrChangeTodoEvent(todoEvent);
            setState(() {});
          },
          onInfoPressed: () async {
            context.go(NotesScreen.route, extra: todoEvent);
          },
          onLongPressed: () {
            context.go(NotesScreen.route, extra: todoEvent);
          },
        ),
      );
    }
    return Container();
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
            showName: false,
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
