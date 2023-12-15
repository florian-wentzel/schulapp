import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/screens/time_table/time_table_screen.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/theme/themes.dart';

//wenn wir später noch ne BottomNavigationBar einfügen
//dann kann man hier auch noch ShellRoute hinzufügen
final _router = GoRouter(
  routes: [
    GoRoute(
      path: TimeTableScreen.route,
      builder: (context, state) => const TimeTableScreen(),
    ),
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
