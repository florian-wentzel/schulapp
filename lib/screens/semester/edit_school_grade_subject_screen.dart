import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/date_selection_button.dart';

// ignore: must_be_immutable
class EditSchoolGradeSubjectScreen extends StatefulWidget {
  SchoolGradeSubject subject;
  SchoolSemester semester;

  EditSchoolGradeSubjectScreen({
    super.key,
    required this.subject,
    required this.semester,
  });

  @override
  State<EditSchoolGradeSubjectScreen> createState() =>
      _EditSchoolGradeSubjectScreenState();
}

class _EditSchoolGradeSubjectScreenState
    extends State<EditSchoolGradeSubjectScreen> {
  int currPercentageChangingGroupIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Edit: "),
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
          Center(
            child: InkWell(
              onTap: () async {
                String? name = await Utils.showStringInputDialog(
                  context,
                  hintText: "Subject name",
                );
                if (name == null) return;
                if (name.isEmpty) return;

                widget.subject.name = name;
                setState(() {});
              },
              child: Hero(
                tag: widget.subject,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.subject.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  GradeGroup? gradeGroup =
                      await _showAddGradeGroupSheet(context);
                  if (gradeGroup == null) return;

                  widget.subject.addGradeGroup(gradeGroup);

                  setState(() {});
                },
                child: const Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Icon(Icons.add),
                    SizedBox(
                      height: 12,
                    ),
                    Text("Add Gradegroup"),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String name =
                      String.fromCharCodes(widget.subject.name.codeUnits);

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
          ),
        ],
      ),
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
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: gg.percent.toDouble(),
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      gg.percent = value.toInt();

                      currPercentageChangingGroupIndex = index + 1;

                      currPercentageChangingGroupIndex =
                          currPercentageChangingGroupIndex %
                              widget.subject.gradeGroups.length;

                      widget.subject.adaptPercentage(
                          gg, currPercentageChangingGroupIndex);

                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    bool awnser = await Utils.showBoolInputDialog(
                      context,
                      question: "Do you want to delete: ${gg.name}?",
                    );
                    if (!awnser) return;

                    String name = String.fromCharCodes(gg.name.codeUnits);

                    bool removed = widget.subject.removeGradegroup(gg);
                    setState(() {});
                    SaveManager().saveSemester(widget.semester);

                    if (!mounted) return;

                    if (removed) {
                      Utils.showInfo(
                        context,
                        msg: "$name successfully removed!",
                        type: InfoType.success,
                      );
                    } else {
                      Utils.showInfo(
                        context,
                        msg: "$name could not be removed!",
                        type: InfoType.error,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Future<GradeGroup?> _showAddGradeGroupSheet(BuildContext context) async {
    const maxNameLength = GradeGroup.maxNameLength;

    TextEditingController nameController = TextEditingController();

    bool createPressed = false;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Add Gradegroup',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
                autofocus: true,
                maxLines: 1,
                maxLength: maxNameLength,
                textAlign: TextAlign.center,
                controller: nameController,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  createPressed = true;
                  Navigator.of(context).pop();
                },
                child: const Text("Create"),
              ),
            ],
          ),
        );
      },
    );

    if (!createPressed) return null;
    String name = nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: "Name can not be empty!",
          type: InfoType.error,
        );
      }
      return null;
    }

    return GradeGroup(
      name: name,
      percent: 50,
      grades: [],
    );
  }
}
