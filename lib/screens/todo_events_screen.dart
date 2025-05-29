import 'dart:io';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/timetable/export_timetable_page.dart';
import 'package:schulapp/widgets/animated_go_file_io_share_button.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/widgets/notes/school_note_list_item.dart';
import 'package:schulapp/widgets/task/todo_event_list_item_widget.dart';
import 'package:schulapp/code_behind/todo_event_util_functions.dart';
import 'package:schulapp/widgets/task/todo_event_to_finished_task_overlay.dart';
import 'package:tuple/tuple.dart';

class TodoEventsScreen extends StatefulWidget {
  static const route = "/tasks";

  final TodoEvent? todoEvent;
  final bool showFinishedTasks;

  const TodoEventsScreen({
    super.key,
    this.todoEvent,
    this.showFinishedTasks = false,
  });

  @override
  State<TodoEventsScreen> createState() => _TodoEventsScreenState();
}

class _TodoEventsScreenState extends State<TodoEventsScreen> {
  final GlobalKey _showFinishedTasksActionKey = GlobalKey();
  final GlobalKey _backButtonKey = GlobalKey();

  List<TodoEvent> selectedTodoEvents = [];
  bool isMultiselectionActive = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () async {
        final todoEvent = widget.todoEvent;
        if (todoEvent != null && mounted) {
          if (todoEvent.finished && !widget.showFinishedTasks) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TodoEventsScreen(
                  todoEvent: todoEvent,
                  showFinishedTasks: true,
                ),
              ),
            );
            setState(() {});
            return;
          }
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
      drawer: widget.showFinishedTasks
          ? null
          : const NavigationBarDrawer(selectedRoute: TodoEventsScreen.route),
      appBar: AppBar(
        title: widget.showFinishedTasks
            ? Text(
                "${AppLocalizationsManager.localizations.strFinishedTasks} (${TimetableManager().sortedFinishedTodoEvents.length})",
              )
            : Text(
                "${AppLocalizationsManager.localizations.strTasks} (${TimetableManager().sortedUnfinishedTodoEvents.length})",
              ),
        leading: widget.showFinishedTasks
            ? IconButton(
                key: _backButtonKey,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: !isMultiselectionActive
            ? [
                Visibility(
                  visible: !widget.showFinishedTasks,
                  child: IconButton(
                    onPressed: _importViaOnlineCode,
                    tooltip: AppLocalizationsManager.localizations.strImport,
                    icon: const Icon(
                      Icons.file_download,
                    ),
                  ),
                ),
                Visibility(
                  visible: !widget.showFinishedTasks,
                  child: IconButton(
                    key: _showFinishedTasksActionKey,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TodoEventsScreen(
                            showFinishedTasks: true,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    tooltip: AppLocalizationsManager
                        .localizations.strShowFinishedTasks,
                    icon: const Icon(
                      Icons.done_all,
                    ),
                  ),
                ),
              ]
            : [
                IconButton(
                  onPressed: _shareAllItems,
                  tooltip: AppLocalizationsManager.localizations.strExport,
                  icon: const Icon(
                    Icons.upload,
                  ),
                ),
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
      floatingActionButton:
          widget.showFinishedTasks ? null : _floatingActionButton(),
      body: _body(),
    );
  }

  Widget _body() {
    final List<TodoEvent> events;

    if (widget.showFinishedTasks) {
      events = TimetableManager().sortedFinishedTodoEvents;
    } else {
      events = TimetableManager().sortedUnfinishedTodoEvents;
    }

    if (events.isEmpty) {
      if (widget.showFinishedTasks) {
        return Center(
          child: Text(
            AppLocalizationsManager.localizations.strNoTasksFinishedYet,
          ),
        );
      }
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            //selectedSubjectName, isCustomName
            (String, bool)? selectedSubjectTuple =
                await showSelectSubjectNameSheet(
              context,
              title: AppLocalizationsManager
                  .localizations.strSelectSubjectToAddTaskTo,
              allowCustomNames: true,
            );

            if (!mounted) return;
            if (selectedSubjectTuple == null) return;

            String? selectedSubjectName = selectedSubjectTuple.$1;
            bool? isCustomTask = selectedSubjectTuple.$2;

            TodoEvent? event = await createNewTodoEventSheet(
              context,
              linkedSubjectName: selectedSubjectName,
              isCustomEvent: isCustomTask,
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
              return Builder(
                builder: (itemContext) {
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
                          alpha: 250,
                          body: TodoEventInfoPopUp(
                            event: event,
                            showEditTodoEventSheet: (event) async {
                              TodoEvent? newEvent =
                                  await createNewTodoEventSheet(
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

                        if (!widget.showFinishedTasks) {
                          _createAnimationToFinishedTasks(event, itemContext);
                        } else {
                          _createAnimationToUnfinishedTasks(event, itemContext);
                        }
                      },
                      onDeleteSwipe: () {
                        setState(() {
                          TimetableManager().removeTodoEvent(event);
                        });
                      },
                    ),
                  );
                },
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
      child: const Icon(Icons.assignment_add),
      onPressed: () async {
        //selectedSubjectName, isCustomTask
        (String, bool)? selectedSubjectNameTuple =
            await showSelectSubjectNameSheet(
          context,
          title:
              AppLocalizationsManager.localizations.strSelectSubjectToAddTaskTo,
          allowCustomNames: true,
        );

        if (selectedSubjectNameTuple == null) return;
        if (!mounted) return;

        String selectedSubjectName = selectedSubjectNameTuple.$1;
        bool isCustomTask = selectedSubjectNameTuple.$2;

        TodoEvent? event = await createNewTodoEventSheet(
          context,
          linkedSubjectName: selectedSubjectName,
          isCustomEvent: isCustomTask,
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

    var buttons = [
      Tuple2<String, List<TodoEvent> Function(List<TodoEvent>)>(
        AppLocalizationsManager.localizations.strSelectAllExpiredTasks,
        (todoEvents) {
          return todoEvents.where((element) => element.isExpired()).toList();
        },
      ),
      Tuple2<String, List<TodoEvent> Function(List<TodoEvent>)>(
        AppLocalizationsManager.localizations.strSelectAllTasks,
        (todoEvents) {
          return todoEvents.where((element) => true).toList();
        },
      ),
    ];
    if (widget.showFinishedTasks) {
      buttons = [
        Tuple2<String, List<TodoEvent> Function(List<TodoEvent>)>(
          AppLocalizationsManager.localizations.strSelectAllFinishedTasks,
          (todoEvents) {
            return todoEvents.where((element) => element.finished).toList();
          },
        ),
      ];
    }

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
        child: Text(
          buttons[_currentMultiSelectionButtonTextIndex].item1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _shareAllItems() async {
    final enabled =
        await GoFileIoManager().showTermsOfServicesEnabledDialog(context);

    if (!enabled) return;

    if (!isMultiselectionActive) return;
    isMultiselectionActive = false;

    try {
      final codeFuture = SaveManager().shareTodoEvents(selectedTodoEvents);

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return FutureBuilder(
            future: codeFuture,
            builder: (context, snapshot) {
              Widget child;
              if (!snapshot.hasData) {
                child = const Center(
                  key: ValueKey("CircularProgressIndicator"),
                  child: CircularProgressIndicator(),
                );
              } else {
                final headingText = snapshot.data;

                if (headingText == null) {
                  Utils.showInfo(
                    context,
                    msg: AppLocalizationsManager
                        .localizations.strThereWasAnError,
                    type: InfoType.error,
                  );
                  Navigator.of(context).pop();
                  return const SizedBox.shrink();
                }

                child = ShareGoFileIOBottomSheet(
                  key: const ValueKey("ShareTodoEventBottomSheet"),
                  shareText: AppLocalizationsManager
                      .localizations.strShareYourTodoEvents,
                  code: headingText,
                );
              }

              return AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                duration: const Duration(
                  milliseconds: 400,
                ),
                child: child,
              );
            },
          );
        },
      );
      selectedTodoEvents.clear();
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
    }

    setState(() {});
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
        finishString,
        selectedTodoEvents.length,
      ),
      showYesAndNoInsteadOfOK: true,
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
      showYesAndNoInsteadOfOK: true,
      markTrueAsRed: true,
    );

    if (!delete) return;

    isMultiselectionActive = false;
    setState(() {});

    final copySelectedTodoEvents = List.from(
      selectedTodoEvents,
      growable: false,
    );

    bool deleteNote = false;
    bool showDeleteNote = false;

    for (var event in copySelectedTodoEvents) {
      if (event.linkedSchoolNote != null) {
        showDeleteNote = true;
      }
    }

    if (showDeleteNote && mounted) {
      final delete = await Utils.showBoolInputDialog(
        context,
        question: AppLocalizationsManager
            .localizations.strDoYouWantToDeleteAllLinkedNote,
        showYesAndNoInsteadOfOK: true,
        markTrueAsRed: true,
      );
      deleteNote = delete;
    }

    for (TodoEvent event in copySelectedTodoEvents) {
      TimetableManager().removeTodoEvent(
        event,
        deleteLinkedSchoolNote: deleteNote,
      );
      await Future.delayed(
        const Duration(milliseconds: 150),
      );
      setState(() {});
    }
    selectedTodoEvents.clear();
  }

  void _createAnimationToFinishedTasks(
      TodoEvent event, BuildContext itemContext) {
    _animateTodoEvent(
      todoEvent: event,
      itemContext: itemContext,
      targetKey: _showFinishedTasksActionKey,
    );
  }

  void _createAnimationToUnfinishedTasks(
      TodoEvent event, BuildContext itemContext) {
    _animateTodoEvent(
      todoEvent: event,
      itemContext: itemContext,
      targetKey: _backButtonKey,
    );
  }

  void _importViaOnlineCode() async {
    final userKnows =
        await GoFileIoManager().showImportTodoEventWarningDialog(context);

    if (!userKnows) return;
    if (!mounted) return;

    final enabled =
        await GoFileIoManager().showTermsOfServicesEnabledDialog(context);

    if (!enabled) return;
    if (!mounted) return;

    final codeController = TextEditingController();
    const maxCodeLength = 15;

    bool createPressed = false;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                AppLocalizationsManager.localizations.strImportViaCode,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizationsManager.localizations.strCode,
                ),
                onSubmitted: (value) {
                  createPressed = true;
                  Navigator.of(context).pop();
                },
                autofocus: true,
                maxLines: 1,
                maxLength: maxCodeLength,
                textAlign: TextAlign.center,
                controller: codeController,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  createPressed = true;
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizationsManager.localizations.strImport),
              ),
            ],
          ),
        );
      },
    );

    if (!createPressed) return;

    final code = codeController.text.trim();

    if (code.isEmpty || !mounted) return;

    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        dialogContext = dContext;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                TextButton(
                  child: Text(AppLocalizationsManager.localizations.strCancel),
                  onPressed: () {
                    Navigator.of(dContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    List<String>? downloadedPaths;

    try {
      downloadedPaths = await GoFileIoManager().downloadFiles(
        code,
        isSaveCode: true,
      );
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
    }

    if (dialogContext != null && dialogContext!.mounted) {
      Navigator.of(dialogContext!).pop();
    }

    if (downloadedPaths == null) return;

    List<
        ({
          TodoEvent event,
          SchoolNote? note,
          Directory? filesDirForNote,
        })> todoEventsList = [];

    try {
      todoEventsList = SaveManager().importTodoEvents(
        downloadedPaths
            .map(
              (e) => File(e),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      if (todoEventsList.isEmpty) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strImportingFailed,
          type: InfoType.error,
        );
      } else {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strImportSuccessful,
          type: InfoType.success,
        );
      }
    }

    if (todoEventsList.isEmpty) return;

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    bool okPressed = false;

    List<bool> importList = List.generate(
      todoEventsList.length,
      (i) => true,
    );

    await Utils.showListSelectionBottomSheet(
      context,
      title: AppLocalizationsManager
          .localizations.strWhichTodoEventsWouldYouLikeToImport,
      items: todoEventsList,
      scrollControlDisabledMaxHeightRatio: 0.7,
      bottomActions: [
        ElevatedButton(
          onPressed: () {
            okPressed = true;
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizationsManager.localizations.strImport),
        ),
      ],
      itemBuilder: (context, index) {
        final todoEventGeneric = todoEventsList[index];
        return StatefulBuilder(
          builder: (context, builder) {
            return TodoEventListItemWidget(
              event: todoEventGeneric.event,
              onDeleteSwipe: () {
                builder(() {
                  importList[index] = false;
                });
              },
              onLongPressed: () {
                builder(() {
                  importList[index] = !importList[index];
                });
              },
              onPressed: () {
                builder(() {
                  importList[index] = !importList[index];
                });
              },
              onInfoPressed: null,
              isSelected: importList[index],
              removeHero: true,
              notSavedNote: todoEventGeneric.note,
              showTimeLeft: false,
            );
          },
        );
      },
    );

    if (!okPressed) return;

    if (!mounted) return;

    for (var i = 0; i < todoEventsList.length; i++) {
      final import = importList[i];

      if (!import) continue;

      final todoEventRecord = todoEventsList[i];

      TimetableManager().addOrChangeTodoEvent(
        todoEventRecord.event,
      );

      final note = todoEventRecord.note;
      if (note != null) {
        SchoolNotesManager().addSchoolNote(note);
      }
    }

    SaveManager().deleteTempDir();
    SaveManager().getImportDir().deleteSync(recursive: true);

    setState(() {});
  }

  void _animateTodoEvent({
    required TodoEvent todoEvent,
    required BuildContext itemContext,
    required GlobalKey targetKey,
  }) {
    final backButtonBox =
        targetKey.currentContext!.findRenderObject() as RenderBox;
    final itemEndTopLeft = backButtonBox.localToGlobal(Offset.zero);

    final itemEndCenter = Offset(
      itemEndTopLeft.dx + backButtonBox.size.width / 2,
      itemEndTopLeft.dy + backButtonBox.size.height / 2,
    );

    // Get the position of ListTile
    RenderBox listItemBox = itemContext.findRenderObject() as RenderBox;
    Offset itemStartTopLeft = listItemBox.localToGlobal(Offset.zero);

    final itemStartCenter = Offset(
      itemStartTopLeft.dx + listItemBox.size.width / 2,
      itemStartTopLeft.dy + listItemBox.size.height / 2,
    );

    OverlayState overlayState = Overlay.of(context);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TodoEventToFinishedTaskOverlay(
        todoEvent: todoEvent,
        itemStartCenter: itemStartCenter,
        itemEndCenter: itemEndCenter,
        itemSize: listItemBox.size,
        onComplete: () {
          overlayEntry?.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class TodoEventInfoPopUp extends StatelessWidget {
  final Future<TodoEvent?> Function(TodoEvent event) showEditTodoEventSheet;
  final TodoEvent event;

  const TodoEventInfoPopUp({
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
                bool deleteNote = false;

                if (event.linkedSchoolNote != null) {
                  final delete = await Utils.showBoolInputDialog(
                    context,
                    question: AppLocalizationsManager
                        .localizations.strDoYouWantToDeleteLinkedNote,
                    showYesAndNoInsteadOfOK: true,
                    markTrueAsRed: true,
                  );
                  deleteNote = delete;
                }
                TimetableManager().removeTodoEvent(
                  event,
                  deleteLinkedSchoolNote: deleteNote,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
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

                if (!context.mounted) return;
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
        _getDescriptionOrSchoolNoteWidget(context),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: event.endTime == null
              ? Text(
                  AppLocalizationsManager.localizations.strNoEndDate,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                )
              : Text(
                  "${Utils.dateToString(event.endTime!)} | ${event.endTime!.hour} : ${event.endTime!.minute}",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedGoFileIOShareButton(
              onPressed: _shareTodoEvent,
              saveOnlineCode: event.saveOnlineCode,
              isSaveCode: true,
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
      ],
    );
  }

  Widget _getDescriptionOrSchoolNoteWidget(BuildContext context) {
    final linkedNote = event.linkedSchoolNote;
    if (linkedNote != null) {
      final schoolNote = SchoolNotesManager().getSchoolNoteBySaveName(
        linkedNote,
      );

      if (schoolNote != null) {
        return Flexible(
          fit: FlexFit.tight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                child: SchoolNoteListItem(
                  schoolNote: schoolNote,
                  showDeleteBtn: false,
                ),
              ),
            ],
          ),
        );
      }
    }
    return Visibility(
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
    );
  }

  Future<String?> _shareTodoEvent() async {
    final code = await SaveManager().shareTodoEvent(event);

    // nicht so machen, weil [addOrChangeTodoEvnet] diese Flag überschreibt
    // event.saveOnlineCode = code;

    TimetableManager().addOrChangeTodoEvent(
      event,
      saveOnlineCode: code,
    );

    return code;
  }
}
