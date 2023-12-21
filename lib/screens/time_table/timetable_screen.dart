import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';

class TimeTableScreen extends StatefulWidget {
  static const String route = "/";
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
      ),
      body: Visibility(
        visible: TimetableManager().timetables.isNotEmpty,
        replacement: Center(
          child: ElevatedButton(
            onPressed: () async {
              Timetable? tt = await _showCreateTimeTableSheet();
              if (tt == null) return;

              if (!mounted) return;
              //Ich pushe es so weil kein plan wie man es mit GoROuter macht lol (und ist spät)
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateTimeTableScreen(timeTable: tt),
                ),
              );
            },
            child: const Text("Create a Timetable"),
          ),
        ),
        child: Center(
          child: Text(
            "You have ${TimetableManager().timetables.length} timetables",
          ),
        ),
      ),
    );
  }

  Future<Timetable?> _showCreateTimeTableSheet() async {
    const defaultLessonCountValue = 9;
    const maxNameLength = 15;
    const minLessonCount = 5;
    const maxLessonCount = 12;

    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    TextEditingController nameController = TextEditingController();
    TextEditingController lessonCountController = TextEditingController();

    String ttName = "";
    int lessonCount = -1;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Create Timetable',
                style: TextStyle(
                  color: textColor,
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
                  hintText: "Lesson Count",
                ),
                autofocus: false,
                maxLines: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: lessonCountController,
              ),
              //TODO: Auswählen ob man 5 tage woche hat oder 6/7 Tage Woche
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ttName = nameController.text.trim();
                  //sollte immer funktionieren da man nur Zahlen eingebe kann
                  if (lessonCountController.text.isNotEmpty) {
                    lessonCount = int.parse(lessonCountController.text.trim());
                  }

                  Navigator.of(context).pop();
                },
                child: const Text("Create"),
              ),
            ],
          ),
        );
      },
    );

    if (ttName.isEmpty) {
      //show error
      return null;
    }
    if (lessonCount == -1) {
      //also nicht gesetzt
      lessonCount = defaultLessonCountValue;
    }
    if (lessonCount < minLessonCount || lessonCount > maxLessonCount) {
      return null;
    }

    return Timetable(
      name: nameController.text,
      maxLessonCount: lessonCount,
      schoolDays: Timetable.defaultSchoolDays(lessonCount),
      schoolTimes: Timetable.defaultSchoolTimes(lessonCount),
    );
  }
}
