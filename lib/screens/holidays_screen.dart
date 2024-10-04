import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:schulapp/code_behind/federal_state.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/holidays/edit_custom_holidays_screen.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class HolidaysScreen extends StatefulWidget {
  static const route = "/holidays";
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();

  static Future<bool> selectFederalStateButtonPressed(
    BuildContext context, {
    void Function()? setState,
    void Function()? fetchHolidays,
  }) async {
    FederalState? selectedFederalState;
    bool removeHolidays = false;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizationsManager.localizations.strSelectFederalState,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: FederalStatesList.states.length,
                    itemBuilder: (context, index) {
                      FederalState state = FederalStatesList.states[index];

                      return ListTile(
                        title: Text(state.name),
                        onTap: () {
                          selectedFederalState = state;
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  removeHolidays = true;
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizationsManager.localizations.strRemoveHolidays,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (removeHolidays) {
      TimetableManager().settings.setVar(
            Settings.selectedFederalStateCodeKey,
            null,
          );

      HolidaysManager.removeLoadedHolidays();

      setState?.call();
    }

    if (selectedFederalState == null) return false;

    TimetableManager().settings.setVar(
          Settings.selectedFederalStateCodeKey,
          selectedFederalState?.apiCode,
        );

    HolidaysManager.removeLoadedHolidays();

    fetchHolidays?.call();
    setState?.call();
    return true;
  }
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  String federalStateName = "";

  List<Holidays> allHolidays = [];

  @override
  void initState() {
    _fetchHolidays();
    super.initState();
  }

  Future<void> _fetchHolidays() async {
    allHolidays = HolidaysManager.getCustomHolidays();
    setState(() {});

    String? stateCode = TimetableManager().settings.getVar(
          Settings.selectedFederalStateCodeKey,
        );

    if (stateCode == null) return;

    allHolidays = await HolidaysManager.getAllHolidaysForState(
      stateApiCode: stateCode,
      withCustomHolidays: true,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    federalStateName = _getFederalStateName();

    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: HolidaysScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strHolidaysWithStateName(
            federalStateName,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      floatingActionButton: _floatingActionButton(),
      body: _body(),
    );
  }

  String _getFederalStateName() {
    final apiCode = TimetableManager().settings.getVar(
          Settings.selectedFederalStateCodeKey,
        );

    return FederalStatesList.states.firstWhere(
      (element) {
        return element.apiCode == apiCode;
      },
      orElse: () => FederalState(name: "", officialCode: "", apiCode: ""),
    ).name;
  }

  Widget _body() {
    if (TimetableManager().settings.getVar(
                  Settings.selectedFederalStateCodeKey,
                ) ==
            null &&
        allHolidays.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () => HolidaysScreen.selectFederalStateButtonPressed(
            context,
            fetchHolidays: _fetchHolidays,
            setState: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
          child: Text(
            AppLocalizationsManager.localizations.strSelectFederalState,
          ),
        ),
      );
    }

    if (allHolidays.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: _fetchHolidays,
          child: Text(
            AppLocalizationsManager.localizations.strTryAgain,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: allHolidays.length,
      itemBuilder: _itemBuilder,
    );
  }

  Widget _itemBuilder(context, index) {
    final holidays = allHolidays[index];
    if (holidays.end.isBefore(DateTime.now().copyWith(
      hour: 0,
      microsecond: 0,
      millisecond: 0,
      second: 0,
      minute: 0,
    ))) {
      return Container();
    }

    return HolidaysListItemWidget(
      holidays: holidays,
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizationsManager.localizations.strInformation,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocalizationsManager.localizations.strHolidaysInfoText,
                ),
                Text(
                  AppLocalizationsManager.localizations.strHolidaysThanksText,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizationsManager.localizations.strOK,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _floatingActionButton() {
    // if (TimetableManager()
    //             .settings
    //             .getVar(Settings.selectedFederalStateCodeKey) ==
    //         null &&
    //     allHolidays.isEmpty) {
    //   return null;
    // }

    return SpeedDial(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.close,
      spacing: 3,
      useRotationAnimation: true,
      tooltip: '',
      animationCurve: Curves.elasticInOut,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.location_on),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          label: AppLocalizationsManager.localizations.strSelectFederalState,
          onTap: () => HolidaysScreen.selectFederalStateButtonPressed(
            context,
            fetchHolidays: _fetchHolidays,
            setState: () {
              if (mounted) {
                if (TimetableManager().settings.getVar(
                          Settings.selectedFederalStateCodeKey,
                        ) ==
                    null) {
                  allHolidays.clear();
                  _fetchHolidays();
                }
                setState(() {});
              }
            },
          ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          label: AppLocalizationsManager.localizations.strEditCustomHolidays,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EditCustomHolidaysScreen(),
              ),
            );
            _fetchHolidays();
          },
        ),
      ],
    );
  }
}

class HolidaysListItemWidget extends StatelessWidget {
  final Holidays holidays;
  final bool showBackground;
  final bool showDateInfo;
  final bool textLineThrough;
  final void Function(Holidays holidays)? onDeletePressed;

  const HolidaysListItemWidget({
    super.key,
    required this.holidays,
    this.showBackground = true,
    this.showDateInfo = true,
    this.textLineThrough = false,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith();

    if (textLineThrough) {
      textStyle = textStyle?.copyWith(
        decoration: TextDecoration.lineThrough,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            showBackground ? Theme.of(context).cardColor : Colors.transparent,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  holidays.getFormattedName(),
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Visibility(
                visible: onDeletePressed == null,
                replacement: IconButton(
                  onPressed: () => onDeletePressed?.call(holidays),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                child: Text(
                  _getDaysLeftString(holidays),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Visibility(
            visible: showDateInfo,
            child: Text(
              Utils.dateToString(holidays.start),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Visibility(
            visible: showDateInfo && holidays.start != holidays.end,
            child: Text(
              "-",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Visibility(
            visible: showDateInfo && holidays.start != holidays.end,
            child: Text(
              Utils.dateToString(holidays.end),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      // Text(
      //   AppLocalizationsManager.localizations.strHolidaysLengthXDays(
      //     holidays.end.difference(holidays.start).inDays + 1,
      //   ),
      //   style: Theme.of(context).textTheme.bodyLarge,
      // ),
    );
  }

  String _getDaysLeftString(Holidays holidays) {
    final now = DateTime.now().copyWith(
      microsecond: 0,
      millisecond: 0,
      second: 0,
      minute: 0,
      hour: 0,
    );
    //sollte nie aufgerufen werden aber man weiß ja nie
    if (now.isAfter(holidays.end)) {
      return AppLocalizationsManager.localizations.strAlreadyOver;
    }

    if (now.isBefore(holidays.start)) {
      Duration timeLeft = holidays.start.difference(now);
      if (timeLeft.inDays == 1) {
        return AppLocalizationsManager.localizations.strStartsTomorrow;
      }
      return AppLocalizationsManager.localizations.strInXDays(
        timeLeft.inDays,
      );
    } else if (now == holidays.start && now == holidays.end) {
      return AppLocalizationsManager.localizations.strToday;
    } else if (now == holidays.start) {
      return AppLocalizationsManager.localizations.strStartsToday;
    } else if (now.isBefore(holidays.end)) {
      Duration timeLeft = holidays.end.difference(now);

      if (timeLeft.inDays == 1) {
        return AppLocalizationsManager.localizations.strEndsTomorrow;
      }
      return AppLocalizationsManager.localizations.strEndsInXDays(
        timeLeft.inDays,
      );
    } else if (now == holidays.end) {
      return AppLocalizationsManager.localizations.strEndsToday;
    }

    return "";
  }
}
