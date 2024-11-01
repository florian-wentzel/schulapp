import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/notification_schedule.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/widgets/new_todo_event_widget.dart';
import 'package:schulapp/widgets/task/set_notification_schedule_list_widget.dart';

Future<TodoEvent?> createNewTodoEventSheet(
  BuildContext context, {
  required String linkedSubjectName,
  bool? isCustomEvent,
  TodoEvent? event,
}) async {
  final todoEvent = await showModalBottomSheet<TodoEvent?>(
    context: context,
    isScrollControlled: true,
    scrollControlDisabledMaxHeightRatio: 0.5,
    builder: (context) {
      return NewTodoEventWidget(
        event: event,
        isCustomEvent: isCustomEvent,
        linkedSubjectName: linkedSubjectName,
      );
    },
  );

  return todoEvent;
}

Future<void> setNotificationScheduleList(BuildContext context) async {
  final List<NotificationSchedule> notificationScheduleList =
      TimetableManager().settings.getVar(
            Settings.notificationScheduleListKey,
          );

  final newList = await showModalBottomSheet<List<NotificationSchedule>?>(
    context: context,
    isScrollControlled: true,
    scrollControlDisabledMaxHeightRatio: 0.5,
    builder: (context) {
      return const SetNotificationScheduleListWidget();
    },
  );
}
