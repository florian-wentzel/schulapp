///Routes and Theme updates

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/all_timetables_screen.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/tasks_screen.dart';
import 'package:schulapp/screens/settings_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/theme/themes.dart';
import 'package:schulapp/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final localizations = AppLocalizations.of(context);
        if (localizations != null) {
          AppLocalizationsManager.setLocalizations(localizations);
        }
        return Material(
          child: Scaffold(
            backgroundColor: Theme.of(context).canvasColor,
            body: Center(
              child: child,
            ),
            bottomNavigationBar: Utils.isMobileRatio(context)
                ? CustomBottomNavigationBar(
                    currRoute: state.fullPath ?? "",
                  )
                : null,
          ),
        );
      },
      routes: [
        GoRoute(
          path: TimetableScreen.route,
          builder: (context, state) => TimetableScreen(
            title: AppLocalizationsManager.localizations.strStartScreen,
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
          path: HolidaysScreen.route,
          builder: (context, state) => const HolidaysScreen(),
        ),
        GoRoute(
          path: SettingsScreen.route,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();

  static void setLocale(BuildContext context, Locale? newLocale) {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  void setLocale(Locale? newLocale) {
    _locale = newLocale;
    TimetableManager().settings.languageCode = _locale?.languageCode;

    setState(() {});
  }

  void themeListener() {
    //wenn man den State setzten kann dann setzte ihn..
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    ThemeManager().addListener(themeListener);

    if (TimetableManager().settings.languageCode != null) {
      setLocale(Locale(TimetableManager().settings.languageCode!));
    }

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      debugShowCheckedModeBanner: true,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeManager().themeMode,
      routerConfig: _router,
    );
  }
}
