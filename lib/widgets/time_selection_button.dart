import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/date_selection_button.dart';

// ignore: must_be_immutable
class TimeSelectionButton extends StatefulWidget {
  DateSelectionButtonController controller;

  TimeSelectionButton({super.key, required this.controller});

  @override
  State<TimeSelectionButton> createState() => _TimeSelectionButtonState();
}

class _TimeSelectionButtonState extends State<TimeSelectionButton> {
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
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime == null) return;

              final date = widget.controller.date;
              widget.controller.date = DateTime(
                date.year,
                date.month,
                date.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              setState(() {});
            },
      child: Text(Utils.timeToString(widget.controller.date)),
    );
  }

  void _onValueChanged() {
    setState(() {});
  }
}
