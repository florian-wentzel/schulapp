import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/school_grade_subject_widget.dart';

// ignore: must_be_immutable
class SemesterScreen extends StatefulWidget {
  SchoolSemester semester;
  String heroString;

  SemesterScreen({
    super.key,
    required this.semester,
    required this.heroString,
  });

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester: ${widget.semester.name}"),
        actions: [
          IconButton(
            tooltip: "Show Grades Graph",
            onPressed: _showGradesGraphPressed,
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        useRotationAnimation: true,
        tooltip: '',
        animationCurve: Curves.elasticInOut,

        // onOpen: () => print('OPENING DIAL'),
        // onClose: () => print('DIAL CLOSED'),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            label: 'Create new Subject',
            onTap: () async {
              final subject = await _showCreateSubjectSheet(context);

              if (subject == null) return;

              widget.semester.subjects.add(subject);

              setState(() {});

              SaveManager().saveSemester(widget.semester);
            },
          ),
          // SpeedDialChild(
          //   child: const Icon(Icons.edit),
          //   backgroundColor: Colors.blueAccent,
          //   foregroundColor: Colors.white,
          //   label: 'Edit',
          //   onTap: () => Utils.showInfo(
          //     context,
          //     msg: "This function is not impelemented yet! sry :/",
          //     type: InfoType.warning,
          //   ),
          // ),
          SpeedDialChild(
            child: const Icon(Icons.import_export),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            label: 'Import',
            onTap: () async {
              final subjects = await _showImportSubjectsSheet(context);

              if (subjects == null) return;

              widget.semester.subjects.addAll(subjects);

              setState(() {});

              SaveManager().saveSemester(widget.semester);
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final semester = widget.semester;

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          delegate: CircleHeaderDelegate(
            heroString: widget.heroString,
            text: widget.semester.getGradeAverageString(),
            color: widget.semester.getColor(),
          ),
          floating: false,
          pinned: true,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 24,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _listItem(
              context,
              index,
              semester.sortedSubjects,
            ),
            childCount: semester.subjects.length + 1,
          ),
        ),
        SliverVisibility(
          visible: semester.subjects.isEmpty,
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    final subject = await _showCreateSubjectSheet(context);

                    if (subject == null) return;

                    semester.subjects.add(subject);

                    setState(() {});
                    SaveManager().saveSemester(semester);
                  },
                  child: const Text("Create new Subject"),
                ),
                TextButton(
                  onPressed: () async {
                    final subjects = await _showImportSubjectsSheet(context);

                    if (subjects == null) return;

                    semester.subjects.addAll(subjects);

                    setState(() {});

                    SaveManager().saveSemester(semester);
                  },
                  child: const Text("Import Subjects"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _listItem(
    BuildContext context,
    int index,
    List<SchoolGradeSubject> sortedSubjects,
  ) {
    if (index == sortedSubjects.length) {
      return const SizedBox(
        height: 64,
      );
    }
    SchoolGradeSubject subject = sortedSubjects[index];
    return Material(
      child: Center(
        child: Hero(
          tag: subject,
          flightShuttleBuilder: (flightContext, animation, flightDirection,
              fromHeroContext, toHeroContext) {
            return SchoolGradeSubjectWidget(
              subject: subject,
              semester: widget.semester,
              isFlightShuttleBuilder: true,
            );
          },
          child: InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SchoolGradeSubjectScreen(
                    subject: subject,
                    semester: widget.semester,
                  ),
                ),
              );

              setState(() {});
            },
            child: SchoolGradeSubjectWidget(
              subject: subject,
              semester: widget.semester,
            ),
          ),
        ),
      ),
    );
  }

  Future<SchoolGradeSubject?> _showCreateSubjectSheet(
      BuildContext context) async {
    const maxNameLength = SchoolGradeSubject.maxNameLength;

    TextEditingController nameController = TextEditingController();

    bool createPressed = false;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Create Subject",
                style: Theme.of(context).textTheme.headlineMedium,
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
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  createPressed = true;
                  Navigator.of(context).pop();
                },
                child: const Text("Create"),
              ),
            ],
          ),
        );
      },
    );

    if (!createPressed) return null;

    String name = nameController.text.trim();

    if (name.isEmpty) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: "Subject name can not be empty!",
          type: InfoType.error,
        );
      }
      return null;
    }

    return SchoolGradeSubject(
      name: name,
      gradeGroups: TimetableManager().settings.defaultGradeGroups,
    );
  }

  Future<List<SchoolGradeSubject>?> _showImportSubjectsSheet(
      BuildContext context) async {
    Timetable? timetable;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Import Subjects',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'Select Semester to import:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                fit: FlexFit.tight,
                child: ListView.builder(
                  itemCount: TimetableManager().timetables.length,
                  itemBuilder: (context, index) {
                    final tt = TimetableManager().timetables[index];

                    return ListTile(
                      onTap: () {
                        timetable = tt;
                        Navigator.of(context).pop();
                      },
                      title: Text(tt.name),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancle"),
              ),
            ],
          ),
        );
      },
    );

    if (timetable == null) return null;

    List<SchoolLessonPrefab> lessonPrefabs =
        Utils.createLessonPrefabsFromTt(timetable!);

    List<SchoolGradeSubject> subjects = List.generate(
      lessonPrefabs.length,
      (index) {
        return SchoolGradeSubject(
          name: lessonPrefabs[index].name,
          gradeGroups: TimetableManager().settings.defaultGradeGroups,
        );
      },
    );

    return subjects;
  }

  void _showGradesGraphPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grades'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  _createLineChartData(),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  LineChartData _createLineChartData() {
    List<FlSpot> spots = [];
    List<Grade> grades = [];

    for (SchoolGradeSubject subject in widget.semester.subjects) {
      for (GradeGroup gg in subject.gradeGroups) {
        for (Grade grade in gg.grades) {
          grades.add(grade);
        }
      }
    }

    grades.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    double sum = 0;

    for (int i = 0; i < grades.length; i++) {
      sum += grades[i].grade;
      final y = sum / (i + 1);

      spots.add(
        FlSpot((i + 1).toDouble(), y),
      );
    }

    // Grade? endSetGrade = widget.subject.endSetGrade;
    // spots.add(
    //   FlSpot(spots.length.toDouble(), endSetGrade.grade.toDouble()),
    // );
    // const darkModeColor = Color(0xff37434d);
    // const lightModeColor = Color(0xff37434d);

    // final isLightMode =
    //     MediaQuery.of(context).platformBrightness == Brightness.light;

    // final currLineColor = isLightMode ? lightModeColor : darkModeColor;

    return LineChartData(
      // lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        verticalInterval: (spots.length ~/ 10).toDouble(),
        horizontalInterval: 5,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: (spots.length ~/ 10).toDouble(),
            reservedSize: 30,
            showTitles: true,
          ),
        ),
      ),
      minY: 0,
      maxY: 15,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
        ),
      ],
    );
  }
}

class CircleHeaderDelegate extends SliverPersistentHeaderDelegate {
  String heroString;
  String text;
  Color color;

  CircleHeaderDelegate({
    required this.heroString,
    required this.text,
    required this.color,
  });

  @override
  double get minExtent => 75.0; // Minimum height of the header

  @override
  double get maxExtent => 150.0; // Maximum height of the header

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate the size of the circle based on the shrink offset
    double circleSize = 150.0 - shrinkOffset.clamp(0, 50.0);

    return Container(
      color: Theme.of(context).canvasColor, // Background color of the header
      child: Center(
        child: Hero(
          tag: heroString,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: FractionallySizedBox(
              heightFactor: 0.5,
              widthFactor: 0.5,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
