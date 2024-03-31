import 'dart:convert';
import 'dart:io';

import 'package:schulapp/code_behind/holidays.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HolidaysManager {
  static const String cacheKey = 'cached_holidays';
  static const String cacheStateKey = "cached_holiday_state";
  static const String cacheYearKey = "cached_holiday_year";

  //https://ferien-api.de/
  static const apiUrl = "https://ferien-api.de/api/v1/holidays/";

  HolidaysManager();

  Future<Holidays?> getCurrOrNextHolidayForState({
    required String stateApiCode,
  }) async {
    List<Holidays> allHolidays =
        await getAllHolidaysForState(stateApiCode: stateApiCode);

    for (Holidays holidays in allHolidays) {
      if (holidays.end.isBefore(DateTime.now())) {
        continue;
      }
      return holidays;
    }
    return null;
  }

  Future<List<Holidays>> getAllHolidaysForState({
    required String stateApiCode,
  }) async {
    final currYear = DateTime.now().year;
    final cachedYear = await _getCachedYear();
    final cachedStateCode = await _getCachedStateCode();

    if (cachedYear != null &&
        currYear == cachedYear &&
        cachedStateCode != null &&
        stateApiCode == cachedStateCode) {
      List<Holidays>? cachedHolidays = await _getCachedHolidayData();
      if (cachedHolidays != null) {
        return cachedHolidays;
      }
    }

    final url = Uri.parse("$apiUrl$stateApiCode/$currYear");

    List<Holidays> allHolidays = [];
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
        print('Failed to load post: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }

    if (allHolidays.isNotEmpty) {
      _cacheHolidayData(
        holidaysString: responseBody,
        stateCode: stateApiCode,
        year: currYear,
      );
    }

    return allHolidays;
  }

  static List<Holidays> _jsonToHolidaysList(
      List<Map<String, dynamic>> jsonList) {
    return List.generate(
      jsonList.length,
      (index) {
        final json = jsonList[index];
        final start = DateTime.parse(json["start"]);
        final end = DateTime.parse(json["end"]);
        String stateCode = json["stateCode"];
        String name = json["name"];
        String slug = json["slug"];

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
