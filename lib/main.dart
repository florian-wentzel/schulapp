import 'dart:convert';
import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/widgets/custom_feedback_form.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

void main() async {
  //sichergehen dass alle plugins initialisiert wurden
  WidgetsFlutterBinding.ensureInitialized();

  final futures = [
    NotificationManager().initNotifications(),
    SaveManager().loadApplicationDocumentsDirectory(),
  ];

  tz.initializeTimeZones();

  await Future.wait(futures);

  runApp(
    BetterFeedback(
      feedbackBuilder: (context, onSubmit, scrollController) =>
          CustomFeedbackForm(
        onSubmit: onSubmit,
        scrollController: scrollController,
      ),
      themeMode: ThemeManager().themeMode,
      mode: FeedbackMode.navigate,
      child: const MainApp(),
    ),
  );
}

Future<void> submitFeedback(BuildContext context) async {
  BetterFeedback.of(context).show(
    (feedback) async {
      bool cancel = false;
      BuildContext? dialogContext;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dContext) {
            dialogContext = dContext;
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    TextButton(
                      child:
                          Text(AppLocalizationsManager.localizations.strCancel),
                      onPressed: () {
                        cancel = true;
                        Navigator.of(dContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      try {
        final feedbackFile = File(
          join(
            SaveManager().getTempDir().path,
            "feedback.png",
          ),
        );

        feedbackFile.writeAsBytesSync(feedback.screenshot);

        String? code = await GoFileIoManager().uploadFile(feedbackFile);

        if (dialogContext != null && dialogContext!.mounted) {
          Navigator.of(dialogContext!).pop();
        }

        final extra = feedback.extra ?? {};

        extra["app_version"] =
            await VersionManager().getVersionWithBuildnumberString();
        extra["code"] = code;

        const email = "schulapp.feedback@gmail.com";
        const subject = "App Feedback";

        final mailtoLink =
            "mailto:$email?subject=$subject&body=${jsonEncode(extra)}";

        if (cancel) return;

        launchUrl(Uri.parse(mailtoLink));

        await Future.delayed(
          const Duration(milliseconds: 100),
        );

        SaveManager().deleteTempDir();

        if (context.mounted) {
          Utils.showInfo(
            context,
            msg: "AppLocalizationsManager.localizations.strFeedbackSent",
            type: InfoType.success,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Utils.showInfo(
            context,
            msg: e.toString(),
            type: InfoType.error,
          );
        }
      }
    },
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
