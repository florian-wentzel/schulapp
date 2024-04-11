import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/federal_state.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class HolidaysScreen extends StatefulWidget {
  static const route = "/holidays";
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
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
    String? stateCode = TimetableManager().settings.selectedFederalStateCode;
    if (stateCode == null) return;

    allHolidays = await HolidaysManager().getAllHolidaysForState(
      stateApiCode: stateCode,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    federalStateName = FederalStatesList.states.firstWhere(
      (element) {
        return element.apiCode ==
            TimetableManager().settings.selectedFederalStateCode;
      },
      orElse: () => FederalState(name: "", officialCode: "", apiCode: ""),
    ).name;

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

  Widget _body() {
    if (TimetableManager().settings.selectedFederalStateCode == null) {
      return Center(
        child: ElevatedButton(
          onPressed: _selectedFederalStateButtonPressed,
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
    if (holidays.end.isBefore(DateTime.now())) {
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

  Future<void> _selectedFederalStateButtonPressed() async {
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
      TimetableManager().settings.setSelectedFederalStateCode(null);

      setState(() {});
    }

    if (selectedFederalState == null) return;

    TimetableManager()
        .settings
        .setSelectedFederalStateCode(selectedFederalState);

    _fetchHolidays();

    if (mounted) {
      setState(() {});
    }
  }

  Widget? _floatingActionButton() {
    if (TimetableManager().settings.selectedFederalStateCode == null) {
      return null;
    }

    return FloatingActionButton(
      onPressed: _selectedFederalStateButtonPressed,
      child: const Icon(Icons.location_on),
    );
  }
}

// ignore: must_be_immutable
class HolidaysListItemWidget extends StatelessWidget {
  Holidays holidays;
  bool showBackground;
  bool showDateInfo;

  HolidaysListItemWidget({
    super.key,
    required this.holidays,
    this.showBackground = true,
    this.showDateInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            showBackground ? Theme.of(context).cardColor : Colors.transparent,
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _transformName(holidays.name),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _getDaysLeftString(holidays),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 18),
              showDateInfo
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Utils.dateToString(holidays.start),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          Utils.dateToString(holidays.end),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          AppLocalizationsManager.localizations
                              .strHolidaysLengthXDays(
                            holidays.end.difference(holidays.start).inDays + 1,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  String _transformName(String name) {
    List<String> words = name.split(" ");
    return _capitalizeWords(words.first);
  }

  String _getDaysLeftString(Holidays holidays) {
    Duration timeLeft = holidays.start.difference(DateTime.now());

    if (timeLeft.inDays > 0) {
      return AppLocalizationsManager.localizations.strInXDays(
        timeLeft.inDays,
      );
    } else if (timeLeft.inDays < 0) {
      Duration timeUntilEnd = holidays.end.difference(DateTime.now());

      return AppLocalizationsManager.localizations.strEndsInXDays(
        timeUntilEnd.inDays + 1,
      );
    }

    return timeLeft.inDays.toString();
  }

  String _capitalizeWords(String input) {
    // Split the input string into words
    List<String> words = input.split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return word; // If the word is empty, return it as is
      } else {
        // Capitalize the first letter of the word and concatenate with the rest
        return word[0].toUpperCase() + word.substring(1);
      }
    }).toList();

    // Join the capitalized words back into a single string
    return capitalizedWords.join(' ');
  }
}
