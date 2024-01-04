import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/school_grade_subject_widget.dart';

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
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  return SchoolGradeSubjectWidget(
                    semester: widget.semester,
                    subject: widget.subject,
                    isFlightShuttleBuilder: true,
                  );
                },
                child: SchoolGradeSubjectWidget(
                  semester: widget.semester,
                  subject: widget.subject,
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
              InkWell(
                onTap: () async {
                  String? newName = await Utils.showStringInputDialog(
                    context,
                    hintText: "Name",
                    autofocus: true,
                    maxInputLength: GradeGroup.maxNameLength,
                  );

                  if (newName == null) return;

                  gg.name = newName;
                  setState(() {});
                },
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
