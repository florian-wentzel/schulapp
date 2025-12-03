import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/mergable.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/notification_schedule.dart';
import 'package:schulapp/code_behind/online_sync_manager.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/unique_id_generator.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class TodoEvent extends MergableClass<TodoEvent> {
  static const String _nameKey = "name";
  static const String _linkedSubjectNameKey = "linkedSubjectName";
  static const String _linkedSchoolNoteKey = "linkedNote";
  static const String _endTimeKey = "endTime";
  static const String _uniqueKeyKey = "key";
  static const String _typeKey = "type";
  static const String _desciptionKey = "desciption";
  static const String _finishedKey = "finished";
  static const String _customEventKey = "isCustomEvent";
  static const String _saveOnlineCodeKey = "saveOnlineCode";
  static const String _uidKey = "uid";
  static const String _lastModifiedKey = "lastModified";

  static const IconData homeworkIcon = Icons.assignment;
  static const IconData presentationIcon = Icons.speaker_notes;
  static const IconData testIcon = Icons.edit;
  static const IconData examIcon = Icons.school;
  static const int maxNameLength = 25;

  @override
  DateTime get lastModified => _lastModified;
  DateTime _lastModified;

  @override
  TodoEvent get parent => this;

  @override //vielleicht key? erst setzen nach dem snchronisiert wurde?
  String get uid => _key.toString();

  ///identifyer set at runtime from [UniqueIdGenerator.createUniqueId()]
  int get key => _key;
  late final int _key;

  final String name;
  final String linkedSubjectName;

  ///SchoolNote.saveFileName
  final String? linkedSchoolNote;
  final bool isCustomEvent;

  String? _saveOnlineCode;
  String? get saveOnlineCode => _saveOnlineCode;
  set saveOnlineCode(String? value) {
    _saveOnlineCode = value;
    _lastModified = DateTime.now().toUtc();
  }

  final DateTime? _endTime;
  DateTime? get endTime => _endTime;

  final TodoType _type;
  TodoType get type => _type;

  final String _desciption;
  String get desciption => _desciption;

  bool _finished;
  bool get finished => _finished;
  set finished(bool value) {
    _finished = value;
    _lastModified = DateTime.now().toUtc();
  }

  static const int maxDescriptionLength = 150;

  TodoEvent({
    int? key,
    required this.name,
    required this.linkedSubjectName,
    required this.linkedSchoolNote,
    required DateTime? endTime,
    required TodoType type,
    required String desciption,
    required bool finished,
    required this.isCustomEvent,
    String? saveOnlineCode,
    DateTime? lastModified,
  })  : _desciption = desciption,
        _finished = finished,
        _saveOnlineCode = saveOnlineCode,
        _endTime = endTime,
        _type = type,
        _lastModified = lastModified?.toUtc() ?? DateTime.now().toUtc() {
    key ??= UniqueIdGenerator.createUniqueId();

    if (key > NotificationManager.maxIdNum) {
      key = UniqueIdGenerator.createUniqueId();
    }

    _key = key;
  }

  bool isExpired() {
    if (finished) return false;

    return endTime?.isBefore(DateTime.now()) ?? false;
  }

  String getEndTimeString() {
    if (finished) {
      return AppLocalizationsManager.localizations.strFinished;
    }
    DateTime? endDateTime = endTime;

    if (endDateTime == null) {
      return AppLocalizationsManager.localizations.strNoEndDate;
    }

    return _getTimeLeftString(DateTime.now(), endDateTime);
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
      // _uidKey: uid, //weil bisher uid = key
      _lastModifiedKey: _lastModified.toIso8601String(),
      _linkedSchoolNoteKey: linkedSchoolNote,
      _linkedSubjectNameKey: linkedSubjectName,
      _endTimeKey: endTime?.millisecondsSinceEpoch,
      _typeKey: type.toString(),
      _desciptionKey: desciption,
      _finishedKey: finished,
      _customEventKey: isCustomEvent,
      _saveOnlineCodeKey: saveOnlineCode,
      _uniqueKeyKey: _key,
    };
  }

  static TodoEvent fromJson(Map<String, dynamic> json) {
    String name = json[_nameKey];
    // String uid = json[_uidKey]; //Weilbisher uid = key
    String lastModified = json[_lastModifiedKey];
    String linkedSubjectName = json[_linkedSubjectNameKey];
    String? linkedSchoolNote = json[_linkedSchoolNoteKey];
    String? saveOnlineCode = json[_saveOnlineCodeKey];
    int? milliSec = json[_endTimeKey];
    int? key = json[_uniqueKeyKey];
    DateTime? endTime;

    if (milliSec != null) {
      endTime = DateTime.fromMillisecondsSinceEpoch(milliSec);
    }

    TodoType type = todoTypeFromString(json[_typeKey]);
    String desciption = json[_desciptionKey];
    bool finished = json[_finishedKey];
    bool customEvent = json[_customEventKey] ?? false;

    return TodoEvent(
      key: key,
      // uid: uid,
      lastModified: DateTime.tryParse(lastModified),
      name: name,
      linkedSchoolNote: linkedSchoolNote,
      linkedSubjectName: linkedSubjectName,
      endTime: endTime,
      type: type,
      desciption: desciption,
      isCustomEvent: customEvent,
      finished: finished,
      saveOnlineCode: saveOnlineCode,
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

  TodoEvent copy({bool withNewKey = false}) {
    return TodoEvent(
      key: withNewKey ? null : _key,
      name: name,
      linkedSchoolNote: linkedSchoolNote,
      linkedSubjectName: linkedSubjectName,
      endTime: endTime?.copyWith(),
      type: type,
      desciption: desciption,
      finished: finished,
      isCustomEvent: isCustomEvent,
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
    DateTime? endDateTime = endTime;
    if (endDateTime == null) return;

    final scheduleNotification = TimetableManager().settings.getVar<bool>(
          Settings.notificationScheduleEnabledKey,
        );

    if (!scheduleNotification) return;

    final List<NotificationSchedule> notificationScheduleList =
        TimetableManager().settings.getVar(
              Settings.notificationScheduleListKey,
            );

    for (int i = 0; i < notificationScheduleList.length; i++) {
      final correctedDateTime =
          notificationScheduleList[i].getCorrectedDateTime(endDateTime);
      String title = linkedSubjectName;

      if (name.isEmpty) {
        title += " (${TodoEvent.typeToString(type)})";
      } else {
        title += ", $name";
      }

      final body = _getTimeLeftString(
        correctedDateTime,
        endDateTime,
      );

      await NotificationManager().scheduleNotification(
        id: key + i,
        scheduledDateTime: correctedDateTime,
        title: title,
        body: body,
        type: NotificationType.todo,
      );
    }
  }

  String _getTimeLeftString(DateTime start, DateTime end) {
    Duration timeLeft = end.difference(start);

    int daysLeft = DateTime(end.year, end.month, end.day)
        .difference(
          DateTime(
            start.year,
            start.month,
            start.day,
          ),
        )
        .inDays;

    if (daysLeft > 0) {
      return AppLocalizationsManager.localizations.strInXDays(daysLeft);
    } else if (daysLeft < 0) {
      return AppLocalizationsManager.localizations
          .strExpiredXDaysAgo(daysLeft.abs());
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

  Future<void> cancleNotification() async {
    final List<NotificationSchedule> notificationScheduleList =
        TimetableManager().settings.getVar(
              Settings.notificationScheduleListKey,
            );

    for (int i = 0; i < notificationScheduleList.length; i++) {
      await NotificationManager().cancleNotification(
        key + i,
      );
    }
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

  @override
  Future<List<TodoEvent>> merge(
    TodoEvent other,
    Future<MergeErrorSolution> Function(String errorMsg) onMergeError,
  ) async {
    if (other.key != key) {
      throw "Can only merge TodoEvents with the same key!";
    }
    if (other.uid != uid) {
      throw "Can only merge TodoEvents with the same uid!";
    }

    // Settings.syncConflictResolutionTimeKey
    // lastsynced
    // lastmodified

    final lastSyncTime = OnlineSyncManager().lastSyncTime;

    if (lastSyncTime == null) {
      //never synced before, take the most recently modified one
      if (lastModified.isAfter(other.lastModified)) {
        return [this];
      } else {
        return [other];
      }
    }

    final thisChanged = lastModified.isAfter(lastSyncTime);
    final otherChanged = other.lastModified.isAfter(lastSyncTime);

    if (thisChanged && !otherChanged) {
      return [this];
    } else if (!thisChanged && otherChanged) {
      return [other];
    } else if (!thisChanged && !otherChanged) {
      //none changed
      return [this];
    } else {
      //both changed

      //bevor man fragt welche behalten werden soll, vielleicht wurden ja beide gleich verändert?
      if (name == other.name &&
          linkedSubjectName == other.linkedSubjectName &&
          linkedSchoolNote == other.linkedSchoolNote &&
          isCustomEvent == other.isCustomEvent &&
          saveOnlineCode == other.saveOnlineCode &&
          endTime == other.endTime &&
          type == other.type &&
          desciption == other.desciption &&
          finished == other.finished) {
        //weil beide doch gleich sind, einfach das neuere zurückgeben..
        if (lastModified.isAfter(other.lastModified)) {
          return [this];
        } else {
          return [other];
        }
      }

      //Man könnte jetzt noch einzelne oft bearbeitete Membervars mit DateTimes anpassen um diese einzeln nach konflikten zu testen..
      final solution = await onMergeError(
        "Die Aufgabe (lokal) $linkedSubjectName $name ${typeToString(type)} und\n"
        "(remote) ${other.linkedSubjectName} ${other.name} ${typeToString(other.type)}\n"
        "wurden beide verändert. Welche Version soll beibehalten werden?",
      );

      if (solution == MergeErrorSolution.keepLocal) {
        return [this];
      } else if (solution == MergeErrorSolution.keepRemote) {
        return [other];
      } else {
        //keepBoth
        return [
          this,
          other.copy(withNewKey: true),
        ];
      }
    }
  }

  String toDeletedString() => "${uid}_$key";
}

enum TodoType {
  exam,
  test,
  presentation,
  homework,
}

class DeletedTodoEvent {
  static const int daysToKeepDeletedEvents = 30;
  //gets generated by TodoEvent.toDeletedString()
  String deletedStr;
  //in UTC
  DateTime time;

  DeletedTodoEvent({
    required this.deletedStr,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'deletedStr': deletedStr,
      'time': time.toIso8601String(),
    };
  }

  static DeletedTodoEvent? fromJson(Map<String, dynamic> json) {
    String? uid = json['deletedStr'];
    String? timeString = json['time'];
    DateTime? time = DateTime.tryParse(timeString ?? "");

    if (uid == null || time == null) {
      return null;
    }

    return DeletedTodoEvent(
      deletedStr: uid,
      time: time,
    );
  }

  static DeletedTodoEvent fromTodoEvent(TodoEvent todoEvent) {
    return DeletedTodoEvent(
      deletedStr: todoEvent.toDeletedString(),
      time: DateTime.now().toUtc(),
    );
  }
}
