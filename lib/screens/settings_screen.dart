import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/backup_manager.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/code_behind/todo_event_util_functions.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/l10n/generated/app_localizations.dart';
import 'package:schulapp/screens/versions_screen.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/widgets/custom_feedback_form.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = "/settings";

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();

  static Widget listItem(
    BuildContext context, {
    required String? title,
    List<Widget>? body,
    List<Widget>? afterTitle,
    bool hide = false,
  }) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      duration: const Duration(
        milliseconds: 400,
      ),
      child: hide
          ? const SizedBox.shrink(
              key: ValueKey("nothing"),
            )
          : Container(
              key: const ValueKey("item"),
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
                  if (title != null || afterTitle != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (title != null)
                          Flexible(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ...afterTitle ?? [Container()],
                      ],
                    ),
                  body != null && (title != null || afterTitle != null)
                      ? const SizedBox(
                          height: 12,
                        )
                      : Container(),
                  ...body ?? [Container()],
                ],
              ),
            ),
    );
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<ThemeMode> themeSelection = {};
  Set<GradingSystem> gradingSystemSelection = {};

  @override
  void initState() {
    themeSelection = {
      ThemeManager().themeMode,
    };
    gradingSystemSelection = {
      TimetableManager().settings.getVar(Settings.selectedGradeSystemKey),
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
        actions: [
          IconButton(
            onPressed: () async {
              final openFeedback = await Utils.showBoolInputDialog(
                context,
                question: AppLocalizationsManager
                    .localizations.strDoYoutWantToOpenFeedbackMenu,
                description: AppLocalizationsManager
                    .localizations.strOpenFeedbackDescription,
                showYesAndNoInsteadOfOK: true,
              );

              if (!openFeedback || !context.mounted) return;

              CustomFeedbackForm.submitFeedback(context);
            },
            icon: const Icon(Icons.feedback),
            tooltip: AppLocalizationsManager.localizations.strSendFeedback,
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      children: [
        _themeSelector(),
        _gradeSystemSelector(),
        _openMainSemesterAutomatically(),
        _showTasksOnHomeScreen(),
        _highContrastOnHomeScreen(),
        _reducedClassHoursEnabled(),
        _reducedClassHours(),
        _todoEventNotificationScheduleEnabled(),
        _todoEventNotificationScheduleList(),
        _pinHomeWidget(),
        _createBackup(),
        _selectLanguage(),
        _paulDessauLogout(),
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
                textAlign: TextAlign.center,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text(
                AppLocalizationsManager.localizations.strSystem,
                textAlign: TextAlign.center,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text(
                AppLocalizationsManager.localizations.strLight,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          selected: themeSelection,
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            themeSelection = newSelection;
            ThemeManager().themeMode = themeSelection.first;
            setState(() {});
          },
          showSelectedIcon: false,
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ],
    );
  }

  Widget _gradeSystemSelector() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strGradeSystem,
      body: [
        SegmentedButton<GradingSystem>(
          segments: <ButtonSegment<GradingSystem>>[
            ButtonSegment<GradingSystem>(
              value: GradingSystem.grade_0_15,
              label: Text(
                AppLocalizationsManager.localizations.strPoints_0_15,
                textAlign: TextAlign.center,
              ),
            ),
            ButtonSegment<GradingSystem>(
              value: GradingSystem.grade_1_6,
              label: Text(
                AppLocalizationsManager.localizations.strGrade_1_6,
                textAlign: TextAlign.center,
              ),
            ),
            ButtonSegment<GradingSystem>(
              value: GradingSystem.grade_6_1,
              label: Text(
                AppLocalizationsManager.localizations.strGrade_6_1,
                textAlign: TextAlign.center,
              ),
            ),
            ButtonSegment<GradingSystem>(
              value: GradingSystem.grade_A_F,
              label: Text(
                AppLocalizationsManager.localizations.strGrade_A_F,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          selected: gradingSystemSelection,
          onSelectionChanged: (Set<GradingSystem> newSelection) {
            gradingSystemSelection = newSelection;
            setState(() {});
            TimetableManager().settings.setVar(
                  Settings.selectedGradeSystemKey,
                  gradingSystemSelection.first,
                );
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
      bottomActions: [
        ElevatedButton(
          onPressed: () {
            okPressed = true;
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizationsManager.localizations.strOK),
        ),
      ],
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

  Widget _highContrastOnHomeScreen() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strHighContrastOnHomeScreen,
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.getVar(
                Settings.highContrastTextOnHomescreenKey,
              ),
          onChanged: (value) {
            TimetableManager().settings.setVar(
                  Settings.highContrastTextOnHomescreenKey,
                  value,
                );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _reducedClassHoursEnabled() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strReducedClassHours,
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.getVar(
                Settings.reducedClassHoursEnabledKey,
              ),
          onChanged: (value) {
            TimetableManager().settings.setVar(
                  Settings.reducedClassHoursEnabledKey,
                  value,
                );

            final reducedClassHours = TimetableManager().settings.getVar(
                  Settings.reducedClassHoursKey,
                );

            if (value && reducedClassHours == null) {
              Utils.showInfo(
                context,
                msg: AppLocalizationsManager
                    .localizations.strYouDontHaveAnyReducedTimesSetUpYet,
                type: InfoType.warning,
              );
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _reducedClassHours() {
    final times = TimetableManager().settings.getVar<List<SchoolTime>?>(
              Settings.reducedClassHoursKey,
            ) ??
        [];
    return SettingsScreen.listItem(
      context,
      title: null,
      hide: !TimetableManager().settings.getVar(
            Settings.reducedClassHoursEnabledKey,
          ),
      body: [
        if (times.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            child: ListView.builder(
              itemCount: times.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: times[index].start,
                          );

                          if (time == null) return;

                          if (!time.isBefore(times[index].end)) {
                            if (context.mounted) {
                              Utils.showInfo(
                                context,
                                msg: AppLocalizationsManager
                                    .localizations.strTimeNotValid,
                                type: InfoType.error,
                              );
                            }
                            return;
                          }

                          if (index - 1 >= 0 &&
                              time.isBefore(times[index - 1].end)) {
                            if (context.mounted) {
                              Utils.showInfo(
                                context,
                                msg: AppLocalizationsManager
                                    .localizations.strTimeNotValid,
                                type: InfoType.error,
                              );
                            }
                            return;
                          }

                          times[index].start = time;

                          TimetableManager().settings.setVar<List<SchoolTime>?>(
                                Settings.reducedClassHoursKey,
                                times,
                              );

                          setState(() {});
                        },
                        child: Text(
                          times[index].getStartString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Text(
                        "-",
                      ),
                      InkWell(
                        onTap: () async {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: times[index].end,
                          );

                          if (time == null) return;

                          if (time.isBefore(times[index].start)) {
                            if (context.mounted) {
                              Utils.showInfo(
                                context,
                                msg: AppLocalizationsManager
                                    .localizations.strTimeNotValid,
                                type: InfoType.error,
                              );
                            }
                            return;
                          }

                          if (index + 1 < times.length &&
                              !time.isBefore(times[index + 1].start)) {
                            if (context.mounted) {
                              Utils.showInfo(
                                context,
                                msg: AppLocalizationsManager
                                    .localizations.strTimeNotValid,
                                type: InfoType.error,
                              );
                            }
                            return;
                          }

                          times[index].end = time;

                          TimetableManager().settings.setVar<List<SchoolTime>?>(
                                Settings.reducedClassHoursKey,
                                times,
                              );

                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Text(
                            times[index].getEndString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (times.isNotEmpty)
          const SizedBox(
            height: 8,
          ),
        ElevatedButton(
          onPressed: _setTimesPressed,
          child: Text(AppLocalizationsManager.localizations.strSetTimes),
        ),
      ],
    );
  }

  Widget _todoEventNotificationScheduleEnabled() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strTaskNotification,
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.getVar(
                Settings.notificationScheduleEnabledKey,
              ),
          onChanged: (value) async {
            if (value) {
              await NotificationManager().askForPermission();
            }

            TimetableManager().settings.setVar(
                  Settings.notificationScheduleEnabledKey,
                  value,
                );

            setState(() {});

            TimetableManager().sortedTodoEvents;
          },
        ),
      ],
    );
  }

  Widget _todoEventNotificationScheduleList() {
    return SettingsScreen.listItem(
      context,
      title: null,
      hide: !TimetableManager().settings.getVar(
            Settings.notificationScheduleEnabledKey,
          ),
      body: [
        ElevatedButton(
          onPressed: _onSetNotificationSchedulePressed,
          child: Text(
            AppLocalizationsManager.localizations.strSetTaskNotification,
          ),
        ),
      ],
    );
  }

  Widget _pinHomeWidget() {
    return SettingsScreen.listItem(
      context,
      hide: !Platform.isAndroid,
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

  Widget _paulDessauLogout() {
    final username =
        TimetableManager().settings.getVar<String?>(Settings.usernameKey);

    return SettingsScreen.listItem(
      context,
      title: "Paul-Dessau",
      hide: username == null,
      body: [
        ElevatedButton(
          onPressed: () {
            TimetableManager().settings.setVar(
                  Settings.usernameKey,
                  null,
                );

            TimetableManager().settings.setVar(
                  Settings.securePasswordKey,
                  null,
                );

            TimetableManager().settings.setVar<Uint8List?>(
                  Settings.paulDessauPdfBytesKey,
                  null,
                );

            TimetableManager().settings.setVar<DateTime?>(
                  Settings.paulDessauPdfBytesSavedDateKey,
                  null,
                );

            setState(() {});

            Utils.showInfo(
              context,
              msg: "Erfolgreich abgemeldet",
              type: InfoType.success,
            );
          },
          child: const Text("Abmelden"),
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
            future: VersionManager().getVersionWithBuildnumberString(),
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
    final platform = Theme.of(context).platform;

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
      if (platform == TargetPlatform.iOS) {
        throw Exception();
      }
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

    await TimetableManager().removeTodoEventNotifications();

    TimetableManager().markAllDataToBeReloaded();

    if (mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strRestoredSuccessfully(
          selectedFilePath,
        ),
        type: InfoType.success,
      );

      themeSelection = {
        ThemeManager().themeMode,
      };
      ThemeManager().themeMode = ThemeManager().themeMode;
      setState(() {});
    }

    if (mounted) {
      context.go("${SettingsScreen.route}?reload=true");
    }
  }

  Future<void> _setTimesPressed() async {
    final times = (await showCreateTimetableSheet(
      context,
      onlySchoolTimes: true,
    ))
        ?.schoolTimes;

    if (times == null) return;

    final b = TimetableManager().settings.setVar<List<SchoolTime>>(
          Settings.reducedClassHoursKey,
          times,
        );

    if (b && mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strSuccessfullySaved,
        type: InfoType.success,
      );
    }

    setState(() {});
  }

  Future<void> _onSetNotificationSchedulePressed() async {
    final newList = await setNotificationScheduleList(context);

    if (newList == null) return;

    TimetableManager().removeTodoEventNotifications();

    TimetableManager().settings.setVar(
          Settings.notificationScheduleListKey,
          newList,
        );

    TimetableManager().setTodoEventsNotifications();

    setState(() {});
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
