import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/time_table/timetable_droptarget.dart';

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
  List<SchoolLessonPrefab> lessonPrefabs = [];

  late final String _originalName = widget.timetable.name;

  @override
  void initState() {
    lessonPrefabs = _createLessonPrefabsFromTt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            String? name = await Utils.showStringInputDialog(
              context,
              hintText: "Enter Timetable name",
              maxInputLength: Timetable.maxNameLength,
            );

            if (name == null) {
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
          child: Text("Create a Timetable: ${widget.timetable.name}"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          SchoolLessonPrefab? prefab = await _showCreateNewPrefabBottomSheet();

          if (prefab == null) return;

          lessonPrefabs.add(prefab);
          setState(() {});
        },
      ),
      body: _body(),
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
            ElevatedButton(
              onPressed: () async {
                //TODO: Are there "-$number-" lessons? then ask question othetwise skip
                bool replace = await Utils.showBoolInputDialog(
                  context,
                  question: "Do you want to replace empty lessons with '---'?",
                );

                if (replace) {
                  Utils.removeEmptySchoolLessons(
                    widget.timetable,
                    newName: "---",
                    newColor: Colors.transparent,
                    // newRoom: "---", ist schon "---"
                    // newTeacher: "---", ist schon "---"
                  );
                }

                TimetableManager().addOrChangeTimetable(
                  widget.timetable,
                  originalName: _originalName,
                );

                if (!mounted) return;

                //weil neuer timetable erstellt return true damit kann man später vielleicht was anfangen
                Navigator.of(context).pop(true);
              },
              child: const Icon(
                Icons.arrow_right_alt,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonPrefabScrollbar() {
    const containerHeight = 100.0;
    const containerWidth = containerHeight;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          lessonPrefabs.length,
          (index) {
            SchoolLessonPrefab prefab = lessonPrefabs[index];
            return GestureDetector(
              onTap: () async {
                SchoolLessonPrefab? newPrefab =
                    await _showCreateNewPrefabBottomSheet(
                  title: "Change School lesson",
                  name: prefab.name,
                  room: prefab.room,
                  teacher: prefab.teacher,
                  color: prefab.color,
                );

                if (newPrefab == null) return;

                if (!mounted) return;

                bool updateLessons = await Utils.showBoolInputDialog(
                  context,
                  question: "Do you want to update all Lessons?",
                  description: "(rooms wont change)",
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

                lessonPrefabs[index] = newPrefab;
                setState(() {});
              },
              child: Draggable(
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
    String title = "Create School lesson",
    String name = "",
    String room = "",
    String teacher = "",
    Color color = Colors.white,
  }) async {
    const maxNameLength = 20;

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
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Name",
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
                  decoration: const InputDecoration(
                    hintText: "Teacher",
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
                  decoration: const InputDecoration(
                    hintText: "Room",
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
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    name = nameController.text.trim();
                    teacher = teacherController.text.trim();
                    room = roomController.text.trim();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Create"),
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

  List<SchoolLessonPrefab> _createLessonPrefabsFromTt() {
    Map<String, SchoolLessonPrefab> lessonPrefabsMap = {};

    for (int schoolDayIndex = 0;
        schoolDayIndex < widget.timetable.schoolDays.length;
        schoolDayIndex++) {
      for (int schoolLessonIndex = 0;
          schoolLessonIndex < widget.timetable.maxLessonCount;
          schoolLessonIndex++) {
        SchoolLesson lesson = widget
            .timetable.schoolDays[schoolDayIndex].lessons[schoolLessonIndex];

        if (lesson.name.startsWith("-")) {
          continue;
        }

        bool exists = lessonPrefabsMap.containsKey(lesson.name);

        if (exists) continue;

        SchoolLessonPrefab prefab = SchoolLessonPrefab(
          name: lesson.name,
          room: lesson.room,
          teacher: lesson.teacher,
          color: lesson.color,
        );

        lessonPrefabsMap[lesson.name] = prefab;
      }
    }

    return lessonPrefabsMap.values.toList();
  }
}
