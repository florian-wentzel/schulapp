import 'dart:io';

// import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
// import 'package:android_intent_plus/flag.dart' as flag;

// import 'package:share_plus/share_plus.dart';
enum ShareResult {
  success,
  error,
}

class MultiPlatformManager {
  static Future<ShareResult> shareFile(File exportFile) async {
    if (kIsWeb) {
      debugPrint("WARNING: Share Timetable not Implemented!");
      return ShareResult.error;
    }

    if (Platform.isAndroid) {
      debugPrint("WARNING: Share Timetable not Implemented!");
      // try {
      //   final intent = AndroidIntent(
      //     action: 'android.intent.action.VIEW',
      //     data:
      //         "content://com.android.externalstorage.documents/document/${Uri.encodeComponent(exportFile.)}",
      //     flags: <int>[flag.Flag.FLAG_ACTIVITY_NEW_TASK],
      //   );

      //   await intent.launch();
      // } catch (e) {
      //   debugPrint("Error opening file explorer: $e");
      // }
      // Intent intent = new Intent(Intent.ACTION_VIEW);
      //   Uri uri = Uri.parse("file://" + filePath);
      //   intent.setDataAndType(uri, "*/*");
      //   startActivity(intent);

      // result = await Share.shareXFiles(
      //   [XFile(exportFile.path)],
      //   text: "Share you Timetable!",
      // );
      return ShareResult.success;
    }
    if (Platform.isIOS) {
      debugPrint("WARNING: Share Timetable not Implemented!");
      return ShareResult.success;
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
        debugPrint(e.toString());
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
        debugPrint(e.toString());
        return ShareResult.error;
      }
    }

    return ShareResult.error;
  }
}
