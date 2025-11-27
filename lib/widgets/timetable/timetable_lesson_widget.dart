import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/todo_event_util_functions.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/high_contrast_text.dart';
import 'package:schulapp/widgets/strike_through_container.dart';

class TimetableLessonWidget extends StatefulWidget {
  final StrikeThroughContainerController containerController;
  final Timetable tt;
  final DateTime currLessonDateTime;
  final SchoolLesson lesson;
  final TodoEvent? currEvent;

  final String heroString;

  final double lessonWidth;
  final double lessonHeight;

  final Color containerColor;

  final bool showTaskOnHomescreen;

  final int currYear;
  final int currWeekIndex;
  final int dayIndex;
  final int lessonIndex;

  final bool showSubstituteLessons;
  final bool showOnlyShortName;

  const TimetableLessonWidget({
    super.key,
    required this.tt,
    required this.lesson,
    required this.containerController,
    required this.currEvent,
    required this.currLessonDateTime,
    required this.dayIndex,
    required this.heroString,
    required this.lessonIndex,
    required this.currWeekIndex,
    required this.currYear,
    required this.containerColor,
    required this.lessonHeight,
    required this.lessonWidth,
    required this.showTaskOnHomescreen,
    required this.showOnlyShortName,
    this.showSubstituteLessons = true,
  });

  @override
  State<TimetableLessonWidget> createState() => _TimetableLessonWidgetState();
}

class _TimetableLessonWidgetState extends State<TimetableLessonWidget> {
  bool highContrastEnabled = TimetableManager().settings.getVar<bool>(
        Settings.highContrastTextOnHomescreenKey,
      );

  @override
  Widget build(BuildContext context) {
    final specialLesson = widget.tt.getSpecialLesson(
      year: widget.currYear,
      weekIndex: widget.currWeekIndex,
      schoolDayIndex: widget.dayIndex,
      schoolTimeIndex: widget.lessonIndex,
    );

    SchoolLessonPrefab lessonPrefab = SchoolLessonPrefab.fromSchoolLesson(
      lesson: widget.lesson,
    );

    if (specialLesson is SubstituteSpecialLesson &&
        widget.showSubstituteLessons) {
      SubstituteSpecialLesson substituteSpecialLesson = specialLesson;
      lessonPrefab = SchoolLessonPrefab(
        name: substituteSpecialLesson.name,
        shortName: substituteSpecialLesson.shortName,
        room: substituteSpecialLesson.room,
        teacher: substituteSpecialLesson.teacher,
        color: substituteSpecialLesson.color,
      );
    }

    return InkWell(
      onTap: SchoolLesson.isEmptyLesson(widget.lesson) &&
              specialLesson is! SubstituteSpecialLesson
          ? null
          : () => _onLessonWidgetTap(
                dayIndex: widget.dayIndex,
                lessonIndex: widget.lessonIndex,
                heroString: widget.heroString,
                currEvent: widget.currEvent,
                eventEndTime: widget.currLessonDateTime,
                lesson: lessonPrefab,
                showDeleteButton: specialLesson is SubstituteSpecialLesson,
              ),
      onLongPress: () {
        final specialLesson = widget.tt.getSpecialLesson(
          year: widget.currYear,
          weekIndex: widget.currWeekIndex,
          schoolDayIndex: widget.dayIndex,
          schoolTimeIndex: widget.lessonIndex,
        );

        Utils.showStringActionListBottomSheet(
          context,
          runActionAfterPop: true,
          autoRunOnlyPossibleOption: true,
          items: [
            if (specialLesson is! CancelledSpecialLesson &&
                specialLesson == null)
              (
                AppLocalizationsManager.localizations.strMarkAsCancelled,
                SchoolLesson.isEmptyLesson(widget.lesson)
                    ? null
                    : () async {
                        await Future.delayed(
                          const Duration(milliseconds: 100),
                        );

                        widget.containerController.strikeThrough = true;
                        if (context.mounted) {
                          widget.containerController
                              .setStrikeColorToCancelled(context);
                        }
                        widget.tt.setSpecialLesson(
                          weekIndex: widget.currWeekIndex,
                          year: widget.currYear,
                          specialLesson: CancelledSpecialLesson(
                            dayIndex: widget.dayIndex,
                            timeIndex: widget.lessonIndex,
                          ),
                        );

                        _updateNotification();
                      }
              ),
            if (specialLesson is! SickSpecialLesson && specialLesson == null)
              (
                AppLocalizationsManager.localizations.strMarkAsSick,
                SchoolLesson.isEmptyLesson(widget.lesson)
                    ? null
                    : () async {
                        await Future.delayed(
                          const Duration(milliseconds: 100),
                        );

                        widget.containerController.setStrikeColorToSick();
                        widget.containerController.strikeThrough = true;
                        widget.tt.setSpecialLesson(
                          weekIndex: widget.currWeekIndex,
                          year: widget.currYear,
                          specialLesson: SickSpecialLesson(
                            dayIndex: widget.dayIndex,
                            timeIndex: widget.lessonIndex,
                          ),
                        );

                        _updateNotification();
                      }
              ),
            //weil es wenn, nur alleine steht, brauch man nichts hinschreiben,
            //weil es automatisch ausgeführt wird: autoRunOnlyPossibleOption: true
            if (specialLesson is SickSpecialLesson ||
                specialLesson is CancelledSpecialLesson)
              (
                "",
                () async {
                  await Future.delayed(
                    const Duration(milliseconds: 100),
                  );
                  widget.containerController.strikeThrough = false;
                  widget.tt.removeSpecialLesson(
                    weekIndex: widget.currWeekIndex,
                    year: widget.currYear,
                    dayIndex: widget.dayIndex,
                    timeIndex: widget.lessonIndex,
                  );

                  _updateNotification();
                }
              ),
            if (specialLesson is! SubstituteSpecialLesson &&
                specialLesson == null)
              (
                AppLocalizationsManager.localizations.strMarkAsSubstitute,
                () async {
                  final prefabs = widget.tt.lessonPrefabs;

                  // prefabs.remove(
                  //   prefabs.cast<SchoolLessonPrefab?>().firstWhere(
                  //         (element) => element?.name == widget.lesson.name,
                  //         orElse: () => null,
                  //       ),
                  // );

                  //can not be shown to users and not inputted
                  final nullchar = String.fromCharCode(0);

                  prefabs.add(
                    SchoolLessonPrefab(
                      name: AppLocalizationsManager
                              .localizations.strCustomSubject +
                          nullchar,
                      color: Colors.transparent,
                    ),
                  );

                  if (!context.mounted) return;

                  SchoolLessonPrefab? prefab =
                      await Utils.showSelectLessonPrefabList(
                    context,
                    prefabs: prefabs,
                  );

                  if (prefab == null) return;

                  if (prefab.name.contains(nullchar)) {
                    if (!context.mounted) {
                      return;
                    }

                    final lessonTuple =
                        await showCreateNewPrefabBottomSheet(context);

                    if (lessonTuple == null) return;

                    prefab = lessonTuple.$1;
                  }

                  widget.tt.setSpecialLesson(
                    weekIndex: widget.currWeekIndex,
                    year: widget.currYear,
                    specialLesson: SubstituteSpecialLesson(
                      dayIndex: widget.dayIndex,
                      timeIndex: widget.lessonIndex,
                      prefab: prefab,
                    ),
                  );

                  _updateNotification();

                  setState(() {});
                }
              ),
            //weil es wenn, nur alleine steht, brauch man nichts hinschreiben,
            //weil es automatisch ausgeführt wird: autoRunOnlyPossibleOption: true
            if (specialLesson is SubstituteSpecialLesson)
              (
                "",
                () async {
                  widget.tt.removeSpecialLesson(
                    weekIndex: widget.currWeekIndex,
                    year: widget.currYear,
                    dayIndex: widget.dayIndex,
                    timeIndex: widget.lessonIndex,
                  );

                  _updateNotification();

                  setState(() {});
                }
              )
          ],
        );
      },
      child: Container(
        color: widget.containerColor,
        width: widget.lessonWidth,
        height: widget.lessonHeight,
        child: Center(
          child: Hero(
            tag: widget.heroString,
            flightShuttleBuilder: (context, animation, __, ___, ____) {
              const targetAlpha = 220;

              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return Container(
                    width: widget.lessonWidth,
                    height: widget.lessonHeight,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorTween(
                        begin: lessonPrefab.color,
                        end: Theme.of(context).cardColor.withAlpha(targetAlpha),
                      ).lerp(animation.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              );
            },
            child: StrikeThroughContainer(
              key: UniqueKey(),
              controller: widget.containerController,
              child: Container(
                width: widget.lessonWidth,
                height: widget.lessonHeight,
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: lessonPrefab.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          HighContrastText(
                            text: widget.showOnlyShortName
                                ? lessonPrefab.shortName
                                : lessonPrefab.name,
                            highContrastEnabled: highContrastEnabled,
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                            fontWeight: null,
                            outlineWidth: 2,
                          ),
                          lessonPrefab.room.isEmpty
                              ? const SizedBox.shrink()
                              : HighContrastText(
                                  text: lessonPrefab.room,
                                  highContrastEnabled: highContrastEnabled,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyLarge,
                                  fontWeight: null,
                                  outlineWidth: 2,
                                ),
                        ],
                      ),
                    ),
                    if (specialLesson is SubstituteSpecialLesson &&
                        widget.showSubstituteLessons)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.5, 1.5),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Container(
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //     decoration: BoxDecoration(
                    //       color: Colors.red,
                    //       borderRadius: BorderRadius.only(
                    //         topRight: Radius.circular(10),
                    //         bottomLeft: Radius.circular(10),
                    //       ),
                    //     ),
                    //     child: Text(
                    //       'Vertretung',
                    //       style: TextStyle(color: Colors.white, fontSize: 10),
                    //     ),
                    //   ),
                    // ),
                    if (widget.currEvent != null)
                      Visibility(
                        visible: widget.showTaskOnHomescreen,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: HighContrastText(
                            text: widget.currEvent?.finished ?? false
                                ? Timetable.tickMark
                                : Timetable.exclamationMark,
                            fillColor: widget.currEvent?.getColor(),
                            textStyle: GoogleFonts.dmSerifDisplay(
                              textStyle:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                            outlineWidth: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateNotification() {
    final monday = Utils.getWeekDay(
      widget.currLessonDateTime.toUtc().copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
      DateTime.monday,
    );

    return NotificationManager().updateNotification(
      currTimetable: widget.tt,
      monday: monday,
      dayIndex: widget.dayIndex,
      lessonIndex: widget.lessonIndex,
      lesson: widget.lesson,
    );
  }

  Future<void> _onLessonWidgetTap({
    required int lessonIndex,
    required int dayIndex,
    required String heroString,
    required DateTime eventEndTime,
    required SchoolLessonPrefab lesson,
    required bool showDeleteButton,
    TodoEvent? currEvent,
  }) async {
    final day = widget.tt.schoolDays[dayIndex];
    final schoolTime = widget.tt.schoolTimes[lessonIndex];

    bool? showNewTodoEvent = await showSchoolLessonHomePopUp(
      context,
      lesson,
      day,
      schoolTime,
      currEvent,
      heroString,
      showDeleteButton,
      () {
        //delete button pressed
        widget.tt.removeSpecialLesson(
          weekIndex: widget.currWeekIndex,
          year: widget.currYear,
          dayIndex: widget.dayIndex,
          timeIndex: widget.lessonIndex,
        );

        _updateNotification();

        setState(() {});
      },
      () async {
        //edit button pressed
        final specialLesson = widget.tt.getSpecialLesson(
          year: widget.currYear,
          weekIndex: widget.currWeekIndex,
          schoolDayIndex: widget.dayIndex,
          schoolTimeIndex: widget.lessonIndex,
        );

        if (specialLesson is! SubstituteSpecialLesson) {
          return;
        }

        final lessonTuple = await showCreateNewPrefabBottomSheet(
          context,
          prefab: specialLesson.asSchoolLessonPrefab,
        );

        if (lessonTuple == null) return;

        final prefab = lessonTuple.$1;
        final delete = lessonTuple.$2;

        if (delete) {
          widget.tt.removeSpecialLesson(
            weekIndex: widget.currWeekIndex,
            year: widget.currYear,
            dayIndex: widget.dayIndex,
            timeIndex: widget.lessonIndex,
          );

          _updateNotification();

          setState(() {});

          return;
        }

        widget.tt.setSpecialLesson(
          removeIfExists: true,
          weekIndex: widget.currWeekIndex,
          year: widget.currYear,
          specialLesson: SubstituteSpecialLesson(
            dayIndex: widget.dayIndex,
            timeIndex: widget.lessonIndex,
            prefab: prefab,
          ),
        );

        _updateNotification();

        setState(() {});
      },
    );

    if (!mounted) return;
    setState(() {});

    if (showNewTodoEvent == null) return;
    if (!showNewTodoEvent) return;

    eventEndTime = eventEndTime.copyWith(
      hour: schoolTime.start.hour,
      minute: schoolTime.start.minute,
    );

    TodoEvent? event = TodoEvent(
      name: "",
      linkedSchoolNote: null,
      linkedSubjectName: lesson.name,
      endTime: eventEndTime,
      type: TodoType.test,
      desciption: "",
      isCustomEvent: false,
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
      msg: AppLocalizationsManager.localizations.strTaskSuccessfullyCreated,
    );

    setState(() {});
  }
}
