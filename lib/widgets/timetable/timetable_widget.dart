import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/todo_events_screen.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/semester/school_grade_subject_widget.dart';
import 'package:schulapp/widgets/strike_through_container.dart';
import 'package:schulapp/widgets/timetable/time_to_next_lesson_widget.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';
import 'package:schulapp/widgets/task/todo_event_list_item_widget.dart';
import 'package:schulapp/widgets/timetable/timetable_lesson_widget.dart';

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
  static const double minLessonWidth = 100;
  static const double minLessonHeight = 50;
  static const int pagesCount = 200;
  static const int initialPageIndex = pagesCount ~/ 2;

  final _pageController = PageController(
    initialPage: initialPageIndex,
  );

  late List<SchoolTime> ttSchoolTimes;

  double lessonHeight = minLessonHeight;
  double lessonWidth = minLessonWidth;

  late Color selectedColor;
  late Color unselectedColor;

  late int currWeekIndex;
  late int currYear;

  @override
  void initState() {
    super.initState();

    ttSchoolTimes = widget.timetable.schoolTimes;

    final reducedClassHoursEnabled = TimetableManager().settings.getVar<bool>(
          Settings.reducedClassHoursEnabledKey,
        );

    if (!reducedClassHoursEnabled) {
      return;
    }

    final reducedClassHours =
        TimetableManager().settings.getVar<List<SchoolTime>?>(
              Settings.reducedClassHoursKey,
            );

    if (reducedClassHours == null) {
      Future.delayed(
        Duration.zero,
        () {
          if (!mounted) return;

          Utils.showInfo(
            context,
            msg: AppLocalizationsManager
                .localizations.strYouDontHaveAnyReducedTimesSetUpYet,
            type: InfoType.error,
          );
        },
      );

      return;
    }

    if (reducedClassHours.length < widget.timetable.schoolTimes.length) {
      Future.delayed(
        Duration.zero,
        () {
          if (!mounted) return;

          Utils.showInfo(
            context,
            msg: AppLocalizationsManager
                .localizations.strReducedTimesCannotBeUsed,
            type: InfoType.error,
          );
        },
      );

      return;
    }

    while (reducedClassHours.length > widget.timetable.schoolTimes.length) {
      reducedClassHours.removeLast();
    }

    ttSchoolTimes = reducedClassHours;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    selectedColor = Theme.of(context).colorScheme.secondary.withAlpha(30);

    unselectedColor = Colors.transparent;

    lessonWidth = (MediaQuery.of(context).size.width * 0.8) /
        (widget.timetable.schoolDays.length + 1);
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }

    lessonHeight = (MediaQuery.of(context).size.height * 0.8) /
        (widget.timetable.maxLessonCount);
    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }

    return SizedBox(
      width: lessonWidth * (widget.timetable.schoolDays.length + 1),
      height: lessonHeight * (widget.timetable.maxLessonCount + 1) +
          lessonHeight / 4, //_createBreakHighlight
      child: PageView.builder(
        itemCount: pagesCount,
        controller: _pageController,
        itemBuilder: (context, index) {
          return _createPage(index);
        },
      ),
    );
  }

  Widget _createPage(int pageIndex) {
    int currWeekIndex = pageIndex - initialPageIndex;

    Timetable tt = widget.timetable;

    DateTime currMonday = Utils.getWeekDay(
      DateTime.now().copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      ),
      DateTime.monday,
    ).add(
      Duration(days: 7 * currWeekIndex),
    );

    this.currWeekIndex = Utils.getWeekIndex(currMonday);
    currYear = currMonday.year;

    List<Widget> dayWidgets = [];

    dayWidgets.add(_createTimes());

    for (int dayIndex = 0; dayIndex < tt.schoolDays.length; dayIndex++) {
      Widget dayWidget = _createDay(
        dayIndex: dayIndex,
        currMonday: currMonday,
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
    List<Widget> timeWidgets = [];

    timeWidgets.add(
      SizedBox(
        width: lessonWidth,
        height: lessonHeight,
        child: Center(
          child: TimeToNextLessonWidget(
            ttSchoolTimes: ttSchoolTimes,
            onNewLessonCB: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ),
      ),
    );

    for (int lessonIndex = 0;
        lessonIndex < ttSchoolTimes.length;
        lessonIndex++) {
      final schoolTime = ttSchoolTimes[lessonIndex];
      String startString = schoolTime.getStartString();
      String endString = schoolTime.getEndString();

      Color containerColor = unselectedColor;

      bool addBreakWidget = false;

      if (schoolTime.isCurrentlyRunning()) {
        containerColor = selectedColor;
      } else {
        if (lessonIndex + 1 < ttSchoolTimes.length) {
          final nextSchoolTime = ttSchoolTimes[lessonIndex + 1];
          int currTimeInSec = Utils.nowInSeconds();
          int currSchoolTimeEndInSec = schoolTime.end.toSeconds();
          int nextSchoolTimeStartInSec = nextSchoolTime.start.toSeconds();

          addBreakWidget = (currTimeInSec > currSchoolTimeEndInSec &&
              currTimeInSec < nextSchoolTimeStartInSec);
        }
      }

      Widget widget = Container(
        color: containerColor,
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

      timeWidgets.add(widget);

      if (addBreakWidget) {
        timeWidgets.add(_createBreakHighlight());
      }
    }

    return Column(
      children: timeWidgets,
    );
  }

  Widget _createBreakHighlight() {
    return Container(
      color: selectedColor,
      height: lessonHeight / 4,
      width: lessonWidth,
    );
  }

  Widget _createDay({
    required int dayIndex,
    required DateTime currMonday,
  }) {
    final tt = widget.timetable;
    final day = widget.timetable.schoolDays[dayIndex];

    List<Widget> lessonWidgets = [];

    DateTime currLessonDateTime = currMonday.add(Duration(days: dayIndex));
    final nowMonday = Utils.getWeekDay(DateTime.now(), DateTime.monday);
    bool notTappable = Utils.sameDay(currMonday, nowMonday);

    final customTask = TimetableManager().getCustomTodoEventForDay(
      day: currLessonDateTime,
    );

    final showTaskOnHomescreen = TimetableManager().settings.getVar(
          Settings.showTasksOnHomeScreenKey,
        );

    final List<StrikeThroughContainerController> dayContainerControllers = [];

    lessonWidgets.add(
      InkWell(
        onTap: notTappable
            ? null
            : () {
                _pageController.animateToPage(
                  initialPageIndex,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCirc,
                );
              },
        onLongPress: () async {
          final value = !tt.isSpecialLesson(
            year: currYear,
            weekIndex: currWeekIndex,
            schoolDayIndex: dayIndex,
            schoolTimeIndex: 0,
          );
          for (int timeIndex = 0;
              timeIndex < dayContainerControllers.length;
              timeIndex++) {
            final containerController = dayContainerControllers[timeIndex];
            if (SchoolLesson.isEmptyLesson(day.lessons[timeIndex])) {
              continue;
            }
            containerController.strikeThrough = value;

            if (value) {
              tt.setSpecialLesson(
                weekIndex: currWeekIndex,
                year: currYear,
                specialLesson: CancelledSpecialLesson(
                  dayIndex: dayIndex,
                  timeIndex: timeIndex,
                ),
              );
            } else {
              tt.removeSpecialLesson(
                year: currYear,
                weekIndex: currWeekIndex,
                dayIndex: dayIndex,
                timeIndex: timeIndex,
              );
            }
            await Future.delayed(
              const Duration(
                milliseconds: 100,
              ),
            );
          }
        },
        child: Container(
          color: Utils.sameDay(currLessonDateTime, DateTime.now())
              ? selectedColor
              : unselectedColor,
          width: lessonWidth,
          height: lessonHeight,
          child: Center(
            child: SizedBox(
              width: lessonWidth * 0.8,
              height: lessonHeight * 0.8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: HolidaysManager.getRunningHolidays(
                            currLessonDateTime,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              snapshot.data!.getFormattedName(),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                        customTask == null || !showTaskOnHomescreen
                            ? const SizedBox.shrink()
                            : Text(
                                customTask.linkedSubjectName,
                                textAlign: TextAlign.center,
                              ),
                        Text(
                          day.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          Utils.dateToString(
                            currLessonDateTime,
                            showYear: false,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: customTask != null && showTaskOnHomescreen,
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
                                  ..color = Theme.of(context).canvasColor,
                              ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: customTask != null && showTaskOnHomescreen,
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
                                color: customTask?.getColor(),
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

    for (int lessonIndex = 0; lessonIndex < day.lessons.length; lessonIndex++) {
      final currSchoolTime = ttSchoolTimes[lessonIndex];
      final lesson = day.lessons[lessonIndex];
      final heroString = "$lessonIndex:$dayIndex";

      TodoEvent? currEvent;

      if (widget.showTodoEvents) {
        currEvent = TimetableManager().getRunningTodoEvent(
          linkedSubjectName: lesson.name,
          lessonDayTime: currLessonDateTime,
        );
      }

      Color containerColor = unselectedColor;

      bool addBreakWidget = false;

      if (Utils.sameDay(currLessonDateTime, DateTime.now()) ||
          currSchoolTime.isCurrentlyRunning()) {
        containerColor = selectedColor;
      }

      if (lessonIndex + 1 < ttSchoolTimes.length) {
        final nextSchoolTime = ttSchoolTimes[lessonIndex + 1];
        int currTimeInSec = Utils.nowInSeconds();
        int currSchoolTimeEndInSec = currSchoolTime.end.toSeconds();
        int nextSchoolTimeStartInSec = nextSchoolTime.start.toSeconds();
        addBreakWidget = (currTimeInSec > currSchoolTimeEndInSec &&
            currTimeInSec < nextSchoolTimeStartInSec);
      }
      final StrikeThroughContainerController containerController =
          StrikeThroughContainerController();

      dayContainerControllers.add(containerController);

      containerController.strikeThrough = tt.isSpecialLesson(
        schoolDayIndex: dayIndex,
        schoolTimeIndex: lessonIndex,
        weekIndex: currWeekIndex,
        year: currYear,
      );

      Widget lessonWidget = TimetableLessonWidget(
        containerController: containerController,
        heroString: heroString,
        containerColor: containerColor,
        currEvent: currEvent,
        currLessonDateTime: currLessonDateTime,
        currYear: currYear,
        currWeekIndex: currWeekIndex,
        dayIndex: dayIndex,
        lessonIndex: lessonIndex,
        lesson: lesson,
        lessonHeight: lessonHeight,
        lessonWidth: lessonWidth,
        showTaskOnHomescreen: showTaskOnHomescreen,
        tt: tt,
      );

      lessonWidgets.add(lessonWidget);

      if (addBreakWidget) {
        lessonWidgets.add(_createBreakHighlight());
      }
    }

    return Column(
      children: lessonWidgets,
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
      children: [
        Column(
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
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Flexible(
          fit: FlexFit.tight,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
              ],
            ),
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
                            question: AppLocalizationsManager.localizations
                                .strDoYouWantToDeleteTaskX(
                              widget.event!.linkedSubjectName,
                            ),
                            description: widget.event!.endTime == null
                                ? AppLocalizationsManager.localizations
                                    .strNoEndDate //kann nicht eintreten eigentlich
                                : "(${Utils.dateToString(widget.event!.endTime!)})",
                            showYesAndNoInsteadOfOK: true,
                            markTrueAsRed: true,
                          );
                          if (!removeTodoEvent || !context.mounted) return;

                          final deleteNote = await Utils.showBoolInputDialog(
                            context,
                            question: AppLocalizationsManager
                                .localizations.strDoYouWantToDeleteLinkedNote,
                            showYesAndNoInsteadOfOK: true,
                            markTrueAsRed: true,
                          );

                          TimetableManager().removeTodoEvent(
                            widget.event!,
                            deleteLinkedSchoolNote: deleteNote,
                          );

                          if (!context.mounted) return;

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
                      Icons.assignment_add,
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
            context.go(TodoEventsScreen.route, extra: todoEvent);
          },
          onLongPressed: () {
            context.go(TodoEventsScreen.route, extra: todoEvent);
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
      errorMsg = AppLocalizationsManager.localizations
          .strYourSelectedSemesterDoesNotContainSubjectNamedX(
        lesson.name,
      );
      buttonText = AppLocalizationsManager.localizations.strCreateSubjectNamedX(
        lesson.name,
      );
      buttonFunc = () {
        selectedSemester!.subjects.add(
          SchoolGradeSubject(
            name: lesson.name,
            gradeGroups: TimetableManager().settings.getVar(
                  Settings.defaultGradeGroupsKey,
                ),
          ),
        );
        if (mounted) {
          setState(() {});
        }
        SaveManager().saveSemester(selectedSemester);
      };
    }
    if (selectedSemester == null) {
      errorMsg = AppLocalizationsManager
          .localizations.strYouDidNotSelectASemesterToShowOnHomescreen;
      buttonText = AppLocalizationsManager.localizations.strGoToGradesScreen;
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
