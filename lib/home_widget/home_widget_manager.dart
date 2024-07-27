import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/utils.dart';

class HomeWidgetManager {
  static const groupID = "group.schulapp";
  static const qualifiedAndroidName = "com.flologames.schulapp.TimetableOneDay";
  static const timetableId = "timetable";
  static const timesColorKey = "timesColor";

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;
    await HomeWidget.setAppGroupId(groupID);
    _isInitialized = true;
  }

  static Future<void> update(Timetable timetable, BuildContext? context) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;
    if (!_isInitialized) return;

    try {
      final json = timetable.toJson();

      json[timesColorKey] = Utils.colorToJson(Colors.transparent);
      // json["timesColor"] = Utils.colorToJson(Theme.of(context).scaffoldBackgroundColor);

      String jsonString = jsonEncode(json);

      await HomeWidget.saveWidgetData(timetableId, jsonString);

      await HomeWidget.updateWidget(
        qualifiedAndroidName: qualifiedAndroidName,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> updateWithDefaultTimetable({
    BuildContext? context,
  }) async {
    final timetable = Utils.getHomescreenTimetable();

    if (timetable == null) return;

    return HomeWidgetManager.update(timetable, context);
  }

  static Future<void> requestToAddHomeWidget() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;
    if (!_isInitialized) return;

    bool? supported = await HomeWidget.isRequestPinWidgetSupported();
    supported ??= false;

    if (!supported) {
      return;
    }

    await HomeWidget.requestPinWidget(
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }
}
