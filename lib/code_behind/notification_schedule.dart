import 'package:flutter/material.dart';

class NotificationSchedule {
  static const timeBeforeKey = "timeBefore";
  static const timeOfDayKey = "timeOfDay";
  static const hourKey = "hour";
  static const minuteKey = "minute";

  TimeOfDay? timeOfDay;

  Duration timeBefore;

  NotificationSchedule({
    required this.timeBefore,
    this.timeOfDay,
  });

  DateTime getCorrectedDateTime(DateTime dateTime) {
    final correctedDateTime = dateTime.subtract(timeBefore);

    if (timeOfDay != null) {
      return correctedDateTime.copyWith(
        hour: timeOfDay?.hour,
        minute: timeOfDay?.minute,
      );
    }

    return correctedDateTime;
  }

  Map<String, dynamic> toJson() {
    return {
      timeBeforeKey: timeBefore.inMilliseconds,
      timeOfDayKey: _getTimeOfDayAsJson(),
    };
  }

  static NotificationSchedule fromJson(Map<String, dynamic> json) {
    int timeBeforeInMilliseconds = json[timeBeforeKey];
    final timeBefore = Duration(milliseconds: timeBeforeInMilliseconds);
    final timeOfDay = _getTimeOfDayFromJson(json[timeOfDayKey]);

    return NotificationSchedule(
      timeBefore: timeBefore,
      timeOfDay: timeOfDay,
    );
  }

  Map<String, dynamic>? _getTimeOfDayAsJson() {
    final tod = timeOfDay;
    if (tod == null) return null;

    return {
      hourKey: tod.hour,
      minuteKey: tod.minute,
    };
  }

  static TimeOfDay? _getTimeOfDayFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final hour = json[hourKey];
    final minute = json[minuteKey];

    if (hour == null || minute == null) return null;

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }
}
