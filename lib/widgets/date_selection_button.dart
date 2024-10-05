import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

class DateSelectionButtonController {
  DateTime? firstDate, lastDate;

  DateTime _date;
  bool _noDate;

  DateTime get date => _date;
  set date(DateTime? dateTime) {
    if (dateTime == null) {
      _noDate = true;
    } else {
      _date = dateTime;
    }

    for (var element in onDateChangedCBs) {
      element.call(_noDate ? null : dateTime);
    }
  }

  bool get noDate => _noDate;
  set noDate(bool noDate) {
    _noDate = noDate;

    for (var element in onDateChangedCBs) {
      element.call(_noDate ? null : _date);
    }
  }

  DateSelectionButtonController({
    required DateTime date,
    bool noDate = false,
  })  : _date = date,
        _noDate = noDate;

  List<void Function(DateTime?)> onDateChangedCBs = [];
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
      onPressed: widget.controller.noDate
          ? null
          : () async {
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
