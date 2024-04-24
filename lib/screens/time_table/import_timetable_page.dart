import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';

// ignore: must_be_immutable
class ImportTimetablePage extends StatefulWidget {
  void Function() goToHomePage;

  ImportTimetablePage({
    super.key,
    required this.goToHomePage,
  });

  @override
  State<ImportTimetablePage> createState() => _ImportTimetablePageState();
}

class _ImportTimetablePageState extends State<ImportTimetablePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: _selectTimetable,
          child: Text(
            AppLocalizationsManager.localizations.strSelectTimetableFile,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            widget.goToHomePage();
          },
          child: Text(
            AppLocalizationsManager.localizations.strBack,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  void _selectTimetable() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          "zip",
          SaveManager.timetableExportExtension.replaceAll(".", "")
        ],
      );
    } on Exception {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );
    }

    if (result == null) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strNoFileSelected,
          type: InfoType.error,
        );
      }
      return;
    }

    File selectedFile = File(result.files.single.path!);
    if (!selectedFile.existsSync()) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg:
              AppLocalizationsManager.localizations.strSelectedFileDoesNotExist,
          type: InfoType.error,
        );
      }
      return;
    }

    if (mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strImportingTimetable,
      );
    }
    Timetable? timetable;
    try {
      timetable = SaveManager().importTimetable(selectedFile);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      if (timetable == null) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strImportingFailed,
          type: InfoType.error,
        );
      } else {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strImportSuccessful,
          type: InfoType.success,
        );
      }
    }
    if (timetable == null) return;

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTimeTableScreen(timetable: timetable!),
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pop();
  }
}
