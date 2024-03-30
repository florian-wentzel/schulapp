import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/time_to_next_lesson_widget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/todo_event_util_functions.dart';

// ignore: must_be_immutable
class TimetableOneDayWidget extends StatefulWidget {
  Timetable timetable;
  bool showTodoEvents;

  TimetableOneDayWidget({
    super.key,
    required this.timetable,
    required this.showTodoEvents,
  });

  @override
  State<TimetableOneDayWidget> createState() => _TimetableOneDayWidgetState();
}

class _TimetableOneDayWidgetState extends State<TimetableOneDayWidget> {
  final PageController _pageController = PageController(
    initialPage: Utils.getCurrentWeekDayIndex(),
  );

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: _createDayWidgets(),
    );
  }

  List<Widget> _createDayWidgets() {
    Timetable tt = widget.timetable;
    List<Widget> widgets = [];

    const double minLessonWidth = 100;
    const double minLessonHeight = 50;
    double lessonWidth = (MediaQuery.of(context).size.width * 0.8) / 2;
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }

    double lessonHeight = (MediaQuery.of(context).size.height * 0.8) /
        (widget.timetable.maxLessonCount + 1);
    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }

    final selectedColor = Theme.of(context)
        .colorScheme
        .secondary
        .withAlpha(30); // Color.fromARGB(30, 255, 255, 255);

    const unselectedColor = Colors.transparent;

    DateTime currMonday = Utils.getWeekDay(DateTime.now(), DateTime.monday);

    for (int dayIndex = 0; dayIndex < tt.schoolDays.length; dayIndex++) {
      SchoolDay day = tt.schoolDays[dayIndex];
      Widget returnWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: List.generate(
              tt.schoolTimes.length + 1,
              (int lessonIndex) {
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
          ),
          Column(
            children: List.generate(
              day.lessons.length + 1,
              (lessonIndex) {
                if (lessonIndex == 0) {
                  DateTime lessonDayTime =
                      currMonday.add(Duration(days: dayIndex));

                  if (lessonDayTime.isBefore(
                      DateTime.now().subtract(const Duration(days: 1)))) {
                    lessonDayTime = lessonDayTime.add(
                      const Duration(days: 7),
                    );
                  }

                  return InkWell(
                    onTap: dayIndex != DateTime.now().weekday - 1
                        ? () {
                            int currDayIndex = Utils.getCurrentWeekDayIndex();
                            _pageController.animateToPage(
                              currDayIndex,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCirc,
                            );
                          }
                        : null,
                    child: Container(
                      color: dayIndex == DateTime.now().weekday - 1
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
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
                    ),
                  );
                }
                final schoolTime = tt.schoolTimes[lessonIndex - 1];
                final lesson = day.lessons[lessonIndex - 1];
                final heroString = "$lessonIndex:$dayIndex";

                Color color = unselectedColor;

                if (schoolTime.isCurrentlyRunning()) {
                  color = selectedColor;
                }

                TodoEvent? currEvent;

                if (widget.showTodoEvents) {
                  DateTime lessonDayTime =
                      currMonday.add(Duration(days: dayIndex)).copyWith(
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
                            Duration(days: dayIndex),
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
                    color: color,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                              ..color =
                                                  Theme.of(context).canvasColor,
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
          ),
        ],
      );
      widgets.add(returnWidget);
    }

    return widgets;
  }
}
