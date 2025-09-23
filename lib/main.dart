import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/online_sync_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/widgets/custom_feedback_form.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final futures = [
    NotificationManager().initNotifications(),
    SaveManager().loadApplicationDocumentsDirectory(),
  ];

  tz.initializeTimeZones();

  await Future.wait(futures);

  //damit GoogleSignIn.init aufgerufen wird
  OnlineSyncManager();
  // debugRepaintRainbowEnabled = true;

  runApp(
    BetterFeedback(
      feedbackBuilder: (context, onSubmit, scrollController) =>
          CustomFeedbackForm(
        onSubmit: onSubmit,
        scrollController: scrollController,
      ),
      themeMode: ThemeManager().themeMode,
      darkTheme: FeedbackThemeData(
        background: Colors.grey.shade700,
        dragHandleColor: Colors.white38,
        feedbackSheetColor: const Color(0xFF303030),
        bottomSheetDescriptionStyle: const TextStyle(
          color: Colors.white,
        ),
        feedbackSheetHeight: 0.4,
      ),
      theme: FeedbackThemeData(
        background: Colors.grey,
        dragHandleColor: Colors.black26,
        feedbackSheetColor: const Color(0xFFFAFAFA),
        bottomSheetDescriptionStyle: const TextStyle(
          color: Colors.black,
        ),
        feedbackSheetHeight: 0.4,
      ),
      localeOverride: Locale(AppLocalizationsManager.localizations.localeName),
      mode: FeedbackMode.navigate,
      child: const MainApp(),
    ),
  );
}

//android.permission.WAKE_LOCK
//for background tasks?

//windows notifications
//https://pub.dev/packages/windows_notification

//file_picker setup: (already working for: windows and android)
//https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup

//Save data online
//https://stackoverflow.com/questions/68955545/flutter-how-to-backup-user-data-on-google-drive-like-whatsapp-does
