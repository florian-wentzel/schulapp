import 'package:flutter_test/flutter_test.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';

void main() {
  late String code;

  setUp(
    () =>
        {code = "jipd7u"}, //created on 6.1.2026, so you should create a new one
  );

  test(
    "Test if file exists",
    () async {
      final exists =
          await GoFileIoManager().doesFileExists(code, isSaveCode: false);

      expect(exists, true);
    },
  );

  test(
    "Test if file can be downloaded",
    () async {
      final list = await GoFileIoManager().downloadFiles(
        code,
        isSaveCode: false,
      );

      expect(list.isNotEmpty, true);
    },
  );

  test(
    "Test hash algorithm",
    () async {
      final payload =
          "Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0::en-US::AH4ll6uk98UxPA5ILUkAzr3awK1tEQcl::123117::gf2026x";

      final hash = GoFileIoManager().sha256Hex(payload);
      expect(hash,
          "7af33a9ace925cf83753d73adf74444f4cd694f7bbd571ed4f7067641d8395a6");
    },
  );
}
