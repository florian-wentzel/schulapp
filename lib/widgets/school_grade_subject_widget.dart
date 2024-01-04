import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';

// ignore: must_be_immutable
class SchoolGradeSubjectWidget extends StatelessWidget {
  SchoolGradeSubject subject;
  SchoolSemester semester;
  bool isFlightShuttleBuilder;

  SchoolGradeSubjectWidget({
    super.key,
    required this.subject,
    required this.semester,
    this.isFlightShuttleBuilder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                subject.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Visibility(
                visible: !isFlightShuttleBuilder,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 16,
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
            width: isFlightShuttleBuilder ? 30 : null,
            height: isFlightShuttleBuilder ? 30 : null,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Utils.getGradeColor(subject.getGradeAverage().toInt()),
            ),
            child: Center(
              child: Text(
                subject.getGradeAverageString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
