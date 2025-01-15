import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/hello_screen.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/versions_screen.dart';
import 'package:schulapp/screens/todo_events_screen.dart';
import 'package:schulapp/screens/timetable/create_timetable_screen.dart';
import 'package:schulapp/screens/timetable/import_export_timetable_screen.dart';
import 'package:schulapp/screens/vertretungsplan_paul_dessau_screen.dart';
import 'package:schulapp/widgets/timetable/timetable_widget.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/timetable/timetable_one_day_widget.dart';
import 'package:schulapp/widgets/task/todo_event_list_item_widget.dart';
import 'package:schulapp/code_behind/todo_event_util_functions.dart';

class HomeScreen extends StatefulWidget {
  static const String route = "/";

  final String title;
  final Timetable? timetable;
  final bool isHomeScreen;

  const HomeScreen({
    super.key,
    required this.title,
    required this.timetable,
    this.isHomeScreen = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _intentSubscription;

  final _verticalPageViewController = PageController();

  List<SchoolTime>? ttSchoolTimes;

  Holidays? currentOrNextHolidays;
  Timer? _dayProgressTimer;

  double _dayProgress = 0;

  int _currPageIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      _postFrameCallback,
    );
    _fetchHolidays();

    // _initReceiveSharingIntent();

    _initTtSchoolTimes();

    super.initState();
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    _cancelDayProgressTimer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MainApp.changeNavBarVisibilitySecure(
      context,
      value: true,
    );

    bool showSubstitutionplanAction =
        TimetableManager().settings.getVar(Settings.usernameKey) != null;

    String? extraTimetableName = TimetableManager()
        .settings
        .getVar(Settings.extraTimetableOnHomeScreenKey);

    Timetable? extraTimetable =
        TimetableManager().timetables.cast<Timetable?>().firstWhere(
              (element) => element?.name == extraTimetableName,
              orElse: () => null,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Visibility(
            visible: extraTimetable != null && widget.isHomeScreen,
            child: IconButton(
              onPressed: () async {
                final ett = extraTimetable;

                if (ett == null) return;

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      title: AppLocalizationsManager.localizations
                          .strTimetableWithName(
                        ett.name,
                      ),
                      timetable: ett,
                    ),
                  ),
                );

                setState(() {});
              },
              icon: const Icon(Icons.event),
            ),
          ),
          Visibility(
            visible: showSubstitutionplanAction && widget.isHomeScreen,
            child: IconButton(
              tooltip:
                  AppLocalizationsManager.localizations.strSubstitutionPlan,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VertretungsplanPaulDessauScreen(
                      loadPDFDirectly: true,
                    ),
                  ),
                );

                setState(() {});
              },
              icon: const Icon(Icons.cloud_download),
            ),
          ),
        ],
      ),
      drawer: widget.isHomeScreen
          ? NavigationBarDrawer(selectedRoute: HomeScreen.route)
          : null,
      floatingActionButton: _floatingActionButton(context),
      body: _body(),
    );
  }

  Widget? _floatingActionButton(BuildContext context) {
    if (_currPageIndex != 0) return null;

    return SpeedDial(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.close,
      spacing: 3,
      useRotationAnimation: true,
      tooltip: '',
      animationCurve: Curves.elasticInOut,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.assignment_add),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          label: AppLocalizationsManager.localizations.strCreateATask,
          onTap: () async {
            //selectedSubjectName, isCustomTask
            (String, bool)? selectedSubjectNameTuple =
                await showSelectSubjectNameSheet(
              context,
              title: AppLocalizationsManager
                  .localizations.strSelectSubjectToAddTaskTo,
              allowCustomNames: true,
            );

            if (selectedSubjectNameTuple == null) return;
            if (!context.mounted) return;

            String selectedSubjectName = selectedSubjectNameTuple.$1;
            bool isCustomTask = selectedSubjectNameTuple.$2;

            TodoEvent? event = await createNewTodoEventSheet(
              context,
              linkedSubjectName: selectedSubjectName,
              isCustomEvent: isCustomTask,
            );

            if (event == null) return;

            TimetableManager().addOrChangeTodoEvent(event);

            if (!mounted) return;

            setState(() {});
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          label: AppLocalizationsManager.localizations.strCreateTimetable,
          onTap: () async {
            await createNewTimetable(context);

            if (!mounted) return;
            //not sure
            setState(() {});
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit),
          visible: widget.timetable != null,
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          label: AppLocalizationsManager.localizations.strEdit,
          onTap: () async {
            final tt = widget.timetable;
            if (tt == null) return;

            final ttCopy = tt.copy();

            bool? newTtCreated = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => CreateTimetableScreen(
                  timetable: tt,
                ),
              ),
            );

            newTtCreated ??= false;

            if (!newTtCreated) {
              //reset timetable
              tt.setValuesFrom(ttCopy);
            }

            setState(() {});
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.import_export),
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
          label: AppLocalizationsManager.localizations.strImportExport,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ImportExportTimetableScreen(),
              ),
            );
            setState(() {});
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.event),
          backgroundColor: Colors.lightBlue.shade200,
          foregroundColor: Colors.white,
          label:
              AppLocalizationsManager.localizations.strSetHomeScreenTimetable,
          onTap: () async {
            Timetable? tt = await showSelectTimetableSheet(
              context,
              title: AppLocalizationsManager
                  .localizations.strSetHomeScreenTimetable,
            );

            if (tt == null) return;

            TimetableManager().settings.setVar(
                  Settings.mainTimetableNameKey,
                  tt.name,
                );

            if (!context.mounted) return;

            HomeWidgetManager.updateWithDefaultTimetable(
              context: context,
            );

            //damit der screen neu erstellt und der neue timetable angezeigt wird
            context.go(
              "${HomeScreen.route}?reload=${DateTime.now().millisecondsSinceEpoch}",
            );
          },
        ),
      ],
    );
  }

  Widget _body() {
    final tt = widget.timetable;
    if (tt == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await createNewTimetable(context);
            if (!mounted) return;
            //damit er neu geladen wird
            context.go("${HomeScreen.route}?reload=true");
          },
          child: Text(
            AppLocalizationsManager.localizations.strCreateTimetable,
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    double height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;

    if (Utils.isMobileRatio(context)) {
      height -= kBottomNavigationBarHeight;
      height -= 2; //without you could scroll a little bit

      return _timetableBuilder(
        width: width,
        height: height,
        child: TimetableOneDayWidget(
          timetable: tt,
          showTodoEvents: widget.isHomeScreen,
        ),
      );
    }

    return _timetableBuilder(
      child: TimetableWidget(
        timetable: tt,
        showTodoEvents: widget.isHomeScreen,
      ),
      width: width,
      height: height,
    );
  }

  Widget _timetableBuilder({
    required Widget child,
    required double width,
    required double height,
  }) {
    return PageView(
      scrollDirection: Axis.vertical,
      controller: _verticalPageViewController,
      onPageChanged: (value) {
        _currPageIndex = value;
        const statsPageIndex = 1;
        if (value == statsPageIndex) {
          _startDayProgressTimer();
        } else {
          _cancelDayProgressTimer();
        }
        setState(() {});
      },
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 1],
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context).cardColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                primary: false,
                child: Center(
                  child: child,
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //     color: Colors.transparent,
              //     width: width,
              //     height: height / 3,
              //   ),
              // ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: InkWell(
              //     onTap: () {
              //       _verticalPageViewController.animateToPage(
              //         1,
              //         duration: const Duration(
              //           milliseconds: 500,
              //         ),
              //         curve: Curves.easeInOutCirc,
              //       );
              //     },
              //     child: Container(
              //       width: width,
              //       height: 30,
              //       decoration: BoxDecoration(
              //         color: Theme.of(context).cardColor,
              //         borderRadius: const BorderRadius.only(
              //           topLeft: Radius.circular(64),
              //           topRight: Radius.circular(64),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        _statsPage(
          width: width,
          height: height,
        ),
      ],
    );
  }

  Widget _statsPage({
    required double width,
    required double height,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: width,
      height: height,
      color: Theme.of(context).cardColor,
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            child: Column(
              children: [
                Text(
                  AppLocalizationsManager.localizations.strStatistics,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                _gradesChartWidget(),
                const SizedBox(
                  height: 8,
                ),
                _nextTaskWidget(),
                _dayProgressBar(),
                const SizedBox(
                  height: 8,
                ),
                _holidaysWidget(),
                // Container(
                //   height: height,
                //   color: Colors.amber,
                // ),
              ],
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     color: Colors.transparent,
          //     width: width,
          //     height: height / 3,
          //   ),
          // ),
        ],
      ),
    );
  }

  int _pieChartTouchedIndex = -1;

  Widget _gradesChartWidget() {
    SchoolSemester? semester = Utils.getMainSemester();

    if (semester == null) return Container();

    final sections = _generatePieChartSecions(semester);
    if (sections == null) return Container();

    final width = MediaQuery.of(context).size.width * 0.8;

    return Container(
      width: width,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  //if (!event.isInterestedForInteractions ||
                  if (pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _pieChartTouchedIndex = -1;
                    return;
                  }
                  _pieChartTouchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;

                  setState(() {});
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              sections: sections,
              centerSpaceRadius: 30,
              centerSpaceColor: semester.getColor(),
            ),
          ),
          Center(
            child: InkWell(
              onTap: () {
                context.go(GradesScreen.route);
              },
              child: Text(
                semester.getGradePointsAverageString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData>? _generatePieChartSecions(SchoolSemester semester) {
    const defaultRadius = 40.0;
    const selectedRadius = 60.0;
    List<PieChartSectionData> list = [];
    int numberOfGrades = 0;

    //grade, count
    Map<int, int> grades = {};
    for (final subject in semester.subjects) {
      for (final gradeGroup in subject.gradeGroups) {
        for (final grade in gradeGroup.grades) {
          if (grades[grade.grade] == null) {
            grades[grade.grade] = 1;
          } else {
            grades[grade.grade] = grades[grade.grade]! + 1;
          }
          numberOfGrades++;
        }
      }
    }

    grades = Map.fromEntries(
      grades.entries.toList()
        ..sort(
          (e1, e2) => e1.key.compareTo(e2.key),
        ),
    );

    if (numberOfGrades == 0) return null;

    int index = 0;
    for (int key in grades.keys) {
      String title = GradingSystemManager.convertGradeToSelectedSystem(key);
      bool selected = index == _pieChartTouchedIndex;

      if (selected && grades[key] != null) {
        title = "x ${grades[key]?.toString() ?? key.toString()}";
      }

      list.add(
        PieChartSectionData(
          borderSide: BorderSide(
            width: 0,
            color: Theme.of(context).canvasColor,
          ),
          color: Utils.getGradeColor(key),
          title: title,
          radius: selected ? selectedRadius : defaultRadius,
          value: grades[key]! / numberOfGrades,
        ),
      );
      index++;
    }

    return list;
  }

  Widget _dayProgressBar() {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.secondaryContainer;
    final gradientStartColor = theme.colorScheme.tertiary;
    final gradientEndColor = theme.colorScheme.primaryContainer;
    final textColor = theme.colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizationsManager.localizations.strDayProgress,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            height: 18,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: constraints.maxWidth * _dayProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStartColor, gradientEndColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${(_dayProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextTaskWidget() {
    TodoEvent? nextTodoEvent = TimetableManager().sortedTodoEvents.firstOrNull;

    if (nextTodoEvent == null) return Container();

    return TodoEventListItemWidget(
      event: nextTodoEvent,
      onPressed: () {
        nextTodoEvent.finished = !nextTodoEvent.finished;
        //damit es gespeichert wird
        TimetableManager().addOrChangeTodoEvent(nextTodoEvent);
        setState(() {});
      },
      onInfoPressed: () async {
        await Utils.showCustomPopUp(
          context: context,
          heroObject: nextTodoEvent,
          body: TodoEventInfoPopUp(
            event: nextTodoEvent,
            showEditTodoEventSheet: (event) async {
              TodoEvent? newEvent = await createNewTodoEventSheet(
                context,
                linkedSubjectName: event.linkedSubjectName,
                event: event,
              );

              return newEvent;
            },
          ),
          flightShuttleBuilder: (p0, p1, p2, p3, p4) {
            return Container(
              color: Theme.of(context).cardColor,
            );
          },
        );

        //warten damit animation funktioniert
        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        setState(() {});
      },
      onLongPressed: () {},
      onDeleteSwipe: () {},
    );
  }

  Widget _holidaysWidget() {
    if (currentOrNextHolidays == null) {
      return ElevatedButton(
        onPressed: () => HolidaysScreen.selectFederalStateButtonPressed(
          context,
          fetchHolidays: _fetchHolidays,
          setState: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
        child: Text(
          AppLocalizationsManager.localizations.strSelectFederalState,
        ),
      );
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            context.go(HolidaysScreen.route);
          },
          child: HolidaysListItemWidget(
            holidays: currentOrNextHolidays!,
            showBackground: false,
            showDateInfo: false,
          ),
        ),
      ],
    );
  }

  Future<void> _fetchHolidays() async {
    String? stateApiCode = TimetableManager().settings.getVar(
          Settings.selectedFederalStateCodeKey,
        );
    stateApiCode ??= "";

    currentOrNextHolidays = await HolidaysManager.getCurrOrNextHolidayForState(
      stateApiCode: stateApiCode,
    );

    setState(() {});
  }

  void _postFrameCallback(Duration _) async {
    final currVersion = await VersionManager().getVersionString();

    if (!mounted) return;

    //only for developers
    if (kDebugMode && !VersionHolder.isVersionSaved(currVersion)) {
      Utils.showInfo(
        context,
        msg:
            "Current version: $currVersion is not safed in version_manager.dart/VersionHolder.versions\npls add it!",
        type: InfoType.error,
        duration: const Duration(seconds: 8),
      );
    }

    final fistTimeOpening = VersionManager().isFirstTimeOpening();

    if (!mounted) return;

    if (fistTimeOpening) {
      context.go(HelloScreen.route);
      return;
    }

    final isNewVersionInstalled =
        await VersionManager().isNewVersionInstalled();

    if (!mounted) return;

    if (isNewVersionInstalled) {
      String? lastUsedVersion = TimetableManager().settings.getVar(
            Settings.lastUsedVersionKey,
          );

      if (lastUsedVersion == null) return;

      Utils.showInfo(
        context,
        msg: AppLocalizationsManager
            .localizations.strYouUpdatedYourAppWantToSeeNewFeatures,
        type: InfoType.info,
        duration: const Duration(seconds: 8),
        actionWidget: SnackBarAction(
          label: AppLocalizationsManager.localizations.strShowNewFeatures,
          onPressed: () async {
            Utils.hideCurrInfo(context);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VersionsScreen(
                  lastUsedVersion: lastUsedVersion,
                ),
              ),
            );

            VersionManager().updateLastUsedVersion();
          },
        ),
      );
      VersionManager().updateLastUsedVersion();
    }
  }

  // void _initReceiveSharingIntent() async {
  //   if (!Platform.isAndroid && !Platform.isIOS) {
  //     return;
  //   }

  //   try {
  //     ReceiveSharingIntent.instance.getInitialMedia().then(
  //           (value) => _handleFiles(
  //             value,
  //             resetAfter: true,
  //           ),
  //         );
  //     _intentSubscription = ReceiveSharingIntent.instance
  //         .getMediaStream()
  //         .listen(
  //           _handleFiles,
  //           onError: (error) => debugPrint("getIntentDataStream error: $error"),
  //         );
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Future<void> _handleFiles(
  //   List<SharedMediaFile> files, {
  //   bool resetAfter = false,
  // }) async {
  //   //only go to all timetablesscreen when user saves timetable
  //   bool goToAllTimetables = false;

  //   for (SharedMediaFile mediaFile in files) {
  //     final file = File(mediaFile.path);

  //     if (!file.existsSync()) {
  //       continue;
  //     }

  //     if (mounted) {
  //       Utils.showInfo(
  //         context,
  //         duration: const Duration(seconds: 1),
  //         msg: AppLocalizationsManager.localizations.strImportingTimetable,
  //       );
  //     }

  //     Timetable? timetable;

  //     try {
  //       timetable = SaveManager().importTimetable(file);
  //     } catch (e) {
  //       debugPrint(e.toString());
  //     }

  //     await Future.delayed(
  //       const Duration(milliseconds: 500),
  //     );

  //     if (mounted) {
  //       if (timetable == null) {
  //         Utils.showInfo(
  //           context,
  //           msg: AppLocalizationsManager.localizations.strImportingFailed,
  //           type: InfoType.error,
  //         );
  //       } else {
  //         Utils.showInfo(
  //           context,
  //           msg: AppLocalizationsManager.localizations.strImportSuccessful,
  //           type: InfoType.success,
  //         );
  //       }
  //     }
  //     if (timetable == null) continue;

  //     await Future.delayed(
  //       const Duration(milliseconds: 250),
  //     );

  //     if (!mounted) return;

  //     bool timetableSaved = await Navigator.of(context).push<bool?>(
  //           MaterialPageRoute(
  //             builder: (context) =>
  //                 CreateTimetableScreen(timetable: timetable!),
  //           ),
  //         ) ??
  //         false;

  //     if (timetableSaved) goToAllTimetables = true;
  //   }

  //   if (resetAfter) {
  //     ReceiveSharingIntent.instance.reset();
  //   }

  //   if (!goToAllTimetables) return;

  //   if (mounted) {
  //     context.go(TimetablesScreen.route);
  //   }
  // }

  void _startDayProgressTimer() {
    if (_dayProgressTimer != null) return;

    _dayProgressTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => _calcDayProgressTimer(),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _calcDayProgressTimer(),
    );
  }

  SchoolTime? _getStartTime(Timetable tt) {
    //index welcher angibt was wir als start ansehen
    int startIndex = 0;

    final dayIndex = Utils.getCurrentWeekDayIndex();
    final schoolDay = tt.schoolDays[dayIndex];
    final now = DateTime.now();
    final weekIndex = Utils.getWeekIndex(now);
    final year = now.year;

    for (int i = startIndex; i < schoolDay.lessons.length; i++) {
      final isSpecialLesson = TimetableManager().isSpecialLesson(
        timetable: tt,
        schoolTimeIndex: i,
        schoolDayIndex: dayIndex,
        weekIndex: weekIndex,
        year: year,
      );
      if (!SchoolLesson.isEmptyLesson(schoolDay.lessons[i]) &&
          !isSpecialLesson) {
        break;
      }
      startIndex++;
    }
    final schoolTimes = ttSchoolTimes;
    if (schoolTimes != null && startIndex >= schoolTimes.length) {
      return null;
    }

    return ttSchoolTimes?[startIndex];
  }

  void _calcDayProgressTimer() {
    final schoolTimes = ttSchoolTimes;
    final tt = widget.timetable;

    if (tt == null) return;
    if (schoolTimes == null) return;

    final first = _getStartTime(tt);
    if (first == null) {
      setState(() {
        _dayProgress = 1;
      });
      return;
    }

    final last = _getEndTime(tt);
    if (last == null) {
      setState(() {
        _dayProgress = 1;
      });
      return;
    }

    final startInSeconds = first.start.toSeconds();
    final endInSeconds = last.end.toSeconds();

    final totalSecondsInDay = endInSeconds - startInSeconds;

    if (totalSecondsInDay == 0) return;

    final now = TimeOfDay.now();

    if (now.isBefore(schoolTimes.first.start)) {
      setState(() {
        _dayProgress = 0;
      });
      return;
    }
    if (schoolTimes.last.end.isBefore(now)) {
      setState(() {
        _dayProgress = 1;
      });
      return;
    }

    final secondsPassedToday = now.toSeconds() - startInSeconds;

    double progress =
        (secondsPassedToday.toDouble() / totalSecondsInDay.toDouble())
            .clamp(0, 1);

    setState(() {
      _dayProgress = progress;
    });
  }

  void _cancelDayProgressTimer() {
    _dayProgressTimer?.cancel();
    _dayProgressTimer = null;
    _dayProgress = 0;
  }

  void _initTtSchoolTimes() {
    final tt = widget.timetable;

    if (tt == null) return;

    ttSchoolTimes = tt.schoolTimes;

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
      return;
    }

    if (reducedClassHours.length < tt.schoolTimes.length) {
      return;
    }

    while (reducedClassHours.length > tt.schoolTimes.length) {
      reducedClassHours.removeLast();
    }

    ttSchoolTimes = reducedClassHours;
  }

  SchoolTime? _getEndTime(Timetable tt) {
    final schoolTimes = ttSchoolTimes;
    if (schoolTimes == null) {
      return null;
    }

    //index welcher angibt was wir als ende ansehen
    int endIndex = schoolTimes.length - 1;

    final dayIndex = Utils.getCurrentWeekDayIndex();
    final schoolDay = tt.schoolDays[dayIndex];
    final now = DateTime.now();
    final weekIndex = Utils.getWeekIndex(now);
    final year = now.year;

    for (int i = endIndex; i >= 0; i--) {
      final isSpecialLesson = TimetableManager().isSpecialLesson(
        timetable: tt,
        schoolTimeIndex: i,
        schoolDayIndex: dayIndex,
        weekIndex: weekIndex,
        year: year,
      );
      if (!SchoolLesson.isEmptyLesson(schoolDay.lessons[i]) &&
          !isSpecialLesson) {
        break;
      }
      endIndex--;
    }

    if (endIndex < 0) {
      return null;
    }

    return schoolTimes[endIndex];
  }
}
