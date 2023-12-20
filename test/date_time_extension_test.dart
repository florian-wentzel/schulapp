import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
