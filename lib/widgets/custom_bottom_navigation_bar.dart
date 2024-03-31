import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/tasks_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final String currRoute;
  const CustomBottomNavigationBar({super.key, required this.currRoute});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final List<String> pageRoutes = [
    GradesScreen.route,
    TimetableScreen.route,
    NotesScreen.route,
  ];

  int _getCurrentIndex() {
    for (int i = 0; i < pageRoutes.length; i++) {
      if (pageRoutes[i] == widget.currRoute) {
        return i;
      }
    }

    const defaultIndex = 1;

    return defaultIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(),
      onTap: (value) {
        context.go(pageRoutes[value]);
        setState(() {});
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: "Grades",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: "Tasks",
        ),
      ],
    );
  }
}


// ? NavigationBar(
              //     destinations: const [
              //       NavigationDestination(
              //         icon: Icon(Icons.home),
              //         label: "Home",
              //       ),
              //       NavigationDestination(
              //         icon: Icon(Icons.home),
              //         label: "Grades",
              //       ),
              //       NavigationDestination(
              //         icon: Icon(Icons.check),
              //         label: "Tasks",
              //       ),
              //     ],
              //   )