import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/time_table.dart';

// ignore: must_be_immutable
class CreateTimeTableScreen extends StatefulWidget {
  static const String route = "/createTimeTable";
  TimeTable timeTable;

  CreateTimeTableScreen({super.key, required this.timeTable});

  @override
  State<CreateTimeTableScreen> createState() => _CreateTimeTableScreenState();
}

class _CreateTimeTableScreenState extends State<CreateTimeTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Timetable: ${widget.timeTable.name}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _timeTable()),
          ],
        ),
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
}
