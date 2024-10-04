import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

class DateSelectionButtonController {
  DateTime? firstDate, lastDate;

  DateTime _date;
  DateTime get date => _date;
  set date(DateTime dateTime) {
    _date = dateTime;

    for (var element in onDateChangedCBs) {
      element.call(dateTime);
    }
  }

  DateSelectionButtonController({required DateTime date}) : _date = date;

  List<Function(DateTime)> onDateChangedCBs = [];
}

class DateSelectionButton extends StatefulWidget {
  final DateSelectionButtonController controller;

  const DateSelectionButton({super.key, required this.controller});

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
          firstDate: widget.controller.firstDate ??
              DateTime.fromMillisecondsSinceEpoch(0),
          //This number is the max
          lastDate: widget.controller.lastDate ??
              DateTime.fromMillisecondsSinceEpoch(8640000000000000),
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
