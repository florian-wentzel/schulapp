import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/holidays.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HolidaysManager {
  static const String cacheHolidaysKey = 'cached_holidays';
  static const String cacheStateKey = "cached_holiday_state";
  static const String cacheYearKey = "cached_holiday_year";

  //Feiertage
  static const String cacheForPublicHolidaysKey = 'cached_public_holidays';
  static const String cacheStateForPublicHolidaysKey =
      "cached_public_holiday_state";
  static const String cacheYearForPublicHolidaysKey =
      "cached_public_holiday_year";

  static const nameKey = "name";
  static const startKey = "start";
  static const endKey = "end";
  static const stateCodeKey = "stateCode";
  static const slugKey = "slug";

  //https://ferien-api.de/
  static const apiUrl = "https://ferien-api.de/api/v1/holidays/";
  //Ferien
  static const apiForPublicHolidaysUrl = "https://get.api-feiertage.de?";

  static List<Holidays>? _loadedHolidays;

  HolidaysManager();

  static Future<Holidays?> getCurrOrNextHolidayForState({
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

  static Future<List<Holidays>> getAllHolidaysForState({
    required String stateApiCode,
    bool withCustomHolidays = true,
    bool sorted = true,
  }) async {
    if (_loadedHolidays != null) {
      return _loadedHolidays!;
    }

    final currYear = DateTime.now().year;
    final cachedYear = await _getCachedYear();
    final cachedStateCode = await _getCachedStateCode();

    List<Holidays> allPublicHolidays =
        await _getPublicHolidays(stateApiCode) ?? [];

    if (cachedYear != null &&
        currYear == cachedYear &&
        cachedStateCode != null &&
        stateApiCode == cachedStateCode &&
        stateApiCode.isNotEmpty) {
      _loadedHolidays = await _getCachedHolidayData(
        cacheHolidaysKey,
      );
      if (_loadedHolidays != null) {
        _loadedHolidays!.addAll(allPublicHolidays);
        if (withCustomHolidays) {
          _loadedHolidays!.addAll(getCustomHolidays());
        }
        if (sorted) {
          _loadedHolidays!.sort(
            (a, b) => a.start.compareTo(b.start),
          );
        }
        return _loadedHolidays!;
      }
    }

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

          _loadedHolidays == null
              ? _loadedHolidays = _jsonToHolidaysList(jsonList)
              : _loadedHolidays!.addAll(
                  _jsonToHolidaysList(jsonList),
                );
        } else {
          debugPrint('Failed to load holidays: ${response.statusCode}');
          if (withCustomHolidays) {
            _loadedHolidays = getCustomHolidays();
            _loadedHolidays!.addAll(allPublicHolidays);

            if (sorted) {
              _loadedHolidays!.sort(
                (a, b) => a.start.compareTo(b.start),
              );
            }
            return _loadedHolidays!;
          }
          return allPublicHolidays;
        }
      } catch (e) {
        debugPrint('Error: $e');
        return allPublicHolidays;
      }

      if (_loadedHolidays!.isNotEmpty) {
        _cacheHolidayData(
          holidaysString: responseBody,
          stateCode: stateApiCode,
          year: currYear,
        );
      }
    }

    _loadedHolidays ??= [];

    if (withCustomHolidays) {
      _loadedHolidays!.addAll(getCustomHolidays());
    }

    _loadedHolidays!.addAll(allPublicHolidays);

    if (sorted) {
      _loadedHolidays!.sort(
        (a, b) => a.start.compareTo(b.start),
      );
    }

    return _loadedHolidays!;
  }

  static Future<Holidays?> getRunningHolidays(DateTime dateTime) async {
    String? stateCode = TimetableManager().settings.getVar(
          Settings.selectedFederalStateCodeKey,
        );

    if (stateCode == null) return null;

    List<Holidays> allHolidays = await getAllHolidaysForState(
      stateApiCode: stateCode,
    );

    for (final holidays in allHolidays) {
      if (dateTime == holidays.start || dateTime == holidays.end) {
        return holidays;
      }
      if (dateTime.isAfter(holidays.start) && dateTime.isBefore(holidays.end)) {
        return holidays;
      }
    }

    return null;
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

      removeLoadedHolidays();
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
    await prefs.setString(cacheHolidaysKey, holidaysString);
    await prefs.setString(cacheStateKey, stateCode);
    await prefs.setInt(cacheYearKey, year);
  }

  static Future<void> _cachePublicHolidayData({
    required String holidaysString,
    required int year,
    required String stateCode,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheForPublicHolidaysKey, holidaysString);
    await prefs.setString(cacheStateForPublicHolidaysKey, stateCode);
    await prefs.setInt(cacheYearForPublicHolidaysKey, year);
  }

  static Future<List<Holidays>?> _getCachedHolidayData(String cacheKey) async {
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

  static Future<int?> _getCachedYearForPublicHolidays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(cacheYearForPublicHolidaysKey);
  }

  static Future<String?> _getCachedStateCodeForPublicHolidays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(cacheStateForPublicHolidaysKey);
  }

  static Future<List<Holidays>?> _getPublicHolidays(String stateCode) async {
    final currYear = DateTime.now().year;
    final cachedYear = await _getCachedYearForPublicHolidays();
    final cachedStateCode = await _getCachedStateCodeForPublicHolidays();

    if (cachedYear != null &&
        currYear == cachedYear &&
        cachedStateCode != null &&
        stateCode == cachedStateCode &&
        stateCode.isNotEmpty) {
      List<Holidays>? cachedHolidays = await _getCachedHolidayData(
        cacheForPublicHolidaysKey,
      );
      if (cachedHolidays != null) {
        return cachedHolidays;
      }
    }

    List<Holidays> publicHolidays = [];
    if (stateCode.isNotEmpty) {
      final url = Uri.parse(
          "${apiForPublicHolidaysUrl}years=$currYear&states=${stateCode.toLowerCase()}");

      String responseBody = "";
      try {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(url);
        final response = await request.close();

        if (response.statusCode == HttpStatus.ok) {
          responseBody = await response.transform(utf8.decoder).join();

          Map<String, dynamic> json = jsonDecode(responseBody);

          final success = json["status"] == "success";

          if (!success) {
            return null;
          }

          publicHolidays = _jsonToPublicHolidaysList(
            (json["feiertage"] as List).cast<Map<String, dynamic>>(),
            stateCode,
          );
        } else {
          debugPrint('Failed to load holidays: ${response.statusCode}');

          return null;
        }
      } catch (e) {
        debugPrint('Error: $e');
        return null;
      }

      if (publicHolidays.isNotEmpty) {
        _cachePublicHolidayData(
          holidaysString: jsonEncode(
            _holidaysListToJson(publicHolidays),
          ),
          stateCode: stateCode,
          year: currYear,
        );

        return publicHolidays;
      }
    }

    return null;
  }

  static List<Holidays> _jsonToPublicHolidaysList(
      List<Map<String, dynamic>> jsonList, String stateCode) {
    return List.generate(
      jsonList.length,
      (index) {
        final json = jsonList[index];
        final startAndEnd = DateTime.parse(json["date"]);
        String name = json["fname"];
        String slug = "";

        return Holidays(
          start: startAndEnd,
          end: startAndEnd,
          stateCode: stateCode,
          name: name,
          slug: slug,
        );
      },
    );
  }

  static void removeLoadedHolidays() {
    _loadedHolidays = null;
  }
}
