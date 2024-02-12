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

// ignore: must_be_immutable
class TimetableOneDayWidget extends StatefulWidget {
  Timetable timetable;

  TimetableOneDayWidget({super.key, required this.timetable});

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
      Widget widget = Row(
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
                  return Container(
                    color: dayIndex == DateTime.now().weekday - 1
                        ? selectedColor
                        : unselectedColor,
                    width: lessonWidth,
                    height: lessonHeight,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          day.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
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

                TodoEvent? currEvent = TimetableManager().getRunningTodoEvent(
                  linkedSubjectName: lesson.name,
                  lessonDayTime: currMonday.add(Duration(days: dayIndex)),
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
      widgets.add(widget);
    }

    return widgets;
  }
}
