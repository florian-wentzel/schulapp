import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/time_table.dart';

// ignore: must_be_immutable
class TimetableDroptarget extends StatefulWidget {
  TimeTable timeTable;
  TimetableDroptarget({super.key, required this.timeTable});

  @override
  State<TimetableDroptarget> createState() => _TimetableDroptargetState();
}

class _TimetableDroptargetState extends State<TimetableDroptarget> {
  @override
  Widget build(BuildContext context) {
    TimeTable tt = widget.timeTable;
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

    List<DataRow> dataRow = List.generate(
      tt.maxLessonCount,
      (rowIndex) {
        return DataRow(
          // selected: rowIndex == 2,
          cells: List.generate(
            tt.schoolDays.length,
            (cellIndex) {
              final heroString = "$rowIndex:$cellIndex";
              final schoolDay = tt.schoolDays[cellIndex];
              final lesson = schoolDay.lessons[rowIndex];

              return DataCell(
                onTap: () {
                  _showPopUp(context, lesson, schoolDay, heroString);
                },
                DragTarget(
                  onWillAccept: (SchoolLessonPrefab? schoolLessonPrefab) {
                    return schoolLessonPrefab != null;
                  },
                  onAccept: (SchoolLessonPrefab schoolLessonPrefab) {
                    lesson.setFromPrefab(schoolLessonPrefab);
                  },
                  builder: (context, accepted, rejected) {
                    const targetAlpha = 200;
                    return Center(
                      child: Hero(
                        tag: heroString,
                        flightShuttleBuilder:
                            (context, animation, __, ___, ____) {
                          return Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: lesson.color.withAlpha((255 -
                                      (1 - animation.value) *
                                          (255 - targetAlpha))
                                  .toInt()),
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                          child: Center(
                            child: Text(
                              lesson.name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
        columnSpacing: 50,
        horizontalMargin: 25,
      ),
    );
  }

  void _showPopUp(
    BuildContext context,
    SchoolLesson lesson,
    SchoolDay day,
    String heroString,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => TestPopUp(
          heroString: heroString,
          schoolDay: day,
          schoolLesson: lesson,
        ),
        barrierDismissible: true,
        fullscreenDialog: true, // Set this to true for a pop-up style
      ),
    );

    // showCupertinoModalPopup(
    //   context: context,
    //   builder: (context) {
    //     return Container();
    //   },
    // );
  }

  // void _showPopUp(BuildContext context, String lessonName, String dayName,
  //     String heroString) {
  //   // final overlay = Overlay.of(context);
  //   OverlayEntry? entry;
  //   showAdaptiveDialog(
  //     context: context,
  //     builder: (context) {
  //       // final width = MediaQuery.of(context).size.width * 0.5;
  //       // final height = MediaQuery.of(context).size.height * 0.5;
  //       return Hero(
  //         tag: heroString,
  //         child: Dialog(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(lessonName),
  //                 const SizedBox(height: 8),
  //                 Text('dayName: $dayName'),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //   entry = OverlayEntry(
  //     builder: (context) => Positioned(
  //       top: 0,
  //       left: 0,
  //       child: GestureDetector(
  //         onTap: () {
  //           entry?.remove();
  //         },
  //         child: Material(
  //           color: Colors.transparent,
  //           child: Container(
  //             width: MediaQuery.of(context).size.width,
  //             height: MediaQuery.of(context).size.height,
  //             color: Colors.transparent,
  //             child: Center(
  //               child: Card(
  //                 elevation: 5.0,
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Hero(
  //                         tag: heroString,
  //                         child: Text(lessonName),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Text('dayName: $dayName'),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  //   // overlay.insert(entry);
  // }
}

class TestPopUp extends StatefulWidget {
  SchoolLesson schoolLesson;
  SchoolDay schoolDay;
  String heroString;
  TestPopUp({
    super.key,
    required this.heroString,
    required this.schoolDay,
    required this.schoolLesson,
  });

  @override
  State<TestPopUp> createState() => _TestPopUpState();
}

class _TestPopUpState extends State<TestPopUp> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 0.7,
        child: Hero(
          tag: widget.heroString,
          child: Container(
            decoration: BoxDecoration(
              color: widget.schoolLesson.color.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
            ),
            // width: MediaQuery.of(context).size.width * 0.5,
            // height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Half Screen'),
    //   ),
    //   body: SizedBox(
    //     height: MediaQuery.of(context).size.height *
    //         0.5, // Set to 50% of screen height
    //     child: Center(
    //       child: ElevatedButton(
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //         child: const Text('Close'),
    //       ),
    //     ),
    //   ),
    // );
  }
}
