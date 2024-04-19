import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/todo_event_list_item_widget.dart';
import 'package:schulapp/widgets/todo_event_util_functions.dart';
import 'package:tuple/tuple.dart';

// ignore: must_be_immutable
class NotesScreen extends StatefulWidget {
  static const route = "/notes";

  TodoEvent? todoEvent;

  NotesScreen({super.key, this.todoEvent});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<TodoEvent> selectedTodoEvents = [];
  bool isMultiselectionActive = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () async {
        if (widget.todoEvent != null) {
          await Utils.showCustomPopUp(
            context: context,
            heroObject: widget.todoEvent!,
            body: TodoEventInfoPopUp(
              event: widget.todoEvent!,
              showEditTodoEventSheet: (event) async {
                TodoEvent? newEvent = await createNewTodoEventSheet(
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: NotesScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strTasks,
        ),
        actions: !isMultiselectionActive
            ? null
            : [
                IconButton(
                  onPressed: _unselectAllItems,
                  tooltip: AppLocalizationsManager.localizations.strCancel,
                  icon: const Icon(
                    Icons.cancel,
                  ),
                ),
                IconButton(
                  onPressed: _finishOrUnfinishSelectedEvents,
                  tooltip:
                      AppLocalizationsManager.localizations.strMarkAsUNfinished,
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: _deleteSelectedEvents,
                  tooltip: AppLocalizationsManager
                      .localizations.strDeleteSelectedItems,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
      ),
      floatingActionButton: _floatingActionButton(),
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
              title: AppLocalizationsManager
                  .localizations.strSelectSubjectToAddTaskTo,
            );

            if (!mounted) return;
            if (selectedSubjectName == null) return;

            TodoEvent? event = await createNewTodoEventSheet(
              context,
              linkedSubjectName: selectedSubjectName,
            );

            if (event == null) return;

            TimetableManager().addOrChangeTodoEvent(event);

            if (!mounted) return;

            setState(() {});
          },
          child: Text(
            AppLocalizationsManager.localizations.strCreateATask,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ImplicitlyAnimatedList<TodoEvent>(
            items: events,
            itemBuilder: (context, animation, event, index) {
              final bool isSelected = isMultiselectionActive
                  ? _selectedTodoEventsContains(event)
                  : false;
              return SizeFadeTransition(
                sizeFraction: 0.7,
                animation: animation,
                key: Key(event.key.toString()),
                child: TodoEventListItemWidget(
                  event: event,
                  isSelected: isSelected,
                  onLongPressed: () {
                    addOrActivateMultiselection(event);
                  },
                  onInfoPressed: () async {
                    await Utils.showCustomPopUp(
                      context: context,
                      heroObject: event,
                      body: TodoEventInfoPopUp(
                        event: event,
                        showEditTodoEventSheet: (event) async {
                          TodoEvent? newEvent = await createNewTodoEventSheet(
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
                    if (isMultiselectionActive) {
                      addOrActivateMultiselection(event);
                      return;
                    }
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
          ),
        ),
        multiSelectionButton(),
      ],
    );
  }

  void addOrActivateMultiselection(TodoEvent event) {
    if (!isMultiselectionActive) {
      isMultiselectionActive = true;
      _finishSelectedEvents = !event.finished;
      _currentMultiSelectionButtonTextIndex = 0;
    }
    bool isSelected = _selectedTodoEventsContains(event);
    if (isSelected) {
      removeOrDisableMultiselection(event);
    } else {
      addToMultiselection(event);
    }
  }

  bool _selectedTodoEventsContains(TodoEvent event) {
    return selectedTodoEvents.contains(event);
    // return selectedTodoEvents.any(
    //   (element) {
    //     return element.name == event.name &&
    //         element.desciption == event.desciption &&
    //         element.linkedSubjectName == event.linkedSubjectName;
    //   },
    // );
  }

  void addToMultiselection(TodoEvent event) {
    selectedTodoEvents.add(event);
    setState(() {});
  }

  void removeOrDisableMultiselection(TodoEvent event) {
    if (!isMultiselectionActive) return;

    bool isSelected = _selectedTodoEventsContains(event);

    if (isSelected) {
      removeFromMultiselection(event);
    }
    isMultiselectionActive = selectedTodoEvents.isNotEmpty;
    setState(() {});
  }

  void removeFromMultiselection(TodoEvent event) {
    selectedTodoEvents.remove(event);
    setState(() {});
  }

  Widget? _floatingActionButton() {
    if (isMultiselectionActive) return null;
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        String? selectedSubjectName = await showSelectSubjectNameSheet(
          context,
          title:
              AppLocalizationsManager.localizations.strSelectSubjectToAddTaskTo,
        );

        if (selectedSubjectName == null) return;
        if (!mounted) return;

        if (selectedSubjectName ==
            AppLocalizationsManager.localizations.strCustomSubject) {
          String? customName = await Utils.showStringInputDialog(
            context,
            hintText: AppLocalizationsManager.localizations.strCustomSubject,
            autofocus: true,
            maxInputLength: 30,
          );

          if (customName == null) {
            return;
          }

          if (customName.isEmpty) {
            if (!mounted) return;

            Utils.showInfo(
              context,
              msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
              type: InfoType.error,
            );
            return;
          }

          selectedSubjectName = customName;
        }

        if (!mounted) return;

        TodoEvent? event = await createNewTodoEventSheet(
          context,
          linkedSubjectName: selectedSubjectName,
        );

        if (event == null) return;

        TimetableManager().addOrChangeTodoEvent(event);

        if (!mounted) return;

        setState(() {});
      },
    );
  }

  int _currentMultiSelectionButtonTextIndex = 0;
  Widget multiSelectionButton() {
    if (!isMultiselectionActive) return Container();

    final buttons = [
      Tuple2<String, List<TodoEvent> Function(List<TodoEvent>)>(
        AppLocalizationsManager.localizations.strSelectAllFinishedTasks,
        (todoEvents) {
          return todoEvents.where((element) => element.finished).toList();
        },
      ),
      Tuple2<String, List<TodoEvent> Function(List<TodoEvent>)>(
        AppLocalizationsManager.localizations.strSelectAllExpiredTasks,
        (todoEvents) {
          return todoEvents.where((element) => element.isExpired()).toList();
        },
      ),
      Tuple2<String, List<TodoEvent> Function(List<TodoEvent>)>(
        AppLocalizationsManager.localizations.strSelectAllTasks,
        (todoEvents) {
          return todoEvents;
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {
          List<TodoEvent> Function(List<TodoEvent>) func =
              buttons[_currentMultiSelectionButtonTextIndex].item2;

          isMultiselectionActive = true;
          selectedTodoEvents = func(TimetableManager().sortedTodoEvents);
          _currentMultiSelectionButtonTextIndex++;
          if (_currentMultiSelectionButtonTextIndex >= buttons.length) {
            _currentMultiSelectionButtonTextIndex = 0;
          }
          setState(() {});
        },
        child: Text(buttons[_currentMultiSelectionButtonTextIndex].item1),
      ),
    );
  }

  void _unselectAllItems() {
    if (!isMultiselectionActive) return;
    isMultiselectionActive = false;
    selectedTodoEvents.clear();
    setState(() {});
  }

  bool _finishSelectedEvents = true;
  Future<void> _finishOrUnfinishSelectedEvents() async {
    if (!isMultiselectionActive) return;
    final List<String> finishOrUnfinisString = [
      AppLocalizationsManager.localizations.strFinish,
      AppLocalizationsManager.localizations.strUnfinish,
    ];
    String finishString = finishOrUnfinisString[_finishSelectedEvents ? 0 : 1];
    bool finishOrUnfinish = await Utils.showBoolInputDialog(
      context,
      question:
          AppLocalizationsManager.localizations.strDoYouWantToFinishXTasks(
        selectedTodoEvents.length,
        finishString,
      ),
    );
    if (!finishOrUnfinish) return;

    final copySelectedTodoEvents = List<TodoEvent>.from(
      selectedTodoEvents,
      growable: true,
    );

    for (TodoEvent event in copySelectedTodoEvents) {
      event.finished = _finishSelectedEvents;

      TimetableManager().addOrChangeTodoEvent(event);

      await Future.delayed(
        const Duration(milliseconds: 150),
      );
      setState(() {});
    }
    selectedTodoEvents.clear();
    isMultiselectionActive = false;
    setState(() {});

    _finishSelectedEvents = !_finishSelectedEvents;
  }

  Future<void> _deleteSelectedEvents() async {
    if (!isMultiselectionActive) return;

    bool delete = await Utils.showBoolInputDialog(
      context,
      question:
          AppLocalizationsManager.localizations.strDoYouWantToDeleteXTasks(
        selectedTodoEvents.length,
      ),
    );

    if (!delete) return;

    isMultiselectionActive = false;
    setState(() {});

    final copySelectedTodoEvents = List.from(
      selectedTodoEvents,
      growable: false,
    );

    for (TodoEvent event in copySelectedTodoEvents) {
      TimetableManager().removeTodoEvent(event);
      await Future.delayed(
        const Duration(milliseconds: 150),
      );
      setState(() {});
    }
    selectedTodoEvents.clear();
  }
}

// ignore: must_be_immutable
class TodoEventInfoPopUp extends StatelessWidget {
  Future<TodoEvent?> Function(TodoEvent event) showEditTodoEventSheet;
  TodoEvent event;

  TodoEventInfoPopUp({
    super.key,
    required this.event,
    required this.showEditTodoEventSheet,
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
                TodoEvent? newEvent = await showEditTodoEventSheet(event);

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
          textAlign: TextAlign.center,
        ),
        Text(
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          event.name,
          textAlign: TextAlign.center,
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
