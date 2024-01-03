import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/semester/semester_screen.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';

class GradesScreen extends StatefulWidget {
  static const route = "/grades";

  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: GradesScreen.route),
      appBar: AppBar(
        title: const Text("Semesters"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          SchoolSemester? semester = await createNewSemester(context);

          if (semester == null) return;

          TimetableManager().addOrChangeSemester(semester);

          if (!mounted) return;

          setState(() {});
        },
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (TimetableManager().semesters.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            SchoolSemester? semester = await createNewSemester(context);

            if (semester == null) return;

            TimetableManager().addOrChangeSemester(semester);

            if (!mounted) return;

            setState(() {});
          },
          child: const Text("Create a Semester"),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: TimetableManager().semesters.length,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget itemBuilder(context, index) {
    final semester = TimetableManager().semesters[index];
    final heroString = semester.name;

    return ListTile(
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SemesterScreen(
              semester: semester,
              heroString: heroString,
            ),
          ),
        );
      },
      title: Text(semester.name),
      leading: Hero(
        tag: heroString,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: semester.getColor(),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  semester.getGradeAverageString(),
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      trailing: Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              bool delete = await Utils.showBoolInputDialog(
                context,
                question: "Do you want to delete ${semester.name}?",
              );

              if (!delete) return;

              bool removed = TimetableManager().removeSemester(semester);

              setState(() {});

              if (!mounted) return;

              if (removed) {
                Utils.showInfo(
                  context,
                  type: InfoType.success,
                  msg: "${semester.name} successfully removed!",
                );
              } else {
                Utils.showInfo(
                  context,
                  type: InfoType.error,
                  msg: "${semester.name} could not be removed!",
                );
              }
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
