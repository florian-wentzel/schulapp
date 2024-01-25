import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_event.dart';

// ignore: must_be_immutable
class TodoEventListItemWidget extends StatelessWidget {
  TodoEvent event;
  // Animation<double> animation;
  void Function() onPressed;
  void Function() onInfoPressed;
  void Function() onDeleteSwipe;

  TodoEventListItemWidget({
    super.key,
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
    return Hero(
      tag: event,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          onTap: onPressed,
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
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.edit,
              //   ),
              // ),
              Text(
                event.getEndTimeString(),
                style: event.isExpired()
                    ? Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.red)
                    : Theme.of(context).textTheme.bodyLarge,
              ),
              // Checkbox(
              //   onChanged: (value) {
              //     onPressed.call();
              //   },
              //   value: event.finished,
              // ),
              IconButton(
                onPressed: onInfoPressed,
                icon: const Icon(Icons.info),
              ),
              // ElevatedButton(
              //   onPressed: () {},
              //   child: const Text("FINISHED"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
