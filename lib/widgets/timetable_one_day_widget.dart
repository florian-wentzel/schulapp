import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
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
  static const double minLessonWidth = 100;
  static const double minLessonHeight = 50;
  static const int pagesCount = 1000;
  //monday of curr week
  static const int initialMondayPageIndex = pagesCount ~/ 2;

  late final PageController _pageController;

  double lessonHeight = minLessonHeight;
  double lessonWidth = minLessonWidth;

  late Color selectedColor;
  late Color unselectedColor;

  @override
  void initState() {
    int showNextWeek = 0;
    if (DateTime.now().weekday == DateTime.sunday) {
      showNextWeek = widget.timetable.schoolDays.length;
    }
    _pageController = PageController(
      initialPage: initialMondayPageIndex +
          Utils.getCurrentWeekDayIndex() +
          showNextWeek,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    lessonWidth = MediaQuery.of(context).size.width * 0.8 / 2;
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }

    lessonHeight = MediaQuery.of(context).size.height *
        0.8 /
        (widget.timetable.maxLessonCount + 1);

    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }

    selectedColor = Theme.of(context).colorScheme.secondary.withAlpha(30);

    unselectedColor = Colors.transparent;

    return SizedBox(
      width: lessonWidth * (2),
      height: lessonHeight * (widget.timetable.schoolTimes.length + 1),
      child: PageView.builder(
        controller: _pageController,
        itemCount: pagesCount,
        itemBuilder: (context, index) {
          Timetable tt = widget.timetable;

          int currDayIndex =
              (index - initialMondayPageIndex) % tt.schoolDays.length;
          int currWeekIndex =
              (index - initialMondayPageIndex) ~/ tt.schoolDays.length;

          DateTime currMonday =
              Utils.getWeekDay(DateTime.now(), DateTime.monday);

          return _createDay(
            dayIndex: currDayIndex,
            currMonday: currMonday.add(Duration(days: 7 * currWeekIndex)),
          );
        },
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

      Widget timeWidget = Container(
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

      timeWidgets.add(timeWidget);

      if (addBreakWidget) {
        timeWidgets.add(_createBreakHighlight());
      }
    }

    return Column(
      children: timeWidgets,
    );
  }

  Widget _createDay({
    required DateTime currMonday,
    required int dayIndex,
  }) {
    final tt = widget.timetable;
    final day = tt.schoolDays[dayIndex];

    List<Widget> lessonWidgets = [];

    DateTime currLessonDateTime = currMonday.add(Duration(days: dayIndex));

    lessonWidgets.add(
      InkWell(
        onTap: Utils.sameDay(currLessonDateTime, DateTime.now())
            ? null
            : () {
                int currDayIndex = Utils.getCurrentWeekDayIndex();
                int showNextWeek = 0;
                if (DateTime.now().weekday == DateTime.sunday) {
                  showNextWeek = widget.timetable.schoolDays.length;
                }
                _pageController.animateToPage(
                  initialMondayPageIndex + currDayIndex + showNextWeek,
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
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
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
          ),
        ),
      ),
    );

    for (int lessonIndex = 0; lessonIndex < day.lessons.length; lessonIndex++) {
      final currSchoolTime = tt.schoolTimes[lessonIndex];
      final lesson = day.lessons[lessonIndex];
      final heroString = "$lessonIndex:$dayIndex";

      Color containerColor = unselectedColor;

      bool addBreakWidget = false;

      if (currSchoolTime.isCurrentlyRunning()) {
        containerColor = selectedColor;
      } else {
        if (lessonIndex + 1 < tt.schoolTimes.length) {
          final nextSchoolTime = tt.schoolTimes[lessonIndex + 1];
          int currTimeInSec = Utils.nowInSeconds();
          int currSchoolTimeEndInSec = currSchoolTime.end.toSeconds();
          int nextSchoolTimeStartInSec = nextSchoolTime.start.toSeconds();
          addBreakWidget = (currTimeInSec > currSchoolTimeEndInSec &&
              currTimeInSec < nextSchoolTimeStartInSec);
        }
      }

      TodoEvent? currEvent;

      if (widget.showTodoEvents) {
        currEvent = TimetableManager().getRunningTodoEvent(
          linkedSubjectName: lesson.name,
          lessonDayTime: currLessonDateTime,
        );
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

  Widget _createBreakHighlight() {
    return Container(
      color: selectedColor,
      height: lessonHeight / 4,
      width: lessonWidth,
    );
  }

  void _onLessonWidgetTap({
    required int dayIndex,
    required int lessonIndex,
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
