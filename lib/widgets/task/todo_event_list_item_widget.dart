import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/widgets/notes/school_note_list_item.dart';
import 'package:schulapp/widgets/periodic_updating_widget.dart';

// ignore: must_be_immutable
class TodoEventListItemWidget extends StatelessWidget {
  // Animation<double> animation;
  void Function() onPressed;
  void Function() onLongPressed;
  void Function() onInfoPressed;
  void Function() onDeleteSwipe;

  TodoEvent event;
  bool removeHero;
  bool showTimeLeft;
  bool isSelected;

  TodoEventListItemWidget({
    super.key,
    this.removeHero = false,
    this.showTimeLeft = true,
    this.isSelected = false,
    required this.event,
    required this.onInfoPressed,
    required this.onPressed,
    required this.onLongPressed,
    required this.onDeleteSwipe,
  });

  @override
  Widget build(BuildContext context) {
    // Dismissible(
    //   key: ValueKey<TodoEvent>(event),
    //   onDismissed: (direction) {
    //     onDeleteSwipe.call();
    //   },
    //   background: Container(
    //     color: Colors.red,
    //     padding: const EdgeInsets.all(32),
    //     child: const Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Icon(Icons.delete),
    //         Icon(Icons.delete),
    //       ],
    //     ),
    //   ),
    if (removeHero) {
      return _body(context);
    }
    return Hero(
      tag: event,
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final linkedSchoolNote = SchoolNotesManager().getSchoolNoteBySaveName(
      event.linkedSchoolNote,
    );

    return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
        ),
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //leading
                Icon(
                  isSelected ? Icons.check : event.getIcon(),
                  color: isSelected ? Colors.white : event.getColor(),
                  size: 32,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.linkedSubjectName,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              decoration: event.finished
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                      ),
                      if (event.name.isNotEmpty)
                        Text(
                          event.name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                //trailing
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    linkedSchoolNote != null
                        ? IconButton(
                            onPressed: () => _onLinkedSchoolNotePressed(
                                context, linkedSchoolNote),
                            icon: const Icon(Icons.description),
                          )
                        : const SizedBox.shrink(),
                    showTimeLeft
                        ? PeriodicUpdatingWidget(
                            timerDuration: const Duration(seconds: 1),
                            updateWidget: () {
                              return Text(
                                event.getEndTimeString(),
                                style: event.isExpired()
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: Colors.red)
                                    : Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                    IconButton(
                      onPressed: onInfoPressed,
                      icon: const Icon(Icons.info),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void _onLinkedSchoolNotePressed(
    BuildContext context,
    SchoolNote linkedSchoolNote,
  ) async {
    await SchoolNoteListItem.openNote(
      context,
      linkedSchoolNote,
    );
  }
}
