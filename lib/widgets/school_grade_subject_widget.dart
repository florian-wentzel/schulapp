import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_semester.dart';

// ignore: must_be_immutable
class SchoolGradeSubjectWidget extends StatelessWidget {
  SchoolGradeSubject subject;
  SchoolSemester semester;

  SchoolGradeSubjectWidget({
    super.key,
    required this.subject,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            subject.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SingleChildScrollView(
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
                      subject.gradeGroups[gradeGroupsIndex].grades[gradeIndex]
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
        ],
      ),
    );
  }
}
