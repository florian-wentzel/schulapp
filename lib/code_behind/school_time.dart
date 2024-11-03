import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';

class SchoolTime {
  static const startKey = "start";
  static const endKey = "end";

  TimeOfDay start;
  TimeOfDay end;

  SchoolTime({
    required this.start,
    required this.end,
  });

  String getStartString() {
    String hour = start.hour < 10 ? "0${start.hour}" : start.hour.toString();
    String minute =
        start.minute < 10 ? "0${start.minute}" : start.minute.toString();
    return "$hour : $minute";
  }

  String getEndString() {
    String hour = end.hour < 10 ? "0${end.hour}" : end.hour.toString();
    String minute = end.minute < 10 ? "0${end.minute}" : end.minute.toString();
    return "$hour : $minute";
  }

  Map<String, dynamic> toJson() {
    return {
      startKey: Utils.timeToJson(start),
      endKey: Utils.timeToJson(end),
    };
  }

  static SchoolTime fromJson(Map<String, dynamic> json) {
    TimeOfDay start = Utils.jsonToTime(json[startKey]);
    TimeOfDay end = Utils.jsonToTime(json[endKey]);

    return SchoolTime(start: start, end: end);
  }

  bool isCurrentlyRunning() {
    DateTime now = DateTime.now();

    // Convert start and end to DateTime for proper comparison
    DateTime startDate = DateTime(2023, 1, 1, start.hour, start.minute);
    DateTime endDate = DateTime(2023, 1, 1, end.hour, end.minute);

    // Convert now to DateTime for proper comparison
    DateTime nowDate = DateTime(2023, 1, 1, now.hour, now.minute, now.second);

    // Check if nowDate is between startDate and endDate
    return nowDate.isAfter(startDate) && nowDate.isBefore(endDate);
  }

  SchoolTime clone() {
    return SchoolTime(
      start: start.add(),
      end: end.add(),
    );
  }
}
