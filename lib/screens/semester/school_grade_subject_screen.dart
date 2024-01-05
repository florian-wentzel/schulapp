import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/semester/edit_school_grade_subject_screen.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/school_grade_subject_widget.dart';

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
            const Text("Subject: "),
            Text(widget.subject.name),
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
                isFlightShuttleBuilder: true,
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
          child: const Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Icon(Icons.edit),
              SizedBox(
                height: 12,
              ),
              Text("Edit Subject"),
              SizedBox(
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
              question: "Do you want to delete: ${widget.subject.name}?",
            );

            if (!value) return;

            bool removed = widget.semester.removeSubject(widget.subject);

            setState(() {});

            SaveManager().saveSemester(widget.semester);

            if (!mounted) return;

            if (removed) {
              Utils.showInfo(
                context,
                msg: "$name was successfully removed!",
                type: InfoType.success,
              );
            } else {
              Utils.showInfo(
                context,
                msg: "$name could not be removed!",
                type: InfoType.error,
              );
            }

            Navigator.of(context).pop();
          },
          child: const Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(
                height: 12,
              ),
              Text("Delete Subject"),
              SizedBox(
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
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gg.name,
                style: Theme.of(context).textTheme.titleLarge,
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
                  'Edit Grade',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Extra info",
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
                      "Date:",
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
                            '$grade',
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
                  child: const Text("OK"),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
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
                  'Edit Grade',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Extra info",
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
                      "Date:",
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
                            '$grade',
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
                  child: const Text("Cancel"),
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

    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
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
        ),
        GestureDetector(
          child: Text(
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
              // decoration: TextDecoration.underline,
              fontSize: 42.0,
              fontWeight: FontWeight.bold,
            ),
            gg.name,
          ),
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
              color: Utils.getGradeColor(grade.grade),
            ),
            child: Center(
              child: Text(
                grade.toString(),
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
          visible: grade.info.isNotEmpty,
          child: Text(
            grade.info,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: 42.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          Utils.dateToString(grade.date),
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
}
