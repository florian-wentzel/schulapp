import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

class DateSelectionButtonController {
  DateTime date;

  DateSelectionButtonController({required this.date});
}

// ignore: must_be_immutable
class DateSelectionButton extends StatefulWidget {
  DateSelectionButtonController controller;

  DateSelectionButton({super.key, required this.controller});

  @override
  State<DateSelectionButton> createState() => _DateSelectionButtonState();
}

class _DateSelectionButtonState extends State<DateSelectionButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        DateTime? dateTime = await showDatePicker(
          context: context,
          //min
          firstDate: DateTime.fromMillisecondsSinceEpoch(0),
          //This number is the max
          lastDate: DateTime.fromMillisecondsSinceEpoch(8640000000000000),
        );

        if (dateTime == null) return;

        widget.controller.date = dateTime.copyWith(
          hour: widget.controller.date.hour,
          minute: widget.controller.date.minute,
          second: widget.controller.date.second,
          millisecond: widget.controller.date.millisecond,
          microsecond: widget.controller.date.microsecond,
        );
        setState(() {});
      },
      child: Text(Utils.dateToString(widget.controller.date)),
    );
  }
}
