part of '../../code_behind/timetable_controller.dart';

class TimetableWidget extends StatefulWidget {
  final TimetableController controller;
  final Timetable timetable;
  final bool showTodoEvents;
  final bool showPageView;
  final bool showHolidaysAndDates;
  final bool highlightCurrLessonAndDay;
  final Size? size;

  const TimetableWidget({
    super.key,
    required this.controller,
    required this.timetable,
    required this.showTodoEvents,
    this.showPageView = true,
    this.showHolidaysAndDates = true,
    this.highlightCurrLessonAndDay = true,
    this.size,
  });

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();

  static Size getPrefferedSize(Timetable timetable, {double multiplier = 1}) {
    return Size(
      _TimetableWidgetState.minLessonWidth *
          (timetable.schoolDays.length + 1) *
          multiplier,
      //_TimetableWidgetState.minLessonHeight
      50 * (timetable.maxLessonCount + 1) * multiplier,
    );
  }
}

class _TimetableWidgetState extends State<TimetableWidget> {
  static const double minLessonWidth = 100;
  static const double minLessonHeight = 30;
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

  bool _alreadyShowedErrorBecauseOfReducedHours = false;

  late Size mediaQuerySize;

  double get _breakLightHeight => lessonHeight / 4;

  //nicht mehr in der funktion damit sie auch noch gültig sind nachdem setState gecalled wurde
  final Map<int, List<StrikeThroughContainerController>>
      dayContainerControllers = {};

  @override
  void initState() {
    DateTime getMondayForIndex(int index) {
      int currWeekIndex = index - initialPageIndex;

      DateTime currMonday = Utils.getWeekDay(
        DateTime.now().toUtc().copyWith(
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
      return currMonday;
    }

    widget.controller._firstDay = getMondayForIndex(0);

    final lastMonday = getMondayForIndex(pagesCount - 1);
    widget.controller._lastDay = lastMonday.add(
      Duration(
        days: widget.timetable
                .getWeekTimetableForDateTime(lastMonday)
                .schoolDays
                .length -
            1,
      ),
    );

    widget.controller._onGoToDay = (targetDay) {
      int? getIndexForDate(DateTime date) {
        for (int i = 0; i < pagesCount; i++) {
          final currDay = getMondayForIndex(i);

          if (currDay.year == date.year &&
              currDay.month == date.month &&
              currDay.day == date.day) {
            return i;
          }
        }
        return null;
      }

      final date = Utils.getWeekDay(
        targetDay,
        DateTime.monday,
      );

      int? index = getIndexForDate(date);

      if (index == null) {
        return false;
      }

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCirc,
      );

      return true;
    };

    // widget.controller.swipeToRight = () {
    //   _pageController.animateToPage(
    //     _pageController.page!.toInt() + 1,
    //     duration: const Duration(milliseconds: 500),
    //     curve: Curves.easeInOutCirc,
    //   );
    // };
    // widget.controller.swipeToLeft = () {
    //   _pageController.animateToPage(
    //     _pageController.page!.toInt() - 1,
    //     duration: const Duration(milliseconds: 500),
    //     curve: Curves.easeInOutCirc,
    //   );
    // };

    super.initState();

    _updateTtSchoolTimes(widget.timetable.getCurrWeekTimetable());

    setState(() {});
  }

  @override
  void dispose() {
    widget.controller._onGoToDay = null;
    super.dispose();
  }

  void _updateTtSchoolTimes(Timetable timetable) {
    ttSchoolTimes = timetable.schoolTimes;

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
          if (!mounted || _alreadyShowedErrorBecauseOfReducedHours) return;
          _alreadyShowedErrorBecauseOfReducedHours = true;

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

    if (reducedClassHours.length < timetable.schoolTimes.length) {
      Future.delayed(
        Duration.zero,
        () {
          if (!mounted || _alreadyShowedErrorBecauseOfReducedHours) return;
          _alreadyShowedErrorBecauseOfReducedHours = true;

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

    while (reducedClassHours.length > timetable.schoolTimes.length) {
      reducedClassHours.removeLast();
    }

    ttSchoolTimes = reducedClassHours;
  }

  @override
  Widget build(BuildContext context) {
    mediaQuerySize = widget.size ??
        Size(
          MediaQuery.of(context).size.width * 0.9,
          MediaQuery.of(context).size.height, // * 0.8
        );

    final currTimetableWeek = widget.timetable;
    selectedColor = Theme.of(context).colorScheme.secondary.withAlpha(30);

    unselectedColor = Colors.transparent;

    lessonWidth =
        (mediaQuerySize.width) / (currTimetableWeek.schoolDays.length + 1);
    if (lessonWidth < minLessonWidth) {
      lessonWidth = minLessonWidth;
    }

    lessonHeight = (mediaQuerySize.height -
            (widget.highlightCurrLessonAndDay ? _breakLightHeight : 0)) /
        (currTimetableWeek.maxLessonCount + 1);

    if (lessonHeight < minLessonHeight) {
      lessonHeight = minLessonHeight;
    }

    final Widget child;

    if (widget.showPageView) {
      child = PageView.builder(
        itemCount: pagesCount,
        controller: _pageController,
        itemBuilder: (context, index) {
          return _createPage(index);
        },
      );
    } else {
      child = _createPage(initialPageIndex);
    }

    return SizedBox(
      width: lessonWidth * (currTimetableWeek.schoolDays.length + 1),
      height: lessonHeight * (currTimetableWeek.maxLessonCount + 1) +
          _breakLightHeight,
      child: child,
    );
  }

  Widget _createPage(int pageIndex) {
    int currWeekIndex = pageIndex - initialPageIndex;

    DateTime currMonday = Utils.getWeekDay(
      DateTime.now().toUtc().copyWith(
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

    widget.controller._currDay = currMonday;

    Timetable tt = widget.timetable.getWeekTimetableForDateTime(currMonday);

    _updateTtSchoolTimes(tt);

    this.currWeekIndex = Utils.getWeekIndex(currMonday);
    currYear = currMonday.year;

    List<Widget> dayWidgets = [];

    final currDayPage = pageIndex == initialPageIndex;

    dayWidgets.add(_createTimes(currDayPage));

    for (int dayIndex = 0; dayIndex < tt.schoolDays.length; dayIndex++) {
      Widget dayWidget = _createDay(
        currDayPage: currDayPage,
        dayIndex: dayIndex,
        currMonday: currMonday,
        tt: tt,
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

  Widget _createTimes(bool currDayPage) {
    List<Widget> timeWidgets = [];

    timeWidgets.add(
      SizedBox(
        key: currDayPage ? widget.controller.timeLeftKey : null,
        width: lessonWidth,
        height: lessonHeight,
        child: Center(
          child: TimeToNextLessonWidget(
            showTime: widget.highlightCurrLessonAndDay,
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

      if (schoolTime.isCurrentlyRunning() && widget.highlightCurrLessonAndDay) {
        containerColor = selectedColor;
      } else {
        if (lessonIndex + 1 < ttSchoolTimes.length) {
          final nextSchoolTime = ttSchoolTimes[lessonIndex + 1];
          int currTimeInSec = Utils.nowInSeconds();
          int currSchoolTimeEndInSec = schoolTime.end.toSeconds();
          int nextSchoolTimeStartInSec = nextSchoolTime.start.toSeconds();

          addBreakWidget = (currTimeInSec > currSchoolTimeEndInSec &&
                  currTimeInSec < nextSchoolTimeStartInSec) &&
              widget.highlightCurrLessonAndDay;
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

  Widget _createBreakHighlight() {
    return Container(
      color: selectedColor,
      height: _breakLightHeight,
      width: lessonWidth,
    );
  }

  Widget _createDay({
    required bool currDayPage,
    required int dayIndex,
    required DateTime currMonday,
    required Timetable tt,
  }) {
    final day = tt.schoolDays[dayIndex];

    List<Widget> lessonWidgets = [];

    DateTime currLessonDateTime = currMonday.add(Duration(days: dayIndex));
    final nowMonday = Utils.getWeekDay(DateTime.now(), DateTime.monday);
    bool notTappable = Utils.sameDay(currMonday, nowMonday);

    final customTask = TimetableManager().getCustomTodoEventForDay(
      day: currLessonDateTime,
    );

    final showTaskOnHomescreen = TimetableManager().settings.getVar(
              Settings.showTasksOnHomeScreenKey,
            ) &&
        widget.showTodoEvents;

    dayContainerControllers[dayIndex]?.clear();

    lessonWidgets.add(
      InkWell(
        key: dayIndex == 0 && currDayPage ? widget.controller.dayNameKey : null,
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
          final lessons = tt.schoolDays[dayIndex].lessons;

          int totalCancelledLessonsCount = 0;
          int totalSubstituteLessonsCount = 0;
          int totalLessonCount = 0;

          for (int i = 0;
              i <
                  min(lessons.length,
                      dayContainerControllers[dayIndex]?.length ?? 0);
              i++) {
            if (SchoolLesson.isEmptyLesson(lessons[i])) {
              continue;
            }

            final specialLesson = tt.getSpecialLesson(
              year: currYear,
              weekIndex: currWeekIndex,
              schoolDayIndex: dayIndex,
              schoolTimeIndex: i,
            );

            if (specialLesson is CancelledSpecialLesson) {
              totalCancelledLessonsCount++;
            }
            if (specialLesson is SubstituteSpecialLesson) {
              totalSubstituteLessonsCount++;
            }

            totalLessonCount++;
          }

          final dayIsCancelled =
              totalCancelledLessonsCount > totalLessonCount / 2;
          final dayIsSubstituted =
              totalSubstituteLessonsCount > totalLessonCount / 2;

          Utils.showStringAcionListBottomSheet(
            context,
            runActionAfterPop: true,
            items: [
              if (!dayIsCancelled)
                (
                  AppLocalizationsManager.localizations.strMarkDayAsCancelled,
                  dayIsSubstituted
                      ? null
                      : () async {
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );

                          for (int i = 0;
                              i <
                                  min(
                                      lessons.length,
                                      dayContainerControllers[dayIndex]
                                              ?.length ??
                                          0);
                              i++) {
                            if (SchoolLesson.isEmptyLesson(lessons[i])) {
                              tt.removeSpecialLesson(
                                year: currYear,
                                weekIndex: currWeekIndex,
                                dayIndex: dayIndex,
                                timeIndex: i,
                              );
                              continue;
                            }

                            await Future.delayed(
                              const Duration(milliseconds: 50),
                            );

                            dayContainerControllers[dayIndex]?[i]
                                .strikeThrough = true;

                            //falls es schon ausgefallen ist
                            tt.removeSpecialLesson(
                              year: currYear,
                              weekIndex: currWeekIndex,
                              dayIndex: dayIndex,
                              timeIndex: i,
                            );

                            tt.setSpecialLesson(
                              weekIndex: currWeekIndex,
                              year: currYear,
                              specialLesson: CancelledSpecialLesson(
                                dayIndex: dayIndex,
                                timeIndex: i,
                              ),
                            );
                          }

                          //falls vertretungsstunden dabei waren damit sie nach der animation berichtigt werden
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          if (mounted) {
                            setState(() {});
                          }
                        },
                ),
              if (dayIsCancelled)
                (
                  AppLocalizationsManager
                      .localizations.strMarkDayAsNotCancelled,
                  dayIsSubstituted
                      ? null
                      : () async {
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );

                          for (int i = 0;
                              i <
                                  min(
                                      lessons.length,
                                      dayContainerControllers[dayIndex]
                                              ?.length ??
                                          0);
                              i++) {
                            await Future.delayed(
                              const Duration(milliseconds: 50),
                            );

                            dayContainerControllers[dayIndex]?[i]
                                .strikeThrough = false;

                            //falls es schon ausgefallen ist
                            tt.removeSpecialLesson(
                              year: currYear,
                              weekIndex: currWeekIndex,
                              dayIndex: dayIndex,
                              timeIndex: i,
                            );
                          }

                          //falls vertretungsstunden dabei waren damit sie nach der animation berichtigt werden
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          if (mounted) {
                            setState(() {});
                          }
                        },
                ),
              if (!dayIsSubstituted)
                (
                  AppLocalizationsManager.localizations.strMarkDayAsSubstituted,
                  dayIsCancelled
                      ? null
                      : () async {
                          final prefabs = tt.lessonPrefabs;

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

                          SchoolLessonPrefab? prefab =
                              await Utils.showSelectLessonPrefabList(
                            context,
                            prefabs: prefabs,
                          );

                          if (prefab == null) return;

                          if (prefab.name.contains(nullchar)) {
                            if (!mounted) {
                              return;
                            }

                            final lessonTuple =
                                await showCreateNewPrefabBottomSheet(context);

                            if (lessonTuple == null) return;

                            prefab = lessonTuple.$1;
                          }

                          for (int i = 0;
                              i <
                                  min(
                                      lessons.length,
                                      dayContainerControllers[dayIndex]
                                              ?.length ??
                                          0);
                              i++) {
                            await Future.delayed(
                              const Duration(milliseconds: 50),
                            );

                            //falls es schon ausgefallen ist
                            tt.removeSpecialLesson(
                              year: currYear,
                              weekIndex: currWeekIndex,
                              dayIndex: dayIndex,
                              timeIndex: i,
                            );

                            dayContainerControllers[dayIndex]?[i]
                                .strikeThrough = false;

                            tt.setSpecialLesson(
                              year: currYear,
                              weekIndex: currWeekIndex,
                              specialLesson: SubstituteSpecialLesson(
                                dayIndex: dayIndex,
                                timeIndex: i,
                                prefab: prefab,
                              ),
                            );

                            setState(() {});
                          }
                        },
                ),
              if (dayIsSubstituted)
                (
                  AppLocalizationsManager
                      .localizations.strMarkDayAsNotSubstituted,
                  dayIsCancelled
                      ? null
                      : () async {
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );

                          for (int i = 0;
                              i <
                                  min(
                                      lessons.length,
                                      dayContainerControllers[dayIndex]
                                              ?.length ??
                                          0);
                              i++) {
                            await Future.delayed(
                              const Duration(milliseconds: 50),
                            );

                            dayContainerControllers[dayIndex]?[i]
                                .strikeThrough = false;

                            //falls es schon ausgefallen ist
                            tt.removeSpecialLesson(
                              year: currYear,
                              weekIndex: currWeekIndex,
                              dayIndex: dayIndex,
                              timeIndex: i,
                            );

                            setState(() {});
                          }
                        },
                ),
            ],
          );
        },
        child: Container(
          color: Utils.sameDay(currLessonDateTime, DateTime.now()) &&
                  widget.highlightCurrLessonAndDay
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
                        Visibility(
                          visible: widget.showHolidaysAndDates,
                          child: FutureBuilder(
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
                        Visibility(
                          visible: widget.showHolidaysAndDates,
                          child: Text(
                            Utils.dateToString(
                              currLessonDateTime,
                              showYear: currLessonDateTime.year !=
                                  DateTime.now().toUtc().year,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: customTask != null && showTaskOnHomescreen,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: HighContrastText(
                        text: customTask?.finished ?? false
                            ? Timetable.tickMark
                            : Timetable.exclamationMark,
                        fillColor: customTask?.getColor(),
                        textStyle: GoogleFonts.dmSerifDisplay(
                          textStyle: Theme.of(context).textTheme.headlineMedium,
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
    );

    for (int lessonIndex = 0; lessonIndex < day.lessons.length; lessonIndex++) {
      final currSchoolTime = ttSchoolTimes[lessonIndex];
      final lesson = day.lessons[lessonIndex];
      final heroString = "$lessonIndex:$dayIndex";

      TodoEvent? currEvent;

      if (widget.showTodoEvents) {
        final specialLesson = tt.getSpecialLesson(
          year: currYear,
          weekIndex: currWeekIndex,
          schoolDayIndex: dayIndex,
          schoolTimeIndex: lessonIndex,
        );

        SubstituteSpecialLesson? substituteSpecialLesson =
            (specialLesson is SubstituteSpecialLesson) ? specialLesson : null;

        currEvent = TimetableManager().getRunningTodoEvent(
          linkedSubjectName: substituteSpecialLesson?.name ?? lesson.name,
          lessonDayTime: currLessonDateTime,
        );
      }

      Color containerColor = unselectedColor;

      bool addBreakWidget = false;

      if ((Utils.sameDay(currLessonDateTime, DateTime.now()) ||
              currSchoolTime.isCurrentlyRunning()) &&
          widget.highlightCurrLessonAndDay) {
        containerColor = selectedColor;
      }

      if (lessonIndex + 1 < ttSchoolTimes.length) {
        final nextSchoolTime = ttSchoolTimes[lessonIndex + 1];
        int currTimeInSec = Utils.nowInSeconds();
        int currSchoolTimeEndInSec = currSchoolTime.end.toSeconds();
        int nextSchoolTimeStartInSec = nextSchoolTime.start.toSeconds();
        addBreakWidget = (currTimeInSec > currSchoolTimeEndInSec &&
                currTimeInSec < nextSchoolTimeStartInSec) &&
            widget.highlightCurrLessonAndDay;
      }
      final StrikeThroughContainerController containerController =
          StrikeThroughContainerController();

      dayContainerControllers[dayIndex] ??= [];
      dayContainerControllers[dayIndex]?.add(containerController);

      containerController.strikeThrough = tt.getSpecialLesson(
            schoolDayIndex: dayIndex,
            schoolTimeIndex: lessonIndex,
            weekIndex: currWeekIndex,
            year: currYear,
          ) is CancelledSpecialLesson &&
          widget.highlightCurrLessonAndDay;

      // if (dayIndex == 0 && lessonIndex == 0) {
      //   widget.controller.markSpecialLesson = () {
      //     containerController.strikeThrough = true;
      //     // tt.isSpecialLesson(
      //     //   schoolDayIndex: dayIndex,
      //     //   schoolTimeIndex: lessonIndex,
      //     //   weekIndex: currWeekIndex,
      //     //   year: currYear,
      //     // );
      //   };
      //   widget.controller.removeSpecialLessonMark = () {
      //     containerController.strikeThrough = false;
      //   };
      // }

      Widget lessonWidget = TimetableLessonWidget(
        key: dayIndex == 0 && lessonIndex == 0 && currDayPage
            ? widget.controller.firstLessonKey
            : null,
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
        showSubstituteLessons: widget.showTodoEvents,
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

class CustomPopUpShowLesson extends StatefulWidget {
  final SchoolLessonPrefab lesson;
  final SchoolDay day;
  final SchoolTime schoolTime;
  final String heroString;
  final TodoEvent? event;
  final bool showDeleteButton;
  final VoidCallback? onDeleteButtonPressed;

  const CustomPopUpShowLesson({
    super.key,
    required this.heroString,
    required this.day,
    required this.lesson,
    required this.schoolTime,
    required this.showDeleteButton,
    this.onDeleteButtonPressed,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
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
                widget.showDeleteButton
                    ? IconButton(
                        tooltip: AppLocalizationsManager
                            .localizations.strRemoveSubstitutionLesson,
                        padding: const EdgeInsets.all(18),
                        onPressed: () {
                          widget.onDeleteButtonPressed?.call();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
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
                replacement: Tooltip(
                  message: AppLocalizationsManager.localizations.strDeleteTask,
                  child: ElevatedButton(
                    onPressed: widget.event == null
                        ? null
                        : () async {
                            final event = widget.event;
                            if (event == null) return;

                            bool removeTodoEvent =
                                await Utils.showBoolInputDialog(
                              context,
                              question: AppLocalizationsManager.localizations
                                  .strDoYouWantToDeleteTaskX(
                                event.linkedSubjectName,
                              ),
                              description: event.endTime == null
                                  ? AppLocalizationsManager.localizations
                                      .strNoEndDate //kann nicht eintreten eigentlich
                                  : "(${Utils.dateToString(event.endTime!)})",
                              showYesAndNoInsteadOfOK: true,
                              markTrueAsRed: true,
                            );
                            if (!removeTodoEvent || !context.mounted) return;
                            bool deleteNote = false;

                            if (event.linkedSchoolNote != null) {
                              final delete = await Utils.showBoolInputDialog(
                                context,
                                question: AppLocalizationsManager.localizations
                                    .strDoYouWantToDeleteLinkedNote,
                                showYesAndNoInsteadOfOK: true,
                                markTrueAsRed: true,
                              );
                              deleteNote = delete;
                            }

                            TimetableManager().removeTodoEvent(
                              event,
                              deleteLinkedSchoolNote: deleteNote,
                            );

                            if (!context.mounted) return;

                            Navigator.of(context).pop();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 42,
                      ),
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
    required SchoolLessonPrefab lesson,
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
            color: lesson.color,
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
