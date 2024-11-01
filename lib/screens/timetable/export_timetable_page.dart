import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/multi_platform_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:share_plus/share_plus.dart';

class ExportTimetablePage extends StatefulWidget {
  final void Function() goToHomePage;

  const ExportTimetablePage({
    super.key,
    required this.goToHomePage,
  });

  @override
  State<ExportTimetablePage> createState() => EexportTimetablePageState();
}

class EexportTimetablePageState extends State<ExportTimetablePage> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          AppLocalizationsManager.localizations.strSelectTimetableToExport,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        _timetableList(),
        ElevatedButton(
          onPressed: () {
            widget.goToHomePage();
          },
          child: Text(AppLocalizationsManager.localizations.strBack),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _timetableList() {
    return Flexible(
      fit: FlexFit.tight,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.builder(
          itemCount: TimetableManager().timetables.length,
          itemBuilder: _itemBuilder,
        ),
      ),
    );
  }

  Widget _itemBuilder(context, index) {
    Timetable timetable = TimetableManager().timetables[index];

    return IgnorePointer(
      ignoring: _exporting,
      child: ListTile(
        title: Text(timetable.name),
        trailing: IconButton(
          onPressed: () {
            Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => TimetableScreen(
                  timetable: timetable,
                  title: AppLocalizationsManager.localizations.strTimetableX(
                    timetable.name,
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.info),
        ),
        onTap: () async {
          _exporting = true;
          setState(() {});
          await _exportTimetable(index);
          _exporting = false;
          setState(() {});
        },
      ),
    );
  }

  Future<void> _exportTimetable(int index) async {
    Timetable timetable = TimetableManager().timetables[index];

    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strExporting,
    );

    try {
      SaveManager().cleanExports();
    } catch (e) {
      Utils.hideCurrInfo(context);
      Utils.showInfo(
        context,
        msg: e.toString(),
        type: InfoType.error,
      );
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      if (mounted) {
        Utils.showInfo(
          context,
          type: InfoType.warning,
          msg: AppLocalizationsManager.localizations.strNoFileSelected,
        );
      }
      return;
    }
    if (selectedDirectory == "/") {
      if (mounted) {
        Utils.showInfo(
          context,
          type: InfoType.error,
          msg: AppLocalizationsManager.localizations.strThereWasAnError,
        );
      }
      return;
    }

    File? exportFile;

    try {
      exportFile = SaveManager().exportTimetable(timetable, selectedDirectory);
      if (mounted) {
        Utils.hideCurrInfo(context);
      }
    } catch (e) {
      exportFile = null;
      if (mounted) {
        Utils.hideCurrInfo(context);
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
      return;
    }

    if (mounted) {
      if (Platform.isAndroid || Platform.isIOS) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strFileSavedInDownloadsDirectory,
          type: InfoType.success,
        );
      } else {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strExportingSuccessful,
          type: InfoType.success,
        );
      }
    }

    await MultiPlatformManager.shareFile(exportFile);

    await Share.shareXFiles(
      [XFile(exportFile.path)],
      subject: AppLocalizationsManager.localizations.strShareYourTimetable,
      text: AppLocalizationsManager.localizations.strShareYourTimetable,
    );

    widget.goToHomePage();
  }
}
