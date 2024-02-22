import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/widgets/periodic_updating_widget.dart';

// ignore: must_be_immutable
class TodoEventListItemWidget extends StatelessWidget {
  TodoEvent event;
  bool removeHero;
  // Animation<double> animation;
  void Function() onPressed;
  void Function() onInfoPressed;
  void Function() onDeleteSwipe;

  TodoEventListItemWidget({
    super.key,
    this.removeHero = false,
    required this.event,
    required this.onInfoPressed,
    required this.onPressed,
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
        onLongPress: onInfoPressed,
        subtitle: Text(
          event.name,
        ),
        title: Text(
          event.linkedSubjectName,
          style: TextStyle(
            decoration: event.finished ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: Icon(
          event.getIcon(),
          color: event.getColor(),
          size: 32,
        ),
        trailing: Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PeriodicUpdatingWidget(
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
            ),
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
