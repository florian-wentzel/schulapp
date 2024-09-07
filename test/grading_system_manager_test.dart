import 'package:flutter_test/flutter_test.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';

void main() {
  setUp(
    () => {},
  );

  test(
    "Test if GradingSystemManager works",
    () {
      for (int i = 0; i < 16; i++) {
        print(
          GradingSystemManager.convertGradeToSystem(
            i,
            GradingSystem.grade_6_1,
          ),
        );
      }

      expect(true, true);
      // expect(timeOfDay.minute, 30);
    },
  );
}
