import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:schulapp/code_behind/grade.dart';
import 'package:schulapp/code_behind/grade_group.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/screens/semester/semester_screen_settings_dialog.dart';
import 'package:schulapp/widgets/semester/school_grade_subject_widget.dart';

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
        title: Text(
          AppLocalizationsManager.localizations.strSemesterX(
            widget.semester.name,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizationsManager.localizations.strShowGradesGraph,
            onPressed: _showGradesGraphPressed,
            icon: const Icon(Icons.info),
          ),
          IconButton(
            tooltip: AppLocalizationsManager.localizations.strSettings,
            onPressed: _showSettingsPressed,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz_outlined,
        activeIcon: Icons.close,
        spacing: 3,
        useRotationAnimation: true,
        tooltip: '',
        animationCurve: Curves.elasticInOut,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            label: AppLocalizationsManager.localizations.strCreateNewSubject,
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
            label: AppLocalizationsManager
                .localizations.strImportSubjectsFromTimetable,
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
            text: widget.semester.getGradePointsAverageString(),
            buttomText: widget.semester.getGradeAverageString(),
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
                  child: Text(
                    AppLocalizationsManager.localizations.strCreateNewSubject,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final subjects = await _showImportSubjectsSheet(context);

                    if (subjects == null) return;

                    semester.subjects.addAll(subjects);

                    setState(() {});

                    SaveManager().saveSemester(semester);
                  },
                  child: Text(
                    AppLocalizationsManager
                        .localizations.strImportSubjectsFromTimetable,
                  ),
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
                AppLocalizationsManager.localizations.strCreateNewSubject,
                style: Theme.of(context).textTheme.headlineMedium,
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
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  createPressed = true;
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizationsManager.localizations.strCreate,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!createPressed) return null;

    String name = nameController.text.trim();

    if (name.isEmpty) {
      if (context.mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
          type: InfoType.error,
        );
      }
      return null;
    }

    return SchoolGradeSubject(
      name: name,
      gradeGroups: TimetableManager().settings.getVar(
            Settings.defaultGradeGroupsKey,
          ),
    );
  }

  Future<List<SchoolGradeSubject>?> _showImportSubjectsSheet(
      BuildContext context) async {
    Timetable? timetable;
    await Utils.showListSelectionBottomSheet(
      context,
      title:
          "${AppLocalizationsManager.localizations.strImportSubjectsFromTimetable}:",
      items: TimetableManager().timetables,
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
    );

    if (timetable == null) return null;

    List<SchoolLessonPrefab> lessonPrefabs =
        Utils.createLessonPrefabsFromTt(timetable!);

    List<SchoolGradeSubject> subjects = List.generate(
      lessonPrefabs.length,
      (index) {
        return SchoolGradeSubject(
          name: lessonPrefabs[index].name,
          gradeGroups: TimetableManager().settings.getVar(
                Settings.defaultGradeGroupsKey,
              ),
        );
      },
    );

    return subjects;
  }

  Future<void> _showSettingsPressed() async {
    await showDialog(
      context: context,
      builder: (context) => SemesterScreenSettingsDialog(
        semester: widget.semester,
      ),
    );

    setState(() {});
    SaveManager().saveSemester(widget.semester);
  }

  void _showGradesGraphPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizationsManager.localizations.strGrades,
          ),
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
              child: Text(
                AppLocalizationsManager.localizations.strOK,
              ),
            ),
          ],
        );
      },
    );
  }

  LineChartData _createLineChartData() {
    List<FlSpot> spots = [];

    SchoolSemester calcSemester = SchoolSemester(
      name: "calcSemester",
      subjects: List.generate(
        widget.semester.subjects.length,
        (subjectIndex) {
          SchoolGradeSubject subject = widget.semester.subjects[subjectIndex];

          return SchoolGradeSubject(
            name: subject.name,
            gradeGroups: List.generate(
              subject.gradeGroups.length,
              (gradeGroupIndex) {
                GradeGroup gradeGroup = subject.gradeGroups[gradeGroupIndex];

                return GradeGroup(
                  name: gradeGroup.name,
                  percent: gradeGroup.percent,
                  grades: [],
                );
              },
            ),
          );
        },
      ),
    );

    //subjectIndex, schoolGradeSubjectIndex, grade
    List<(int, int, Grade)> grades = [];

    for (int subjectIndex = 0;
        subjectIndex < widget.semester.subjects.length;
        subjectIndex++) {
      SchoolGradeSubject subject = widget.semester.subjects[subjectIndex];

      for (int gradeGroupIndex = 0;
          gradeGroupIndex < subject.gradeGroups.length;
          gradeGroupIndex++) {
        GradeGroup gg = subject.gradeGroups[gradeGroupIndex];

        for (Grade grade in gg.grades) {
          grades.add((subjectIndex, gradeGroupIndex, grade));
        }
      }

      if (subject.endSetGrade != null) {
        grades.add((subjectIndex, -1, subject.endSetGrade!));
      }
    }

    grades.sort(
      (a, b) => a.$3.date.compareTo(b.$3.date),
    );

    for (int i = 0; i < grades.length; i++) {
      int subjectIndex = grades[i].$1;
      int gradeGroupIndex = grades[i].$2;
      Grade grade = grades[i].$3;

      if (gradeGroupIndex == -1) {
        calcSemester.subjects[subjectIndex].endSetGrade = grade;
      } else {
        calcSemester.subjects[subjectIndex].gradeGroups[gradeGroupIndex].grades
            .add(grade);
      }

      final y = calcSemester.getGradeAverage();

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

    const verticalCount = 5;

    double verticalInterval = (spots.length ~/ verticalCount).toDouble();

    if (verticalInterval == 0) {
      verticalInterval = 1;
    }

    return LineChartData(
      // lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        verticalInterval: verticalInterval,
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
            interval: verticalInterval,
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
  String buttomText;
  Color color;

  CircleHeaderDelegate({
    required this.heroString,
    required this.text,
    required this.buttomText,
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
                child: Column(
                  children: [
                    Text(
                      text,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(
                      buttomText,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
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
