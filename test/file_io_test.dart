import 'package:flutter_test/flutter_test.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';

void main() {
  late String code;

  setUp(
    () => {
      code = "bRFvpzMRh"
    }, //created on 6.1.2026, so you should create a new one
  );

  test(
    "Test if file exists",
    () async {
      final exists =
          await GoFileIoManager().doesFileExists(code, isSaveCode: true);

      expect(exists, true);
    },
  );
}
