import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/all_timetables_screen.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/notes_screen.dart';
import 'package:schulapp/screens/vertretungsplan_paul_dessau_screen.dart';
import 'package:schulapp/screens/tasks_screen.dart';
import 'package:schulapp/screens/settings_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';

class CustomDestination {
  final String label;
  final String route;
  final Widget icon;
  final Widget selectedIcon;

  CustomDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });
}

// ignore: must_be_immutable
class NavigationBarDrawer extends StatefulWidget {
  String selectedRoute;

  NavigationBarDrawer({super.key, required this.selectedRoute});

  @override
  State<NavigationBarDrawer> createState() => _NavigationBarDrawerState();
}

class _NavigationBarDrawerState extends State<NavigationBarDrawer> {
  final List<CustomDestination?> destinations = <CustomDestination?>[
    CustomDestination(
      label: AppLocalizationsManager.localizations.strStartScreen,
      route: TimetableScreen.route,
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
    ),
    CustomDestination(
      label: AppLocalizationsManager.localizations.strTimetables,
      route: AllTimetablesScreen.route,
      icon: const Icon(Icons.dataset_outlined),
      selectedIcon: const Icon(Icons.dataset),
    ),
    CustomDestination(
      label: AppLocalizationsManager.localizations.strGrades,
      route: GradesScreen.route,
      icon: const Icon(Icons.school_outlined),
      selectedIcon: const Icon(Icons.school),
    ),
    CustomDestination(
      label: AppLocalizationsManager.localizations.strTasks,
      route: TasksScreen.route,
      icon: const Icon(Icons.assignment_outlined),
      selectedIcon: const Icon(Icons.assignment),
    ),
    CustomDestination(
      label: AppLocalizationsManager.localizations.strNotes,
      route: NotesScreen.route,
      icon: const Icon(Icons.book_outlined),
      selectedIcon: const Icon(Icons.book),
    ),
    CustomDestination(
      label: AppLocalizationsManager.localizations.strHolidays,
      route: HolidaysScreen.route,
      icon: const Icon(Icons.card_giftcard_outlined),
      selectedIcon: const Icon(Icons.card_giftcard),
    ),
    null,
    CustomDestination(
      label: AppLocalizationsManager.localizations.strSettings,
      route: SettingsScreen.route,
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
    ),
    // CustomDestination(
    //     label: 'Messages', Icon(Icons.widgets_outlined), Icon(Icons.widgets)),
    // CustomDestination(
    //     'Profile', Icon(Icons.format_paint_outlined), Icon(Icons.format_paint)),
    // CustomDestination(
    //     'Settings', Icon(Icons.settings_outlined), Icon(Icons.settings)),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    int nullCorrection = 0;
    for (int i = 0; i < destinations.length; i++) {
      if (destinations[i] == null) {
        nullCorrection++;
        continue;
      }
      if (destinations[i]!.route == widget.selectedRoute) {
        _selectedIndex = i - nullCorrection;
        break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: _onDestinationSelected,
      selectedIndex: _selectedIndex,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Column(
            children: [
              Text(
                'Schulapp',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(
                height: 4,
              ),
              InkWell(
                onTap: _loggedInTextPressed,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    _getLogInText(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...destinations.map(
          (CustomDestination? destination) {
            if (destination == null) {
              return _divider();
            }
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
      ],
    );
  }

  String _getLogInText() {
    final username = TimetableManager().settings.getVar(Settings.usernameKey);

    if (username != null) {
      return username;
    }

    return AppLocalizationsManager.localizations.strNotLoggedIn;
  }

  void _onDestinationSelected(int index) {
    int correctedIndex = index;
    for (int i = 0; i <= index; i++) {
      if (destinations[i] == null) correctedIndex++;
    }
    if (destinations[correctedIndex] == null) return;
    context.go(destinations[correctedIndex]!.route);
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Divider(),
    );
  }

  Future<void> _loggedInTextPressed() async {
    // Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VertretungsplanPaulDessauScreen(),
      ),
    );

    setState(() {});
  }
}
