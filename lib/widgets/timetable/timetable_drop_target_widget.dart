import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/time_table/timetable_droptarget_helper.dart';

class TimetableDropTargetWidget extends StatefulWidget {
  final Timetable timetable;
  const TimetableDropTargetWidget({
    super.key,
    required this.timetable,
  });

  @override
  State<TimetableDropTargetWidget> createState() =>
      _TimetableDropTargetWidgetState();
}

class _TimetableDropTargetWidgetState extends State<TimetableDropTargetWidget> {
  static const double minLessonWidth = 100;
  static const double minLessonHeight = 50;

  double lessonHeight = minLessonHeight;
  double lessonWidth = minLessonWidth;

  @override
  Widget build(BuildContext context) {
    lessonWidth = (MediaQuery.of(context).size.width * 0.8) /
        (widget.timetable.schoolDays.length + 1);
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }
    final correctedHeight =
        MediaQuery.of(context).size.height - kBottomNavigationBarHeight;

    lessonHeight = (correctedHeight * 0.7) / (widget.timetable.maxLessonCount);
    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }
    return SizedBox(
      width: lessonWidth * (widget.timetable.schoolDays.length + 1),
      height: lessonHeight * (widget.timetable.maxLessonCount + 1),
      child: _createTimetable(),
    );
  }

  Widget _createTimetable() {
    Timetable tt = widget.timetable;
    List<Widget> dayWidgets = [];

    dayWidgets.add(_createTimes());

    for (int dayIndex = 0; dayIndex < tt.schoolDays.length; dayIndex++) {
      Widget dayWidget = _createDay(
        dayIndex: dayIndex,
      );
      dayWidgets.add(dayWidget);
    }

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dayWidgets,
        ),
      ),
    );
  }

  Widget _createTimes() {
    final tt = widget.timetable;

    List<Widget> timeWidgets = [];

    timeWidgets.add(
      SizedBox(
        width: lessonWidth,
        height: lessonHeight,
        child: Center(
          child: Text(
            AppLocalizationsManager.localizations.strTimes,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    for (int lessonIndex = 0;
        lessonIndex < tt.schoolTimes.length;
        lessonIndex++) {
      final schoolTime = tt.schoolTimes[lessonIndex];
      String startString = schoolTime.getStartString();
      String endString = schoolTime.getEndString();

      Widget timeWidget = Hero(
        tag: schoolTime,
        child: InkWell(
          onTap: () async {
            await Utils.showCustomPopUp(
              context: context,
              heroObject: schoolTime,
              flightShuttleBuilder: (p0, animation, p2, p3, p4) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      color: ColorTween(
                        begin: Colors.transparent,
                        end: Theme.of(context).cardColor.withAlpha(220),
                      ).lerp(animation.value),
                    );
                  },
                );
              },
              body: CustomPopUpChangeSubjectTime(
                schoolTime: schoolTime,
              ),
            );
            setState(() {});
          },
          child: SizedBox(
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
          ),
        ),
      );

      timeWidgets.add(timeWidget);
    }

    return Column(
      children: timeWidgets,
    );
  }

  Widget _createDay({required int dayIndex}) {
    final tt = widget.timetable;
    final day = widget.timetable.schoolDays[dayIndex];

    List<Widget> lessonWidgets = [];

    lessonWidgets.add(
      SizedBox(
        width: lessonWidth,
        height: lessonHeight,
        child: Center(
          child: SizedBox(
            width: lessonWidth * 0.8,
            height: lessonHeight * 0.8,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                children: [
                  Text(
                    day.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    for (int lessonIndex = 0; lessonIndex < day.lessons.length; lessonIndex++) {
      final currSchoolTime = tt.schoolTimes[lessonIndex];
      final lesson = day.lessons[lessonIndex];
      final heroString = "$lessonIndex:$dayIndex";

      Widget lessonWidget = DragTarget(
        onWillAcceptWithDetails:
            (DragTargetDetails<SchoolLessonPrefab?> schoolLessonPrefab) {
          return schoolLessonPrefab.data != null;
        },
        onAcceptWithDetails:
            (DragTargetDetails<SchoolLessonPrefab> schoolLessonPrefab) {
          lesson.setFromPrefab(schoolLessonPrefab.data);
        },
        builder: (context, candidateData, rejectedData) {
          return InkWell(
            onTap: SchoolLesson.isEmptyLessonName(lesson.name)
                ? null
                : () => onLessonWidgetTap(
                      context,
                      timetable: tt,
                      day: day,
                      heroString: heroString,
                      lesson: lesson,
                      schoolTime: currSchoolTime,
                      setState: () {
                        setState(() {});
                      },
                    ),
            child: SizedBox(
              width: lessonWidth,
              height: lessonHeight,
              child: Center(
                child: Hero(
                  tag: heroString,
                  flightShuttleBuilder: (context, animation, __, ___, ____) {
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: lessonWidth * 0.8,
                    height: lessonHeight * 0.8,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
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
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                lesson.room,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall,
                                overflow: TextOverflow.fade,
                              ),
                            ],
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
      );

      lessonWidgets.add(lessonWidget);
    }

    return Column(
      children: lessonWidgets,
    );
  }
}
