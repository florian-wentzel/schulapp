import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/calendar_todo_event_style.dart';
import 'package:schulapp/code_behind/google_drive/confilct_resolution.dart';
import 'package:schulapp/code_behind/grading_system_manager.dart';
import 'package:schulapp/code_behind/notification_schedule.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

import 'grade_group.dart';

class SettingsVar<T> {
  String key;

  T? _value;
  T Function() defaultValue;

  T? Function(String? value)? loadCustomType;
  String? Function(T type)? saveCustomType;

  //für settings die noch nicht gespeichert werden aber übersetzt werden müssen
  final bool _alwaysReturnDefaultValue;
  final T Function(T? value)? _onlyReturnCopy;

  //sollte man setzen wenn der default wert nicht null zurück gibt
  final T Function()? _canBeNull;

  final void Function(T value)? _onSetterCalled;

  SettingsVar({
    required this.key,
    required this.defaultValue,
    this.loadCustomType,
    this.saveCustomType,
    T? value,
    T Function(T? value)? onlyReturnCopy,
    void Function(T value)? onSetterCalled,
    bool alwaysReturnDefaultValue = false,
    T Function()? canBeNull,
  })  : _value = value,
        _alwaysReturnDefaultValue = alwaysReturnDefaultValue,
        _onSetterCalled = onSetterCalled,
        _onlyReturnCopy = onlyReturnCopy,
        _canBeNull = canBeNull;

  T get value {
    if (_alwaysReturnDefaultValue) {
      return defaultValue.call();
    }
    if (_onlyReturnCopy != null) {
      return _onlyReturnCopy.call(_value);
    }
    if (_canBeNull != null && _value == null) {
      return _canBeNull.call();
    }

    return _value ?? defaultValue.call();
  }

  set value(T value) {
    _onSetterCalled?.call(value);

    _value = value; // ?? defaultValue.call();
  }

  dynamic toNormalType() {
    try {
      final sct = saveCustomType;

      if (sct == null) {
        return value;
      }

      return sct.call(value);
    } catch (e) {
      return value;
    }
  }

  void fromNormalType(dynamic type) {
    try {
      final lct = loadCustomType;

      if (lct != null) {
        _value = lct.call(type);
      } else {
        _value = type;
      }

      if (_value == null && _canBeNull != null) {
        _value = _canBeNull.call();
        return;
      }

      _value ??= defaultValue.call();
    } catch (e) {
      value = defaultValue.call();
    }
  }
}

class Settings {
  static const mainTimetableNameKey = "mainTimetable";
  static const mainSemesterNameKey = "mainSemester";
  static const defaultGradeGroupsKey = "defaultGradeGroups";
  static const showLessonNumbersKey = "showLessonNumbers";
  static const openMainSemesterAutomaticallyKey =
      "openMainSemesterAutomatically";
  static const showTasksOnHomeScreenKey = "showTasksOnHomeScreen";
  static const themeModeKey = "theme";
  static const languageCodeKey = "language";
  static const hiddenDebugModeKey = "hiddenDebugMode";
  //represents the API-Code
  static const selectedFederalStateCodeKey = "selectedFederalState";
  static const lastUsedVersionKey = "lastUsedVersion";
  static const customHolidaysKey = "customHolidays";
  static const sortSubjectsByKey = "sortSubjectsBy";
  static const pinWeightedSubjectsAtTopKey = "pinWeightedSubjectsAtTop";
  static const selectedGradeSystemKey = "selectedGradeSystem";
  static const usernameKey = "username";
  static const securePasswordKey = "password";
  static const highContrastTextOnHomescreenKey = "highContrastTextOnHomescreen";
  static const reducedClassHoursEnabledKey = "reducedClassHoursEnabled";
  static const reducedClassHoursKey = "reducedClassHours";
  static const paulDessauPdfBytesKey = "paulDessauPdfBytes";
  static const paulDessauPdfBytesSavedDateKey = "paulDessauPdfBytesSavedDate";
  static const notificationScheduleListKey = "notificationScheduleList";
  static const notificationScheduleEnabledKey = "notificationScheduleEnabled";
  static const extraTimetableOnHomeScreenKey = "extraTimetableOnHomeScreen";
  static const showTutorialInCreateTimetableScreenKey =
      "showTutorialInCreateTimetableScreen";
  static const showTutorialOnHomeScreenKey = "showTutorialInHomeScreen";
  static const termsOfServiceGoFileIoAllowed =
      "termsOfServiceGoFileIoAllowedKey";
  static const lastAskForReviewDateKey = "lastAskForReviewDate";
  static const calendarShowTodoEventColorKey = "calendarShowTodoEventColor";
  static const showNextDayAfterDayEndKey = "showNextDayAfterDayEnd";
  static const showAlwaysWeekTimetableKey = "showAlwaysWeekTimetable";
  static const showImportTodoEventsWarnigKey = "showImportTodoEventsWarnig";
  static const showAbiAverageNotAlwaysCorrectInfoKey =
      "showAbiAverageNotAlwaysCorrect";
  static const lessonReminderNotificationEnabledKey =
      "lessonNotificationEnabled";
  static const preLessonReminderNotificationDurationKey =
      "preLessonReminderNotificationDuration";
  static const lastSyncTimeKey = "lastSyncTime";
  static const syncConflictResolutionKey = "syncConflictResolution";

  static const waitBetweenAskForReviewDuration = Duration(days: 3);

  static final key = encrypt.Key.fromUtf8("a/wdkaw1ln=921jt48wadan249Bamd=#");
  static final _iv = encrypt.IV.fromUtf8("a2lA.8_n&dXa0?.e");

  static encrypt.Encrypter get _encrypter =>
      encrypt.Encrypter(encrypt.AES(key));

  static int decimalPlaces = 1;

  final List<SettingsVar> _variablesList = [
    ///if [null] firstTimetable shown
    SettingsVar<String?>(
      key: mainTimetableNameKey,
      canBeNull: () => null,
      defaultValue: () => null,
    ),
    SettingsVar<String?>(
      key: selectedFederalStateCodeKey,
      canBeNull: () => null,
      defaultValue: () => null,
    ),
    SettingsVar<String?>(
      key: mainSemesterNameKey,
      defaultValue: () => null,
      canBeNull: () => null,
    ),
    SettingsVar<String>(
      key: customHolidaysKey,
      defaultValue: () => "[]",
    ),
    SettingsVar<GradingSystem>(
      key: selectedGradeSystemKey,
      defaultValue: () => GradingSystem.grade_0_15,
      saveCustomType: (type) {
        return type.toString();
      },
      loadCustomType: (type) {
        if (type == GradingSystem.grade_0_15.toString()) {
          return GradingSystem.grade_0_15;
        }
        if (type == GradingSystem.grade_1_6.toString()) {
          return GradingSystem.grade_1_6;
        }
        if (type == GradingSystem.grade_6_1.toString()) {
          return GradingSystem.grade_6_1;
        }
        if (type == GradingSystem.grade_A_F.toString()) {
          return GradingSystem.grade_A_F;
        }
        return null;
      },
    ),
    SettingsVar<ThemeMode>(
      key: themeModeKey,
      defaultValue: () => ThemeMode.system,
      saveCustomType: (type) {
        return type.toString();
      },
      loadCustomType: (value) {
        if (value == ThemeMode.light.toString()) {
          return ThemeMode.light;
        }
        if (value == ThemeMode.system.toString()) {
          return ThemeMode.system;
        }
        if (value == ThemeMode.dark.toString()) {
          return ThemeMode.dark;
        }
        return null;
      },
    ),
    // SettingsVar<>(key: key, defaultValue: defaultValue,),
    //for now we only save the api key
    SettingsVar<String?>(
      key: languageCodeKey,
      defaultValue: () => null,
      canBeNull: () => null,
    ),
    SettingsVar<String>(
      key: sortSubjectsByKey,
      defaultValue: () => SchoolSemester.sortByGradeValue,
    ),
    SettingsVar<bool>(
      key: pinWeightedSubjectsAtTopKey,
      defaultValue: () => false,
    ),
    SettingsVar<bool>(
      key: reducedClassHoursEnabledKey,
      defaultValue: () => false,
    ),
    SettingsVar<List<SchoolTime>?>(
      key: reducedClassHoursKey,
      defaultValue: () => null,
      canBeNull: () => null,
      onlyReturnCopy: (value) {
        if (value == null) {
          return null;
        }

        return value.map((item) => item.clone()).toList();
      },
      loadCustomType: (string) {
        if (string == null) {
          return null;
        }
        final Map<String, dynamic> json = jsonDecode(string);

        List<Map<String, dynamic>> ts =
            (json[Timetable.schoolTimesKey] as List).cast();

        return List.generate(
          ts.length,
          (index) => SchoolTime.fromJson(ts[index]),
        );
      },
      saveCustomType: (times) {
        if (times == null) {
          return null;
        }

        final map = {
          Timetable.schoolTimesKey: List<Map<String, dynamic>>.generate(
            times.length,
            (index) => times[index].toJson(),
          ),
        };

        return jsonEncode(map);
      },
    ),
    SettingsVar<String?>(
      key: lastUsedVersionKey,
      canBeNull: () => null,
      defaultValue: () => null,
    ),
    SettingsVar<bool>(
      key: showLessonNumbersKey,
      defaultValue: () => false,
    ),
    SettingsVar<bool>(
      key: openMainSemesterAutomaticallyKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: showTasksOnHomeScreenKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: highContrastTextOnHomescreenKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: hiddenDebugModeKey,
      defaultValue: () => false,
    ),
    SettingsVar<List<GradeGroup>>(
      key: defaultGradeGroupsKey,
      defaultValue: () => _defaultGradeGroups,
      alwaysReturnDefaultValue: true,
    ),
    SettingsVar<String?>(
      key: usernameKey,
      canBeNull: () => null,
      defaultValue: () => null,
    ),
    SettingsVar<String?>(
      key: securePasswordKey,
      defaultValue: () => null,
      canBeNull: () => null,
      loadCustomType: (value) {
        if (value == null) {
          return null;
        }

        final decrypted = _encrypter.decrypt(
          encrypt.Encrypted.fromBase64(
            value,
          ),
          iv: _iv,
        );

        return decrypted;
      },
      saveCustomType: (value) {
        if (value == null) {
          return null;
        }
        final encrypted = _encrypter.encrypt(value, iv: _iv);
        return encrypted.base64;
      },
    ),
    SettingsVar<Uint8List?>(
      key: paulDessauPdfBytesKey,
      defaultValue: () => null,
      canBeNull: () => null,
      saveCustomType: (type) {
        if (type == null) return null;

        return base64Encode(type);
      },
      loadCustomType: (value) {
        if (value == null) return null;

        return base64Decode(value);
      },
    ),
    SettingsVar<DateTime?>(
      key: paulDessauPdfBytesSavedDateKey,
      defaultValue: () => null,
      canBeNull: () => null,
      loadCustomType: (value) {
        if (value == null) return null;
        int? millieseconds = int.tryParse(value);

        if (millieseconds == null) return null;

        return DateTime.fromMillisecondsSinceEpoch(millieseconds);
      },
      saveCustomType: (type) {
        if (type == null) return null;

        return type.millisecondsSinceEpoch.toString();
      },
    ),
    SettingsVar<bool>(
      key: notificationScheduleEnabledKey,
      defaultValue: () => true,
    ),
    SettingsVar<List<NotificationSchedule>>(
      key: notificationScheduleListKey,
      defaultValue: () {
        return [
          NotificationSchedule(timeBefore: Duration.zero),
          NotificationSchedule(
            timeBefore: const Duration(days: 1),
            timeOfDay: const TimeOfDay(
              hour: 12,
              minute: 0,
            ),
          ),
        ];
      },
      saveCustomType: (list) {
        List<Map<String, dynamic>> json = List.generate(
          list.length,
          (index) => list[index].toJson(),
        );
        return jsonEncode(json);
      },
      loadCustomType: (savedString) {
        if (savedString == null) return null;

        List<Map<String, dynamic>> jsonList =
            (jsonDecode(savedString) as List).cast();

        return List.generate(
          jsonList.length,
          (index) => NotificationSchedule.fromJson(
            jsonList[index],
          ),
        );
      },
    ),
    SettingsVar<String?>(
      key: extraTimetableOnHomeScreenKey,
      defaultValue: () => null,
      canBeNull: () => null,
    ),
    SettingsVar<bool>(
      key: showTutorialInCreateTimetableScreenKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: showTutorialOnHomeScreenKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: termsOfServiceGoFileIoAllowed,
      defaultValue: () => false,
    ),
    //wenn null dann wird nicht mehr angezeigt
    SettingsVar<DateTime?>(
      key: lastAskForReviewDateKey,
      canBeNull: () => null,
      defaultValue: () => DateTime.now().add(
        const Duration(days: 7) - waitBetweenAskForReviewDuration,
      ),
      loadCustomType: (value) {
        if (value == null) return null;

        int? millieseconds = int.tryParse(value);
        if (millieseconds == null) return null;

        return DateTime.fromMillisecondsSinceEpoch(millieseconds);
      },
      saveCustomType: (type) {
        return type?.millisecondsSinceEpoch.toString();
      },
    ),
    // zeigt an, ob die App die Todo-Farbe verwenden soll oder
    // die Farbe des Verbundenen Fachs
    SettingsVar<CalendarTodoEventStyle>(
      key: calendarShowTodoEventColorKey,
      defaultValue: () => CalendarTodoEventStyle.colorFromTodoEvent,
      saveCustomType: (type) {
        return type.toString();
      },
      loadCustomType: (value) {
        for (var item in CalendarTodoEventStyle.values) {
          if (value == item.toString()) {
            return item;
          }
        }
        return null;
      },
    ),
    SettingsVar<bool>(
      key: showNextDayAfterDayEndKey,
      defaultValue: () => false,
    ),
    SettingsVar<bool>(
      key: showAlwaysWeekTimetableKey,
      defaultValue: () => false,
    ),
    SettingsVar<bool>(
      key: showImportTodoEventsWarnigKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: showAbiAverageNotAlwaysCorrectInfoKey,
      defaultValue: () => true,
    ),
    SettingsVar<bool>(
      key: lessonReminderNotificationEnabledKey,
      defaultValue: () => false,
    ),
    SettingsVar<Duration>(
      key: preLessonReminderNotificationDurationKey,
      defaultValue: () => const Duration(minutes: 5),
      saveCustomType: (type) {
        return type.inMilliseconds.toString();
      },
      loadCustomType: (value) {
        if (value == null) return null;

        final millis = int.tryParse(value);

        if (millis == null) return null;

        return Duration(milliseconds: millis);
      },
    ),
    SettingsVar<DateTime?>(
      key: lastSyncTimeKey,
      defaultValue: () => null,
      canBeNull: () => null,
      loadCustomType: (value) {
        if (value == null) return null;

        return DateTime.tryParse(value);
      },
      saveCustomType: (type) {
        if (type == null) return null;

        return type.toIso8601String();
      },
    ),
    SettingsVar<ConflictResolutionStrategy>(
      key: syncConflictResolutionKey,
      defaultValue: () => ConflictResolutionStrategy.lastWriteWins,
      saveCustomType: (type) {
        return type.toString();
      },
      loadCustomType: (value) {
        for (var item in ConflictResolutionStrategy.values) {
          if (value == item.toString()) {
            return item;
          }
        }
        return null;
      },
    ),
  ];

  static List<GradeGroup> get _defaultGradeGroups {
    return [
      GradeGroup(
        name: AppLocalizationsManager.localizations.strWrittenAndVerbalGrades,
        percent: 67,
        grades: [],
      ),
      GradeGroup(
        name: AppLocalizationsManager.localizations.strExamGrades,
        percent: 33,
        grades: [],
      ),
    ];
  }

  final Map<String, SettingsVar> _variables = {};

  Settings() {
    _initVariables();

    for (String key in _variables.keys) {
      final settingsVar = _variables[key];

      if (settingsVar == null) continue;

      settingsVar.value = settingsVar.defaultValue.call();
    }
  }

  Settings.fromJson(Map<String, dynamic> json) {
    _initVariables();

    for (String key in _variables.keys) {
      final settingsVar = _variables[key];

      if (settingsVar == null) continue;

      if (!json.containsKey(key)) {
        //if the key is not in the json, we set it to the default value
        settingsVar.value = settingsVar.defaultValue.call();
        continue;
      }

      settingsVar.fromNormalType(json[key]);
    }
  }

  void _initVariables() {
    for (SettingsVar settingsVar in _variablesList) {
      _variables[settingsVar.key] = settingsVar;
    }
  }

  T getVar<T>(String key) {
    if (_variables[key] == null) {
      throw Exception("$key does not exist in settings!");
    }
    return _variables[key]!.value;
  }

  bool setVar<T>(String key, T value) {
    if (_variables[key] == null) {
      return false;
    }
    _variables[key]!.value = value;

    SaveManager().saveSettings(this);

    return true;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    for (String key in _variables.keys) {
      SettingsVar? settingsVar = _variables[key];

      if (settingsVar == null) continue;

      json[key] = settingsVar.toNormalType();
    }

    return json;

    // List<Map<String, dynamic>>? defaultGradeGroupsJson =
    //     json[defaultGradeGroupsKey];

    // List<GradeGroup>? gradeGroups = defaultGradeGroupsJson == null
    //     ? null
    //     : List.generate(
    //         defaultGradeGroupsJson.length,
    //         (index) => GradeGroup.fromJson(
    //           defaultGradeGroupsJson[index],
    //         ),
    //       );

    // defaultGradeGroupsKey: _defaultGradeGroups != null
    //     ? List.generate(
    //         _defaultGradeGroups!.length,
    //         (index) => _defaultGradeGroups![index].toJson(),
    //       )
    //     : null,
  }
}
