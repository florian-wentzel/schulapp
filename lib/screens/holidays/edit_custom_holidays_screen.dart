import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/holidays_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/holidays_screen.dart';
import 'package:schulapp/widgets/date_selection_button.dart';

class EditCustomHolidaysScreen extends StatefulWidget {
  const EditCustomHolidaysScreen({super.key});

  @override
  State<EditCustomHolidaysScreen> createState() =>
      _EditCustomHolidaysScreenState();
}

class _EditCustomHolidaysScreenState extends State<EditCustomHolidaysScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strEditCustomHolidays,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomHolidays,
        child: const Icon(Icons.add),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    List<Holidays> customHolidays = HolidaysManager.getCustomHolidays();

    if (customHolidays.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: _addCustomHolidays,
          child: Text(
            AppLocalizationsManager.localizations.strCreateCustomHolidays,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: customHolidays.length,
      itemBuilder: (context, index) => _itemBuilder(
        context,
        customHolidays[index],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Holidays holidays) {
    return HolidaysListItemWidget(
      holidays: holidays,
      onDeletePressed: (holidays) {
        final customHolidaysList = HolidaysManager.getCustomHolidays();
        Holidays? holidaysToDelete;
        try {
          holidaysToDelete = customHolidaysList.firstWhere(
            (element) =>
                element.name == holidays.name &&
                element.start.toIso8601String() ==
                    holidays.start.toIso8601String() &&
                element.end.toIso8601String() == holidays.end.toIso8601String(),
          );
        } catch (e) {
          //
        }

        if (holidaysToDelete == null) return;

        customHolidaysList.remove(holidaysToDelete);

        HolidaysManager.setCustomHolidays(customHolidaysList);

        setState(() {});
      },
    );
  }

  Future<void> _addCustomHolidays() async {
    const maxNameLength = 25;

    TextEditingController nameController = TextEditingController();
    final initDate = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    DateSelectionButtonController startDateController =
        DateSelectionButtonController(
      date: initDate,
    );

    DateSelectionButtonController endDateController =
        DateSelectionButtonController(
      date: initDate.add(
        const Duration(days: 1),
      ),
    );

    startDateController.onDateChangedCBs.add(
      (dateTime) {
        endDateController.firstDate = dateTime.add(
          const Duration(days: 1),
        );
      },
    );

    endDateController.onDateChangedCBs.add(
      (dateTime) {
        startDateController.lastDate = dateTime.subtract(
          const Duration(days: 1),
        );
      },
    );

    bool create = false;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                AppLocalizationsManager.localizations.strCreateCustomHolidays,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizationsManager.localizations.strName,
                ),
                maxLines: 1,
                maxLength: maxNameLength,
                textAlign: TextAlign.center,
                controller: nameController,
              ),
              const SizedBox(
                height: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppLocalizationsManager
                                    .localizations.strHolidaysStart,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              DateSelectionButton(
                                controller: startDateController,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppLocalizationsManager
                                    .localizations.strHolidaysEnd,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              DateSelectionButton(
                                controller: endDateController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  create = true;
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizationsManager.localizations.strCreate),
              ),
            ],
          ),
        );
      },
    );

    if (!create) return;

    String name = nameController.text.trim();

    if (name.isEmpty) {
      if (!mounted) return;

      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
        type: InfoType.error,
      );

      return;
    }

    if (startDateController.date == endDateController.date ||
        startDateController.date.isAfter(endDateController.date)) {
      if (!mounted) return;

      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strHolidaysDateError,
        type: InfoType.error,
      );

      return;
    }

    final customHolidays = Holidays(
      start: startDateController.date,
      end: endDateController.date,
      name: name,
    );

    final customHolidaysList = HolidaysManager.getCustomHolidays();

    customHolidaysList.add(customHolidays);

    HolidaysManager.setCustomHolidays(customHolidaysList);

    setState(() {});
  }
}
