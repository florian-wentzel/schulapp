import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/screens/all_timetables_screen.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/notes_screen.dart';
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
  final List<CustomDestination> destinations = <CustomDestination>[
    CustomDestination(
      label: "Home",
      route: TimetableScreen.route,
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
    ),
    CustomDestination(
      label: "Timetables",
      route: AllTimetablesScreen.route,
      icon: const Icon(Icons.dataset_outlined),
      selectedIcon: const Icon(Icons.dataset),
    ),
    CustomDestination(
      label: "Grades",
      route: GradesScreen.route,
      icon: const Icon(Icons.school_outlined),
      selectedIcon: const Icon(Icons.school),
    ),
    CustomDestination(
      label: "Tasks", // / Notes",
      route: NotesScreen.route,
      icon: const Icon(Icons.assignment_outlined),
      selectedIcon: const Icon(Icons.assignment),
    ),
    CustomDestination(
      label: "Settings",
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
    for (int i = 0; i < destinations.length; i++) {
      if (destinations[i].route == widget.selectedRoute) {
        _selectedIndex = i;
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
              Text(
                'nicht angemeldet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ...destinations.map(
          (CustomDestination destination) {
            return NavigationDrawerDestination(
              label: Text(destination.label),
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
            );
          },
        ),
        _divider(),
      ],
    );
  }

  void _onDestinationSelected(int index) {
    context.go(destinations[index].route);
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 10, 28, 10),
      child: Divider(),
    );
  }
}
