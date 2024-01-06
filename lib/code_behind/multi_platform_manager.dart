import 'dart:io';

import 'package:flutter/foundation.dart';
// import 'package:share_plus/share_plus.dart';

class MultiPlatformManager {
  // static Future<ShareResult?> shareFile(File exportFile) async {
  //   ShareResult? result;

  //   if (kIsWeb) {
  //     if (kDebugMode) print("WARNING: Share Timetable not Implemented!");

  //     return null;
  //   }

  //   if (Platform.isAndroid || Platform.isIOS) {
  //     result = await Share.shareXFiles(
  //       [XFile(exportFile.path)],
  //       text: "Share you Timetable!",
  //     );
  //   } else if (Platform.isWindows) {
  //     try {
  //       Process.run(
  //         'explorer.exe',
  //         [
  //           '/select,',
  //           exportFile.path,
  //         ],
  //       );
  //       result = const ShareResult("windows", ShareResultStatus.success);
  //     } on Exception catch (e) {
  //       if (kDebugMode) print(e);
  //     }
  //   } else if (Platform.isMacOS) {
  //     //TODO: Testing
  //     try {
  //       Process.run(
  //         'open',
  //         [
  //           '--reveal',
  //           exportFile.path,
  //         ],
  //       );
  //       result = const ShareResult("macOS", ShareResultStatus.success);
  //     } catch (e) {
  //       if (kDebugMode) print(e);
  //     }
  //   }

  //   return result;
  // }
}
