import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_event.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class NotesScreen extends StatefulWidget {
  static const route = "/notes";

  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: NotesScreen.route),
      appBar: AppBar(
        title: const Text("Tasks / Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          SchoolEvent? event = await _createNewSchoolEventSheet(context);

          if (event == null) return;

          TimetableManager().addOrChangeSchoolEvent(event);

          if (!mounted) return;

          setState(() {});
        },
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final events = TimetableManager().schoolEvents;
    if (events.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            SchoolEvent? event = await _createNewSchoolEventSheet(context);

            if (event == null) return;

            TimetableManager().addOrChangeSchoolEvent(event);

            if (!mounted) return;

            setState(() {});
          },
          child: const Text("Create a Task / Note"),
        ),
      );
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(
            event.name,
          ),
          // trailing: Checkbox(
          //   onChanged: (value){

          //   },
          //   value: event.,
          // ),
        );
      },
    );
  }

  Future<SchoolEvent?> _createNewSchoolEventSheet(BuildContext context) async {
    const int taskType = 1;
    const int noteType = 2;
    int type = -1;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create new Task / Note',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _customButton(
                    text: "Task",
                    onTap: () async {
                      type = taskType;
                      Navigator.of(context).pop();
                    },
                  ),
                  _customButton(
                    text: "Note",
                    onTap: () {
                      type = noteType;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );

    if (type == -1) return null;
    if (!mounted) return null;

    //müsste eigentlich weiter unten abgefragt werden aber ist noch nicht implementiert deswegen..
    if (type == noteType) {
      Utils.showInfo(
        context,
        msg: "Not Implemented yet! Sorry :/",
        type: InfoType.error,
      );
      return null;
    }

    String? mainTimetableName = TimetableManager().settings.mainTimetableName;

    if (mainTimetableName == null) {
      Utils.showInfo(
        context,
        msg:
            "You did not select an Timetable to be the default!\nGo to the Timetables Screen and select a Timetable.",
        type: InfoType.error,
      );
      return null;
    }

    String? selectedSubjectName = await _showSelectSubjectNameSheet(context);

    if (!mounted) return null;
    if (selectedSubjectName == null) return null;

    if (type == taskType) {
      TodoEvent? event = await _createNewTodoEventSheet(
        context,
        linkedSubjectName: selectedSubjectName,
      );

      return event;
    }

    return null;
  }

  Future<TodoEvent?> _createNewTodoEventSheet(
    BuildContext context, {
    required String linkedSubjectName,
  }) async {
    const maxNameLength = SchoolEvent.maxNameLength;
    const maxDescriptionLength = TodoEvent.maxDescriptionLength;

    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    DateSelectionButtonController endDateController =
        DateSelectionButtonController(
      date: DateTime.now(),
    );

    TodoType? type;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: 0.5,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create new Task / Note\n$linkedSubjectName',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Name",
                  ),
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
                    hintText: "Extra info",
                  ),
                  maxLength: maxDescriptionLength,
                  maxLines: 5,
                  minLines: 1,
                  textAlign: TextAlign.center,
                  controller: descriptionController,
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "End date:",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      DateSelectionButton(
                        controller: endDateController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _customButton(
                        text: "Exam",
                        onTap: () {
                          type = TodoType.exam;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Expanded(
                      child: _customButton(
                        text: "Test",
                        onTap: () {
                          type = TodoType.test;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Expanded(
                      child: _customButton(
                        text: "Homework",
                        onTap: () {
                          type = TodoType.homework;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (type == null) return null;

    String name = nameController.text.trim();
    String desciption = descriptionController.text.trim();

    // if (name.isEmpty) {
    //   if (mounted) {
    //     Utils.showInfo(
    //       context,
    //       msg: "Name can not be empty!",
    //       type: InfoType.error,
    //     );
    //   }
    //   return null;
    // }

    return TodoEvent(
      key: TimetableManager().getNextSchoolEventKey(),
      name: name,
      desciption: desciption,
      linkedSubjectName: linkedSubjectName,
      endTime: endDateController.date,
      type: type!,
      finished: false,
    );
  }

  Widget _customButton({
    required String text,
    required void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          // borderRadius: BorderRadius.circular(16),
          shape: BoxShape.circle,
        ),
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Future<String?> _showSelectSubjectNameSheet(BuildContext context) async {
    Timetable? selectedTimetable = Utils.getHomescreenTimetable();
    if (selectedTimetable == null) return null;

    List<SchoolLessonPrefab> selectedTimetablePrefabs =
        Utils.createLessonPrefabsFromTt(selectedTimetable);

    String? selectdSubjectName;

    await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.6,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Select Subject to add Task Or Note!",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: selectedTimetablePrefabs.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(selectedTimetablePrefabs[index].name),
                      onTap: () {
                        selectdSubjectName =
                            selectedTimetablePrefabs[index].name;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return selectdSubjectName;
  }
}
