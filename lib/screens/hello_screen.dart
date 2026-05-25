import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/home_screen.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/code_behind/todo_event_util_functions.dart';

// class _FeatureTopic {
//   final IconData icon;
//   final String title;
//   final String description;

//   const _FeatureTopic({
//     required this.icon,
//     required this.title,
//     required this.description,
//   });
// }

// const _featureTopics = [
//   _FeatureTopic(
//     icon: Icons.calendar_today,
//     title: 'Stundenplan',
//     description:
//         'Anstatt dir einen Stundenplan zu erstellen, kannst du dir auch einfach den Stundenplan eines Freundes / einer Freundin importieren (einfach auf dem Startbildschirm die drei Punkte drücken und auf "Importieren / Exportieren" gehen, dann auf "via Online Code importieren und fertig)\n\n'
//         'So kannst du natürlich auch deinen Stundenplan mit Freund*innen teilen! Sehr praktisch um zu wissen wann wer frei hat :)',
//   ),
//   _FeatureTopic(
//     icon: Icons.grade,
//     title: 'Noten',
//     description: 'Verwalte deine Noten pro Semester und Fach.'
//         'Die App berechnet automatisch deinen Notendurchschnitt du kannst verschiedene Notengruppen unterschiedlich gewichten.\n'
//         'Außerdem kannst du dir deinen Abischnitt berechnen lassen.',
//   ),
//   _FeatureTopic(
//     icon: Icons.task_alt,
//     title: 'Aufgaben',
//     description: 'Behalte den Überblick über Hausaufgaben und Prüfungen. '
//         'Verknüpfe Aufgaben mit einem Fach und verpasse keine Abgabe mehr.',
//   ),
//   _FeatureTopic(
//     icon: Icons.beach_access,
//     title: 'Ferien',
//     description: 'Wähle dein Bundesland aus und sieh auf einen Blick, '
//         'wann die nächsten Schulferien und Feiertage sind.',
//   ),
//   _FeatureTopic(
//     icon: Icons.code,
//     title: 'Wer Programmiert die App?',
//     description: 'Warum ist sie kostenlos und ohne Werbung und Opensource!?, '
//         'wann die nächsten Schulferien und Feiertage sind.',
//   ),
// ];

// class FeaturesOverviewWidget extends StatelessWidget {
//   const FeaturesOverviewWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16.0),
//       child: OutlinedButton.icon(
//         onPressed: () => _showFeaturesSheet(context),
//         icon: const Icon(Icons.explore_outlined),
//         label: Text(AppLocalizationsManager.localizations.strWhatCanYouDo),
//       ),
//     );
//   }

//   void _showFeaturesSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       showDragHandle: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => const _FeaturesBottomSheetContent(),
//     );
//   }
// }

// class _FeatureExpansionTile extends StatelessWidget {
//   final _FeatureTopic topic;
//   final ExpansibleController controller;
//   final VoidCallback? onExpanded;
//   final VoidCallback? onCollapsed;

//   const _FeatureExpansionTile({
//     required this.topic,
//     required this.controller,
//     this.onExpanded,
//     this.onCollapsed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: colorScheme.outlineVariant),
//       ),
//       child: ExpansionTile(
//         controller: controller,
//         leading: CircleAvatar(
//           backgroundColor: colorScheme.primaryContainer,
//           child: Icon(topic.icon, color: colorScheme.onPrimaryContainer),
//         ),
//         title: Text(
//           topic.title,
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         shape: const RoundedRectangleBorder(side: BorderSide.none),
//         collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
//         onExpansionChanged: (expanded) {
//           if (expanded) {
//             onExpanded?.call();
//           } else {
//             onCollapsed?.call();
//           }
//         },
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//             child: Text(
//               topic.description,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FeaturesBottomSheetContent extends StatefulWidget {
//   const _FeaturesBottomSheetContent();

//   @override
//   State<_FeaturesBottomSheetContent> createState() =>
//       _FeaturesBottomSheetContentState();
// }

// class _FeaturesBottomSheetContentState
//     extends State<_FeaturesBottomSheetContent> {
//   final _sheetController = DraggableScrollableController();
//   late final List<ExpansibleController> _tileControllers;
//   int? _expandedIndex;

//   @override
//   void initState() {
//     super.initState();
//     _tileControllers = List.generate(
//       _featureTopics.length,
//       (_) => ExpansibleController(),
//     );
//   }

//   @override
//   void dispose() {
//     _sheetController.dispose();
//     super.dispose();
//   }

//   void _onTileExpanded(int index) {
//     // Collapse the previously open tile without triggering the sheet animation
//     if (_expandedIndex != null && _expandedIndex != index) {
//       _tileControllers[_expandedIndex!].collapse();
//     }
//     _expandedIndex = index;
//     _sheetController.animateTo(
//       0.92,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _onTileCollapsed(int index) {
//     if (_expandedIndex == index) {
//       _expandedIndex = null;
//       _sheetController.animateTo(
//         0.6,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       controller: _sheetController,
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.92,
//       expand: false,
//       snap: true,
//       snapSizes: const [0.6, 0.92],
//       builder: (context, scrollController) => ListView(
//         controller: scrollController,
//         padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//         children: [
//           Text(
//             'Was kann die App noch?',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Entdecke alle Funktionen im Überblick',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ..._featureTopics.asMap().entries.map(
//                 (e) => _FeatureExpansionTile(
//                   topic: e.value,
//                   controller: _tileControllers[e.key],
//                   onExpanded: () => _onTileExpanded(e.key),
//                   onCollapsed: () => _onTileCollapsed(e.key),
//                 ),
//               ),
//         ],
//       ),
//     );
//   }
// }

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
          actionDescription: AppLocalizationsManager.localizations.strNext,
          action: _imGoingToDoItLater,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strTimetable,
          description: AppLocalizationsManager
              .localizations.strDoYouWantToCreateYourTimetable,
          icon: Icons.calendar_today,
          actionDescription:
              AppLocalizationsManager.localizations.strImGoingToDoItLater,
          action: _imGoingToDoItLater,
          customContent: _createTimetable,
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
              AppLocalizationsManager.localizations.strImGoingToDoItLater,
          action: _imGoingToDoItLater,
          customContent: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: _createSemester,
                child: Text(
                    AppLocalizationsManager.localizations.strCreateSemester),
              ),
            );
          },
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strGradeSystem,
          description: AppLocalizationsManager
              .localizations.strWhichGradingSystemDoesYourSchoolUse,
          icon: Icons.calculate,
          customContent: _buildGradeSystemSelector,
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strTasks,
          description: AppLocalizationsManager
              .localizations.strFeelFreeToCreateATaskForTheFuture,
          icon: Icons.task_alt,
          actionDescription:
              AppLocalizationsManager.localizations.strImGoingToDoItLater,
          action: _imGoingToDoItLater,
          customContent: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: _createTask,
                child:
                    Text(AppLocalizationsManager.localizations.strCreateATask),
              ),
            );
          },
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strHolidays,
          description: AppLocalizationsManager
              .localizations.strDoYouWantToSeeTheUpcomingHolidays,
          icon: Icons.beach_access,
          actionDescription:
              AppLocalizationsManager.localizations.strImGoingToDoItLater,
          action: _imGoingToDoItLater,
          customContent: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: _selectState,
                child: Text(AppLocalizationsManager
                    .localizations.strSelectFederalState),
              ),
            );
          },
        ),
        HelloPage(
          title: AppLocalizationsManager.localizations.strYourReadyToGetStarted,
          description: AppLocalizationsManager
              .localizations.strYourReadyToGetStartedDescription,
          icon: Icons.rocket_launch,
          actionDescription: AppLocalizationsManager.localizations.strStart,
          // customContent: (BuildContext context) {
          //   return const FeaturesOverviewWidget(); //TODO
          // },
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
            mainAxisSize: MainAxisSize.min,
            children: [
              if (page.icon != null)
                Icon(
                  page.icon,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              const SizedBox(height: 16),
              FittedBox(
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                  maxLines: 1,
                ),
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
              if (page.customContent != null) page.customContent!.call(context),
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

  Widget _buildGradeSystemSelector(BuildContext context) {
    final manager = TimetableManager();
    final GradingSystem selected =
        manager.settings.getVar(Settings.selectedGradeSystemKey);

    final systems = [
      (
        GradingSystem.grade_0_15,
        Icons.tag,
        AppLocalizationsManager.localizations.strPoints_0_15,
        '15 · 10 · 05 · 00',
      ),
      (
        GradingSystem.grade_1_6,
        Icons.looks_one,
        AppLocalizationsManager.localizations.strGrade_1_6,
        '1+ · 2 · 3- · 4',
      ),
      (
        GradingSystem.grade_6_1,
        Icons.looks_6,
        AppLocalizationsManager.localizations.strGrade_6_1,
        '4 · 3- · 2 · 1+',
      ),
      (
        GradingSystem.grade_A_F,
        Icons.abc,
        AppLocalizationsManager.localizations.strGrade_A_F,
        'A · B · C · D',
      ),
    ];

    final rows = [
      systems.sublist(0, 2),
      systems.sublist(2, 4),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _gradeSystemCard(
                        context: context,
                        system: row[0].$1,
                        icon: row[0].$2,
                        label: row[0].$3,
                        example: row[0].$4,
                        selected: selected,
                        onTap: () {
                          manager.settings.setVar(
                            Settings.selectedGradeSystemKey,
                            row[0].$1,
                          );
                          setState(() {});
                          _nextPage();
                        },
                      ),
                      const SizedBox(width: 12),
                      _gradeSystemCard(
                        context: context,
                        system: row[1].$1,
                        icon: row[1].$2,
                        label: row[1].$3,
                        example: row[1].$4,
                        selected: selected,
                        onTap: () {
                          manager.settings.setVar(
                            Settings.selectedGradeSystemKey,
                            row[1].$1,
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _gradeSystemCard({
    required BuildContext context,
    required GradingSystem system,
    required IconData icon,
    required String label,
    required String example,
    required GradingSystem selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = system == selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 148,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              example,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary.withValues(alpha: 0.8)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableViewSelector(BuildContext context) {
    final manager = TimetableManager();
    final bool showAlwaysWeekTimetable =
        manager.settings.getVar(Settings.showAlwaysWeekTimetableKey);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
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
                _nextPage();
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
                _nextPage();
              },
            ),
          ],
        ),
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
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
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
            borderRadius: BorderRadius.circular(8),
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

  void _imGoingToDoItLater() {
    _nextPage();
  }

  Widget _createTimetable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () async {
          bool created = await createNewTimetable(context) ?? false;

          if (!created) return;

          _nextPage();
        },
        child: Text(AppLocalizationsManager.localizations.strCreateTimetable),
      ),
    );
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
