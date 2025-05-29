import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_note_part.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/notes/school_note_list_item.dart';
import 'package:schulapp/widgets/time_selection_button.dart';

class NewTodoEventWidget extends StatefulWidget {
  final String linkedSubjectName;
  final TodoEvent? event;
  final bool? isCustomEvent;

  const NewTodoEventWidget({
    super.key,
    required this.event,
    required this.linkedSubjectName,
    required this.isCustomEvent,
  });

  @override
  State<NewTodoEventWidget> createState() => _NewTodoEventWidgetState();
}

class _NewTodoEventWidgetState extends State<NewTodoEventWidget> {
  final maxNameLength = TodoEvent.maxNameLength;
  final maxDescriptionLength = TodoEvent.maxDescriptionLength;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late DateSelectionButtonController endDateController;
  SchoolNote? linkedSchoolNote;
  bool isCustomEvent = false;

  @override
  void initState() {
    nameController.text = widget.event?.name ?? "";
    descriptionController.text = widget.event?.desciption ?? "";
    if (widget.isCustomEvent == null) {
      isCustomEvent = widget.event?.isCustomEvent ?? false;
    } else {
      isCustomEvent = widget.isCustomEvent!;
    }

    endDateController = DateSelectionButtonController(
      date: Utils.getHomescreenTimetable()
              ?.getNextLessonDate(widget.linkedSubjectName) ??
          DateTime.now(),
    );

    linkedSchoolNote = SchoolNotesManager().getSchoolNoteBySaveName(
      widget.event?.linkedSchoolNote,
    );

    if (widget.event != null) {
      endDateController.date = widget.event!.endTime?.copyWith();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "${AppLocalizationsManager.localizations.strCreateATask}\n${widget.linkedSubjectName}",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizationsManager.localizations.strTopic,
              ),
              maxLines: 1,
              maxLength: maxNameLength,
              textAlign: TextAlign.center,
              controller: nameController,
            ),
            const SizedBox(
              height: 12,
            ),
            _getExtraInfoOrSchoolNoteWidget(),
            const SizedBox(
              height: 12,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizationsManager.localizations.strEndDate,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                AppLocalizationsManager
                                    .localizations.strNoEndDate,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Switch.adaptive(
                              value: endDateController.noDate,
                              onChanged: (value) {
                                endDateController.noDate = value;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () async {
                      //     final timetable = Utils.getHomescreenTimetable();

                      //     if (timetable == null) {
                      //       Utils.showInfo(
                      //         context,
                      //         msg: "No Homescreen timetable selected!",
                      //         type: InfoType.error,
                      //       );
                      //       return;
                      //     }

                      //     Utils.showCustomPopUp(
                      //       context: context,
                      //       heroObject: null,
                      //       body: const Center(
                      //         child: Text("test"),
                      //       ),
                      //     );
                      //   },
                      //   icon: const Icon(Icons.dataset_outlined),
                      // ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: DateSelectionButton(
                          controller: endDateController,
                          onDateSelected: (DateTime newDate) {
                            final Timetable? homescreenTT =
                                Utils.getHomescreenTimetable();
                            if (homescreenTT == null) return;

                            //because monday = 1 | we need to subtract 1
                            final dayIndex = newDate.weekday - 1;
                            if (dayIndex < 0 ||
                                dayIndex >= homescreenTT.schoolDays.length) {
                              return;
                            }

                            final day = homescreenTT.schoolDays[dayIndex];
                            for (int i = 0; i < day.lessons.length; i++) {
                              var lesson = day.lessons[i];
                              if (lesson.name == widget.linkedSubjectName) {
                                var time = homescreenTT.schoolTimes[i];
                                endDateController.date = newDate.copyWith(
                                  hour: time.start.hour,
                                  minute: time.start.minute,
                                );
                                break;
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      TimeSelectionButton(
                        controller: endDateController,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: customButton(
                      context,
                      text: AppLocalizationsManager.localizations.strExam,
                      icon: TodoEvent.examIcon,
                      onTap: () {
                        pop(
                          type: TodoType.exam,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: customButton(
                      context,
                      text:
                          AppLocalizationsManager.localizations.strPresentation,
                      icon: TodoEvent.presentationIcon,
                      onTap: () {
                        pop(
                          type: TodoType.presentation,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: customButton(
                      context,
                      text: AppLocalizationsManager.localizations.strTest,
                      icon: TodoEvent.testIcon,
                      onTap: () {
                        pop(
                          type: TodoType.test,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: customButton(
                      context,
                      text: AppLocalizationsManager.localizations.strHomework,
                      icon: TodoEvent.homeworkIcon,
                      onTap: () {
                        pop(
                          type: TodoType.homework,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            widget.event?.type == null
                ? const SizedBox.shrink()
                : const SizedBox(
                    height: 12,
                  ),
            widget.event?.type == null
                ? const SizedBox.shrink()
                : ElevatedButton(
                    onPressed: () {
                      pop(
                        okayPressed: true,
                      );
                    },
                    child: Text(AppLocalizationsManager.localizations.strOK),
                  ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getExtraInfoOrSchoolNoteWidget() {
    Widget child;
    if (linkedSchoolNote == null) {
      child = Column(
        key: const ValueKey("extraInfo"),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: AppLocalizationsManager.localizations.strExtraInfo,
            ),
            maxLength: maxDescriptionLength,
            maxLines: 5,
            minLines: 1,
            textAlign: TextAlign.center,
            controller: descriptionController,
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addSchoolNote,
                  child: Text(AppLocalizationsManager.localizations.strAddNote),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectSchoolNote,
                  child:
                      Text(AppLocalizationsManager.localizations.strSelectNote),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      child = SchoolNoteListItem(
        key: const ValueKey("extraInfo"),
        onDeletePressed: () async {
          linkedSchoolNote = null;

          setState(() {});

          //damit Benutzer sieht dass die Notitz entfernt wird
          //damit er weiß dass die folgende Frage ob er die Notitz löschen wolle
          //nicht auf das entfernen bezogen ist
          await Future.delayed(
            const Duration(milliseconds: 300),
          );
        },
        onDelete: () async {
          setState(() {});
        },
        schoolNote: linkedSchoolNote!,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 300,
      ),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
        // return FadeTransition(
        //   opacity: animation,
        //   child: SizeTransition(
        //     sizeFactor: animation,
        //     child: child,
        //   ),
        // );
      },
      child: child,
    );
  }

  Future<void> _addSchoolNote() async {
    SchoolNote note = SchoolNote(
        title: AppLocalizationsManager.localizations.strTaskNote(
          widget.linkedSubjectName,
        ),
        parts: [
          SchoolNotePartText(
            value: descriptionController.text.trim(),
          ),
        ]);

    SchoolNotesManager().addSchoolNote(note);

    await SchoolNoteListItem.openNote(context, note);

    MainApp.changeNavBarVisibility(true);

    linkedSchoolNote = note;

    setState(() {});
  }

  Future<void> _selectSchoolNote() async {
    final notes = SchoolNotesManager().schoolNotes;
    SchoolNote? selectedNote;

    await Utils.showStringAcionListBottomSheet(
      context,
      title: AppLocalizationsManager.localizations.strSelectNote,
      items: List.generate(
        notes.length,
        (index) => (
          notes[index].getTitle(context),
          () async {
            selectedNote = notes[index];
          },
        ),
      ),
    );

    linkedSchoolNote = selectedNote;

    setState(() {});
  }

  Widget customButton(
    BuildContext context, {
    required String text,
    IconData? icon,
    required void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(16),
          // shape: BoxShape.circle,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              icon == null
                  ? Container()
                  : Icon(
                      icon,
                    ),
              const SizedBox(
                height: 8,
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pop({TodoType? type, bool okayPressed = false}) {
    if (!okayPressed && type == null) Navigator.of(context).pop();

    type ??= widget.event?.type;

    String name = nameController.text.trim();
    String desciption = descriptionController.text.trim();

    // if (name.isEmpty) {
    //   if (mounted) {
    //     Utils.showInfo(
    //       context,
    //       msg: "Name can not be empty!",
    //       type: InfoType.error,
    //     );
    //   }
    //   return null;
    // }
    Navigator.of(context).pop(
      TodoEvent(
        key: widget.event?.key,
        name: name,
        desciption: desciption,
        linkedSchoolNote: linkedSchoolNote?.saveFileName,
        linkedSubjectName: widget.linkedSubjectName,
        endTime: endDateController.noDate ? null : endDateController.date,
        type: type!,
        finished: widget.event?.finished ?? false,
        isCustomEvent: isCustomEvent,
      ),
    );
  }
}
