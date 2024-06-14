import 'package:flutter_test/flutter_test.dart';
import 'package:schulapp/code_behind/utils.dart';

void main() {
  late DateTime dateTime;

  setUp(
    () => {dateTime = DateTime(2024, 1, 1)},
  );

  test(
    "Test if week index works",
    () {
      for (int i = 0; i < 100; i++) {
        final currDate = dateTime.add(
          Duration(days: i),
        );

        int weekIndex = Utils.getWeekIndex(currDate);
        print("${currDate.day}.${currDate.month}");
        print(weekIndex);
      }
    },
  );
}
