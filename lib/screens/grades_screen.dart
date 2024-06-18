import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/semester/semester_screen.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';

class GradesScreen extends StatefulWidget {
  static const route = "/grades";

  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  void initState() {
    super.initState();

    bool openMainSemsterAutomaticly = TimetableManager().settings.getVar(
          Settings.openMainSemesterAutomaticallyKey,
        );
    if (!openMainSemsterAutomaticly) return;
    Future.delayed(Duration.zero, () {
      final mainSemester = Utils.getMainSemester();

      // Check if mainSemester is not null and not empty
      if (mainSemester != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SemesterScreen(
              semester: mainSemester,
              heroString: mainSemester.name,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: GradesScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strGrades,
        ),
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
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
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
          child: Text(
            AppLocalizationsManager.localizations.strCreateSemester,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: TimetableManager().semesters.length,
      itemBuilder: itemBuilder,
    );
  }

  Widget itemBuilder(context, index) {
    final semester = TimetableManager().semesters[index];
    final mainSemesterName = TimetableManager().settings.getVar(
              Settings.mainSemesterNameKey,
            ) ??
        "";
    final heroString = semester.name;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SemesterScreen(
                semester: semester,
                heroString: heroString,
              ),
            ),
          );

          setState(() {});
        },
        title: Text(semester.name),
        leading: Hero(
          tag: heroString,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: semester.getColor(),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      semester.getGradePointsAverageString(),
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
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
            Checkbox.adaptive(
              value: mainSemesterName == semester.name,
              onChanged: (bool? value) {
                assert(value != null);
                if (value == null) return;
                if (value) {
                  TimetableManager().settings.setVar(
                        Settings.mainSemesterNameKey,
                        semester.name,
                      );
                } else {
                  TimetableManager().settings.setVar(
                        Settings.mainSemesterNameKey,
                        null,
                      );
                }
                setState(() {});
              },
            ),
            IconButton(
              onPressed: () async {
                SchoolSemester? editedSemester = await showCreateSemesterSheet(
                  context,
                  headingText:
                      AppLocalizationsManager.localizations.strEditSemester(
                    semester.name,
                  ),
                  initalNameValue: semester.name,
                );
                if (editedSemester == null) return;

                String originalName =
                    String.fromCharCodes(semester.name.codeUnits);

                semester.name = editedSemester.name;

                TimetableManager().addOrChangeSemester(
                  semester,
                  originalName: originalName,
                );
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                bool delete = await Utils.showBoolInputDialog(
                  context,
                  question: AppLocalizationsManager.localizations
                      .strDoYouWantToDeleteX(
                    semester.name,
                  ),
                );

                if (!delete) return;

                bool removed = TimetableManager().removeSemester(semester);

                setState(() {});

                if (!mounted) return;

                if (removed) {
                  Utils.showInfo(
                    context,
                    type: InfoType.success,
                    msg: AppLocalizationsManager.localizations
                        .strSuccessfullyRemoved(
                      semester.name,
                    ),
                  );
                } else {
                  Utils.showInfo(
                    context,
                    type: InfoType.error,
                    msg: AppLocalizationsManager.localizations
                        .strCouldNotBeRemoved(
                      semester.name,
                    ),
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
      ),
    );
  }
}
