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
            childCount: semester.subjects.length,
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
