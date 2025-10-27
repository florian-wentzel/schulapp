import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/high_contrast_text.dart';

class TimetableOneDayDropTargetWidget extends StatefulWidget {
  final Timetable timetable;

  const TimetableOneDayDropTargetWidget({
    super.key,
    required this.timetable,
  });

  @override
  State<TimetableOneDayDropTargetWidget> createState() =>
      _TimetableOneDayDropTargetWidgetState();
}

class _TimetableOneDayDropTargetWidgetState
    extends State<TimetableOneDayDropTargetWidget> {
  static const double minLessonWidth = 100;
  static const double minLessonHeight = 50;

  double lessonHeight = minLessonHeight;
  double lessonWidth = minLessonWidth;

  @override
  Widget build(BuildContext context) {
    lessonWidth = MediaQuery.of(context).size.width * 0.8 / 2;
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }

    lessonHeight = MediaQuery.of(context).size.height *
        0.7 /
        (widget.timetable.maxLessonCount + 1);

    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }

    return SizedBox(
      width: lessonWidth * 2,
      height: lessonHeight * (widget.timetable.schoolTimes.length + 1),
      child: PageView.builder(
        controller: PageController(
          initialPage: Utils.getCurrentWeekDayIndex(),
        ),
        itemCount: widget.timetable.schoolDays.length,
        itemBuilder: _dayBuilder,
      ),
    );
  }

  Widget _dayBuilder(BuildContext context, int dayIndex) {
    final tt = widget.timetable;
    final day = tt.schoolDays[dayIndex];

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
              child: Text(
                day.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    final highContrastEnabled = TimetableManager().settings.getVar(
          Settings.highContrastTextOnHomescreenKey,
        );

    for (int lessonIndex = 0; lessonIndex < day.lessons.length; lessonIndex++) {
      final lesson = day.lessons[lessonIndex];
      final heroString = "$lessonIndex:$dayIndex";

      Widget lessonWidget = DragTarget(
        onWillAcceptWithDetails:
            (DragTargetDetails<SchoolLessonPrefab?> schoolLessonPrefab) {
          return schoolLessonPrefab.data != null;
        },
        onAcceptWithDetails:
            (DragTargetDetails<SchoolLessonPrefab> schoolLessonPrefab) {
          day.setLessonFromPrefab(lessonIndex, schoolLessonPrefab.data);
          setState(() {});
        },
        builder: (context, candidateData, rejectedData) {
          return InkWell(
            onTap: SchoolLesson.isEmptyLesson(lesson)
                ? null
                : () async {
                    final prefabTuble = await showCreateNewPrefabBottomSheet(
                      context,
                      prefab:
                          SchoolLessonPrefab.fromSchoolLesson(lesson: lesson),
                    );

                    if (prefabTuble == null) return;

                    final prefab = prefabTuble.$1;
                    final delete = prefabTuble.$2;

                    if (delete) {
                      day.setLessonFromPrefab(lessonIndex, null);
                    } else {
                      day.setLessonFromPrefab(lessonIndex, prefab);
                    }

                    setState(() {});
                  },
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
                              HighContrastText(
                                text: lesson.name,
                                textStyle:
                                    Theme.of(context).textTheme.labelSmall,
                                highContrastEnabled: highContrastEnabled,
                                outlineWidth: 1,
                              ),
                              HighContrastText(
                                text: lesson.room,
                                textStyle:
                                    Theme.of(context).textTheme.labelSmall,
                                highContrastEnabled: highContrastEnabled,
                                outlineWidth: 1,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createTimes(),
        Column(
          children: lessonWidgets,
        ),
      ],
    );
  }

  Widget _createTimes() {
    final tt = widget.timetable;

    List<Widget> timeWidgets = [];

    timeWidgets.add(
      InkWell(
        onTap: () async {
          final times = (await showCreateTimetableSheet(
            context,
            onlySchoolTimes: true,
          ))
              ?.schoolTimes;

          if (times == null) return;

          int length = min(tt.schoolTimes.length, times.length);

          for (int i = 0; i < length; i++) {
            tt.schoolTimes[i] = times[i];
          }
        },
        child: SizedBox(
          width: lessonWidth,
          height: lessonHeight,
          child: Center(
            child: Text(
              AppLocalizationsManager.localizations.strTimes,
              textAlign: TextAlign.center,
            ),
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
      final prevSchoolTime =
          lessonIndex > 0 ? tt.schoolTimes[lessonIndex - 1] : null;
      final nextSchoolTime = lessonIndex < tt.schoolTimes.length - 1
          ? tt.schoolTimes[lessonIndex + 1]
          : null;

      Widget timeWidget = Hero(
        tag: schoolTime,
        child: InkWell(
          onTap: () async {
            List<(String, Future<void> Function()?)> items = [
              (
                AppLocalizationsManager.localizations.strSetStartTime,
                () async {
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );

                  if (!mounted) return;

                  final newStartTime = await showTimePicker(
                    context: context,
                    initialTime: schoolTime.start,
                  );

                  if (newStartTime == null) {
                    return;
                  }

                  if (newStartTime.isAfter(schoolTime.end) ||
                      newStartTime.isBefore(
                        prevSchoolTime?.end ?? newStartTime,
                      )) {
                    if (mounted) {
                      Utils.showInfo(
                        context,
                        msg: AppLocalizationsManager
                            .localizations.strTimeNotValid,
                        type: InfoType.error,
                      );
                    }
                    return;
                  }

                  schoolTime.start = newStartTime;

                  setState(() {});
                },
              ),
              (
                AppLocalizationsManager.localizations.strSetEndTime,
                () async {
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );

                  if (!mounted) return;

                  final newEndTime = await showTimePicker(
                    context: context,
                    initialTime: schoolTime.end,
                  );

                  if (newEndTime == null) {
                    return;
                  }

                  if (newEndTime.isBefore(schoolTime.start) ||
                      newEndTime.isAfter(
                        nextSchoolTime?.start ?? newEndTime,
                      )) {
                    if (mounted) {
                      Utils.showInfo(
                        context,
                        msg: AppLocalizationsManager
                            .localizations.strTimeNotValid,
                        type: InfoType.error,
                      );
                    }
                    return;
                  }

                  schoolTime.end = newEndTime;

                  setState(() {});
                },
              )
            ];

            await Utils.showStringActionListBottomSheet(
              context,
              items: items,
              runActionAfterPop: true,
            );
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
}
