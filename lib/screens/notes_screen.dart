import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/time_selection_button.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/todo_event_list_item_widget.dart';

class NotesScreen extends StatefulWidget {
  static const route = "/notes";

  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: NotesScreen.route),
      appBar: AppBar(
        title: const Text("Tasks / Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          String? selectedSubjectName = await showSelectSubjectNameSheet(
            context,
            title: "Select Subject to add Task Or Note!",
          );

          if (selectedSubjectName == null) return;
          if (!mounted) return;

          TodoEvent? event = await _createNewTodoEventSheet(
            context,
            linkedSubjectName: selectedSubjectName,
          );

          if (event == null) return;

          TimetableManager().addOrChangeTodoEvent(event);

          if (!mounted) return;

          setState(() {});
        },
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final events = TimetableManager().sortedTodoEvents;
    if (events.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            String? selectedSubjectName = await showSelectSubjectNameSheet(
              context,
              title: "Select Subject to add Task Or Note!",
            );

            if (!mounted) return;
            if (selectedSubjectName == null) return;

            TodoEvent? event = await _createNewTodoEventSheet(
              context,
              linkedSubjectName: selectedSubjectName,
            );

            if (event == null) return;

            TimetableManager().addOrChangeTodoEvent(event);

            if (!mounted) return;

            setState(() {});
          },
          child: const Text("Create a Task / Note"),
        ),
      );
    }

    return ImplicitlyAnimatedList<TodoEvent>(
      items: events,
      itemBuilder: (context, animation, event, index) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          animation: animation,
          key: Key(event.key.toString()),
          child: TodoEventListItemWidget(
            event: event,
            onInfoPressed: () async {
              await Utils.showCustomPopUp(
                context: context,
                heroObject: event,
                body: TodoEventInfoPopUp(
                  event: event,
                  showEditGradeSheet: (event) async {
                    TodoEvent? newEvent = await _createNewTodoEventSheet(
                      context,
                      linkedSubjectName: event.linkedSubjectName,
                      event: event,
                    );

                    return newEvent;
                  },
                ),
                flightShuttleBuilder: (p0, p1, p2, p3, p4) {
                  return Container(
                    color: Theme.of(context).cardColor,
                  );
                },
              );

              //warten damit animation funktioniert
              await Future.delayed(
                const Duration(milliseconds: 500),
              );

              setState(() {});
            },
            onPressed: () {
              event.finished = !event.finished;
              //damit es gespeichert wird
              TimetableManager().addOrChangeTodoEvent(event);
              setState(() {});
            },
            onDeleteSwipe: () {
              setState(() {
                TimetableManager().removeTodoEvent(event);
              });
            },
          ),
        );
      },
      areItemsTheSame: (a, b) =>
          a.desciption == b.desciption &&
          a.endTime == b.endTime &&
          a.name == b.name &&
          a.type == b.type &&
          a.linkedSubjectName == b.linkedSubjectName,
    );
  }

  Future<TodoEvent?> _createNewTodoEventSheet(
    BuildContext context, {
    required String linkedSubjectName,
    TodoEvent? event,
  }) async {
    const maxNameLength = TodoEvent.maxNameLength;
    const maxDescriptionLength = TodoEvent.maxDescriptionLength;

    TextEditingController nameController = TextEditingController();
    nameController.text = event?.name ?? "";
    TextEditingController descriptionController = TextEditingController();
    descriptionController.text = event?.desciption ?? "";

    DateSelectionButtonController endDateController =
        DateSelectionButtonController(
      date: Utils.getHomescreenTimetable()
              ?.getNextLessonDate(linkedSubjectName) ??
          DateTime.now(),
    );
    if (event != null) {
      endDateController.date = event.endTime;
    }

    TodoType? type;

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
                  'Create new Task / Note\n$linkedSubjectName',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Topic",
                  ),
                  maxLines: 1,
                  maxLength: maxNameLength,
                  textAlign: TextAlign.center,
                  controller: nameController,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Extra info",
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "End date:",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.left,
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
                            ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _customButton(
                          text: "Exam",
                          icon: TodoEvent.examIcon,
                          onTap: () {
                            type = TodoType.exam;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _customButton(
                          text: "Test",
                          icon: TodoEvent.testIcon,
                          onTap: () {
                            type = TodoType.test;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _customButton(
                          text: "Homework",
                          icon: TodoEvent.homeworkIcon,
                          onTap: () {
                            type = TodoType.homework;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
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

    if (type == null) return null;

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

    return TodoEvent(
      key: event?.key ?? TimetableManager().getNextSchoolEventKey(),
      name: name,
      desciption: desciption,
      linkedSubjectName: linkedSubjectName,
      endTime: endDateController.date,
      type: type!,
      finished: event?.finished ?? false,
    );
  }

  Widget _customButton({
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
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(8),
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TodoEventInfoPopUp extends StatelessWidget {
  Future<TodoEvent?> Function(TodoEvent event) showEditGradeSheet;
  TodoEvent event;

  TodoEventInfoPopUp({
    super.key,
    required this.event,
    required this.showEditGradeSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () async {
                TimetableManager().removeTodoEvent(event);
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 32,
              ),
            ),
            Icon(
              event.getIcon(),
              color: event.getColor(),
            ),
            IconButton(
              onPressed: () async {
                TodoEvent? newEvent = await showEditGradeSheet(event);

                if (newEvent == null) return;

                TimetableManager().addOrChangeTodoEvent(newEvent);

                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.edit,
                size: 32,
              ),
            ),
          ],
        ),
        Text(
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          event.linkedSubjectName,
        ),
        Text(
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          event.name,
        ),
        const SizedBox(
          height: 24,
        ),
        Visibility(
          visible: event.desciption.isNotEmpty,
          replacement: const Spacer(),
          child: Flexible(
            fit: FlexFit.tight,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  event.desciption,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${Utils.dateToString(event.endTime)} | ${event.endTime.hour} : ${event.endTime.minute}",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 12,
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
