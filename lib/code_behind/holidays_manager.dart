import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HolidaysManager {
  static const String cacheKey = 'cached_holidays';
  static const String cacheStateKey = "cached_holiday_state";
  static const String cacheYearKey = "cached_holiday_year";

  static const nameKey = "name";
  static const startKey = "start";
  static const endKey = "end";
  static const stateCodeKey = "stateCode";
  static const slugKey = "slug";

  //https://ferien-api.de/
  static const apiUrl = "https://ferien-api.de/api/v1/holidays/";

  HolidaysManager();

  Future<Holidays?> getCurrOrNextHolidayForState({
    required String stateApiCode,
  }) async {
    final now = DateTime.now().copyWith(
      microsecond: 0,
      millisecond: 0,
      second: 0,
      minute: 0,
      hour: 0,
    );

    List<Holidays> allHolidays =
        await getAllHolidaysForState(stateApiCode: stateApiCode);

    int latestHolidaysIndex = -1;

    for (int i = 0; i < allHolidays.length; i++) {
      final currHolidays = allHolidays[i];
      if (currHolidays.end.isBefore(now)) {
        continue;
      }

      if (latestHolidaysIndex == -1 ||
          allHolidays[latestHolidaysIndex].start.isAfter(currHolidays.start)) {
        latestHolidaysIndex = i;
      }
    }

    if (latestHolidaysIndex == -1) return null;

    return allHolidays[latestHolidaysIndex];
  }

  Future<List<Holidays>> getAllHolidaysForState({
    required String stateApiCode,
    bool withCustomHolidays = true,
    bool sorted = true,
  }) async {
    final currYear = DateTime.now().year;
    final cachedYear = await _getCachedYear();
    final cachedStateCode = await _getCachedStateCode();

    if (cachedYear != null &&
        currYear == cachedYear &&
        cachedStateCode != null &&
        stateApiCode == cachedStateCode &&
        stateApiCode.isNotEmpty) {
      List<Holidays>? cachedHolidays = await _getCachedHolidayData();
      if (cachedHolidays != null) {
        if (withCustomHolidays) {
          cachedHolidays.addAll(getCustomHolidays());
        }
        if (sorted) {
          cachedHolidays.sort(
            (a, b) => a.start.compareTo(b.start),
          );
        }
        return cachedHolidays;
      }
    }

    List<Holidays> allHolidays = [];
    if (stateApiCode.isNotEmpty) {
      final url = Uri.parse("$apiUrl$stateApiCode/$currYear");

      String responseBody = "";
      try {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(url);
        final response = await request.close();

        if (response.statusCode == HttpStatus.ok) {
          responseBody = await response.transform(utf8.decoder).join();

          List<Map<String, dynamic>> jsonList =
              (jsonDecode(responseBody) as List).cast();

          allHolidays = _jsonToHolidaysList(jsonList);
        } else {
          debugPrint('Failed to load post: ${response.statusCode}');
          if (withCustomHolidays) {
            allHolidays = getCustomHolidays();
            if (sorted) {
              allHolidays.sort(
                (a, b) => a.start.compareTo(b.start),
              );
            }
            return allHolidays;
          }
          return [];
        }
      } catch (e) {
        debugPrint('Error: $e');
        return [];
      }

      if (allHolidays.isNotEmpty) {
        _cacheHolidayData(
          holidaysString: responseBody,
          stateCode: stateApiCode,
          year: currYear,
        );
      }
    }

    if (withCustomHolidays) {
      allHolidays.addAll(getCustomHolidays());
    }

    if (sorted) {
      allHolidays.sort(
        (a, b) => a.start.compareTo(b.start),
      );
    }

    return allHolidays;
  }

  static List<Holidays> getCustomHolidays() {
    try {
      String holidaysString = TimetableManager().settings.getVar<String>(
            Settings.customHolidaysKey,
          );

      List<Map<String, dynamic>> jsonList =
          (jsonDecode(holidaysString) as List).cast();

      return _jsonToHolidaysList(jsonList);
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  static void setCustomHolidays(List<Holidays> customHolidays) {
    try {
      List<Map<String, dynamic>> holidaysJson =
          _holidaysListToJson(customHolidays);

      String jsonString = jsonEncode(holidaysJson);

      TimetableManager().settings.setVar<String>(
            Settings.customHolidaysKey,
            jsonString,
          );
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  static List<Map<String, dynamic>> _holidaysListToJson(List<Holidays> list) {
    List<Map<String, dynamic>> jsonList = [];

    for (final holidays in list) {
      jsonList.add(
        {
          nameKey: holidays.name,
          startKey: holidays.start.toIso8601String(),
          endKey: holidays.end.toIso8601String(),
          stateCodeKey: holidays.stateCode,
          slugKey: holidays.slug,
        },
      );
    }

    return jsonList;
  }

  static List<Holidays> _jsonToHolidaysList(
      List<Map<String, dynamic>> jsonList) {
    return List.generate(
      jsonList.length,
      (index) {
        final json = jsonList[index];
        final start = DateTime.parse(json[startKey]);
        final end = DateTime.parse(json[endKey]);
        String stateCode = json[stateCodeKey];
        String name = json[nameKey];
        String slug = json[slugKey];

        return Holidays(
          start: start,
          end: end,
          stateCode: stateCode,
          name: name,
          slug: slug,
        );
      },
    );
  }

  static Future<void> _cacheHolidayData({
    required String holidaysString,
    required int year,
    required String stateCode,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, holidaysString);
    await prefs.setString(cacheStateKey, stateCode);
    await prefs.setInt(cacheYearKey, year);
  }

  static Future<List<Holidays>?> _getCachedHolidayData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(cacheKey);
    if (encodedData != null) {
      final List<Map<String, dynamic>> jsonList =
          (jsonDecode(encodedData) as List).cast();
      return _jsonToHolidaysList(jsonList);
    }
    return null;
  }

  static Future<int?> _getCachedYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(cacheYearKey);
  }

  static Future<String?> _getCachedStateCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(cacheStateKey);
  }
}
