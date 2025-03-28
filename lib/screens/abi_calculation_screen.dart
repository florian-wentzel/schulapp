import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/abi_calculator.dart';
import 'package:schulapp/code_behind/abi_calculator_manager.dart';
import 'package:schulapp/code_behind/grade.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/semester/school_grade_subject_screen.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class AbiCalculationScreen extends StatefulWidget {
  static const route = "/abi";

  const AbiCalculationScreen({super.key});

  @override
  State<AbiCalculationScreen> createState() => _AbiCalculationScreenState();
}

class _AbiCalculationScreenState extends State<AbiCalculationScreen> {
  static const double cornerRadius = 4;

  AbiCalculator calculator = AbiCalculatorManager().calculator;

  bool _showSimulatedGrades = true;
  Set<AbiDisplay> _abiDisplaySelection = {
    AbiDisplay.grade,
  };

  @override
  void initState() {
    MainApp.changeNavBarVisibility(false);

    super.initState();
  }

  @override
  void dispose() {
    MainApp.changeNavBarVisibility(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: AbiCalculationScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strAbiCalculator,
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Semester auswählen"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              4,
                              (index) {
                                final displayIndex = index + 1;

                                return ListTile(
                                  title: Text("$displayIndex. Semester"),
                                  onTap: () async {
                                    await _selectSemesterForCalculator(
                                        context, index,);

                                    if (!context.mounted) return;

                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                    setState(() {});
                    calculator.save();
                  },
                  child: Text("Semester Setzen"),
                ),
                ElevatedButton(
                  onPressed: _onExamPressed,
                  child: Text("Prüfung hinzufügen"),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _body(context),
    );
  }

  Future<void> _selectSemesterForCalculator(
      BuildContext context, int index) async {
    SchoolSemester? semester = await _showSelectSemesterBottomSheet(
      context,
      title: "Wähle Q${index + 1} aus",
    );

    calculator.setSemesterName(
      index,
      semester?.name,
    );
  }

  Widget _sectionValueIndecator({
    required String name,
    required int value,
    required int maxValue,
  }) {
    final progress = value / maxValue;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name),
                Text(
                  "$value / $maxValue",
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            LinearProgressIndicator(
              semanticsLabel: name,
              semanticsValue: value.toString(),
              value: progress,
              color: Color.lerp(
                Utils.getGradeColor(
                  0,
                ),
                Utils.getGradeColor(
                  15,
                ),
                progress,
              ),
            ),
          ],
        ),
      ),
    );
    // return Expanded(
    //   child: Container(
    //     padding: EdgeInsets.symmetric(
    //       horizontal: 8,
    //     ),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text("Block I"),
    //         Text(
    //           "356 / 720",
    //           style: TextStyle(fontSize: 12),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _body(BuildContext context) {
    final average = calculator.getAbiAverage(
      overrideIfSimulatedExists: _showSimulatedGrades,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          _customContainer(
            child: Column(
              spacing: 8,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Utils.getGradeColor(
                        15,
                      ),
                      Utils.getGradeColor(
                        1,
                      ),
                      //mindest durchschnitt ist 4.0
                      (average - 1) / 3.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(average.toStringAsPrecision(2)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionValueIndecator(
                      name: "Block I",
                      value: calculator.getSectionIPoints(
                        overrideIfSimulatedExists: _showSimulatedGrades,
                      ),
                      maxValue: calculator.maxSectionIPoints,
                    ),
                    _sectionValueIndecator(
                      name: "Block II",
                      value: calculator.getSectionIIPoints(
                          //brauch man nicht
                          // overrideIfSimulatedExists: _showSimulatedGrades,
                          ),
                      maxValue: calculator.maxSectionIIPoints,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _customContainer(
            child: Row(
              children: [
                Expanded(
                  child: Text("Simulierte Noten anzeigen"),
                ),
                Switch(
                  value: _showSimulatedGrades,
                  onChanged: (value) {
                    setState(() {
                      _showSimulatedGrades = value;
                    });
                  },
                ),
              ],
            ),
          ),
          _customContainer(
            child: SegmentedButton<AbiDisplay>(
              segments: const [
                ButtonSegment(
                  value: AbiDisplay.grade,
                  label: Text("Note"),
                ),
                ButtonSegment(
                  value: AbiDisplay.weights,
                  label: Text("Gewichtung"),
                ),
                ButtonSegment(
                  value: AbiDisplay.weightedPoints,
                  label: Text("Gewichtete-Punkte"),
                ),
              ],
              showSelectedIcon: false,
              emptySelectionAllowed: false,
              multiSelectionEnabled: false,
              onSelectionChanged: (selection) {
                setState(() {
                  _abiDisplaySelection = selection;
                });
              },
              selected: _abiDisplaySelection,
            ),
          ),
          _moduleBuilder(
            title: "Block I",
            subjects: calculator.allSubjects,
          ),
          _customContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        "Block II",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Fach",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            alignment: Alignment.centerRight,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          key: ValueKey(_abiDisplaySelection.first),
                          child: Text(
                            _getAbiDisplaySelectionText(),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: _generateExamRows(
                    calculator.getAbiExamSubjects(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _customContainer({
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: child,
    );
  }

  Widget _moduleBuilder({
    required String title,
    required List<String> subjects,
    bool showHjOneToFour = true,
  }) {
    return _customContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (showHjOneToFour)
                ...List.generate(
                  4,
                  (index) {
                    final displayIndex = index + 1;

                    return Expanded(
                      child: Tooltip(
                        message: calculator.getSemester(index)?.name ?? "",
                        child: InkWell(
                          onTap: () async {
                            await _selectSemesterForCalculator(context, index);
                            calculator.save();
                            setState(() {});
                          },
                          child: Text(
                            "Q$displayIndex",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          Column(
            children: _generateSubjectRows(subjects),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateSubjectRows(List<String> subjects) {
    return List.generate(
      subjects.length,
      (index) {
        final name = subjects[index];

        final highlight = index % 2 == 0;

        List<(String, Color?, VoidCallback)> textAndColors =
            _getTextAndColorsForSubject(name);

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: highlight ? Theme.of(context).highlightColor : null,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  name,
                ),
              ),
              ...List.generate(
                textAndColors.length,
                (index) {
                  final text = textAndColors[index].$1;
                  final color = textAndColors[index].$2;
                  final voidCallback = textAndColors[index].$3;
                  final showOutline =
                      calculator.getSimulatedSubject(index, name) != null &&
                          _showSimulatedGrades;

                  return Expanded(
                    child: InkWell(
                      onTap: voidCallback,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: FittedBox(
                          key: ValueKey(
                            "${_abiDisplaySelection.first}+$index+$showOutline+$text",
                          ),
                          fit: BoxFit.contain,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: showOutline
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius:
                                        BorderRadius.circular(cornerRadius),
                                  )
                                : null,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<SchoolSemester?> _showSelectSemesterBottomSheet(
    BuildContext context, {
    required String title,
  }) async {
    final semesters = TimetableManager().semesters;

    SchoolSemester? selectedSemester;

    final items = semesters
        .map(
          (semester) => (
            semester.name,
            () async {
              selectedSemester = semester;
            },
          ),
        )
        .toList();

    //TODO: remove already selected semesters

    await Utils.showStringAcionListBottomSheet(
      context,
      title: title,
      items: items,
    );

    return selectedSemester;
  }

  List<(String, Color?, VoidCallback)> _getTextAndColorsForSubject(
      String name) {
    final subjects = calculator.getSubjectsFromAllSemesters(
      name,
      overrideIfSimulatedExists: _showSimulatedGrades,
    );

    const notSetString = "x";

    switch (_abiDisplaySelection.first) {
      case AbiDisplay.grade:
        return List.generate(
          4,
          (index) {
            final subject = subjects[index];
            final gradeAverage = subject?.getGradeAverage().round();

            return (
              gradeAverage?.toString() ?? notSetString,
              Utils.getGradeColor(
                gradeAverage ?? 0,
              ),
              () => onGradePressed(name, subject, index),
            );
          },
        );
      case AbiDisplay.weights:
        return List.generate(
          4,
          (index) {
            final subject = subjects[index];

            var weightStr = subject?.weight.round().toString();

            if (weightStr != null) {
              weightStr = "x$weightStr";
            }

            return (
              weightStr ?? notSetString,
              subject == null ? Colors.red : null,
              () => onWeightPressed(name, subject, index),
            );
          },
        );
      case AbiDisplay.weightedPoints:
        return List.generate(
          4,
          (index) {
            final subject = subjects[index];

            if (subject == null) {
              return (
                notSetString,
                Colors.red,
                () => onGradePressed(name, subject, index),
              );
            }

            final weight = subject.weight.round();
            final gradeAverage = subject.getGradeAverage().round();

            return (
              (weight * gradeAverage).toString(),
              Utils.getGradeColor(
                gradeAverage,
              ),
              () => onGradePressed(name, subject, index),
            );
          },
        );
    }
  }

  Future<void> onGradePressed(
    String subjectName,
    SchoolGradeSubject? subject,
    int semesterIndex,
  ) async {
    SchoolSemester? semester = calculator.getSemester(semesterIndex);
    final whatToChange = await _showWhatToChangeDialog(
      semester == null,
      question:
          "Möchtest du die Note im Semester ändern, oder eine Simuliertenote nur für diesen Abitur Rechner erstellen?",
      semesterOption: "Note im Semester",
      simulatedOption: "Simulierte Note",
    );
    if (whatToChange == null) {
      return;
    }

    if (!mounted) return;

    if (whatToChange == WhatToChange.subject &&
        subject != null &&
        semester != null) {
      final endSetGrade = subject.endSetGrade;
      Grade? newGrade;

      if (endSetGrade == null) {
        newGrade = await SchoolGradeSubjectScreen.showAddNewGradeSheet(
          context,
        );
        if (newGrade == null) return;
      } else {
        newGrade = await SchoolGradeSubjectScreen.showEditGradeSheet(
          context,
          endSetGrade,
        );
      }

      subject.endSetGrade = newGrade;
      SaveManager().saveSemester(semester);
    } else if (whatToChange == WhatToChange.simulated) {
      final grade = calculator.getSimulatedSubjectGrade(
        semesterIndex,
        subjectName,
      );

      Grade? newGrade;

      if (grade == null) {
        newGrade = await SchoolGradeSubjectScreen.showAddNewGradeSheet(
          context,
        );

        if (newGrade == null) return;

        final weight = calculator
            .getSubjectFromSemester(
              semesterIndex,
              subjectName,
            )
            ?.weight;
        calculator.setSimulatedSubjectWeight(
          semesterIndex,
          subjectName,
          weight,
        );
      } else {
        newGrade = await SchoolGradeSubjectScreen.showEditGradeSheet(
          context,
          grade,
        );
      }

      calculator.setSimulatedSubjectGrade(
        semesterIndex,
        subjectName,
        newGrade,
      );
    }

    setState(() {});
  }

  Future<void> onWeightPressed(
    String subjectName,
    SchoolGradeSubject? subject,
    int semesterIndex,
  ) async {
    SchoolSemester? semester = calculator.getSemester(semesterIndex);
    final whatToChange = await _showWhatToChangeDialog(
      semester == null,
      question:
          "Möchtest du das Gewicht im Semester ändern, oder das der simulierten Note, dies nur für diesen Abitur Rechner erstellen?",
      semesterOption: "Gewicht im Semester",
      simulatedOption: "Simuliertes Gewicht",
    );

    if (whatToChange == null) {
      return;
    }

    if (!mounted) return;

    if (whatToChange == WhatToChange.subject &&
        subject != null &&
        semester != null) {
      final endSetGrade = subject.endSetGrade;
      Grade? newGrade;

      if (endSetGrade == null) {
        newGrade = await SchoolGradeSubjectScreen.showAddNewGradeSheet(
          context,
        );
        if (newGrade == null) return;
      } else {
        newGrade = await SchoolGradeSubjectScreen.showEditGradeSheet(
          context,
          endSetGrade,
        );
      }

      subject.endSetGrade = newGrade;
      SaveManager().saveSemester(semester);
    } else if (whatToChange == WhatToChange.simulated) {
      final weight =
          calculator.getSimulatedSubjectWeight(semesterIndex, subjectName);

      double? newWeight;

      if (weight == null) {
        newWeight = await Utils.showRangeInputDialog(
          context,
          minValue: 0,
          maxValue: 7,
          onlyIntegers: true,
          startValue: 1,
          distToSnapToPoint: 0.5,
          snapPoints: List.generate(
            8,
            (index) => index.toDouble(),
          ),
          title: "Gewicht einstellen",
        );

        if (newWeight == null) return;

        final grade = calculator
            .getSubjectFromSemester(
              semesterIndex,
              subjectName,
            )
            ?.endSetGrade;

        if (grade != null) {
          calculator.setSimulatedSubjectGrade(
            semesterIndex,
            subjectName,
            grade,
          );
        }
      } else {
        newWeight = await Utils.showRangeInputDialog(
          context,
          minValue: 0,
          maxValue: 7,
          onlyIntegers: true,
          showDeleteButton: true,
          startValue: weight,
          distToSnapToPoint: 0.5,
          snapPoints: List.generate(
            8,
            (index) => index.toDouble(),
          ),
          title: "Gewicht ändern",
        );
      }

      calculator.setSimulatedSubjectWeight(
        semesterIndex,
        subjectName,
        newWeight,
      );
    }

    setState(() {});
  }

  Future<WhatToChange?> _showWhatToChangeDialog(
    bool disableWhatToChangeSubject, {
    required String question,
    required String semesterOption,
    required String simulatedOption,
  }) async {
    return WhatToChange.simulated;

    // ignore: dead_code
    int selection = await Utils.show2OptionDialog(
      context,
      question: question,
      option1: semesterOption,
      option2: simulatedOption,
      disableOption1: disableWhatToChangeSubject,
    );

    if (selection == -1) return null;

    if (selection == 1) {
      return WhatToChange.subject;
    }
    return WhatToChange.simulated;
  }

  Future<void> _onExamPressed() async {
    const maxNameLength = SchoolSemester.maxNameLength;

    final headingText = "Prüfung hinzufügen";

    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    bool createPressed = false;
    String selectedSubject = "...${String.fromCharCode(0)}";
    int selectedWeight = 4;

    Grade? selectedGrade;

    Set<ExamType> examTypeSelection = {ExamType.written};

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                headingText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              _customContainer(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SegmentedButton(
                      segments: [
                        ButtonSegment(
                          value: ExamType.written,
                          label: Text(
                            SchoolExamSubject.examTypeToTranslatedString(
                              ExamType.written,
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: ExamType.verbal,
                          label: Text(
                            SchoolExamSubject.examTypeToTranslatedString(
                              ExamType.verbal,
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: ExamType.presentation,
                          label: Text(
                            SchoolExamSubject.examTypeToTranslatedString(
                              ExamType.presentation,
                            ),
                          ),
                        ),
                      ],
                      selected: examTypeSelection,
                      onSelectionChanged: (p0) {
                        examTypeSelection = p0;
                        setState.call(() {});
                      },
                      emptySelectionAllowed: false,
                      multiSelectionEnabled: false,
                      showSelectedIcon: false,
                    );
                  },
                ),
              ),
              _customContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Ausgewähltes Schulfach: "),
                    ),
                    StatefulBuilder(
                      builder: (context, builder) {
                        return ElevatedButton(
                          onPressed: () async {
                            final sub = await showSelectSubjectName(context);

                            if (sub == null) return;

                            selectedSubject = sub;
                            builder.call(() {});
                          },
                          child: Text(selectedSubject),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _customContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Gewichtung: "),
                    ),
                    StatefulBuilder(
                      builder: (context, builder) {
                        return ElevatedButton(
                          onPressed: () async {
                            final weight = await Utils.showRangeInputDialog(
                              context,
                              minValue: 0,
                              maxValue: 7,
                              onlyIntegers: true,
                              startValue: 4,
                              distToSnapToPoint: 0.5,
                              snapPoints: List.generate(
                                8,
                                (index) => index.toDouble(),
                              ),
                              title: "Gewicht einstellen",
                            );

                            if (weight == null) return;

                            selectedWeight = weight.toInt();

                            builder.call(() {});
                          },
                          child: Text(selectedWeight.toString()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _customContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Note: "),
                    ),
                    StatefulBuilder(
                      builder: (context, builder) {
                        return ElevatedButton(
                          onPressed: () async {
                            Grade? g = selectedGrade;
                            if (g == null) {
                              g = await SchoolGradeSubjectScreen
                                  .showAddNewGradeSheet(
                                context,
                              );
                            } else {
                              g = await SchoolGradeSubjectScreen
                                  .showEditGradeSheet(
                                context,
                                g,
                              );
                            }

                            if (g == null) return;

                            selectedGrade = g;

                            builder.call(() {});
                          },
                          child: Text(
                            selectedGrade?.grade.toString() ?? "...",
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  createPressed = true;
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizationsManager.localizations.strCreate,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!createPressed) return;

    if (selectedSubject.contains(String.fromCharCode(0))) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: "Du musst ein Fach auswählen",
          type: InfoType.error,
        );
      }
      return;
    }

    final g = selectedGrade;
    if (g == null) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: "Du musst eine Note auswählen",
          type: InfoType.error,
        );
      }
      return;
    }

    final examSubject = SchoolExamSubject(
      grade: g,
      connectedSubjectName: selectedSubject,
      examType: examTypeSelection.first,
      weight: selectedWeight,
    );

    calculator.addExamSubject(examSubject);

    calculator.save();

    setState(() {});
  }

  Future<ExamType?> showSelectExamType(
    BuildContext context, {
    ExamType? defaultType = null,
  }) async {
    Set<ExamType> examTypeSelection = {defaultType ?? ExamType.written};
    bool cancelPressed = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Prüfungsart Setzen"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: ExamType.written,
                        label: Text(
                          SchoolExamSubject.examTypeToTranslatedString(
                            ExamType.written,
                          ),
                        ),
                      ),
                      ButtonSegment(
                        value: ExamType.verbal,
                        label: Text(
                          SchoolExamSubject.examTypeToTranslatedString(
                            ExamType.verbal,
                          ),
                        ),
                      ),
                      ButtonSegment(
                        value: ExamType.presentation,
                        label: Text(
                          SchoolExamSubject.examTypeToTranslatedString(
                            ExamType.presentation,
                          ),
                        ),
                      ),
                    ],
                    selected: examTypeSelection,
                    onSelectionChanged: (p0) {
                      examTypeSelection = p0;
                      setState.call(() {});
                    },
                    emptySelectionAllowed: false,
                    multiSelectionEnabled: false,
                    showSelectedIcon: false,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                cancelPressed = true;
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizationsManager.localizations.strOK,
              ),
            ),
          ],
        );
      },
    );

    if (cancelPressed) {
      return defaultType;
    }

    return examTypeSelection.first;
  }

  Future<String?> showSelectSubjectName(BuildContext context) async {
    String? selectedSubjectName;

    final items = calculator.allSubjects;

    await Utils.showStringAcionListBottomSheet(
      context,
      items: items
          .map(
            (e) => (
              e,
              () async {
                selectedSubjectName = e;
              },
            ),
          )
          .toList(),
    );

    return selectedSubjectName;
  }

  List<Widget> _generateExamRows(List<SchoolExamSubject> exams) {
    return List.generate(
      exams.length,
      (index) {
        final exam = exams[index];
        final highlight = index % 2 == 0;
        (String, Color?, VoidCallback) selectedItem;

        void onGradePressed() async {
          final grade = exam.grade;

          Grade? newGrade;

          newGrade = await SchoolGradeSubjectScreen.showEditGradeSheet(
            context,
            grade,
          );

          bool delete = false;

          if (newGrade == null && mounted) {
            delete = await Utils.showBoolInputDialog(
              context,
              question: "Möchtest du die Prüfung löschen?",
              showYesAndNoInsteadOfOK: true,
              markTrueAsRed: true,
            );
          }

          if (delete) {
            calculator.removeAbiExamSubjects(exam);
            setState(() {});
            return;
          }
          if (newGrade != null) {
            exam.grade = newGrade;
          }

          setState(() {});
        }

        switch (_abiDisplaySelection.first) {
          case AbiDisplay.grade:
            selectedItem = (
              exam.grade.grade.toString(),
              Utils.getGradeColor(exam.grade.grade),
              onGradePressed,
            );
            break;
          case AbiDisplay.weights:
            selectedItem = (
              "x${exam.weight.toString()}",
              null,
              () async {
                final weight = exam.weight;

                double? newWeight;

                newWeight = await Utils.showRangeInputDialog(
                  context,
                  minValue: 0,
                  maxValue: 7,
                  onlyIntegers: true,
                  showDeleteButton: true,
                  startValue: weight.toDouble(),
                  distToSnapToPoint: 0.5,
                  snapPoints: List.generate(
                    8,
                    (index) => index.toDouble(),
                  ),
                  title: "Gewicht anpassen",
                );

                bool delete = false;

                if (newWeight == null && mounted) {
                  delete = await Utils.showBoolInputDialog(
                    context,
                    question: "Möchtest du die Prüfung löschen?",
                    showYesAndNoInsteadOfOK: true,
                    markTrueAsRed: true,
                  );
                }

                if (delete) {
                  calculator.removeAbiExamSubjects(exam);
                  setState(() {});
                  return;
                }
                if (newWeight != null) {
                  exam.weight = newWeight.toInt();
                }

                setState(() {});
              },
            );
            break;
          case AbiDisplay.weightedPoints:
            selectedItem = (
              exam.getWeightedPoints().toString(),
              Utils.getGradeColor(exam.grade.grade),
              onGradePressed,
            );
            break;
        }

        final selectedItemText = selectedItem.$1;
        final selectedItemTextColor = selectedItem.$2;
        final onTap = selectedItem.$3;

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: highlight ? Theme.of(context).highlightColor : null,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final type = await showSelectExamType(
                      context,
                      defaultType: exam.examType,
                    );

                    if (type == null) return;

                    exam.examType = type;
                    setState(() {});
                    calculator.save();
                  },
                  child: Text(
                    SchoolExamSubject.examTypeToTranslatedString(
                      exam.examType,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final sub = await showSelectSubjectName(context);

                    if (sub == null) return;

                    exam.connectedSubjectName = sub;
                    setState(() {});
                    calculator.save();
                  },
                  child: Text(
                    exam.connectedSubjectName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      alignment: Alignment.centerRight,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    key: ValueKey(_abiDisplaySelection.first),
                    width: double.infinity,
                    child: InkWell(
                      onTap: onTap,
                      child: Text(
                        selectedItemText,
                        style: TextStyle(
                          color: selectedItemTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAbiDisplaySelectionText() {
    final selection = _abiDisplaySelection.first;
    switch (selection) {
      case AbiDisplay.grade:
        return "Note";
      case AbiDisplay.weights:
        return "Gewichtung";
      case AbiDisplay.weightedPoints:
        return "Punkte";
    }
  }
}

enum WhatToChange {
  subject,
  simulated,
}

enum AbiDisplay {
  grade,
  weights,
  weightedPoints,
}
