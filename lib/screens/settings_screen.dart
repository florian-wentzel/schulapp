import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/backup_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/versions_screen.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = "/settings";

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  static Widget listItem(
    BuildContext context, {
    required String title,
    List<Widget>? body,
    List<Widget>? afterTitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ...afterTitle ?? [Container()],
            ],
          ),
          body != null
              ? const SizedBox(
                  height: 12,
                )
              : Container(),
          ...body ?? [Container()],
        ],
      ),
    );
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<ThemeMode> selection = {};

  @override
  void initState() {
    selection = {
      ThemeManager().themeMode,
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: SettingsScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strSettings,
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      children: [
        _themeSelector(),
        _selectLanguage(),
        _openMainSemesterAutomatically(),
        _showTasksOnHomeScreen(),
        _pinHomeWidget(),
        _createBackup(),
        _currentVersion(),
      ],
    );
  }

  Widget _themeSelector() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strTheme,
      body: [
        SegmentedButton<ThemeMode>(
          segments: <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text(
                AppLocalizationsManager.localizations.strDark,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text(
                AppLocalizationsManager.localizations.strSystem,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text(
                AppLocalizationsManager.localizations.strLight,
              ),
            ),
          ],
          selected: selection,
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            selection = newSelection;
            ThemeManager().themeMode = selection.first;
            setState(() {});
          },
          showSelectedIcon: false,
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ],
    );
  }

  Widget _selectLanguage() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strLanguage,
      body: [
        ElevatedButton(
          onPressed: () async {
            await Utils.showListSelectionBottomSheet(
              context,
              title: AppLocalizationsManager.localizations.strSelectLanguage,
              items: AppLocalizations.supportedLocales,
              itemBuilder: (itemContext, index) {
                final currLocale = AppLocalizations.supportedLocales[index];

                return Localizations.override(
                  context: itemContext,
                  locale: currLocale,
                  child: Builder(builder: (builderContext) {
                    return ListTile(
                      title: Text(
                        AppLocalizations.of(builderContext)?.language_name ??
                            "Error",
                      ),
                      onTap: () async {
                        MainApp.setLocale(context, currLocale);
                        Navigator.of(itemContext).pop();
                        await Future.delayed(
                          const Duration(milliseconds: 250),
                        );
                        _showUpdateTimetableDayNamesAndSemesterGradeGroups();
                      },
                    );
                  }),
                );
              },
            );
          },
          child: Text(AppLocalizationsManager.localizations.strChangeLanguage),
        ),
      ],
    );
  }

  Future<void> _showUpdateTimetableDayNamesAndSemesterGradeGroups() async {
    List<Timetable> timetables = TimetableManager().timetables;

    await _showCheckBoxList(
      title: AppLocalizationsManager
          .localizations.strWhichTimetableWouldYouLikeToTranslate,
      underTitle: AppLocalizationsManager.localizations.strOnlyTheDayNames,
      list: timetables,
      getName: (item) => item.name,
      updateItem: (item) {
        item.translateDayNames();
      },
    );

    List<SchoolSemester> semesters = TimetableManager().semesters;

    await _showCheckBoxList(
      title: AppLocalizationsManager
          .localizations.strWhichSemestersWouldYouLikeToTranslate,
      underTitle: AppLocalizationsManager.localizations.strOnlyTheGradeGroups,
      list: semesters,
      getName: (item) => item.name,
      updateItem: (item) {
        item.translateGradeGroups();
      },
    );

    if (!mounted) return;

    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strSuccessfullyTranslated,
      type: InfoType.success,
    );
  }

  Future<void> _showCheckBoxList<T>({
    required String title,
    required String underTitle,
    required List<T> list,
    required String Function(T item) getName,
    required void Function(T item) updateItem,
  }) async {
    List<bool> selectedCheckbox = List.generate(
      list.length,
      (index) => false,
    );

    bool okPressed = false;

    await Utils.showListSelectionBottomSheet(
      context,
      title: title,
      underTitle: underTitle,
      items: list,
      bottomAction: ElevatedButton(
        onPressed: () {
          okPressed = true;
          Navigator.of(context).pop();
        },
        child: Text(AppLocalizationsManager.localizations.strOK),
      ),
      itemBuilder: (context, index) {
        final timetable = list[index];
        return ListTileWithCheckBox(
          title: getName(timetable),
          value: selectedCheckbox[index],
          onValueChanged: (value) {
            selectedCheckbox[index] = value;
          },
        );
      },
    );

    if (!okPressed) return;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (selectedCheckbox[i]) {
        updateItem(item);
      }
    }
  }

  Widget _openMainSemesterAutomatically() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager
          .localizations.strOpenMainSemesterAutomatically,
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.getVar(
                Settings.openMainSemesterAutomaticallyKey,
              ),
          onChanged: (value) {
            TimetableManager().settings.setVar(
                  Settings.openMainSemesterAutomaticallyKey,
                  value,
                );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _showTasksOnHomeScreen() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strShowTasksOnHomeScreen,
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.getVar(
                Settings.showTasksOnHomeScreenKey,
              ),
          onChanged: (value) {
            TimetableManager().settings.setVar(
                  Settings.showTasksOnHomeScreenKey,
                  value,
                );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _pinHomeWidget() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strWidgets,
      body: [
        ElevatedButton(
          onPressed: () async {
            Timetable? timetable = Utils.getHomescreenTimetable();

            if (timetable == null) {
              Utils.showInfo(
                context,
                msg: AppLocalizationsManager
                    .localizations.strYouDontHaveATimetableJet,
                type: InfoType.error,
              );
              return;
            }

            await HomeWidgetManager.updateWithDefaultTimetable();
            await HomeWidgetManager.requestToAddHomeWidget();
          },
          child: Text(AppLocalizationsManager.localizations.strPinToHomeScreen),
        ),
      ],
    );
  }

  Widget _createBackup() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strBackup,
      body: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _backupButtonPressed,
                child: Text(
                  AppLocalizationsManager.localizations.strCreateBackup,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _restoreButtonPressed,
                child: Text(
                  AppLocalizationsManager.localizations.strRestoreBackup,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _currentVersion() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VersionsScreen(
              lastUsedVersion: TimetableManager()
                      .settings
                      .getVar(Settings.lastUsedVersionKey) ??
                  "",
            ),
          ),
        );
      },
      child: SettingsScreen.listItem(
        context,
        title: AppLocalizationsManager.localizations.strVersion,
        body: [
          FutureBuilder(
            future: VersionManager().getVersionString(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              String text = snapshot.data!;
              return Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _backupButtonPressed() async {
    final backupData = await Utils.showBoolInputDialog(
      context,
      question:
          AppLocalizationsManager.localizations.strTheBackupIsNotEncrypted,
      description: AppLocalizationsManager
          .localizations.strAreYouSureThatYouWantToCreateABackup,
      showYesAndNoInsteadOfOK: true,
      markTrueAsRed: true,
    );

    if (!backupData) return;

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strNoFileSelected,
          type: InfoType.warning,
        );
      }
      return;
    }

    final backupFile = await BackupManager.createBackupAt(
      path: selectedDirectory,
    );

    if (backupFile == null) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strBackupFailed,
          type: InfoType.error,
        );
      }
      return;
    }

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations
            .strBackupSuccessfullyCreatedUnder(
          backupFile.path,
        ),
        type: InfoType.success,
      );
    }
  }

  Future<void> _restoreButtonPressed() async {
    final restoreData = await Utils.showBoolInputDialog(
      context,
      question: AppLocalizationsManager
          .localizations.strAllOfYourDataWillBeOverwritten,
      description: AppLocalizationsManager
          .localizations.strAreYouSureThatYouWantToRestoreYourData,
      showYesAndNoInsteadOfOK: true,
      markTrueAsRed: true,
    );

    if (!restoreData) return;

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          BackupManager.backupExportExtension.replaceAll(".", "")
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

    final selectedFilePath = result.files.single.path!;

    final backupRestored = await BackupManager.restoreBackupFrom(
      path: selectedFilePath,
      onErrorCB: (error) async {
        return await Utils.showBoolInputDialog(
          context,
          question: error,
          description:
              AppLocalizationsManager.localizations.strDoYouWantToContinue,
          markTrueAsRed: true,
          showYesAndNoInsteadOfOK: true,
        );
      },
    );

    if (!backupRestored) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strRestoreFailed(
            selectedFilePath,
          ),
          type: InfoType.error,
        );
      }
      return;
    }

    TimetableManager().markAllDataToBeReloaded();

    if (mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strRestoredSuccessfully(
          selectedFilePath,
        ),
        type: InfoType.success,
      );

      selection = {
        ThemeManager().themeMode,
      };
      ThemeManager().themeMode = ThemeManager().themeMode;
      setState(() {});
    }
  }
}

// ignore: must_be_immutable
class ListTileWithCheckBox extends StatefulWidget {
  String title;
  bool value;

  void Function(bool value) onValueChanged;

  ListTileWithCheckBox({
    super.key,
    required this.title,
    required this.value,
    required this.onValueChanged,
  });

  @override
  State<ListTileWithCheckBox> createState() => _ListTileWithCheckBoxState();
}

class _ListTileWithCheckBoxState extends State<ListTileWithCheckBox> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        widget.value = !widget.value;
        widget.onValueChanged.call(widget.value);
        setState(() {});
      },
      title: Text(widget.title),
      trailing: Checkbox(
        value: widget.value,
        onChanged: (value) {
          widget.value = value ?? false;
          widget.onValueChanged.call(widget.value);
          setState(() {});
        },
      ),
    );
  }
}
