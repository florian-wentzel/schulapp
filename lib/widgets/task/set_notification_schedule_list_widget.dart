import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/notification_schedule.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/notification_schedule_list_item_widget.dart';
import 'package:schulapp/widgets/time_selection_button.dart';

class SetNotificationScheduleListWidget extends StatefulWidget {
  final List<NotificationSchedule> notificationScheduleList;

  const SetNotificationScheduleListWidget({
    super.key,
    required this.notificationScheduleList,
  });

  @override
  State<SetNotificationScheduleListWidget> createState() =>
      _SetNotificationScheduleListWidgetState();
}

class _SetNotificationScheduleListWidgetState
    extends State<SetNotificationScheduleListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizationsManager.localizations.strSetTaskNotification,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 12,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: ListView.builder(
              itemCount: widget.notificationScheduleList.length,
              itemBuilder: (context, index) {
                return NotificationScheduleListItemWidget(
                  notificationSchedule: widget.notificationScheduleList[index],
                  onDeletePressed: () {
                    if (widget.notificationScheduleList.length == 1) {
                      Utils.showInfo(
                        context,
                        msg: AppLocalizationsManager
                            .localizations.strMustAtLeastOneNotificationPresent,
                        type: InfoType.error,
                      );
                      return;
                    }
                    widget.notificationScheduleList.remove(
                      widget.notificationScheduleList[index],
                    );

                    setState(() {});
                  },
                );
              },
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final reminder = await _showAddReminder();

                    if (reminder == null) return;

                    widget.notificationScheduleList.add(reminder);

                    setState(() {});
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strAddReminder,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          widget.notificationScheduleList,
                        );
                      },
                      child: Text(
                        AppLocalizationsManager.localizations.strOK,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child:
                          Text(AppLocalizationsManager.localizations.strCancel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<NotificationSchedule?> _showAddReminder() async {
    const double distToSnapToPoint = 1.5;
    double startValue = 1;
    double minValue = 0;
    double maxValue = 14;

    double currValue = startValue;
    List<double>? snapPoints = [];

    final timeBtnController = DateSelectionButtonController(
      date: DateTime.now(),
    );

    final add = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizationsManager.localizations.strAddReminder),
              content: StatefulBuilder(
                builder: (context, snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizationsManager.localizations
                                  .strXDaysBefore(
                                currValue.toInt(),
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Slider.adaptive(
                              value: currValue,
                              min: minValue,
                              max: maxValue,
                              onChanged: (value) {
                                for (double snapPoint in snapPoints) {
                                  double dist = (snapPoint - value).abs();
                                  if (dist < distToSnapToPoint) {
                                    value = snapPoint;
                                  }
                                }
                                snapshot.call(
                                  () {
                                    currValue = value.toInt().toDouble();
                                    timeBtnController.noDate = currValue == 0;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizationsManager.localizations.strAt,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            TimeSelectionButton(
                              controller: timeBtnController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strAdd,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strCancel,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!add) return null;

    return NotificationSchedule(
      timeBefore: Duration(
        days: currValue.toInt(),
      ),
      timeOfDay: currValue == 0
          ? null
          : TimeOfDay.fromDateTime(
              timeBtnController.date,
            ),
    );
  }
}
