import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/widgets/date_selection_button.dart';

class TimeSelectionButton extends StatefulWidget {
  final DateSelectionButtonController controller;

  const TimeSelectionButton({super.key, required this.controller});

  @override
  State<TimeSelectionButton> createState() => _TimeSelectionButtonState();
}

class _TimeSelectionButtonState extends State<TimeSelectionButton> {
  @override
  void initState() {
    widget.controller.onDateChangedCBs.add((p0) {
      if (!mounted) return;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
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
}
