import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(16),
      child: Row(
        // alignment: Alignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: showName,
                child: Text(
                  subject.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Visibility(
                visible: !isFlightShuttleBuilder,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      direction: Axis.horizontal,
                      children: List.generate(
                        subject.gradeGroups.length,
                        (gradeGroupsIndex) => Wrap(
                          spacing: 8,
                          children: List.generate(
                            subject.gradeGroups[gradeGroupsIndex].grades.length,
                            (gradeIndex) => Text(
                              subject.gradeGroups[gradeGroupsIndex]
                                  .grades[gradeIndex]
                                  .toString(),
                              style: TextStyle(
                                color: subject.gradeGroups[gradeGroupsIndex]
                                    .getGradeColor(gradeIndex),
                              ),
                            ),
                          )..add(
                              (subject.gradeGroups[gradeGroupsIndex].grades
                                      .isNotEmpty)
                                  ? const Text("|")
                                  : Container(),
                            ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
}
