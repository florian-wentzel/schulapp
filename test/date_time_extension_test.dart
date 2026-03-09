import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';

void main() {
  late TimeOfDay timeOfDay;

  setUp(
    () => {timeOfDay = const TimeOfDay(hour: 7, minute: 45)},
  );

  test(
    "Test if .add extension works",
    () {
      timeOfDay = timeOfDay.add(minutes: 45);

      expect(timeOfDay.hour, 8);
      expect(timeOfDay.minute, 30);
    },
  );

  test(
    "Test if getISO8601WeekIndex works",
    () {
      int weekIndex = Utils.getISO8601WeekIndex(DateTime(2024, 1, 1));

      expect(weekIndex, 1);

      weekIndex = Utils.getISO8601WeekIndex(DateTime(2023, 1, 1));

      expect(weekIndex, 52);

      weekIndex = Utils.getISO8601WeekIndex(DateTime(2024, 12, 30));

      expect(weekIndex, 1);
    },
  );
}
