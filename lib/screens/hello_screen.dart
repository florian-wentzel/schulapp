import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/code_behind/todo_event_util_functions.dart';

class HelloScreen extends StatefulWidget {
  static const route = "/hello";
  const HelloScreen({super.key});

  @override
  State<HelloScreen> createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen> {
  final _pageController = PageController();

  final List<HelloPage> _pages = [];
  int _currPageIndex = 0;

  @override
  void initState() {
    _pages.addAll(
      [
        HelloPage(
          title: AppLocalizationsManager.localizations.strSchoolApp,
          description: AppLocalizationsManager
              .localizations.strWelcomeToYourNewSchoolApp,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strTimetable,
          description: AppLocalizationsManager
              .localizations.strDoYouWantToCreateYourTimetable,
          actionDescription:
              AppLocalizationsManager.localizations.strCreateTimetable,
          action: _createTimetable,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strGrades,
          description: AppLocalizationsManager
              .localizations.strCreateYourSemesterAndLetTheAppHandleTheRest,
          actionDescription:
              AppLocalizationsManager.localizations.strCreateSemester,
          action: _createSemester,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strTasks,
          description: AppLocalizationsManager
              .localizations.strFeelFreeToCreateATaskForTheFuture,
          actionDescription:
              AppLocalizationsManager.localizations.strCreateATask,
          action: _createTask,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strHolidays,
          description: AppLocalizationsManager
              .localizations.strDoYouWantToSeeTheUpcomingHolidays,
          actionDescription:
              AppLocalizationsManager.localizations.strSelectFederalState,
          action: _selectState,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strYourReadyToGetStarted,
          description: "",
          actionDescription: AppLocalizationsManager.localizations.strStart,
          action: _start,
        ),
      ],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (currPageIndex) {
              _currPageIndex = currPageIndex;
              setState(() {});
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _pageWidget(page);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).cardColor,
              child: _bottomRow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageWidget(HelloPage page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Column(
          children: [
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            (page.action == null || page.actionDescription == null)
                ? Container()
                : ElevatedButton(
                    onPressed: page.action,
                    child: Text(
                      page.actionDescription!,
                    ),
                  ),
          ],
        ),
        Container(),
      ],
    );
  }

  Widget _bottomRow() {
    double progress = (_currPageIndex + 1) / _pages.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            _pageController.animateToPage(
              _pages.length - 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCirc,
            );
          },
          child: Text(AppLocalizationsManager.localizations.strSkip),
        ),
        Flexible(
          child: LinearProgressIndicator(
            value: progress,
          ),
        ),
        Visibility(
          visible: _isLastPage(),
          replacement: TextButton(
            onPressed: _nextPage,
            child: Text(AppLocalizationsManager.localizations.strNext),
          ),
          child: TextButton(
            onPressed: _start,
            child: Text(AppLocalizationsManager.localizations.strStart),
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    _pageController.animateToPage(
      _currPageIndex + 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCirc,
    );
    setState(() {});
  }

  void _createTimetable() async {
    bool created = await createNewTimetable(context) ?? false;

    if (!created) return;

    _nextPage();
  }

  void _createSemester() async {
    final semester = await showCreateSemesterSheet(context);

    if (semester == null) return;

    TimetableManager().addOrChangeSemester(
      semester,
      originalName: semester.name,
    );

    _nextPage();
  }

  void _createTask() async {
    final event = await createNewTodoEventSheet(
      context,
      linkedSubjectName: "Test",
      isCustomEvent: true,
    );

    if (event == null) return;

    TimetableManager().addOrChangeTodoEvent(event);
    _nextPage();
  }

  void _selectState() async {
    bool selected = await HolidaysScreen.selectFederalStateButtonPressed(
      context,
    );

    if (!selected) return;

    _nextPage();
  }

  void _start() async {
    await VersionManager().updateLastUsedVersion();

    if (!mounted) return;

    context.go(TimetableScreen.route);
  }

  bool _isLastPage() {
    return _currPageIndex == _pages.length - 1;
  }
}

class HelloPage {
  String title;
  String description;
  String? actionDescription;
  void Function()? action;

  HelloPage({
    required this.title,
    required this.description,
    this.actionDescription,
    this.action,
  });
}
