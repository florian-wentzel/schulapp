import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:schulapp/code_behind/backup_manager.dart';
import 'package:schulapp/code_behind/online_share_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/timetable/create_timetable_screen.dart';
import 'package:schulapp/widgets/online_code_bottom_sheet.dart';

class ImportTimetablePage extends StatefulWidget {
  final void Function() goToHomePage;

  const ImportTimetablePage({
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
        Column(
          spacing: 12,
          children: [
            ElevatedButton(
              onPressed: _selectViaCode,
              child: Text(
                AppLocalizationsManager.localizations.strImportViaCode,
              ),
            ),
            ElevatedButton(
              onPressed: _selectTimetable,
              child: Text(
                AppLocalizationsManager.localizations.strSelectTimetableFile(
                  SaveManager.timetableExportExtension,
                ),
              ),
            ),
          ],
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
    PlatformFile? result;
    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        throw Exception("");
      }
      result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [
          SaveManager.timetableExportExtension.replaceAll(".", "")
        ],
      );
    } on Exception {
      result = await FilePicker.pickFile(
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

    File selectedFile = File(result.path!);
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
    bool importSpecialLessons;

    try {
      timetable = await SaveManager().importTimetable(
        selectedFile,
        () async {
          importSpecialLessons = await showImportSpecialLessonsDialog();
          return importSpecialLessons;
        },
      );
      try {
        timetable?.name =
            "${timetable.name} (${AppLocalizationsManager.localizations.strImported})";
      } catch (e) {
        timetable?.name =
            "${timetable.name} (${AppLocalizationsManager.localizations.strImported})"
                .substring(
          0,
          Timetable.maxNameLength,
        );
      }
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

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    if (timetable == null) return;

    final saved = await Navigator.of(context).push<bool?>(
          MaterialPageRoute(
            builder: (context) => CreateTimetableScreen(timetable: timetable!),
          ),
        ) ??
        false;

    if (saved) {
      final dir = SaveManager().getTimetableDir(timetable);
      final specialLessonsDir = Directory(
        path.join(
          SaveManager().getImportDir().path,
          SaveManager.specialLessonsDirName,
        ),
      );

      if (specialLessonsDir.existsSync()) {
        BackupManager.copyDirectorySync(
          source: specialLessonsDir,
          destination: Directory(
            path.join(
              dir.path,
              SaveManager.specialLessonsDirName,
            ),
          ),
        );
      }
    }

    SaveManager().getImportDir().deleteSync(recursive: true);

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<bool> showImportSpecialLessonsDialog() {
    return Utils.showBoolInputDialog(
      context,
      question:
          AppLocalizationsManager.localizations.strImportSpecialLessonsQuestion,
      description: AppLocalizationsManager
          .localizations.strImportSpecialLessonsDescription,
      showYesAndNoInsteadOfOK: true,
    );
  }

  void _selectViaCode() async {
    final allowed =
        await OnlineShareManager.showTermsOfServicesEnabledDialog(context);

    if (!allowed || !mounted) return;

    String? code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const OnlineCodeBottomSheet();
      },
    );

    if (code == null) return;

    if (code.isEmpty || !mounted) return;

    BuildContext? dialogContext;

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
                  child: Text(AppLocalizationsManager.localizations.strCancel),
                  onPressed: () {
                    Navigator.of(dContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    File? downloadedFile;

    try {
      downloadedFile = (await OnlineShareManager.downloadFromLitterbox(
        code,
      ))
          .first;
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
    }

    if (dialogContext != null && dialogContext!.mounted) {
      Navigator.of(dialogContext!).pop();
    }

    if (downloadedFile == null) return;

    Timetable? timetable;
    bool importSpecialLessons;
    try {
      timetable = await SaveManager().importTimetable(
        downloadedFile,
        () async {
          importSpecialLessons = await showImportSpecialLessonsDialog();
          return importSpecialLessons;
        },
      );
      try {
        timetable?.name =
            "${timetable.name} (${AppLocalizationsManager.localizations.strImported})";
      } catch (e) {
        timetable?.name =
            "${timetable.name} (${AppLocalizationsManager.localizations.strImported})"
                .substring(
          0,
          Timetable.maxNameLength,
        );
      }
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

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;
    if (timetable == null) return;

    final saved = await Navigator.of(context).push<bool?>(
          MaterialPageRoute(
            builder: (context) => CreateTimetableScreen(timetable: timetable!),
          ),
        ) ??
        false;

    if (saved) {
      final dir = SaveManager().getTimetableDir(timetable);
      final specialLessonsDir = Directory(
        path.join(
          SaveManager().getImportDir().path,
          SaveManager.specialLessonsDirName,
        ),
      );

      if (specialLessonsDir.existsSync()) {
        BackupManager.copyDirectorySync(
          source: specialLessonsDir,
          destination: Directory(
            path.join(
              dir.path,
              SaveManager.specialLessonsDirName,
            ),
          ),
        );
      }
    }

    SaveManager().getImportDir().deleteSync(recursive: true);

    if (!mounted) return;

    Navigator.of(context).pop();
  }
}
