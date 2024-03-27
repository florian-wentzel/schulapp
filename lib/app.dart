///Routes and Theme updates

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/all_timetables_screen.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/notes_screen.dart';
import 'package:schulapp/screens/settings_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/theme/themes.dart';

//wenn wir später noch ne BottomNavigationBar einfügen
//dann kann man hier auch noch ShellRoute hinzufügen
final _router = GoRouter(
  routes: [
    // ShellRoute(
    //   builder: (context, state, child) {
    //     // return CustomButtonNavigationBar();
    //     print(state.fullPath);
    //     return Scaffold(
    //       body: Center(
    //         child: child,
    //       ),
    //       bottomNavigationBar:
    //           (state.fullPath == null || state.fullPath!.isEmpty)
    //               ? null
    //               : NavigationBar(
    //                   destinations: const [
    //                     NavigationDestination(
    //                       icon: Icon(Icons.home),
    //                       label: "Home",
    //                     ),
    //                     NavigationDestination(
    //                       icon: Icon(Icons.home),
    //                       label: "Grades",
    //                     ),
    //                     NavigationDestination(
    //                       icon: Icon(Icons.check),
    //                       label: "Tasks",
    //                     ),
    //                   ],
    //                 ),
    //     );
    //   },
    //   routes: [
    GoRoute(
      path: TimetableScreen.route,
      builder: (context, state) => TimetableScreen(
        title: "Home",
        timetable: Utils.getHomescreenTimetable(),
        isHomeScreen: true,
      ),
    ),
    GoRoute(
      path: AllTimetablesScreen.route,
      builder: (context, state) => const AllTimetablesScreen(),
    ),
    GoRoute(
      path: GradesScreen.route,
      builder: (context, state) => const GradesScreen(),
    ),
    GoRoute(
      path: NotesScreen.route,
      builder: (context, state) => NotesScreen(
        todoEvent: state.extra as TodoEvent?,
      ),
    ),
    GoRoute(
      path: SettingsScreen.route,
      builder: (context, state) => const SettingsScreen(),
    ),
    //   ],
    // ),
  ],
);

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  void themeListener() {
    //wenn man den State setzten kann dann setzte ihn..
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    ThemeManager().addListener(themeListener);
    super.initState();
  }

  @override
  void dispose() {
    ThemeManager().removeListener(themeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: true,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeManager().themeMode,
      routerConfig: _router,
    );
  }
}
