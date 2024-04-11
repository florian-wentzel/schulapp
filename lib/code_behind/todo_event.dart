import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class TodoEvent {
  static const String _nameKey = "name";
  static const String _linkedSubjectNameKey = "linkedSubjectName";
  static const String _endTimeKey = "endTime";
  static const String _typeKey = "type";
  static const String _desciptionKey = "desciption";
  static const String _finishedKey = "finished";
  static const int notificationMultiplier = 10;

  static const IconData homeworkIcon = Icons.assignment;
  static const IconData presentationIcon = Icons.speaker_notes;
  static const IconData testIcon = Icons.edit;
  static const IconData examIcon = Icons.school;
  static const int maxNameLength = 25;

  //identifyer set at runtime
  int key;
  final String name;
  final String linkedSubjectName;

  DateTime endTime;
  TodoType type;

  String desciption;
  bool finished;

  static const int maxDescriptionLength = 150;

  TodoEvent({
    required this.key,
    required this.name,
    required this.linkedSubjectName,
    required this.endTime,
    required this.type,
    required this.desciption,
    required this.finished,
  });

  bool isExpired() {
    if (finished) return false;

    return endTime.isBefore(DateTime.now());
  }

  String getEndTimeString() {
    if (finished) {
      return AppLocalizationsManager.localizations.strFinished;
    }

    Duration timeLeft = endTime.difference(DateTime.now());

    if (timeLeft.inDays > 0) {
      return AppLocalizationsManager.localizations.strInXDays(timeLeft.inDays);
    } else if (timeLeft.inDays < 0) {
      return AppLocalizationsManager.localizations
          .strExpiredXDaysAgo(timeLeft.inDays.abs());
    }

    if (timeLeft.inHours > 0) {
      return AppLocalizationsManager.localizations
          .strInXHours(timeLeft.inHours);
    } else if (timeLeft.inHours < 0) {
      return AppLocalizationsManager.localizations
          .strExpiredXHoursAgo(timeLeft.inHours.abs());
    }

    if (timeLeft.inMinutes > 0) {
      return AppLocalizationsManager.localizations
          .strInXMinutes(timeLeft.inMinutes);
    } else if (timeLeft.inMinutes < 0) {
      return AppLocalizationsManager.localizations
          .strExpiredXMinutesAgo(timeLeft.inMinutes.abs());
    }

    if (timeLeft.inSeconds > 0) {
      return AppLocalizationsManager.localizations
          .strInXSeconds(timeLeft.inSeconds);
    } else if (timeLeft.inSeconds < 0) {
      return AppLocalizationsManager.localizations
          .strExpiredXSecondsAgo(timeLeft.inSeconds.abs());
    }

    return AppLocalizationsManager.localizations.strNow;
  }

  IconData getIcon() {
    return switchTodoType(
      type,
      onExam: examIcon,
      onTest: testIcon,
      onPresentation: presentationIcon,
      onHomework: homeworkIcon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _nameKey: name,
      _linkedSubjectNameKey: linkedSubjectName,
      _endTimeKey: endTime.millisecondsSinceEpoch,
      _typeKey: type.toString(),
      _desciptionKey: desciption,
      _finishedKey: finished,
    };
  }

  static TodoEvent fromJson(Map<String, dynamic> json, int key) {
    String name = json[_nameKey];
    String linkedSubjectName = json[_linkedSubjectNameKey];
    DateTime endTime = DateTime.fromMillisecondsSinceEpoch(json[_endTimeKey]);
    TodoType type = todoTypeFromString(json[_typeKey]);
    String desciption = json[_desciptionKey];
    bool finished = json[_finishedKey];

    return TodoEvent(
      key: key,
      name: name,
      linkedSubjectName: linkedSubjectName,
      endTime: endTime,
      type: type,
      desciption: desciption,
      finished: finished,
    );
  }

  static int compareType(TodoType a, TodoType b) {
    int aValue = typeToInt(a);
    int bValue = typeToInt(b);

    if (aValue > bValue) return 1;
    if (aValue < bValue) return -1;

    return 0;
  }

  static int typeToInt(TodoType type) {
    return switchTodoType(
      type,
      onExam: 10,
      onTest: 5,
      onPresentation: 5,
      onHomework: 1,
    );
  }

  static TodoType todoTypeFromString(String type) {
    if (type == TodoType.test.toString()) {
      return TodoType.test;
    }
    if (type == TodoType.presentation.toString()) {
      return TodoType.presentation;
    }
    if (type == TodoType.homework.toString()) {
      return TodoType.homework;
    }
    if (type == TodoType.exam.toString()) {
      return TodoType.exam;
    }
    return TodoType.test;
  }

  Color getColor() {
    if (finished) {
      return Colors.green;
    }
    return switchTodoType(
      type,
      onExam: Colors.red,
      onTest: Colors.orange,
      onPresentation: Colors.orange,
      onHomework: Colors.yellow,
    );
  }

  TodoEvent copy() {
    return TodoEvent(
      key: key,
      name: name,
      linkedSubjectName: linkedSubjectName,
      endTime: endTime,
      type: type,
      desciption: desciption,
      finished: finished,
    );
  }

  static String typeToString(TodoType type) {
    return switchTodoType(
      type,
      onExam: AppLocalizationsManager.localizations.strExam,
      onTest: AppLocalizationsManager.localizations.strTest,
      onPresentation: AppLocalizationsManager.localizations.strPresentation,
      onHomework: AppLocalizationsManager.localizations.strHomework,
    );
  }

  Future<void> addNotification() async {
    if (finished) return;
    await NotificationManager().scheduleNotification(
      id: key * notificationMultiplier,
      scheduledDateTime: endTime.subtract(const Duration(days: 1)),
      title: "$linkedSubjectName : ${TodoEvent.typeToString(type)}",
      body: AppLocalizationsManager.localizations.strTomorrow,
    );
    return NotificationManager().scheduleNotification(
      id: key * notificationMultiplier + 1,
      scheduledDateTime: endTime,
      title: "$linkedSubjectName : ${TodoEvent.typeToString(type)}",
      body: AppLocalizationsManager.localizations.strNow,
    );
  }

  Future<void> cancleNotification() async {
    await NotificationManager().cancleNotification(
      key * notificationMultiplier,
    );
    await NotificationManager().cancleNotification(
      key * notificationMultiplier + 1,
    );
  }

  static T switchTodoType<T>(
    TodoType type, {
    required T onExam,
    required T onTest,
    required T onPresentation,
    required T onHomework,
  }) {
    switch (type) {
      case TodoType.exam:
        return onExam;
      case TodoType.presentation:
        return onPresentation;
      case TodoType.test:
        return onTest;
      case TodoType.homework:
        return onHomework;
    }
  }
}

enum TodoType {
  exam,
  test,
  presentation,
  homework,
}
