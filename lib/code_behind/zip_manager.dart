import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class ZipManager {
  static Directory zipToFolder(File selectedFile, Directory exportDir) {
    exportDir.createSync(recursive: true);

    final bytes = selectedFile.readAsBytesSync();

    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      if (file.isFile) {
        final data = file.content as List<int>;
        final path = join(exportDir.path, file.name);
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        final path = join(exportDir.path, file.name);

        Directory(path).createSync(recursive: true);
      }
    }

    return exportDir;
  }

  static File folderToZip(
    Directory selectedDir,
    File exportFile, {
    void Function(double)? onProgress,
  }) {
    if (!selectedDir.existsSync()) {
      throw Exception(
        AppLocalizationsManager.localizations.strSelectedDirDoesNotExist,
      );
    }

    var encoder = ZipFileEncoder();

    encoder.zipDirectory(
      selectedDir,
      filename: exportFile.path,
      onProgress: onProgress,
    );

    return exportFile;
  }
}
