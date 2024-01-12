import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';

// ignore: must_be_immutable
class TimeToNextLessonWidget extends StatefulWidget {
  Timetable timetable;
  void Function() onNewLessonCB;

  TimeToNextLessonWidget({
    super.key,
    required this.timetable,
    required this.onNewLessonCB,
  });

  @override
  State<TimeToNextLessonWidget> createState() => _TimeToNextLessonWidgetState();
}

class _TimeToNextLessonWidgetState extends State<TimeToNextLessonWidget> {
  String currTimeString = "00:00";
  SchoolTime? _currTime;
  Timer? _timer;

  @override
  void initState() {
    _currTime = widget.timetable.getCurrentLessonOrBreakTime();
    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
      onTimer,
    );

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void onTimer(Timer timer) {
    if (_currTime == null) {
      _currTime = widget.timetable.getCurrentLessonOrBreakTime();
      _onNewLesson();
    }

    currTimeString = _getCurrTimeString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    onTimer(Timer(Duration.zero, () {}));
    return Center(
      child: Text(
        "Times\n$currTimeString",
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getCurrTimeString() {
    if (_currTime == null) {
      return "";
    }

    int nowInt = Utils.nowInSeconds();
    int timeLeftInt = _currTime!.end.toSeconds() - nowInt;

    if (timeLeftInt <= 0) {
      _currTime = null;
    }

    int hours = (timeLeftInt ~/ 3600) % 24;
    int minutes = (timeLeftInt ~/ 60) % 60;
    int seconds = timeLeftInt % 60;

    String hoursStr = hours < 10 ? "0$hours" : hours.toString();
    String minutesStr = minutes < 10 ? "0$minutes" : minutes.toString();
    String secondsStr = seconds < 10 ? "0$seconds" : seconds.toString();

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  void _onNewLesson() {
    widget.onNewLessonCB.call();
  }
}
