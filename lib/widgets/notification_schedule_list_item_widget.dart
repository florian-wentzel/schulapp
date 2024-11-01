import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/notification_schedule.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class NotificationScheduleListItemWidget extends StatefulWidget {
  final NotificationSchedule notificationSchedule;
  final void Function()? onDeletePressed;

  const NotificationScheduleListItemWidget({
    super.key,
    required this.notificationSchedule,
    this.onDeletePressed,
  });

  @override
  State<NotificationScheduleListItemWidget> createState() =>
      _NotificationScheduleListItemWidgetState();
}

class _NotificationScheduleListItemWidgetState
    extends State<NotificationScheduleListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(_getText()),
        trailing: IconButton(
          onPressed: widget.onDeletePressed,
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  String _getText() {
    String text = AppLocalizationsManager.localizations.strXDaysBefore(
      widget.notificationSchedule.timeBefore.inDays,
    );

    final timeOfDay = widget.notificationSchedule.timeOfDay;

    if (timeOfDay != null) {
      text += " ";
      text += AppLocalizationsManager.localizations.strAtXOClock(
        timeOfDay.format(context),
      );
    }

    return text;
  }
}
