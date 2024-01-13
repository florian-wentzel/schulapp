import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/grades_screen.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/school_grade_subject_widget.dart';
import 'package:schulapp/widgets/time_to_next_lesson_widget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';

// ignore: must_be_immutable
class TimetableWidget extends StatefulWidget {
  Timetable timetable;

  TimetableWidget({super.key, required this.timetable});

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context)
        .colorScheme
        .secondary
        .withAlpha(30); // Color.fromARGB(30, 255, 255, 255);

    Timetable tt = widget.timetable;
    List<DataColumn> dataColumn = List.generate(
      tt.schoolDays.length,
      (index) => DataColumn(
        label: Expanded(
          child: Container(
            color: index == DateTime.now().weekday - 1
                ? selectedColor
                : Colors.transparent,
            child: Center(
              child: Text(
                tt.schoolDays[index].name,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    //füge Zeiten hinzu
    dataColumn.insert(
      0,
      DataColumn(
        label: Expanded(
          child: TimeToNextLessonWidget(
            timetable: tt,
            onNewLessonCB: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ),
      ),
    );
    List<DataRow> dataRow = List.generate(
      tt.maxLessonCount,
      (rowIndex) {
        return DataRow(
          selected: tt.schoolTimes[rowIndex].isCurrentlyRunning(),
          cells: List.generate(
            dataColumn.length,
            (cellIndex) {
              if (cellIndex == 0) {
                final startString = tt.schoolTimes[rowIndex].getStartString();
                final endString = tt.schoolTimes[rowIndex].getEndString();
                return DataCell(
                  Center(
                    child: Text(
                      "$startString\n$endString",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              //dadurch das wir jz eine Zeile mehr haben durch die Zeit müssen wir einen Index abziehen..
              int correctCellIndex = cellIndex - 1;
              final heroString = "$rowIndex:$correctCellIndex";
              final schoolDay = tt.schoolDays[correctCellIndex];
              final lesson = schoolDay.lessons[rowIndex];

              return DataCell(
                onTap: lesson.name == SchoolLesson.emptyLessonName
                    ? null
                    : () async {
                        await showSchoolLessonHomePopUp(
                          context,
                          lesson,
                          schoolDay,
                          widget.timetable.schoolTimes[rowIndex],
                          heroString,
                        );
                        if (!mounted) return;
                        setState(() {});
                      },
                Center(
                  child: Container(
                    color: cellIndex == DateTime.now().weekday
                        ? selectedColor
                        : Colors.transparent,
                    child: Hero(
                      tag: heroString,
                      // flightShuttleBuilder: (flightContext, animation,
                      //     flightDirection, fromHeroContext, toHeroContext) {
                      //   return Container(
                      //     width: 100,
                      //     // margin: const EdgeInsets.symmetric(vertical: 12),
                      //     // padding: const EdgeInsets.all(6),
                      //     decoration: BoxDecoration(
                      //       color: lesson.color,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   );
                      // },
                      flightShuttleBuilder:
                          (context, animation, __, ___, ____) {
                        const targetAlpha = 220;

                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            return Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: ColorTween(
                                  begin: lesson.color,
                                  end: Theme.of(context)
                                      .cardColor
                                      .withAlpha(targetAlpha),
                                ).lerp(animation.value),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: TimetableManager().settings.timetableLessonWidth,
                        // margin: const EdgeInsets.symmetric(vertical: 12),
                        // padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: lesson.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              lesson.name,
                            ),
                            Visibility(
                              visible: lesson.room.isNotEmpty,
                              child: Text(
                                lesson.room,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: dataColumn,
        rows: dataRow,
        columnSpacing: 25,
        horizontalMargin: 25,
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomPopUpShowLesson extends StatefulWidget {
  SchoolLesson lesson;
  SchoolDay day;
  SchoolTime schoolTime;
  String heroString;

  CustomPopUpShowLesson({
    super.key,
    required this.heroString,
    required this.day,
    required this.lesson,
    required this.schoolTime,
  });

  @override
  State<CustomPopUpShowLesson> createState() => _CustomPopUpShowLessonState();
}

class _CustomPopUpShowLessonState extends State<CustomPopUpShowLesson> {
  @override
  Widget build(BuildContext context) {
    return CustomPopUp(
      heroObject: widget.heroString,
      color: Theme.of(context).cardColor,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final selectedSemester = Utils.getMainSemester();
    final selectedSubject =
        selectedSemester?.getSubjectByName(widget.lesson.name);

    return Column(
      children: [
        Text(
          widget.lesson.name,
          style: TextStyle(
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
            // decoration: TextDecoration.underline,
            fontSize: 42.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
          width: 150,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.lesson.color,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        FittedBox(
          // fit: BoxFit.fitWidth,
          child: Text(
            "Room: ${widget.lesson.room}",
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: 42.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          widget.lesson.teacher,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            fontSize: 42.0,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        _showGradesWidget(
          context,
          lesson: widget.lesson,
          selectedSemester: selectedSemester,
          selectedSubject: selectedSubject,
        ),
        const Spacer(
          flex: 2,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: const Icon(
              Icons.close,
              size: 42,
            ),
          ),
        ),
      ],
    );
  }

  Widget _showGradesWidget(
    BuildContext context, {
    required SchoolLesson lesson,
    SchoolSemester? selectedSemester,
    SchoolGradeSubject? selectedSubject,
  }) {
    if (selectedSemester != null && selectedSubject != null) {
      return InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SchoolGradeSubjectScreen(
                subject: selectedSubject,
                semester: selectedSemester,
              ),
            ),
          );
          if (mounted) {
            setState(() {});
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).canvasColor,
          ),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          child: SchoolGradeSubjectWidget(
            subject: selectedSubject,
            semester: selectedSemester,
          ),
        ),
      );
    }
    String errorMsg = "";
    String buttonText = "";
    void Function() buttonFunc = () {};

    if (selectedSubject == null) {
      errorMsg =
          "Your Selected Semester does not\n contain a Subject named: ${lesson.name}";
      buttonText = "Create a Subject named: ${lesson.name}";
      buttonFunc = () {
        selectedSemester!.subjects.add(
          SchoolGradeSubject(
            name: lesson.name,
            gradeGroups: TimetableManager().settings.defaultGradeGroups,
          ),
        );
        if (mounted) {
          setState(() {});
        }
        SaveManager().saveSemester(selectedSemester);
      };
    }
    if (selectedSemester == null) {
      errorMsg =
          "You did not select a Semester\n to show on homescreen.\nGo to the Grades page\nand select a Semester:)";
      buttonText = "Go to Grades screen";
      buttonFunc = () {
        context.go(GradesScreen.route);
      };
    }
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).canvasColor,
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              errorMsg,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: buttonFunc,
            child: Text(
              buttonText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
