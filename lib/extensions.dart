import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hours = 0, int minutes = 0}) {
    int newHour = hour + hours;

    int newMinute = minute + minutes;
    int minuteInHours = newMinute ~/ 60;

    // Adjust for overflow
    newHour += minuteInHours;
    newHour = newHour % 24;
    newMinute = newMinute % 60;

    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  bool isBefore(TimeOfDay otherTime) {
    int thisTimeInSeconds = toMinutes();
    int otherTimeInSeconds = otherTime.toMinutes();

    return thisTimeInSeconds < otherTimeInSeconds;
  }

  int toMinutes() {
    return hour * 60 + minute;
  }

  int toSeconds() {
    return toMinutes() * 60;
  }
}

extension DoubleExtension on double {
  String roundIfInt() {
    if (this == toInt()) {
      // If it is an integer, return it without the decimal part
      return toInt().toString();
    } else {
      // If it's not an integer, return the original string
      return toString();
    }
  }
}
