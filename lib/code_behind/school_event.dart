import 'package:flutter/material.dart';

class TodoEvent {
  static const IconData homeworkIcon = Icons.assignment;
  static const IconData testIcon = Icons.edit;
  static const IconData examIcon = Icons.school;
  static const String _nameKey = "name";
  static const String _linkedSubjectNameKey = "linkedSubjectName";
  static const int maxNameLength = 25;

  //identifyer set at runtime
  int key;
  final String name;
  final String linkedSubjectName;

  DateTime endTime;
  TodoType type;

  String desciption;
  bool finished;

  static const int maxDescriptionLength = 150;

  TodoEvent({
    required this.key,
    required this.name,
    required this.linkedSubjectName,
    required this.endTime,
    required this.type,
    required this.desciption,
    required this.finished,
  });

  bool isExpired() {
    if (finished) return false;

    return endTime.isBefore(DateTime.now());
  }

  String getEndTimeString() {
    if (finished) return "Finished";

    Duration timeLeft = endTime.difference(DateTime.now());

    if (timeLeft.inSeconds <= 0) {
      if (timeLeft.inDays == 0) {
        return "Expired ${timeLeft.inHours.abs()} hours ago";
      }
      return "Expired ${timeLeft.inDays.abs()} days ago";
    }

    if (timeLeft.inDays == 0) {
      return "In ${timeLeft.inHours} hours";
    }

    return "In ${timeLeft.inDays} days";
  }

  IconData getIcon() {
    switch (type) {
      case TodoType.exam:
        return examIcon;
      case TodoType.test:
        return testIcon;
      case TodoType.homework:
        return homeworkIcon;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      _nameKey: name,
      _linkedSubjectNameKey: linkedSubjectName,
    };
  }

  TodoEvent fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  static int compareType(TodoType a, TodoType b) {
    int aValue = typeToInt(a);
    int bValue = typeToInt(b);

    if (aValue > bValue) return 1;
    if (aValue < bValue) return -1;

    return 0;
  }

  static int typeToInt(TodoType type) {
    switch (type) {
      case TodoType.exam:
        return 10;
      case TodoType.test:
        return 5;
      case TodoType.homework:
        return 1;
    }
  }

  Color getColor() {
    if (finished) {
      return Colors.green;
    }
    switch (type) {
      case TodoType.exam:
        return Colors.red;
      case TodoType.test:
        return Colors.orange;
      case TodoType.homework:
        return Colors.yellow;
    }
  }
}

enum TodoType {
  exam,
  test,
  homework,
}
