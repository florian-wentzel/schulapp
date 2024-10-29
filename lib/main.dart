import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  //sichergehen dass alle plugins initialisiert wurden
  WidgetsFlutterBinding.ensureInitialized();

  final futures = [
    NotificationManager().initNotifications(),
    SaveManager().loadApplicationDocumentsDirectory(),
  ];

  tz.initializeTimeZones();

  await Future.wait(futures);

  runApp(const MainApp());
}

//android.permission.WAKE_LOCK
//for background tasks?

//windows notifications
//https://pub.dev/packages/windows_notification

//file_picker setup: (already working for: windows and android)
//https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup

//Save data online
//https://stackoverflow.com/questions/68955545/flutter-how-to-backup-user-data-on-google-drive-like-whatsapp-does