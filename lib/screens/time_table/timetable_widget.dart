import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/time_table.dart';
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
    Timetable tt = widget.timetable;
    List<DataColumn> dataColumn = List.generate(
      tt.schoolDays.length,
      (index) => DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              tt.schoolDays[index].name,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    //füge Zeiten hinzu
    dataColumn.insert(
      0,
      const DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              "Times",
              textAlign: TextAlign.center,
            ),
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
                onTap: () async {
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
                    flightShuttleBuilder: (context, animation, __, ___, ____) {
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
                      width: 100,
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
                          Text(
                            lesson.room,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
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
class CustomPopUpShowLesson extends StatelessWidget {
  String heroString;

  CustomPopUpShowLesson({super.key, required this.heroString});

  @override
  Widget build(BuildContext context) {
    return CustomPopUp(
      heroObject: heroString,
      color: Theme.of(context).cardColor,
      body: _body(),
    );
  }

  Widget _body() {
    return const Placeholder();
  }
}
