import 'package:flutter/material.dart';

//TODO
extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hours = 0, int minutes = 0}) {
    int newHour = hour + hours;
    int newMinute = minute + minutes;

    // Adjust for overflow
    newHour = newHour % 24;
    newMinute = newMinute % 60;

    return TimeOfDay(hour: newHour, minute: newMinute);
  }
}
