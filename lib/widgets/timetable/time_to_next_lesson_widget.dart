import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

// ignore: must_be_immutable
class TimeToNextLessonWidget extends StatefulWidget {
  List<SchoolTime> ttSchoolTimes;
  void Function() onNewLessonCB;

  TimeToNextLessonWidget({
    super.key,
    required this.ttSchoolTimes,
    required this.onNewLessonCB,
  });

  @override
  State<TimeToNextLessonWidget> createState() => _TimeToNextLessonWidgetState();
}

class _TimeToNextLessonWidgetState extends State<TimeToNextLessonWidget> {
  String _currTimeString = "";
  SchoolTime? _currTime;
  Timer? _timer;

  @override
  void initState() {
    _currTime = _getCurrentLessonOrBreakTime();
    _currTimeString = _getCurrTimeString();
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
      _currTime = _getCurrentLessonOrBreakTime();
      if (_currTime != null) {
        _onNewLesson();
      }
    }

    _currTimeString = _getCurrTimeString();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizationsManager.localizations.strTimes,
            textAlign: TextAlign.center,
          ),
          Visibility(
            visible: _currTimeString.isNotEmpty,
            child: Text(
              _currTimeString,
              textAlign: TextAlign.center,
            ),
          ),
        ],
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

  SchoolTime? _getCurrentLessonOrBreakTime() {
    final timeBeforeFirstLessonStartInt =
        const TimeOfDay(hour: 0, minute: 10).toSeconds();

    final int nowInt = Utils.nowInSeconds();
    final int firstInt = widget.ttSchoolTimes.first.start.toSeconds();
    final int lastInt = widget.ttSchoolTimes.last.end.toSeconds();

    //TODO: wenn firstDouble = 0 dann kommt bestimm nur trash bei raus
    if (nowInt < firstInt - timeBeforeFirstLessonStartInt || nowInt > lastInt) {
      return null;
    }

    SchoolTime? currTime;

    for (int i = widget.ttSchoolTimes.length - 1; i >= 0; i--) {
      SchoolTime time = widget.ttSchoolTimes[i];
      if (nowInt > time.end.toSeconds()) {
        continue;
      }
      currTime = time;
      if (nowInt > time.start.toSeconds()) {
        continue;
      }
      if (i - 1 < 0) continue;

      currTime = SchoolTime(
        start: widget.ttSchoolTimes[i - 1].end,
        end: time.start,
      );
    }

    return currTime;
  }
}
