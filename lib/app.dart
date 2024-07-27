import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/all_timetables_screen.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/hello_screen.dart';
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

        final showBottomNavBar = Utils.isMobileRatio(context) &&
            !VersionManager().isFirstTimeOpening();

        return ValueListenableBuilder<bool>(
          valueListenable: MainApp.showBottomnavBar,
          builder: (context, value, _) {
            return Material(
              child: Scaffold(
                backgroundColor: Theme.of(context).canvasColor,
                body: Center(
                  child: child,
                ),
                bottomNavigationBar: showBottomNavBar && value
                    ? CustomBottomNavigationBar(
                        currRoute: state.fullPath ?? "",
                      )
                    : null,
              ),
            );
          },
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
        GoRoute(
          path: HelloScreen.route,
          builder: (context, state) => const HelloScreen(),
        ),
      ],
    ),
  ],
);

class MainApp extends StatefulWidget {
  static ValueNotifier<bool> showBottomnavBar = ValueNotifier<bool>(true);

  ///secure just means that only the current screen can update the visibility
  static void changeNavBarVisibilitySecure(
    BuildContext context, {
    required bool value,
  }) {
    if (Utils.isScreenOnTop(context)) {
      changeNavBarVisibility(value);
    }
  }

  static void changeNavBarVisibility(bool value) {
    Future.delayed(Duration.zero, () {
      showBottomnavBar.value = value;
    });
  }

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
    TimetableManager().settings.setVar(
          Settings.languageCodeKey,
          _locale?.languageCode,
        );

    setState(() {});
  }

  void themeListener() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    ThemeManager().addListener(themeListener);

    if (TimetableManager().settings.getVar(Settings.languageCodeKey) != null) {
      setLocale(
        Locale(TimetableManager().settings.getVar(Settings.languageCodeKey)!),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback(postFrameCallback);

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

  Future<void> postFrameCallback(Duration timeStamp) async {
    await HomeWidgetManager.initialize();
    if (!mounted) return;
    await HomeWidgetManager.updateWithDefaultTimetable(context: context);
  }
}
