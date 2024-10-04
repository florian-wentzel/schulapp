import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/grade_group.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_grade_subject.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/semester/school_grade_subject_widget.dart';

class EditSchoolGradeSubjectScreen extends StatefulWidget {
  final SchoolGradeSubject subject;
  final SchoolSemester semester;

  const EditSchoolGradeSubjectScreen({
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
        title: Text(
          AppLocalizationsManager.localizations.strEditSchoolGradeSubject,
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
                  hintText:
                      AppLocalizationsManager.localizations.strSubjectName,
                  initText: widget.subject.name,
                  maxInputLength: SchoolGradeSubject.maxNameLength,
                  autofocus: true,
                );

                if (name == null) return;
                name = name.trim();

                if (name.isEmpty) {
                  if (mounted) {
                    Utils.showInfo(
                      context,
                      msg: AppLocalizationsManager
                          .localizations.strNameCanNotBeEmpty,
                      type: InfoType.error,
                    );
                  }
                  return;
                }

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
          _weightWidget(),
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
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    const Icon(Icons.add),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                        AppLocalizationsManager.localizations.strAddGradegroup),
                    const SizedBox(
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
              InkWell(
                onTap: () async {
                  String? newName = await Utils.showStringInputDialog(
                    context,
                    hintText: AppLocalizationsManager.localizations.strName,
                    initText: gg.name,
                    autofocus: true,
                    maxInputLength: GradeGroup.maxNameLength,
                  );

                  if (newName == null) return;
                  newName = newName.trim();

                  if (newName.isEmpty) {
                    if (mounted) {
                      Utils.showInfo(
                        context,
                        msg: AppLocalizationsManager
                            .localizations.strNameCanNotBeEmpty,
                        type: InfoType.error,
                      );
                    }
                    return;
                  }

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
                      question: AppLocalizationsManager.localizations
                          .strDoYouWantToDeleteX(
                        gg.name,
                      ),
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
                        msg: AppLocalizationsManager.localizations
                            .strSuccessfullyRemoved(
                          name,
                        ),
                        type: InfoType.success,
                      );
                    } else {
                      Utils.showInfo(
                        context,
                        msg: AppLocalizationsManager.localizations
                            .strCouldNotBeRemoved(
                          name,
                        ),
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

  final List<double> _weightSnapPoints = [
    0,
    0.33,
    0.5,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ];

  Widget _weightWidget() {
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
              Text(
                AppLocalizationsManager.localizations.strWeight,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "${widget.subject.weight.roundIfInt()}x",
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
                    value: widget.subject.weight,
                    min: 0,
                    max: 7,
                    onChanged: (value) {
                      final nearestSnapPointValue = _getNearestSnapPoint(value);
                      widget.subject.weight = nearestSnapPointValue;

                      setState(() {});
                    },
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
                AppLocalizationsManager.localizations.strAddGradegroup,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizationsManager.localizations.strName,
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
                child: Text(
                  AppLocalizationsManager.localizations.strCreate,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!createPressed) return null;
    String name = nameController.text.trim();
    if (name.isEmpty) {
      if (context.mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
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

  double _getNearestSnapPoint(double value) {
    double nearestDist = double.infinity;
    int nearestSnapPointIndex = 1; //weil 1 der normalwert ist

    for (int i = 0; i < _weightSnapPoints.length; i++) {
      final dist = (value - _weightSnapPoints[i]).abs();
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestSnapPointIndex = i;
      }
    }

    return _weightSnapPoints[nearestSnapPointIndex];
  }
}
