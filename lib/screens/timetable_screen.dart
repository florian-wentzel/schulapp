import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/hello_screen.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/screens/new_versions_screen.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';
import 'package:schulapp/screens/time_table/import_export_timetable_screen.dart';
import 'package:schulapp/widgets/timetable_widget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/timetable_one_day_widget.dart';

// ignore: must_be_immutable
class TimetableScreen extends StatefulWidget {
  static const String route = "/";

  String title;
  Timetable? timetable;
  bool isHomeScreen;

  TimetableScreen({
    super.key,
    required this.title,
    required this.timetable,
    this.isHomeScreen = false,
  });

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Holidays? currentOrNextHolidays;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      _postFrameCallback,
    );
    _fetchHolidays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: widget.isHomeScreen
          ? NavigationBarDrawer(selectedRoute: TimetableScreen.route)
          : null,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        useRotationAnimation: true,
        tooltip: '',
        animationCurve: Curves.elasticInOut,

        // onOpen: () => print('OPENING DIAL'),
        // onClose: () => print('DIAL CLOSED'),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            label: AppLocalizationsManager.localizations.strCreateTimetable,
            onTap: () async {
              await createNewTimetable(context);

              if (!mounted) return;
              //not sure
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            visible: widget.timetable != null,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            label: AppLocalizationsManager.localizations.strEdit,
            onTap: () async {
              if (widget.timetable == null) return;

              await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => CreateTimeTableScreen(
                    timetable: widget.timetable!,
                  ),
                ),
              );

              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.import_export),
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            label: AppLocalizationsManager.localizations.strImportExport,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ImportExportTimetableScreen(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (widget.timetable == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await createNewTimetable(context);
            if (!mounted) return;
            context.go(TimetableScreen.route);
          },
          child: Text(
            AppLocalizationsManager.localizations.strCreateTimetable,
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    double height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;

    if (Utils.isMobileRatio(context)) {
      height -= kBottomNavigationBarHeight;
      height -= 2; //without you could scroll a little bit

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              width: width,
              height: height,
              child: TimetableOneDayWidget(
                timetable: widget.timetable!,
                showTodoEvents: widget.isHomeScreen,
              ),
            ),
            _holidaysWidget(),
            // Container(
            //   height: height,
            //   color: Colors.amber,
            // ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: TimetableWidget(
              timetable: widget.timetable!,
              showTodoEvents: widget.isHomeScreen,
            ),
          ),
          _holidaysWidget(),
          // Container(
          //   height: 120,
          //   color: Colors.amber,
          // ),
        ],
      ),
    );
  }

  Widget _holidaysWidget() {
    if (currentOrNextHolidays == null) {
      return Container();
    }
    final width = MediaQuery.of(context).size.width * 0.8;

    return Column(
      children: [
        SizedBox(
          width: width,
          child: InkWell(
            onTap: () {
              context.go(HolidaysScreen.route);
            },
            child: HolidaysListItemWidget(
              holidays: currentOrNextHolidays!,
              showBackground: false,
              showDateInfo: false,
            ),
          ),
        ),
        const SizedBox(
          height: 32,
        ),
      ],
    );
  }

  Future<void> _fetchHolidays() async {
    final stateApiCode = TimetableManager().settings.getVar(
          Settings.selectedFederalStateCodeKey,
        );
    if (stateApiCode == null) return;

    currentOrNextHolidays = await HolidaysManager()
        .getCurrOrNextHolidayForState(stateApiCode: stateApiCode);

    setState(() {});
  }

  void _postFrameCallback(Duration _) async {
    final currVersion = await VersionManager().getVersionString();

    if (!mounted) return;

    //only for developers
    if (kDebugMode && !VersionHolder.isVersionSaved(currVersion)) {
      Utils.showInfo(
        context,
        msg:
            "Current version: $currVersion is not safed in version_manager.dart/VersionHolder.versions\npls add it!",
        type: InfoType.error,
        duration: const Duration(seconds: 8),
      );
    }

    final fistTimeOpening = VersionManager().isFirstTimeOpening();

    if (!mounted) return;

    if (fistTimeOpening) {
      context.go(HelloScreen.route);
      return;
    }

    final isNewVersionInstalled =
        await VersionManager().isNewVersionInstalled();

    if (!mounted) return;

    if (isNewVersionInstalled) {
      String? lastUsedVersion = TimetableManager().settings.getVar(
            Settings.lastUsedVersionKey,
          );

      if (lastUsedVersion == null) return;

      Utils.showInfo(
        context,
        msg: AppLocalizationsManager
            .localizations.strYouUpdatedYourAppWantToSeeNewFeatures,
        type: InfoType.info,
        duration: const Duration(seconds: 8),
        actionWidget: SnackBarAction(
          label: AppLocalizationsManager.localizations.strShowNewFeatures,
          onPressed: () async {
            Utils.hideCurrInfo(context);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewVersionsScreen(
                  lastUsedVersion: lastUsedVersion,
                ),
              ),
            );

            VersionManager().updateLastUsedVersion();
          },
        ),
      );
      VersionManager().updateLastUsedVersion();
    }
  }
}
