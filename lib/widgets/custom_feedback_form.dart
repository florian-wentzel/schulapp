import 'dart:convert';
import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:schulapp/code_behind/custom_feedback.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomFeedbackForm extends StatefulWidget {
  static const email = "schulapp.feedback@gmail.com";
  static const subject = "App Feedback";

  const CustomFeedbackForm({
    super.key,
    required this.onSubmit,
    required this.scrollController,
  });

  final OnSubmit onSubmit;
  final ScrollController? scrollController;

  @override
  State<CustomFeedbackForm> createState() => _CustomFeedbackFormState();

  static Future<void> submitFeedback(BuildContext context) async {
    BetterFeedback.of(context).show(
      (feedback) async {
        try {
          final feedbackFile = File(
            path.join(
              SaveManager().getTempDir().path,
              "feedback.png",
            ),
          );

          feedbackFile.writeAsBytesSync(feedback.screenshot);

          String code = await GoFileIoManager().uploadFile(feedbackFile);

          final extra = feedback.extra;

          if (extra == null) return;

          extra[CustomFeedback.imageCodeKey] = code;

          final mailtoLink =
              "mailto:$email?subject=$subject&body=${jsonEncode(extra)}";

          launchUrl(Uri.parse(mailtoLink));

          await Future.delayed(
            const Duration(milliseconds: 100),
          );

          SaveManager().deleteTempDir();

          if (context.mounted) {
            Utils.showInfo(
              context,
              msg: AppLocalizationsManager.localizations.strFeedbackSent,
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
}

class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  Set<FeedbackType> _feedbackSelection = {FeedbackType.generlFeedback};

  FeedbackType get _feedbackType => _feedbackSelection.first;
  String _feedbackText = "";
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              const FeedbackSheetDragHandle(),
              ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  0,
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizationsManager
                            .localizations.strWhatDoYouWantToTellTheDeveloper,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<FeedbackType>(
                        segments: [
                          ButtonSegment(
                            value: FeedbackType.bugReport,
                            label: Text(
                              AppLocalizationsManager
                                  .localizations.strBugReport,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ButtonSegment(
                            value: FeedbackType.generlFeedback,
                            label: Text(
                              AppLocalizationsManager
                                  .localizations.strGeneralFeedback,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ButtonSegment(
                            value: FeedbackType.featureRequest,
                            label: Text(
                              AppLocalizationsManager
                                  .localizations.strFeatureRequest,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        selected: _feedbackSelection,
                        showSelectedIcon: false,
                        emptySelectionAllowed: false,
                        multiSelectionEnabled: false,
                        onSelectionChanged: (value) {
                          setState(() {
                            _feedbackSelection = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: AppLocalizationsManager
                              .localizations.strInformation,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (newFeedback) => _feedbackText = newFeedback,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _sending ? null : sendFeedback,
          child: Text(AppLocalizationsManager.localizations.strSendFeedback),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> sendFeedback() async {
    if (_sending) return;

    setState(() {
      _sending = true;
    });

    if (_feedbackText.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizationsManager.localizations.strInformationCanNotBeEmpty,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizationsManager.localizations.strOK),
              ),
            ],
          );
        },
      );

      setState(() {
        _sending = false;
      });

      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );

    final appVersion = await VersionManager().getVersionWithBuildnumberString();

    final feedBack = CustomFeedback(
      feedbackType: _feedbackType,
      feedbackText: _feedbackText,
      appVersion: appVersion,
    );

    widget.onSubmit(
      feedBack.feedbackText,
      extras: feedBack.toJson(),
    );
  }
}
