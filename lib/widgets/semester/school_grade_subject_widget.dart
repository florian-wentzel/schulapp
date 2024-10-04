import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/grade.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';

class SchoolGradeSubjectWidget extends StatelessWidget {
  final SchoolGradeSubject subject;
  final SchoolSemester semester;
  final bool showName;
  final List<Grade?> grades = [];

  SchoolGradeSubjectWidget({
    super.key,
    required this.subject,
    required this.semester,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    grades.clear();
    grades.addAll(_generateGrades());

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 75,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
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
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Visibility(
                  visible: showName && subject.weight != 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).focusColor,
                      ),
                      child: Text(
                        "${subject.weight.roundIfInt()}x",
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Utils.getGradeColor(subject.getGradeAverage().toInt()),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
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
