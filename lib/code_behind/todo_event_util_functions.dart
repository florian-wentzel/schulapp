import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/widgets/new_todo_event_widget.dart';

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
