import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';

// ignore: must_be_immutable
class CreateTimeTableScreen extends StatefulWidget {
  static const String route = "/createTimeTable";
  TimeTable timeTable;

  CreateTimeTableScreen({
    super.key,
    required this.timeTable,
  });

  @override
  State<CreateTimeTableScreen> createState() => _CreateTimeTableScreenState();
}

class _CreateTimeTableScreenState extends State<CreateTimeTableScreen> {
  List<SchoolLessonPrefab> lessonPrefabs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Timetable: ${widget.timeTable.name}"),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: _lessonPrefabScrollbar()),
            Center(child: _timeTable()),
          ],
        ),
      ),
    );
  }

  Widget _lessonPrefabScrollbar() {
    const containerHeight = 100.0;
    const containerWidth = containerHeight;
    return SizedBox(
      width: double.infinity,
      height: containerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lessonPrefabs.length,
        itemBuilder: (context, index) {
          final prefab = lessonPrefabs[index];

          return Container(
            height: containerHeight,
            width: containerWidth,
            color: prefab.color,
            child: Center(child: Text(prefab.name)),
          );
        },
      ),
    );
  }

  Widget _timeTable() {
    TimeTable tt = widget.timeTable;

    List<DataColumn> dataColumn = List.generate(
      tt.schoolDays.length,
      (index) => DataColumn(
        label: Text(tt.schoolDays[index].name),
      ),
    );

    List<DataRow> dataRow = List.generate(
      tt.maxLessonCount,
      (rowIndex) => DataRow(
        cells: List.generate(
          tt.schoolDays.length,
          (cellIndex) => DataCell(
            //DragTarget(builder: builde),
            Text("Placeholder $rowIndex : $cellIndex"),
            placeholder: true,
          ),
        ),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: dataColumn,
        rows: dataRow,
      ),
    );
  }

  Future<SchoolLessonPrefab?> _showCreateNewPrefabBottomSheet() async {
    const maxNameLength = 15;

    TextEditingController nameController = TextEditingController();
    TextEditingController teacherController = TextEditingController();
    TextEditingController roomController = TextEditingController();

    String name = "";
    String room = "";
    String teacher = "";
    Color color = Colors.white;

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
                const Text(
                  'Create School lesson',
                  style: TextStyle(
                    fontSize: 24.0, // Adjust the font size as needed
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
                    teacher = nameController.text.trim();
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
}
