import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/time_table/timetable_droptarget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';

// ignore: must_be_immutable
class CreateTimeTableScreen extends StatefulWidget {
  static const String route = "/createTimeTable";
  Timetable timetable;

  CreateTimeTableScreen({
    super.key,
    required this.timetable,
  });

  @override
  State<CreateTimeTableScreen> createState() => _CreateTimeTableScreenState();
}

class _CreateTimeTableScreenState extends State<CreateTimeTableScreen> {
  List<SchoolLessonPrefab> _lessonPrefabs = [];

  late String _originalName;

  bool _canPop = false;

  @override
  void initState() {
    _lessonPrefabs = Utils.createLessonPrefabsFromTt(widget.timetable);
    _originalName = String.fromCharCodes(widget.timetable.name.codeUnits);
    widget.timetable.changeLessonNumberVisibility(
      TimetableManager().settings.showLessonNumbers,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) async {
        if (_canPop) {
          return;
        }

        bool? exit = await Utils.showBoolInputDialog(
          context,
          question: AppLocalizationsManager
              .localizations.strDoYouWantToExitWithoutSaving,
          showYesAndNoInsteadOfOK: true,
        );

        _canPop = exit;
        setState(() {});

        if (_canPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () async {
              String? name = await Utils.showStringInputDialog(
                context,
                hintText:
                    AppLocalizationsManager.localizations.strEnterTimetableName,
                maxInputLength: Timetable.maxNameLength,
              );

              if (name == null) return;
              name = name.trim();

              if (name.isEmpty) {
                if (mounted) {
                  Utils.showInfo(
                    context,
                    msg: AppLocalizationsManager
                        .localizations.strNameCanNotBeEmpty,
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
            },
            child: Text(
              AppLocalizationsManager.localizations.strCreateTimetableX(
                widget.timetable.name,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            SchoolLessonPrefab? prefab =
                await _showCreateNewPrefabBottomSheet();

            if (prefab == null) return;

            _lessonPrefabs.add(prefab);
            setState(() {});
          },
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            _lessonPrefabScrollbar(),
            TimetableDroptarget(timetable: widget.timetable),
            const SizedBox(
              height: 16,
            ),
            Switch.adaptive(
              value: TimetableManager().settings.showLessonNumbers,
              onChanged: (value) {
                TimetableManager().settings.showLessonNumbers = value;
                widget.timetable.changeLessonNumberVisibility(value);
                setState(() {});
              },
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                _canPop = true;

                TimetableManager().addOrChangeTimetable(
                  widget.timetable,
                  originalName: _originalName,
                );

                if (!mounted) return;

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
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonPrefabScrollbar() {
    const containerHeight = 100.0;
    const containerWidth = containerHeight;

    if (_lessonPrefabs.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              Timetable? timetable = await showSelectTimetableSheet(
                context,
                title: AppLocalizationsManager
                    .localizations.strSelectTimetableToImportSubjectsFrom,
              );

              if (timetable == null) return;
              List<SchoolLessonPrefab> prefabs =
                  Utils.createLessonPrefabsFromTt(timetable);
              _lessonPrefabs.addAll(prefabs);
              setState(() {});
            },
            child: Container(
              height: containerHeight,
              width: containerWidth,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppLocalizationsManager
                      .localizations.strImportSubjectsFromTimetable,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      primary: true,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _lessonPrefabs.length,
          (index) {
            SchoolLessonPrefab prefab = _lessonPrefabs[index];
            return InkWell(
              onTap: () async {
                SchoolLessonPrefab? newPrefab =
                    await _showCreateNewPrefabBottomSheet(
                  title: AppLocalizationsManager
                      .localizations.strChangeSchoolLesson,
                  name: prefab.name,
                  room: prefab.room,
                  teacher: prefab.teacher,
                  color: prefab.color,
                  showDeleteButton: true,
                );

                if (newPrefab == null) {
                  bool delete = await Utils.showBoolInputDialog(
                    context,
                    question: AppLocalizationsManager.localizations
                        .strDoYouWantToDeleteX(
                      prefab.name,
                    ),
                    showYesAndNoInsteadOfOK: true,
                  );

                  if (delete) {
                    try {
                      SchoolLessonPrefab deletePrefab =
                          _lessonPrefabs.firstWhere(
                        (element) => element.name == prefab.name,
                      );
                      _lessonPrefabs.remove(deletePrefab);
                      setState(() {});
                    } catch (_) {}
                    return;
                  } else {
                    return;
                  }
                }

                if (!mounted) return;

                bool updateLessons = await Utils.showBoolInputDialog(
                  context,
                  question: AppLocalizationsManager
                      .localizations.strDoYouWantToUpdateAllLessons,
                  description:
                      AppLocalizationsManager.localizations.strRoomsWontChange,
                );

                if (updateLessons) {
                  Utils.updateTimetableLessons(
                    widget.timetable,
                    prefab,
                    newName: newPrefab.name,
                    newTeacher: newPrefab.teacher,
                    newColor: newPrefab.color,
                  );
                }

                _lessonPrefabs[index] = newPrefab;
                setState(() {});
              },
              child: Draggable(
                affinity: Axis.vertical, // damit man nicht ausversehen scrollt
                data: prefab,
                feedback: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: prefab.color.withAlpha(127),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: containerHeight,
                  width: containerWidth,
                ),
                childWhenDragging: Container(
                  margin: const EdgeInsets.all(12),
                  width: containerWidth,
                  height: containerHeight,
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: prefab.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: containerHeight,
                  width: containerWidth,
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
      ),
    );
  }

  Future<SchoolLessonPrefab?> _showCreateNewPrefabBottomSheet({
    String title = "",
    String name = "",
    String room = "",
    String teacher = "",
    Color color = Colors.white,
    bool showDeleteButton = false,
  }) async {
    const maxNameLength = 20;

    if (title.isEmpty) {
      title = AppLocalizationsManager.localizations.strCreateSchoolLesson;
    }

    TextEditingController nameController = TextEditingController();
    nameController.text = name;
    if (name.isNotEmpty) name = "";

    TextEditingController teacherController = TextEditingController();
    teacherController.text = teacher;
    if (teacher.isNotEmpty) teacher = "";

    TextEditingController roomController = TextEditingController();
    roomController.text = room;
    if (room.isNotEmpty) room = "";

    await showModalBottomSheet(
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
                HueRingPicker(
                  pickerColor: color,
                  onColorChanged: (value) {
                    color = value;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    name = nameController.text.trim();
                    teacher = teacherController.text.trim();
                    room = roomController.text.trim();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strCreate,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: showDeleteButton,
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
                      Navigator.of(context).pop();
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

    if (name.isEmpty) {
      return null;
    }

    return SchoolLessonPrefab(
      name: name,
      room: room,
      teacher: teacher,
      color: color,
    );
  }
}
