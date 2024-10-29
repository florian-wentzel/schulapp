import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';

class DateSelectionButtonController with ChangeNotifier {
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

    notifyListeners();
  }

  bool get noDate => _noDate;
  set noDate(bool noDate) {
    _noDate = noDate;

    notifyListeners();
  }

  DateSelectionButtonController({
    required DateTime date,
    this.firstDate,
    this.lastDate,
    bool noDate = false,
  })  : _date = date,
        _noDate = noDate;
}

class DateSelectionButton extends StatefulWidget {
  final DateSelectionButtonController controller;
  final void Function(DateTime date)? onDateSelected;

  const DateSelectionButton({
    super.key,
    required this.controller,
    this.onDateSelected,
  });

  @override
  State<DateSelectionButton> createState() => _DateSelectionButtonState();
}

class _DateSelectionButtonState extends State<DateSelectionButton> {
  @override
  void initState() {
    widget.controller.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onValueChanged);
    super.dispose();
  }

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

              widget.onDateSelected?.call(dateTime);

              setState(() {});
            },
      child: Text(Utils.dateToString(widget.controller.date)),
    );
  }

  void _onValueChanged() {
    setState(() {});
  }
}
