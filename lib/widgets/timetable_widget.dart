import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/tasks_screen.dart';
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
  static const double minLessonWidth = 100;
  static const double minLessonHeight = 50;
  static const int pagesCount = 200;
  static const int initialPageIndex = pagesCount ~/ 2;

  final _pageController = PageController(
    initialPage: initialPageIndex,
  );

  double lessonHeight = minLessonHeight;
  double lessonWidth = minLessonWidth;

  late Color selectedColor;
  late Color unselectedColor;

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

    DateTime currMonday = Utils.getWeekDay(DateTime.now(), DateTime.monday)
        .add(Duration(days: 7 * currWeekIndex));

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
    final tt = widget.timetable;

    List<Widget> timeWidgets = [];

    timeWidgets.add(
      SizedBox(
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
      ),
    );

    for (int lessonIndex = 0;
        lessonIndex < tt.schoolTimes.length;
        lessonIndex++) {
      final schoolTime = tt.schoolTimes[lessonIndex];
      String startString = schoolTime.getStartString();
      String endString = schoolTime.getEndString();

      Color containerColor = unselectedColor;

      bool addBreakWidget = false;

      if (schoolTime.isCurrentlyRunning()) {
        containerColor = selectedColor;
      } else {
        if (lessonIndex + 1 < tt.schoolTimes.length) {
          final nextSchoolTime = tt.schoolTimes[lessonIndex + 1];
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

  Future<void> _onLessonWidgetTap({
    required int lessonIndex,
    required int dayIndex,
    required String heroString,
    required DateTime eventEndTime,
    TodoEvent? currEvent,
  }) async {
    final day = widget.timetable.schoolDays[dayIndex];
    final lesson = day.lessons[lessonIndex];
    final schoolTime = widget.timetable.schoolTimes[lessonIndex];

    bool? showNewTodoEvent = await showSchoolLessonHomePopUp(
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

    eventEndTime = eventEndTime.copyWith(
      hour: schoolTime.start.hour,
      minute: schoolTime.start.minute,
    );

    TodoEvent? event = TodoEvent(
      key: TimetableManager().getNextSchoolEventKey(),
      name: "",
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
                    visible: customTask != null,
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
                    visible: customTask != null,
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
      final currSchoolTime = tt.schoolTimes[lessonIndex];
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

      if (lessonIndex + 1 < tt.schoolTimes.length) {
        final nextSchoolTime = tt.schoolTimes[lessonIndex + 1];
        int currTimeInSec = Utils.nowInSeconds();
        int currSchoolTimeEndInSec = currSchoolTime.end.toSeconds();
        int nextSchoolTimeStartInSec = nextSchoolTime.start.toSeconds();
        addBreakWidget = (currTimeInSec > currSchoolTimeEndInSec &&
            currTimeInSec < nextSchoolTimeStartInSec);
      }

      Widget lessonWidget = InkWell(
        onTap: SchoolLesson.isEmptyLessonName(lesson.name)
            ? null
            : () => _onLessonWidgetTap(
                  dayIndex: dayIndex,
                  lessonIndex: lessonIndex,
                  heroString: heroString,
                  currEvent: currEvent,
                  eventEndTime: currLessonDateTime,
                ),
        child: Container(
          color: containerColor,
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
              child: Container(
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
                                    ..color = Theme.of(context).canvasColor,
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
                            question: AppLocalizationsManager.localizations
                                .strDoYouWantToDeleteTaskX(
                              widget.event!.linkedSubjectName,
                            ),
                            description:
                                "(${Utils.dateToString(widget.event!.endTime)})",
                            showYesAndNoInsteadOfOK: true,
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
