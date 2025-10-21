import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/tutorial/tutorial.dart';
import 'package:schulapp/code_behind/tutorial/tutorial_step.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/high_contrast_text.dart';
import 'package:schulapp/widgets/timetable/timetable_drop_target_widget.dart';
import 'package:schulapp/widgets/timetable/timetable_one_day_drop_target_widget.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/widgets/tutorial_overlay.dart';

class CreateTimetableScreen extends StatefulWidget {
  static const String route = "/edit-timetable";
  final Timetable timetable;

  const CreateTimetableScreen({
    super.key,
    required this.timetable,
  });

  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  final GlobalKey _saveButtonKey = GlobalKey();
  final GlobalKey _createLessonPrefabKey = GlobalKey();
  final GlobalKey _lessonPrefabScrollbarKey = GlobalKey();
  final GlobalKey _appBarTitleKey = GlobalKey();
  final GlobalKey _moreActionsButtonKey = GlobalKey();

  final _pageController = PageController();

  late Tutorial _tutorial;

  //only edit this tt so there are no changes to the original one
  late Timetable _timetableCopy;

  List<SchoolLessonPrefab> _lessonPrefabs = [];

  // late String _originalName;

  bool _tutorialShowing = false;
  bool _canPop = false;

  Set<int> _weekSelection = {
    0,
  };

  @override
  void initState() {
    _timetableCopy = widget.timetable.copy();

    Map<String, SchoolLessonPrefab> prefabs = {};

    for (var p in _timetableCopy.lessonPrefabs) {
      prefabs[p.name] = p;
    }

    for (var tt in _timetableCopy.weekTimetables) {
      for (var p in tt.lessonPrefabs) {
        prefabs[p.name] = p;
      }
    }
    _lessonPrefabs = prefabs.values.toList();

    _sortLessonPrefabs();
    // _originalName = String.fromCharCodes(widget.timetable.name.codeUnits);

    super.initState();

    _tutorial = Tutorial(
      steps: [
        TutorialStep(
          highlightKey: _createLessonPrefabKey,
          tutorialWidget: Text(
            AppLocalizationsManager.localizations.strAddNewLessons,
          ),
        ),
        TutorialStep(
          highlightKey: _lessonPrefabScrollbarKey,
          tutorialWidget: Text(
            AppLocalizationsManager
                .localizations.strDragAndDropLessonsAndClickToEdit,
          ),
        ),
        TutorialStep(
          highlightKey: _appBarTitleKey,
          tutorialWidget: Text(
            AppLocalizationsManager
                .localizations.strChangeTimetableNameByClickingOnIt,
          ),
        ),
        TutorialStep(
          highlightKey: _moreActionsButtonKey,
          tutorialWidget: Text(
            AppLocalizationsManager.localizations.strAccessAdditionalOptions,
          ),
        ),
        TutorialStep(
          highlightKey: _saveButtonKey,
          tutorialWidget: Text(
            AppLocalizationsManager.localizations.strSaveTimetable,
          ),
        ),
      ],
    );

    bool showTutorial = TimetableManager()
        .settings
        .getVar(Settings.showTutorialInCreateTimetableScreenKey);

    if (showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _showTutorial();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MainApp.changeNavBarVisibilitySecure(context, value: false);

    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) async {
        if (_canPop) {
          return;
        }

        bool exit = await Utils.showBoolInputDialog(
          context,
          question: AppLocalizationsManager
              .localizations.strDoYouWantToExitWithoutSaving,
          showYesAndNoInsteadOfOK: true,
          markTrueAsRed: true,
        );

        _canPop = exit;

        setState(() {});

        if (_canPop && context.mounted) {
          MainApp.changeNavBarVisibilitySecure(context, value: true);
          HomeWidgetManager.updateWithDefaultTimetable(context: context);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            key: _appBarTitleKey,
            onTap: _changeTimetableName,
            child: Text(
              _timetableCopy.name,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help),
              onPressed: _tutorialShowing ? null : _showTutorial,
            ),
          ],
        ),
        bottomNavigationBar: _bottomNavBar(),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _createNewPrefab,
        //   child: const Icon(Icons.add),
        // ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    Widget body;

    final weekTimetables = [_timetableCopy, ..._timetableCopy.weekTimetables];

    if (Utils.isMobileRatio(context)) {
      if (weekTimetables.isEmpty) {
        body = Expanded(
          child: SingleChildScrollView(
            child: TimetableOneDayDropTargetWidget(
              timetable: _timetableCopy,
            ),
          ),
        );
      } else {
        body = Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weekTimetables.length,
            itemBuilder: (context, index) => SingleChildScrollView(
              child: SingleChildScrollView(
                child: TimetableOneDayDropTargetWidget(
                  timetable: weekTimetables[index],
                ),
              ),
            ),
          ),
        );
      }
    } else {
      if (weekTimetables.isEmpty) {
        body = Expanded(
          child: SingleChildScrollView(
            child: TimetableDropTargetWidget(
              timetable: _timetableCopy,
            ),
          ),
        );
      } else {
        body = Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weekTimetables.length,
            itemBuilder: (context, index) => SingleChildScrollView(
              child: SingleChildScrollView(
                child: TimetableDropTargetWidget(
                  timetable: weekTimetables[index],
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _lessonPrefabScrollbar(),
        const SizedBox(
          height: 4,
        ),
        _weekSelectorWidget(),
        body,
      ],
    );
  }

  void _onMoreActionsButtonPressed() {
    final actionWidgets = <(String title, Future<void> Function()? onPressed)>[
      if (!TimetableManager().settings.getVar(Settings.showLessonNumbersKey))
        (
          AppLocalizationsManager
              .localizations.strDisplayFreePeriodsWithLessonNumber,
          () async {
            TimetableManager().settings.setVar(
                  Settings.showLessonNumbersKey,
                  true,
                );
            setState(() {});
          },
        ),
      if (TimetableManager().settings.getVar(Settings.showLessonNumbersKey))
        (
          AppLocalizationsManager
              .localizations.strDisplayFreePeriodsWithoutPeriodNumber,
          () async {
            TimetableManager().settings.setVar(
                  Settings.showLessonNumbersKey,
                  false,
                );
            setState(() {});
          },
        ),
      (
        AppLocalizationsManager.localizations.strAddLesson,
        _timetableCopy.maxLessonCount >= Timetable.maxMaxLessonCount
            ? null
            : () async {
                bool addLesson = await Utils.showBoolInputDialog(
                  context,
                  question: AppLocalizationsManager
                      .localizations.strDoYouWantToAddALesson,
                  showYesAndNoInsteadOfOK: true,
                );

                if (!addLesson) return;

                //allen eine Stunde hinzufügen
                _timetableCopy.addLesson();

                setState(() {});
              },
      ),
      (
        AppLocalizationsManager.localizations.strRemoveLesson,
        _timetableCopy.maxLessonCount <= Timetable.minMaxLessonCount
            ? null
            : () async {
                bool removeLesson = await Utils.showBoolInputDialog(
                  context,
                  question: AppLocalizationsManager
                      .localizations.strDoYouWantToRemoveTheLastLesson,
                  showYesAndNoInsteadOfOK: true,
                  markTrueAsRed: true,
                );

                if (!removeLesson) return;

                //allen eine Stunde entfernen
                _timetableCopy.removeLesson();

                setState(() {});
              },
      ),
      if (_timetableCopy.weekTimetables.isNotEmpty)
        (
          AppLocalizationsManager.localizations.strSetXWeekAsTheCurrentWeek(
            Timetable.weekNames[_weekSelection.first],
          ),
          _weekSelection.first != _timetableCopy.getCurrWeekTimetableIndex()
              ? () async {
                  _timetableCopy
                      .setCurrWeekTimetableIndex(_weekSelection.first);

                  setState(() {});
                }
              : null,
        ),
      (
        AppLocalizationsManager.localizations.strAddXWeek(
          Timetable.weekNames[_timetableCopy.weekTimetables.length + 1],
        ),
        _timetableCopy.canAddAnotherWeek()
            ? () async {
                _timetableCopy.addAnotherWeek();

                _weekSelection = {_timetableCopy.weekTimetables.length};

                _animateToSelectedPage();

                setState(() {});
              }
            : null,
      ),
      if (_timetableCopy.weekTimetables.isNotEmpty)
        (
          AppLocalizationsManager.localizations.strRemoveXWeek(
            Timetable.weekNames[_weekSelection.first],
          ),
          _weekSelection.first != 0
              ? () async {
                  bool removeWeek = await Utils.showBoolInputDialog(
                    context,
                    question: AppLocalizationsManager.localizations
                        .strDoYouWantToRemoveWeekX(
                      Timetable.weekNames[_weekSelection.first],
                    ),
                    showYesAndNoInsteadOfOK: true,
                    markTrueAsRed: true,
                  );

                  if (!removeWeek) return;

                  _timetableCopy.removeWeekX(_weekSelection.first - 1);

                  _weekSelection = {
                    _weekSelection.first - 1,
                  };

                  _animateToSelectedPage();

                  setState(() {});
                }
              : null,
        ),
      (
        AppLocalizationsManager.localizations.strImportSubjectsFromTimetable,
        TimetableManager().timetables.isEmpty
            ? null
            : _importSubjectsFromOtherTimetable,
      ),
    ];

    Utils.showStringAcionListBottomSheet(
      context,
      items: actionWidgets,
    );
  }

  Widget _bottomNavBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(
          bottom: 8,
          left: 8,
          right: 8,
        ),
        height: kBottomNavigationBarHeight,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  key: _saveButtonKey,
                  onPressed: () async {
                    final setAsDefault = TimetableManager().timetables.isEmpty;

                    if (setAsDefault) {
                      TimetableManager().settings.setVar(
                            Settings.mainTimetableNameKey,
                            _timetableCopy.name,
                          );
                    }

                    _canPop = true;
                    _timetableCopy.setLessonPrefabs(_lessonPrefabs);
                    final success =
                        await TimetableManager().addOrChangeTimetable(
                      _timetableCopy,
                      originalName: widget.timetable.name,
                      onAlreadyExists: () {
                        return Utils.showBoolInputDialog(
                          context,
                          question: AppLocalizationsManager.localizations
                              .strDoYouWantToOverrideTimetableX(
                            _timetableCopy.name,
                          ),
                          markTrueAsRed: true,
                          showYesAndNoInsteadOfOK: true,
                        );
                      },
                    );

                    if (!success) {
                      if (mounted) {
                        Utils.showInfo(
                          context,
                          msg: AppLocalizationsManager
                              .localizations.strThereWasAnErrorWhileSaving,
                          type: InfoType.error,
                        );
                      }
                      return;
                    }

                    //den eigentlichen tt auf die richitgen werte die bereits gespeichert wurden setzen
                    widget.timetable.setValuesFrom(_timetableCopy);

                    if (!mounted) return;

                    HomeWidgetManager.updateWithDefaultTimetable(
                      context: context,
                    );

                    TimetableManager().settings.setVar(
                          Settings.showTutorialInCreateTimetableScreenKey,
                          false,
                        );

                    final mainTt = TimetableManager().settings.getVar<String?>(
                          Settings.mainTimetableNameKey,
                        );

                    if (widget.timetable.name == mainTt) {
                      NotificationManager()
                          .resetScheduleNotificationWithTimetable(
                        timetable: widget.timetable,
                      );
                    }

                    //weil neuer timetable erstellt return true damit kann man später vielleicht was anfangen
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strSave,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  key: _moreActionsButtonKey,
                  onPressed: _onMoreActionsButtonPressed,
                  child: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lessonPrefabScrollbar() {
    const minContainerWidth = 100.0;
    const minContainerHeight = minContainerWidth / 2;

    // if (_lessonPrefabs.isEmpty) {
    //   return Center(
    //     child: InkWell(
    //       onTap: _importSubjectsFromOtherTimetable,
    //       child: Container(
    //         constraints: const BoxConstraints(
    //           minHeight: minContainerHeight,
    //           minWidth: minContainerWidth,
    //         ),
    //         // margin: const EdgeInsets.all(12),
    //         padding: const EdgeInsets.all(8),
    //         decoration: BoxDecoration(
    //           color: Theme.of(context).cardColor,
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         child: Center(
    //           child: Text(
    //             AppLocalizationsManager
    //                 .localizations.strImportSubjectsFromTimetable,
    //             textAlign: TextAlign.center,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    List<Widget> children = [];

    children.add(
      const SizedBox(
        width: 8,
      ),
    );
    if (_lessonPrefabs.isEmpty && TimetableManager().timetables.isNotEmpty) {
      children.add(
        InkWell(
          onTap: _importSubjectsFromOtherTimetable,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            height: minContainerHeight,
            // width: minContainerWidth,
            child: Center(
              child: Text(
                AppLocalizationsManager
                    .localizations.strImportSubjectsFromTimetable,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    } else {
      children.addAll(
        List.generate(
          _lessonPrefabs.length,
          (index) {
            SchoolLessonPrefab prefab = _lessonPrefabs[index];
            return InkWell(
              onTap: () => _editPrefab(index),
              child: Draggable(
                onDragEnd: (DraggableDetails details) {
                  if (prefab.room.isEmpty) {
                    Utils.showInfo(
                      context,
                      msg: AppLocalizationsManager
                          .localizations.strYouHavntSetTheRoom,
                      actionWidget: SnackBarAction(
                        label: AppLocalizationsManager.localizations.strSetRoom,
                        onPressed: () async {
                          Utils.hideCurrInfo(context);

                          await _editPrefab(index);

                          if (!mounted) return;

                          Utils.showInfo(
                            context,
                            msg: AppLocalizationsManager
                                .localizations.strToSetTheRoomDrag,
                            type: InfoType.info,
                            actionWidget: SnackBarAction(
                              label:
                                  AppLocalizationsManager.localizations.strOK,
                              onPressed: () {
                                Utils.hideCurrInfo(context);
                              },
                            ),
                          );
                        },
                      ),
                      type: InfoType.info,
                    );
                  }
                },
                affinity: Axis.vertical, // damit man nicht ausversehen scrollt
                data: prefab,
                feedback: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: prefab.color.withAlpha(127),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: minContainerHeight,
                  width: minContainerWidth,
                ),
                childWhenDragging: Container(
                  margin: const EdgeInsets.all(12),
                  width: minContainerWidth,
                  height: minContainerHeight,
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: prefab.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: minContainerWidth,
                  ),
                  height: minContainerHeight,
                  // width: minContainerWidth,
                  child: Center(
                    child: HighContrastText(
                      text: prefab.name,
                      textStyle: Theme.of(context).textTheme.labelLarge,
                      highContrastEnabled: TimetableManager().settings.getVar(
                            Settings.highContrastTextOnHomescreenKey,
                          ),
                      outlineWidth: 1,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    //so there is a bit space between add Button and right screen end
    children.add(
      const SizedBox(
        width: 8,
      ),
    );

    return Center(
      key: _lessonPrefabScrollbarKey,
      child: Row(
        children: [
          InkWell(
            key: _createLessonPrefabKey,
            onTap: _createNewPrefab,
            child: Container(
              width: minContainerHeight,
              height: minContainerHeight,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              // primary: true,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewPrefab() async {
    List<SchoolLessonPrefab>? selectedPrefabs =
        await SelectLessonPrefabsSheet.show(context);

    if (selectedPrefabs == null) return;
    _lessonPrefabs.addAll(selectedPrefabs);

    _sortLessonPrefabs();
    setState(() {});

    // //prefab, delete
    // (SchoolLessonPrefab, bool)? prefab =
    //     await _showCreateNewPrefabBottomSheet();

    // if (prefab == null) return;

    // _lessonPrefabs.add(prefab.$1);

    // _sortLessonPrefabs();
    // setState(() {});
  }

  Future<void> _editPrefab(int index) async {
    SchoolLessonPrefab prefab = _lessonPrefabs[index];

    (SchoolLessonPrefab, bool)? newPrefab =
        await showCreateNewPrefabBottomSheet(
      context,
      prefab: prefab,
    );

    if (newPrefab == null) {
      return;
    }
    bool deletePressed = newPrefab.$2;
    if (deletePressed && mounted) {
      bool delete = await Utils.showBoolInputDialog(
        context,
        question: AppLocalizationsManager.localizations.strDoYouWantToDeleteX(
          prefab.name,
        ),
        showYesAndNoInsteadOfOK: true,
        markTrueAsRed: true,
      );

      if (delete) {
        try {
          SchoolLessonPrefab deletePrefab = _lessonPrefabs.firstWhere(
            (element) => element.name == prefab.name,
          );
          _lessonPrefabs.remove(deletePrefab);
          setState(() {});
        } catch (_) {}
        return;
      }
    }

    if (!mounted) return;

    // bool updateLessons = await Utils.showBoolInputDialog(
    //   context,
    //   question:
    //       AppLocalizationsManager.localizations.strDoYouWantToUpdateAllLessons,
    //   description: AppLocalizationsManager.localizations.strRoomsWontChange,
    //   showYesAndNoInsteadOfOK: true,
    // );

    // if (updateLessons) {
    Utils.updateTimetableLessons(
      _timetableCopy,
      prefab,
      newName: newPrefab.$1.name,
      newShortName: newPrefab.$1.shortName,
      newTeacher: newPrefab.$1.teacher,
      newColor: newPrefab.$1.color,
    );
    // }

    _lessonPrefabs[index] = newPrefab.$1;
    _sortLessonPrefabs();
    setState(() {});
  }

  Future<void> _changeTimetableName() async {
    String? name = await Utils.showStringInputDialog(
      context,
      hintText: AppLocalizationsManager.localizations.strEnterTimetableName,
      maxInputLength: Timetable.maxNameLength,
      initText: _timetableCopy.name,
    );

    if (name == null) return;
    name = name.trim();

    if (name.isEmpty) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
          type: InfoType.error,
        );
      }
      return;
    }

    try {
      _timetableCopy.name = name;
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
    }

    setState(() {});
  }

  void _sortLessonPrefabs() {
    _lessonPrefabs.sort(
      (a, b) => a.name.compareTo(b.name),
    );
  }

  Future<void> _importSubjectsFromOtherTimetable() async {
    Timetable? timetable = await showSelectTimetableSheet(
      context,
      title: AppLocalizationsManager
          .localizations.strSelectTimetableToImportSubjectsFrom,
    );

    if (timetable == null) return;

    if (!mounted) return;

    bool overridePrefabs = false;

    if (_lessonPrefabs.isNotEmpty) {
      overridePrefabs = await Utils.showBoolInputDialog(
        context,
        question: AppLocalizationsManager
            .localizations.strDoYouWantToOverrideAllSubjects,
        showYesAndNoInsteadOfOK: true,
      );
    }

    Map<String, SchoolLessonPrefab> prefabsMap = {};

    for (var p in timetable.lessonPrefabs) {
      prefabsMap[p.name] = p;
    }

    for (var tt in timetable.weekTimetables) {
      for (var p in tt.lessonPrefabs) {
        prefabsMap[p.name] = p;
      }
    }

    if (overridePrefabs) {
      for (var p in _lessonPrefabs) {
        if (!prefabsMap.containsKey(p.name)) {
          prefabsMap[p.name] = p;
        }
      }
    } else {
      for (var p in _lessonPrefabs) {
        prefabsMap[p.name] = p;
      }
    }

    _lessonPrefabs.clear();

    List<SchoolLessonPrefab> prefabs = prefabsMap.values.toList();

    _lessonPrefabs.addAll(prefabs);
    _sortLessonPrefabs();

    for (var prefab in _lessonPrefabs) {
      Utils.updateTimetableLessons(
        _timetableCopy,
        prefab,
        newName: prefab.name,
        newTeacher: prefab.teacher,
        newColor: prefab.color,
      );
    }

    setState(() {});
  }

  Widget _weekSelectorWidget() {
    final weekTimetables = _timetableCopy.weekTimetables;
    if (weekTimetables.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 4,
      ),
      child: SegmentedButton<int>(
        selected: _weekSelection,
        onSelectionChanged: (Set<int> newSelection) {
          _weekSelection = newSelection;
          _animateToSelectedPage();
          setState(() {});
        },
        showSelectedIcon: false,
        multiSelectionEnabled: false,
        emptySelectionAllowed: false,
        segments: List.generate(weekTimetables.length + 1, (index) {
          String label = AppLocalizationsManager.localizations.strXWeek(
            Timetable.weekNames[index],
          );

          if (_timetableCopy.getCurrWeekTimetableIndex() == index) {
            label += "\n";
            label += AppLocalizationsManager.localizations.strCurrentWeek;
          }

          return ButtonSegment<int>(
            value: index,
            label: Text(
              label,
              textAlign: TextAlign.center,
            ),
          );
        }),
      ),
    );
  }

  void _animateToSelectedPage() {
    _pageController.animateToPage(
      _weekSelection.first,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCirc,
    );
  }

  Future<void> _showTutorial() async {
    if (_tutorialShowing) return;

    setState(() {
      _tutorialShowing = true;
    });

    if (!mounted) return;
    TutorialOverlay.show(
      context,
      _tutorial,
      onOverlayRemoved: () {
        if (mounted) {
          setState(() {
            _tutorialShowing = false;
          });
        }
      },
    );
  }
}
