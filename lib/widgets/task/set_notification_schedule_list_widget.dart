import 'package:flutter/material.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class SetNotificationScheduleListWidget extends StatefulWidget {
  const SetNotificationScheduleListWidget({super.key});

  @override
  State<SetNotificationScheduleListWidget> createState() =>
      _SetNotificationScheduleListWidgetState();
}

class _SetNotificationScheduleListWidgetState
    extends State<SetNotificationScheduleListWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Aufgaben Erinnerungen einstellen",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Column(
              children: List.generate(
                5,
                (index) {
                  return ListTile(
                    title: Text(
                      index.toString(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        ),
      ),
    );
  }
}
