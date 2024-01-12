import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/time_table.dart';
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
    List<Widget> widgets = [];

    for (int schoolDayIndex = 0;
        schoolDayIndex < widget.timetable.schoolDays.length;
        schoolDayIndex++) {
      SchoolDay day = widget.timetable.schoolDays[schoolDayIndex];

      Widget dt = DataTable(
        columns: [
          DataColumn(
            label: Expanded(
              child: TimeToNextLessonWidget(
                timetable: widget.timetable,
                onNewLessonCB: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Center(
                child: Text(
                  day.name,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
        rows: List.generate(
          widget.timetable.maxLessonCount,
          (rowIndex) {
            final schoolTime = widget.timetable.schoolTimes[rowIndex];
            final startString = schoolTime.getStartString();
            final endString = schoolTime.getEndString();

            final heroString = "$rowIndex:$schoolDayIndex";
            final schoolDay = widget.timetable.schoolDays[schoolDayIndex];
            final lesson = schoolDay.lessons[rowIndex];

            return DataRow(
              selected: schoolTime.isCurrentlyRunning(),
              cells: [
                DataCell(
                  Center(
                    child: Text(
                      "$startString\n$endString",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  onTap: () async {
                    await showSchoolLessonHomePopUp(
                      context,
                      lesson,
                      schoolDay,
                      widget.timetable.schoolTimes[rowIndex],
                      heroString,
                    );
                    if (!mounted) return;
                    setState(() {});
                  },
                  Center(
                    child: Hero(
                      tag: heroString,
                      flightShuttleBuilder:
                          (context, animation, __, ___, ____) {
                        const targetAlpha = 220;

                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            return Container(
                              width: 100,
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
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: 100,
                        // margin: const EdgeInsets.symmetric(vertical: 12),
                        // padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: lesson.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              lesson.name,
                            ),
                            Text(
                              lesson.room,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      widgets.add(
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: dt,
          ),
        ),
      );
    }
    return widgets;
  }
}
