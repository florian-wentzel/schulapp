import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/save_system/time_table_save_manager.dart';
import 'package:schulapp/screens/time_table/create_time_table_screen.dart';

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
        visible: TimeTableSaveManager().timeTables.isNotEmpty,
        replacement: Center(
          child: ElevatedButton(
            onPressed: () {
              if (TimeTableSaveManager().timeTables.isNotEmpty) {
                return;
              }
              context.push(CreateTimeTableScreen.route);
            },
            child: const Text("Create a Timetable"),
          ),
        ),
        child: Center(
          child: Text(
            "You have ${TimeTableSaveManager().timeTables.length} timetables",
          ),
        ),
      ),
    );
  }
}
