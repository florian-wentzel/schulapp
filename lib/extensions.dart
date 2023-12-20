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
}
