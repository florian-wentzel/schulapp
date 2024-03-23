import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
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
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: onPressed,
        onLongPress: onLongPressed,
        subtitle: Text(
          event.name,
          overflow: TextOverflow.ellipsis,
        ),
        title: Text(
          event.linkedSubjectName,
          overflow: TextOverflow.clip,
          style: TextStyle(
            decoration: event.finished ? TextDecoration.lineThrough : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        leading: Icon(
          isSelected ? Icons.check : event.getIcon(),
          color: isSelected ? Colors.white : event.getColor(),
          size: 32,
        ),
        trailing: Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
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
                      );
                    },
                  )
                : const SizedBox(),
            IconButton(
              onPressed: onInfoPressed,
              icon: const Icon(Icons.info),
            ),
          ],
        ),
      ),
    );
  }
}
