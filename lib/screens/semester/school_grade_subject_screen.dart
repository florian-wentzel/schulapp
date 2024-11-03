import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/grade.dart';
import 'package:schulapp/code_behind/grade_group.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/semester/edit_school_grade_subject_screen.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/semester/school_grade_subject_widget.dart';
import 'package:fl_chart/fl_chart.dart';

// ignore: must_be_immutable
class SchoolGradeSubjectScreen extends StatefulWidget {
  SchoolGradeSubject subject;
  SchoolSemester semester;

  SchoolGradeSubjectScreen({
    super.key,
    required this.subject,
    required this.semester,
  });

  @override
  State<SchoolGradeSubjectScreen> createState() =>
      _SchoolGradeSubjectScreenState();
}

class _SchoolGradeSubjectScreenState extends State<SchoolGradeSubjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              AppLocalizationsManager.localizations.strSchoolGradeSubjectX(
                widget.subject.name,
              ),
            ),
          ],
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Hero(
            tag: widget.subject,
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return SchoolGradeSubjectWidget(
                subject: widget.subject,
                semester: widget.semester,
              );
            },
            child: Center(
              child: SchoolGradeSubjectWidget(
                subject: widget.subject,
                semester: widget.semester,
              ),
            ),
          ),
          ...List.generate(
            widget.subject.gradeGroups.length,
            _gradeGroupBuilder,
          ),
          ...[_setGradeContainer()],
          SizedBox(
            height: 300,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(
                    _createLineChartData(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          _bottomRow(),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  LineChartData _createLineChartData() {
    List<FlSpot> spots = [];
    //gradeGroupIndex, grade
    List<(int, Grade)> grades = [];

    SchoolGradeSubject calcSubject = SchoolGradeSubject(
      name: "calcSubject",
      gradeGroups: List.generate(
        widget.subject.gradeGroups.length,
        (index) => GradeGroup(
          name: widget.subject.gradeGroups[index].name,
          percent: widget.subject.gradeGroups[index].percent,
          grades: [],
        ),
      ),
    );

    for (int gradeGroupIndex = 0;
        gradeGroupIndex < widget.subject.gradeGroups.length;
        gradeGroupIndex++) {
      GradeGroup gg = widget.subject.gradeGroups[gradeGroupIndex];

      for (Grade grade in gg.grades) {
        grades.add((gradeGroupIndex, grade));
      }
    }

    grades.sort(
      (a, b) => a.$2.date.compareTo(b.$2.date),
    );

    for (int i = 0; i < grades.length; i++) {
      final gradeTuple = grades[i];
      int gradeGroupIndex = gradeTuple.$1;
      Grade grade = gradeTuple.$2;
      calcSubject.gradeGroups[gradeGroupIndex].grades.add(grade);
      final y = calcSubject.getGradeAverage();
      spots.add(
        FlSpot((i + 1).toDouble(), y),
      );
    }

    Grade? endSetGrade = widget.subject.endSetGrade;
    if (endSetGrade != null) {
      spots.add(
        FlSpot((spots.length + 1).toDouble(), endSetGrade.grade.toDouble()),
      );
    }
    // const darkModeColor = Color(0xff37434d);
    // const lightModeColor = Color(0xff37434d);

    // final isLightMode =
    //     MediaQuery.of(context).platformBrightness == Brightness.light;

    // final currLineColor = isLightMode ? lightModeColor : darkModeColor;

    return LineChartData(
      // lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 5,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: 1,
            reservedSize: 30,
            showTitles: true,
          ),
        ),
      ),
      minY: 0,
      maxY: 15,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
        ),
      ],
    );
  }

  Widget _bottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditSchoolGradeSubjectScreen(
                  subject: widget.subject,
                  semester: widget.semester,
                ),
              ),
            );

            setState(() {});

            SaveManager().saveSemester(widget.semester);
          },
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              const Icon(Icons.edit),
              const SizedBox(
                height: 12,
              ),
              Text(AppLocalizationsManager.localizations.strEditSubject),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String name = String.fromCharCodes(widget.subject.name.codeUnits);

            bool value = await Utils.showBoolInputDialog(
              context,
              question:
                  AppLocalizationsManager.localizations.strDoYouWantToDeleteX(
                widget.subject.name,
              ),
              showYesAndNoInsteadOfOK: true,
              markTrueAsRed: true,
            );

            if (!value) return;

            bool removed = widget.semester.removeSubject(widget.subject);

            setState(() {});

            SaveManager().saveSemester(widget.semester);

            if (!mounted) return;

            if (removed) {
              Utils.showInfo(
                context,
                msg: AppLocalizationsManager.localizations
                    .strSuccessfullyRemoved(
                  name,
                ),
                type: InfoType.success,
              );
            } else {
              Utils.showInfo(
                context,
                msg: AppLocalizationsManager.localizations.strCouldNotBeRemoved(
                  name,
                ),
                type: InfoType.error,
              );
            }

            Navigator.of(context).pop();
          },
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(AppLocalizationsManager.localizations.strDeleteSubject),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradeGroupBuilder(int index) {
    GradeGroup gg = widget.subject.gradeGroups[index];
    return Container(
      width: MediaQuery.of(context).size.width,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  gg.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                "${gg.percent} %",
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              primary: false,
              scrollDirection: Axis.horizontal,
              child: Row(
                //Wenn man ohne die 0  gleiche größe bekommen möchte kann vielleicht IntrinsicWidth widget helfen
                children: List.generate(
                  gg.grades.length,
                  (gradeNumberItemIndex) =>
                      _gradeNumberItem(gg, gradeNumberItemIndex),
                )..add(
                    IconButton(
                      onPressed: () async {
                        Grade? grade = await _showAddNewGradeSheet();
                        if (grade == null) return;
                        gg.grades.add(grade);
                        setState(() {});
                        SaveManager().saveSemester(widget.semester);
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeNumberItem(GradeGroup gg, int index) {
    Grade grade = gg.grades[index];
    return InkWell(
      onTap: () async {
        Utils.showCustomPopUp(
          context: context,
          heroObject: grade,
          body: _gradeNumberItemPopUp(gg, index),
        );
      },
      child: Hero(
        tag: grade,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Utils.getGradeColor(grade.grade),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(grade.toString()),
          ),
        ),
        flightShuttleBuilder: (context, animation, __, ___, ____) {
          const targetAlpha = 220;

          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: ColorTween(
                    begin: Utils.getGradeColor(grade.grade),
                    end: Theme.of(context).cardColor.withAlpha(targetAlpha),
                  ).lerp(animation.value),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static const maxInfoLength = 50;
  Future<Grade?> _showEditGradeSheet(Grade grade) async {
    TextEditingController infoController = TextEditingController();
    infoController.text = grade.info;

    DateSelectionButtonController dateController =
        DateSelectionButtonController(date: grade.date.copyWith());

    bool deletePressed = false;

    int selectedGrade = -1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: 0.5,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizationsManager.localizations.strEditGrade,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizationsManager.localizations.strExtraInfo,
                  ),
                  maxLines: 1,
                  maxLength: maxInfoLength,
                  textAlign: TextAlign.center,
                  controller: infoController,
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizationsManager.localizations.strDate}:",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DateSelectionButton(
                        controller: dateController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap:
                      true, // Ensure GridView doesn't take more space than needed
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: 16, // Including 0 to 15
                  itemBuilder: (context, index) {
                    int grade = 15 - index; // Numbers from 15 to 0
                    return InkWell(
                      onTap: () {
                        selectedGrade = grade;
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Utils.getGradeColor(grade),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            GradingSystemManager.convertGradeToSelectedSystem(
                              grade,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    selectedGrade = grade.grade;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strOK,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strCancel,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                IconButton(
                  onPressed: () {
                    deletePressed = true;
                    Navigator.of(context).pop();
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
      },
    );

    if (deletePressed) return null;

    if (selectedGrade < 0 || selectedGrade > 15) return grade;

    return Grade(
      grade: selectedGrade,
      date: dateController.date,
      info: infoController.text.trim(),
    );
  }

  Future<Grade?> _showAddNewGradeSheet() async {
    TextEditingController infoController = TextEditingController();

    DateSelectionButtonController dateController =
        DateSelectionButtonController(date: DateTime.now());

    int selectedGrade = -1;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: 0.5,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizationsManager.localizations.strAddGrade,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizationsManager.localizations.strExtraInfo,
                  ),
                  maxLines: 1,
                  maxLength: maxInfoLength,
                  textAlign: TextAlign.center,
                  controller: infoController,
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizationsManager.localizations.strDate}:",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DateSelectionButton(
                        controller: dateController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap:
                      true, // Ensure GridView doesn't take more space than needed
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: 16, // Including 0 to 15
                  itemBuilder: (context, index) {
                    int grade = 15 - index; // Numbers from 15 to 0
                    return InkWell(
                      onTap: () {
                        selectedGrade = grade;
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Utils.getGradeColor(grade),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            GradingSystemManager.convertGradeToSelectedSystem(
                              grade,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizationsManager.localizations.strCancel,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedGrade < 0 || selectedGrade > 15) return null;

    return Grade(
      grade: selectedGrade,
      date: dateController.date,
      info: infoController.text.trim(),
    );
  }

  Widget _gradeNumberItemPopUp(GradeGroup gg, int index) {
    Grade grade = gg.grades[index];

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);

                  //warten damit animation funktioniert
                  await Future.delayed(
                    const Duration(milliseconds: 500),
                  );

                  gg.grades.removeAt(index);
                  setState(() {});
                  SaveManager().saveSemester(widget.semester);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Grade? newGrade = await _showEditGradeSheet(grade);
                  if (newGrade == null) {
                    gg.grades.removeAt(index);
                  } else {
                    gg.grades[index] = newGrade;
                  }
                  setState(() {});
                  SaveManager().saveSemester(widget.semester);
                },
                icon: const Icon(
                  Icons.edit,
                  // color: Colors.red,
                  size: 32,
                ),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    gg.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.white,
                      // decoration: TextDecoration.underline,
                      fontSize: 42.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(16),
                      shape: BoxShape.circle,
                      color: Utils.getGradeColor(grade.grade),
                    ),
                    child: Center(
                      child: Text(
                        grade.toString(),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Visibility(
                    visible: grade.info.isNotEmpty,
                    child: Text(
                      grade.info,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.white,
                        fontSize: 42.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    Utils.dateToString(grade.date),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.white,
                      fontSize: 42.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.check,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }

  Widget _setGradeNumberItemPopUp(Grade? grade) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () async {
                Navigator.pop<Grade?>(context, null);

                //warten damit animation funktioniert
                await Future.delayed(
                  const Duration(milliseconds: 500),
                );

                setState(() {});
                SaveManager().saveSemester(widget.semester);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 32,
              ),
            ),
            // IconButton(
            //   onPressed: () async {
            //     Navigator.pop(context);
            //     Grade? newGrade;
            //     if (grade == null) {
            //       newGrade = await _showAddNewGradeSheet();
            //     } else {
            //       newGrade = await _showEditGradeSheet(grade!);
            //     }
            //     if (newGrade == null) {
            //       grade = null;
            //     } else {
            //       grade = newGrade;
            //     }
            //     setState(() {});
            //     SaveManager().saveSemester(widget.semester);
            //   },
            //   icon: const Icon(
            //     Icons.edit,
            //     // color: Colors.red,
            //     size: 32,
            //   ),
            // ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(16),
              shape: BoxShape.circle,
              color: Utils.getGradeColor(grade?.grade ?? -1),
            ),
            child: Center(
              child: Text(
                grade?.toString() ?? " - ",
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(
          height: 12,
        ),
        Visibility(
          visible: grade?.info.isNotEmpty ?? false,
          child: Text(
            grade?.info ?? "",
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: 42.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          Utils.dateToString(grade?.date ?? DateTime(0)),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            fontSize: 42.0,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(
          flex: 2,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.check,
            size: 42,
          ),
        ),
      ],
    );
  }

  Widget _setGradeContainer() {
    String endSetGradeString = " – ";
    final endSetGrade = widget.subject.endSetGrade;
    if (endSetGrade != null) {
      endSetGradeString = GradingSystemManager.convertGradeToSelectedSystem(
        endSetGrade.grade,
      );
    }
    return InkWell(
      onTap: () async {
        Grade? newGrade = await _showAddNewGradeSheet();
        if (newGrade == null) return;

        widget.subject.endSetGrade = newGrade;
        setState(() {});
        SaveManager().saveSemester(widget.semester);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizationsManager.localizations.strSetEndGrade,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                primary: false,
                scrollDirection: Axis.horizontal,
                child: InkWell(
                  onTap: endSetGrade != null
                      ? () async {
                          Grade? newGrade = await Utils.showCustomPopUp<Grade?>(
                            context: context,
                            heroObject: endSetGrade,
                            body: _setGradeNumberItemPopUp(
                              widget.subject.endSetGrade,
                            ),
                          );
                          widget.subject.endSetGrade = newGrade;
                        }
                      : null,
                  child: Hero(
                    tag: endSetGrade ?? "",
                    flightShuttleBuilder: (context, animation, __, ___, ____) {
                      const targetAlpha = 220;

                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: ColorTween(
                                begin: Utils.getGradeColor(
                                    endSetGrade?.grade ?? -1),
                                end: Theme.of(context)
                                    .cardColor
                                    .withAlpha(targetAlpha),
                              ).lerp(animation.value),
                            ),
                          );
                        },
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Utils.getGradeColor(endSetGrade?.grade ?? -1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(endSetGradeString),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
