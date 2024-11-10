import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/timetable/timetable_drop_target_widget.dart';
import 'package:schulapp/widgets/timetable/timetable_one_day_drop_target_widget.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';

// ignore: must_be_immutable
class CreateTimetableScreen extends StatefulWidget {
  static const String route = "/createTimetable";
  Timetable timetable;

  CreateTimetableScreen({
    super.key,
    required this.timetable,
  });

  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  List<SchoolLessonPrefab> _lessonPrefabs = [];

  late String _originalName;

  bool _canPop = false;

  @override
  void initState() {
    _lessonPrefabs = widget.timetable.lessonPrefabs;
    _sortLessonPrefabs();
    _originalName = String.fromCharCodes(widget.timetable.name.codeUnits);

    super.initState();
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
            onTap: _changeTimetableName,
            child: Text(
              widget.timetable.name,
            ),
          ),
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

    if (Utils.isMobileRatio(context)) {
      body = _mobileBody();
    } else {
      body = _pcBody();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _lessonPrefabScrollbar(),
        const SizedBox(
          height: 4,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: body,
          ),
        ),
      ],
    );
  }

  Widget _mobileBody() {
    return TimetableOneDayDropTargetWidget(
      timetable: widget.timetable,
    );
  }

  Widget _bottomNavBar() {
    return Container(
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
              const SizedBox(
                width: 12,
              ),
              ElevatedButton(
                onPressed: () async {
                  _canPop = true;

                  TimetableManager().addOrChangeTimetable(
                    widget.timetable,
                    originalName: _originalName,
                  );

                  if (!mounted) return;

                  HomeWidgetManager.updateWithDefaultTimetable(
                    context: context,
                  );
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
              Switch.adaptive(
                value: TimetableManager()
                    .settings
                    .getVar(Settings.showLessonNumbersKey),
                onChanged: (value) {
                  TimetableManager().settings.setVar(
                        Settings.showLessonNumbersKey,
                        value,
                      );
                  setState(() {});
                },
              ),
              const SizedBox(
                width: 16,
              ),
              ElevatedButton(
                onPressed: widget.timetable.maxLessonCount >=
                        Timetable.maxMaxLessonCount
                    ? null
                    : () async {
                        bool addLesson = await Utils.showBoolInputDialog(
                          context,
                          question: AppLocalizationsManager
                              .localizations.strDoYouWantToAddALesson,
                          showYesAndNoInsteadOfOK: true,
                        );

                        if (!addLesson) return;

                        widget.timetable.addLesson();
                        setState(() {});
                      },
                child: const Icon(Icons.add),
              ),
              const SizedBox(
                width: 16,
              ),
              ElevatedButton(
                onPressed: widget.timetable.maxLessonCount <=
                        Timetable.minMaxLessonCount
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

                        widget.timetable.removeLesson();

                        setState(() {});
                      },
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pcBody() {
    return TimetableDropTargetWidget(
      timetable: widget.timetable,
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

    if (_lessonPrefabs.isEmpty) {
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
                    child: Text(
                      prefab.name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    children.add(
      InkWell(
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
    );
    //so there is a bit space between add Button and right screen end
    children.add(
      const SizedBox(
        width: 8,
      ),
    );

    return Center(
      child: SingleChildScrollView(
        primary: true,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Future<(SchoolLessonPrefab schoolLessonPrefab, bool delete)?>
      _showCreateNewPrefabBottomSheet({
    SchoolLessonPrefab? prefab,
  }) async {
    const maxNameLength = 20;
    String title;

    if (prefab == null) {
      title = AppLocalizationsManager.localizations.strCreateSchoolLesson;
    } else {
      title = AppLocalizationsManager.localizations.strChangeSchoolLesson;
    }

    TextEditingController nameController = TextEditingController();
    TextEditingController teacherController = TextEditingController();
    TextEditingController roomController = TextEditingController();

    Color color = prefab?.color ?? Colors.white;
    String name = prefab?.name ?? "";
    String teacher = prefab?.teacher ?? "";
    String room = prefab?.room ?? "";

    nameController.text = name;
    teacherController.text = teacher;
    roomController.text = room;

    bool createPressed = false;

    bool? delete = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizationsManager.localizations.strName,
                  ),
                  autofocus: true,
                  maxLines: 1,
                  maxLength: maxNameLength,
                  textAlign: TextAlign.center,
                  controller: nameController,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizationsManager.localizations.strTeacher,
                  ),
                  autofocus: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  controller: teacherController,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizationsManager.localizations.strRoom,
                  ),
                  autofocus: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  controller: roomController,
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 200,
                  child: MaterialPicker(
                    pickerColor: color,
                    onColorChanged: (value) {
                      color = value;
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    name = nameController.text.trim();
                    teacher = teacherController.text.trim();
                    room = roomController.text.trim();
                    createPressed = true;
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    prefab == null
                        ? AppLocalizationsManager.localizations.strCreate
                        : AppLocalizationsManager.localizations.strEdit,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: prefab != null,
                  replacement: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizationsManager.localizations.strCancel,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!createPressed && delete == null) {
      return null;
    }

    if (delete == null) {
      return null;
    }

    if (name.isEmpty && !delete) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
          type: InfoType.error,
        );
      }
      return null;
    }

    return (
      SchoolLessonPrefab(
        name: name,
        room: room,
        teacher: teacher,
        color: color,
      ),
      delete,
    );
  }

  Future<void> _createNewPrefab() async {
    //prefab, delete
    (SchoolLessonPrefab, bool)? prefab =
        await _showCreateNewPrefabBottomSheet();

    if (prefab == null) return;

    _lessonPrefabs.add(prefab.$1);

    _sortLessonPrefabs();
    setState(() {});
  }

  Future<void> _editPrefab(int index) async {
    SchoolLessonPrefab prefab = _lessonPrefabs[index];

    (SchoolLessonPrefab, bool)? newPrefab =
        await _showCreateNewPrefabBottomSheet(
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
      widget.timetable,
      prefab,
      newName: newPrefab.$1.name,
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
      initText: widget.timetable.name,
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
      widget.timetable.name = name;
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

  void _importSubjectsFromOtherTimetable() async {
    Timetable? timetable = await showSelectTimetableSheet(
      context,
      title: AppLocalizationsManager
          .localizations.strSelectTimetableToImportSubjectsFrom,
    );

    if (timetable == null) return;
    List<SchoolLessonPrefab> prefabs = timetable.lessonPrefabs;
    _lessonPrefabs.addAll(prefabs);
    _sortLessonPrefabs();
    setState(() {});
  }
}
