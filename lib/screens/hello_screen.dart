import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/home_screen.dart';
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
          icon: Icons.school,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strTimetable,
          description: AppLocalizationsManager
              .localizations.strDoYouWantToCreateYourTimetable,
          icon: Icons.calendar_today,
          actionDescription:
              AppLocalizationsManager.localizations.strCreateTimetable,
          action: _createTimetable,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strSelectTimetableView,
          description: AppLocalizationsManager
              .localizations.strSelectTimetableViewDescription,
          icon: Icons.view_agenda,
          customContent: _buildTimetableViewSelector,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strGrades,
          description: AppLocalizationsManager
              .localizations.strCreateYourSemesterAndLetTheAppHandleTheRest,
          icon: Icons.grade,
          actionDescription:
              AppLocalizationsManager.localizations.strCreateSemester,
          action: _createSemester,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strTasks,
          description: AppLocalizationsManager
              .localizations.strFeelFreeToCreateATaskForTheFuture,
          icon: Icons.task_alt,
          actionDescription:
              AppLocalizationsManager.localizations.strCreateATask,
          action: _createTask,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strHolidays,
          description: AppLocalizationsManager
              .localizations.strDoYouWantToSeeTheUpcomingHolidays,
          icon: Icons.beach_access,
          actionDescription:
              AppLocalizationsManager.localizations.strSelectFederalState,
          action: _selectState,
        ),
        HelloPage(
          title:
              AppLocalizationsManager.localizations.strYourReadyToGetStarted,
          description: "",
          icon: Icons.rocket_launch,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              if (page.icon != null)
                Icon(
                  page.icon,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              const SizedBox(height: 16),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          Column(
            children: [
              if (page.description.isNotEmpty)
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              if (page.customContent != null)
                page.customContent!.call(context),
              if (page.action != null && page.actionDescription != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: page.action,
                    child: Text(page.actionDescription!),
                  ),
                ),
            ],
          ),
          // Spacer to leave room for the bottom navigation bar
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTimetableViewSelector(BuildContext context) {
    final manager = TimetableManager();
    final bool showAlwaysWeekTimetable =
        manager.settings.getVar(Settings.showAlwaysWeekTimetableKey);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _viewOptionCard(
            context: context,
            label: AppLocalizationsManager.localizations.strDayView,
            icon: Icons.view_day,
            selected: !showAlwaysWeekTimetable,
            onTap: () {
              manager.settings.setVar(
                    Settings.showAlwaysWeekTimetableKey,
                    false,
                  );
              setState(() {});
            },
          ),
          const SizedBox(width: 16),
          _viewOptionCard(
            context: context,
            label: AppLocalizationsManager.localizations.strWeekView,
            icon: Icons.calendar_view_week,
            selected: showAlwaysWeekTimetable,
            onTap: () {
              manager.settings.setVar(
                    Settings.showAlwaysWeekTimetableKey,
                    true,
                  );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _viewOptionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 130,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
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

    context.go(HomeScreen.route);
  }

  bool _isLastPage() {
    return _currPageIndex == _pages.length - 1;
  }
}

class HelloPage {
  String title;
  String description;
  IconData? icon;
  String? actionDescription;
  void Function()? action;
  Widget Function(BuildContext context)? customContent;

  HelloPage({
    required this.title,
    required this.description,
    this.icon,
    this.actionDescription,
    this.action,
    this.customContent,
  });
}
