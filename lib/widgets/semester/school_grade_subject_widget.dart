import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/grade.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';

// ignore: must_be_immutable
class SchoolGradeSubjectWidget extends StatelessWidget {
  SchoolGradeSubject subject;
  SchoolSemester semester;
  bool isFlightShuttleBuilder;
  bool showName;

  SchoolGradeSubjectWidget({
    super.key,
    required this.subject,
    required this.semester,
    this.isFlightShuttleBuilder = false,
    this.showName = true,
  });

  List<Grade?> grades = [];

  @override
  Widget build(BuildContext context) {
    grades = _generateGrades();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Row(
              children: [
                Visibility(
                  visible: showName,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subject.name,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                if (isFlightShuttleBuilder)
                  Container()
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: grades.length,
                      itemBuilder: (context, index) {
                        final grade = grades[index];

                        if (grade == null) {
                          return const Center(child: Text("|  "));
                        }

                        return Center(
                          child: Text(
                            "${grade.toString()}  ",
                            style: TextStyle(
                              color: Utils.getGradeColor(grade.grade),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: isFlightShuttleBuilder ? 80 : null,
            height: isFlightShuttleBuilder ? 80 : null,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Utils.getGradeColor(subject.getGradeAverage().toInt()),
            ),
            child: Center(
              child: Text(
                subject.getGradeAverageString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      decoration: subject.endSetGrade != null
                          ? TextDecoration.underline
                          : null,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Grade?> _generateGrades() {
    List<Grade?> grades = [];

    for (var gradeGroup in subject.gradeGroups) {
      for (var grade in gradeGroup.grades) {
        grades.add(grade);
      }
      if (gradeGroup.grades.isNotEmpty) {
        grades.add(null);
      }
    }

    return grades;
  }
}
