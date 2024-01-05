import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class MultiPlatformManager {
  static Future<ShareResult?> shareFile(File exportFile) async {
    ShareResult? result;

    if (kIsWeb) {
      print("WARNING: Share Timetable not Implemented!");
      return null;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      result = await Share.shareXFiles(
        [XFile(exportFile.path)],
        text: "Share you Timetable!",
      );
    } else if (Platform.isWindows || Platform.isMacOS) {
      print("WARNING: Share Timetable not Implemented!");
    }

    return result;
  }
}
