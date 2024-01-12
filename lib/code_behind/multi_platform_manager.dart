import 'dart:io';

import 'package:flutter/foundation.dart';

// import 'package:share_plus/share_plus.dart';
enum ShareResult {
  success,
  error,
}

class MultiPlatformManager {
  static Future<ShareResult> shareFile(File exportFile) async {
    if (kIsWeb) {
      if (kDebugMode) print("WARNING: Share Timetable not Implemented!");
      return ShareResult.error;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      if (kDebugMode) print("WARNING: Share Timetable not Implemented!");
      // result = await Share.shareXFiles(
      //   [XFile(exportFile.path)],
      //   text: "Share you Timetable!",
      // );
      return ShareResult.error;
    }
    if (Platform.isWindows) {
      try {
        Process.run(
          'explorer.exe',
          [
            '/select,',
            exportFile.path,
          ],
        );
        return ShareResult.success;
      } on Exception catch (e) {
        if (kDebugMode) print(e);
        return ShareResult.error;
      }
    }
    if (Platform.isMacOS) {
      //TODO: Testing
      try {
        Process.run(
          'open',
          [
            '--reveal',
            exportFile.path,
          ],
        );
        return ShareResult.success;
      } catch (e) {
        if (kDebugMode) print(e);
        return ShareResult.error;
      }
    }

    return ShareResult.error;
  }
}
