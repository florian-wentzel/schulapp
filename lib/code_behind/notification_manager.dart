import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_notification.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/special_lesson.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/unique_id_generator.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/todo_events_screen.dart';
import 'package:timezone/timezone.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  NotificationManager()._pendingNotificationResponse = notificationResponse;
}

class NotificationManager {
  static final NotificationManager _instance =
      NotificationManager._privateConstructor();
  NotificationManager._privateConstructor();
  static const maxIdNum = 2147483647;

  factory NotificationManager() {
    return _instance;
  }

  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final _notificationDetails = NotificationDetails(
      android: const AndroidNotificationDetails(
        "channelId",
        "todos",
        category: AndroidNotificationCategory.reminder,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      windows: WindowsNotificationDetails(
        images: [
          WindowsImage(
            WindowsImage.getAssetUri("assets/icon_for_play_store.png"),
            altText: "Icon",
            addQueryParams: false,
            placement: WindowsImagePlacement.appLogoOverride,
          ),
        ],
      ));

  NotificationResponse? _pendingNotificationResponse;
  bool get pendingNotification => _pendingNotificationResponse != null;

  void handlePendingNotification() {
    if (_pendingNotificationResponse != null) {
      onDidReceiveNotificationResponse(_pendingNotificationResponse!);
      _pendingNotificationResponse = null;
    }
  }

  Future<void> initNotifications() async {
    //um logo zu ändern: https://youtu.be/26TTYlwc6FM?t=146
    const initializationSettingsAndroid = AndroidInitializationSettings("icon");

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Schulapp',
      appUserModelId: 'com.flologames.schulapp',
      //TODO: icon does not work jet
      iconPath: 'app_icon.ico',
      // Search online for GUID generators to make your own
      guid: '4a9f4a94-8f00-4cc5-a82d-20187c1a4240',
    );

    var initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      windows: initializationSettingsWindows,
    );

    bool? success = await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    debugPrint("Notifications initialized: $success");
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');

      int? key = int.tryParse(payload ?? "");

      if (key == null || key > maxIdNum) return;

      final todoEvent =
          TimetableManager().todoEvents.cast<TodoEvent?>().firstWhere(
                (element) => element?.key == key,
                orElse: () => null,
              );

      if (todoEvent == null) return;

      MainApp.router.go(
        TodoEventsScreen.route,
        extra: todoEvent,
      );
    }
  }

  Future<Map<Permission, PermissionStatus>?> askForPermission() async {
    try {
      return [
        Permission.notification,
        Permission.scheduleExactAlarm,
      ].request();
    } catch (_) {
      return null;
    }
  }

  Future<void> showNotifications(
      {required int id, required String title, String? body}) async {
    if (!Platform.isIOS && !Platform.isAndroid && !Platform.isWindows) {
      return;
    }
    await askForPermission();
    return notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails,
      payload: "$id",
    );
  }

  Future<void> scheduleNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDateTime,
  }) async {
    if (!Platform.isIOS && !Platform.isAndroid && !Platform.isWindows) {
      return;
    }

    if (scheduledDateTime.isBefore(DateTime.now())) return;

    await askForPermission();

    if (id > maxIdNum) return;

    try {
      return notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        payload: payload ?? "$id",
        TZDateTime.from(scheduledDateTime, local),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      return Future<void>.value();
    }
  }

  Future<void> cancleNotification(int id) async {
    if (!Platform.isIOS && !Platform.isAndroid && !Platform.isWindows) {
      return;
    }

    if (id > maxIdNum) return;
    try {
      return notificationsPlugin.cancel(id);
    } catch (e) {
      return Future<void>.value();
    }
  }

  Future<void> resetScheduleNotification() async {
    List<SchoolLessonNotification> notificationsToSchedule =
        SaveManager().loadLessonReminders();

    final now = DateTime.now().toUtc();

    notificationsToSchedule.removeWhere(
      (element) => element.scheduledTime.isBefore(now),
    );

    for (var notification in notificationsToSchedule) {
      await cancleNotification(notification.notificationID);
    }

    notificationsToSchedule.clear();

    SaveManager().saveLessonReminders(notificationsToSchedule);
  }

  //entfernt alle und setzt sie mit dem gegebenen Timetable neu
  Future<void> resetScheduleNotificationWithTimetable({
    required Timetable timetable,
  }) async {
    await resetScheduleNotification();

    final timeBeforeLessonNotification =
        TimetableManager().settings.getVar<Duration>(
              Settings.preLessonReminderNotificationDurationKey,
            );

    scheduleNotificationForTimetable(
      timetable: timetable,
      timeBeforeLessonNotification: timeBeforeLessonNotification,
    );
  }

  Future<void> updateNotificationsForDay({
    required Timetable timetable,
    required DateTime monday, //utc
    required int dayIndex,
  }) async {
    final enabled = TimetableManager()
        .settings
        .getVar<bool>(Settings.lessonReminderNotificationEnabledKey);

    if (!enabled) return;

    final defaultTt = Utils.getHomescreenTimetable();

    final currTimetable = timetable.getWeekTimetableForDateTime(monday);

    if (currTimetable.name != defaultTt?.name) return;

    final schoolDay = currTimetable.schoolDays[dayIndex];

    final notificationsToSchedule = SaveManager().loadLessonReminders();

    final now = DateTime.now().toUtc();

    notificationsToSchedule.removeWhere(
      (element) => element.scheduledTime.isBefore(now),
    );

    List<SchoolTime>? schoolTimesOverride;

    final reducedClassHoursEnabled = TimetableManager().settings.getVar<bool>(
          Settings.reducedClassHoursEnabledKey,
        );

    if (reducedClassHoursEnabled) {
      schoolTimesOverride =
          TimetableManager().settings.getVar<List<SchoolTime>?>(
                Settings.reducedClassHoursKey,
              );
    }

    final timeBeforeLessonNotification =
        TimetableManager().settings.getVar<Duration>(
              Settings.preLessonReminderNotificationDurationKey,
            );

    for (int lessonIndex = 0;
        lessonIndex < currTimetable.maxLessonCount;
        lessonIndex++) {
      await _scheduleLessonNotification(
        currTimetable: currTimetable,
        schoolDay: schoolDay,
        lessonIndex: lessonIndex,
        monday: monday,
        notificationsToSchedule: notificationsToSchedule,
        now: now,
        schoolTimesOverride: schoolTimesOverride,
        timeBeforeLessonNotification: timeBeforeLessonNotification,
        weekDayIndex: dayIndex,
      );
    }

    SaveManager().saveLessonReminders(
      notificationsToSchedule,
    );
  }

  Future<void> updateNotification({
    required Timetable timetable,
    required DateTime monday, //utc
    required int dayIndex,
    required int lessonIndex,
  }) async {
    final enabled = TimetableManager()
        .settings
        .getVar<bool>(Settings.lessonReminderNotificationEnabledKey);

    if (!enabled) return;

    final defaultTt = Utils.getHomescreenTimetable();

    final currTimetable = timetable.getWeekTimetableForDateTime(monday);

    if (currTimetable.name != defaultTt?.name) return;

    final schoolDay = currTimetable.schoolDays[dayIndex];

    final notificationsToSchedule = SaveManager().loadLessonReminders();

    final now = DateTime.now().toUtc();

    notificationsToSchedule.removeWhere(
      (element) => element.scheduledTime.isBefore(now),
    );

    List<SchoolTime>? schoolTimesOverride;

    final reducedClassHoursEnabled = TimetableManager().settings.getVar<bool>(
          Settings.reducedClassHoursEnabledKey,
        );

    if (reducedClassHoursEnabled) {
      schoolTimesOverride =
          TimetableManager().settings.getVar<List<SchoolTime>?>(
                Settings.reducedClassHoursKey,
              );
    }

    final timeBeforeLessonNotification =
        TimetableManager().settings.getVar<Duration>(
              Settings.preLessonReminderNotificationDurationKey,
            );

    await _scheduleLessonNotification(
      currTimetable: currTimetable,
      schoolDay: schoolDay,
      lessonIndex: lessonIndex,
      monday: monday,
      notificationsToSchedule: notificationsToSchedule,
      now: now,
      schoolTimesOverride: schoolTimesOverride,
      timeBeforeLessonNotification: timeBeforeLessonNotification,
      weekDayIndex: dayIndex,
    );

    SaveManager().saveLessonReminders(
      notificationsToSchedule,
    );
  }

  /// Regestriert eine Benachrichtigung für die aktuelle und nächste Woche
  /// Für jede Stunde
  Future<void> scheduleNotificationForTimetable({
    required Timetable timetable,
    required Duration timeBeforeLessonNotification,
  }) async {
    final notificationsToSchedule = SaveManager().loadLessonReminders();

    final now = DateTime.now().toUtc();

    notificationsToSchedule.removeWhere(
      (element) => element.scheduledTime.isBefore(now),
    );

    final nowMonday = Utils.getWeekDay(
      now.copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      ),
      DateTime.monday,
    );

    List<SchoolTime>? schoolTimesOverride;

    final reducedClassHoursEnabled = TimetableManager().settings.getVar<bool>(
          Settings.reducedClassHoursEnabledKey,
        );

    if (reducedClassHoursEnabled) {
      schoolTimesOverride =
          TimetableManager().settings.getVar<List<SchoolTime>?>(
                Settings.reducedClassHoursKey,
              );
    }

    await _registerScheduleNotificationsForWeek(
      monday: nowMonday,
      timetable: timetable,
      timeBeforeLessonNotification: timeBeforeLessonNotification,
      notificationsToSchedule: notificationsToSchedule,
      schoolTimesOverride: schoolTimesOverride,
    );

    _registerScheduleNotificationsForWeek(
      monday: nowMonday.add(const Duration(days: 7)),
      timetable: timetable,
      timeBeforeLessonNotification: timeBeforeLessonNotification,
      notificationsToSchedule: notificationsToSchedule,
    );

    SaveManager().saveLessonReminders(
      notificationsToSchedule,
    );
  }

  Future<void> _registerScheduleNotificationsForWeek({
    required DateTime monday,
    required Timetable timetable,
    required Duration timeBeforeLessonNotification,
    required List<SchoolLessonNotification> notificationsToSchedule,
    List<SchoolTime>? schoolTimesOverride,
  }) async {
    Timetable currTimetable = timetable.getWeekTimetableForDateTime(monday);

    if ((schoolTimesOverride?.length ?? 0) < currTimetable.schoolTimes.length) {
      schoolTimesOverride = null;
    }

    final now = DateTime.now().toUtc();

    for (int weekDayIndex = 0;
        weekDayIndex < currTimetable.schoolDays.length;
        weekDayIndex++) {
      final day = currTimetable.schoolDays[weekDayIndex];
      for (int lessonIndex = 0;
          lessonIndex < day.lessons.length;
          lessonIndex++) {
        await _scheduleLessonNotification(
          currTimetable: currTimetable,
          schoolDay: day,
          lessonIndex: lessonIndex,
          monday: monday,
          notificationsToSchedule: notificationsToSchedule,
          now: now,
          schoolTimesOverride: schoolTimesOverride,
          timeBeforeLessonNotification: timeBeforeLessonNotification,
          weekDayIndex: weekDayIndex,
        );
      }
    }
  }

  Future<void> _scheduleLessonNotification({
    required Timetable currTimetable,
    required SchoolDay schoolDay,
    required int lessonIndex,
    required int weekDayIndex,
    required List<SchoolTime>? schoolTimesOverride,
    required List<SchoolLessonNotification> notificationsToSchedule,
    required DateTime monday, //utc
    required Duration timeBeforeLessonNotification,
    required DateTime now, //utc
  }) async {
    final lesson = schoolDay.lessons[lessonIndex];

    //benutze die kurzstunden (override) wenn nicht gegeben
    //nimm vom stundenplan
    SchoolTime lessonTime = schoolTimesOverride?[lessonIndex] ??
        currTimetable.schoolTimes[lessonIndex];

    final alreadyPendingNotification =
        notificationsToSchedule.cast<SchoolLessonNotification?>().firstWhere(
              (element) =>
                  element?.dayIndex == weekDayIndex &&
                  element?.lessonIndex == lessonIndex &&
                  element?.scheduledMonday.millisecondsSinceEpoch ==
                      monday.millisecondsSinceEpoch,
              orElse: () => null,
            );

    //WeekTimetable leitet auf richtigen timetable weiter
    SpecialLesson? specialLesson = currTimetable.getSpecialLesson(
      year: monday.year,
      weekIndex: Utils.getWeekIndex(monday),
      schoolDayIndex: weekDayIndex,
      schoolTimeIndex: lessonIndex,
    );

    String lessonName = lesson.name;
    String lessonRoom = lesson.room;
    bool isCancled = false;
    bool isSubstituded = false;

    if (specialLesson != null) {
      if (specialLesson is CancelledSpecialLesson ||
          specialLesson is SickSpecialLesson) {
        lessonName =
            "${lesson.name} ${AppLocalizationsManager.localizations.strCancelledInBrackets}";
        isCancled = true;
      } else if (specialLesson is SubstituteSpecialLesson) {
        lessonName =
            "${specialLesson.name} ${AppLocalizationsManager.localizations.strSubstitutionInBrackets}";
        lessonRoom = specialLesson.room;
        isSubstituded = true;
      }
    }

    final scheduledDateTime = DateTime(
      monday.year,
      monday.month,
      monday.day + weekDayIndex,
      lessonTime.start.hour,
      lessonTime.start.minute,
    ).subtract(timeBeforeLessonNotification).toUtc();

    //wenn es bereits eine nachricht gibt
    if (alreadyPendingNotification != null) {
      //schauen ob sie gleich geblieben ist oder ob man neu erstellen muss
      if (SchoolLesson.isEmptyLesson(lesson) || isCancled) {
        await cancleNotification(alreadyPendingNotification.notificationID);
        notificationsToSchedule.remove(alreadyPendingNotification);
      } else if (alreadyPendingNotification.lessonName == lessonName &&
          alreadyPendingNotification.lessonRoom == lessonRoom &&
          alreadyPendingNotification.scheduledTime.millisecondsSinceEpoch ==
              scheduledDateTime.millisecondsSinceEpoch) {
        //alles gleich also nichts ändern
        return;
      } else {
        await cancleNotification(alreadyPendingNotification.notificationID);
        notificationsToSchedule.remove(alreadyPendingNotification);
      }
    }

    if (SchoolLesson.isEmptyLesson(lesson) && !isSubstituded) return;

    final cancelledReminder = TimetableManager().settings.getVar(
          Settings.cancelledLessonReminderNotificationEnabledKey,
        );

    if (isCancled && !cancelledReminder) return;

    if (scheduledDateTime.isBefore(now)) return; //schon vorbei

    final id = UniqueIdGenerator.createUniqueId();

    // falls es zufälliger weise doch schon eine Nachricht gibt
    await cancleNotification(id);

    if (isCancled) {
      await scheduleNotification(
        id: id,
        scheduledDateTime: scheduledDateTime,
        title: AppLocalizationsManager.localizations.strXisCancelled(
          lesson.name, //hier ganz normalen namen verwendet
        ),
        body: AppLocalizationsManager.localizations.strTimeToRelaxEnjoyIt,
      );
    } else {
      await scheduleNotification(
        id: id,
        scheduledDateTime: scheduledDateTime,
        title: AppLocalizationsManager.localizations.strXisAboutToStart(
          lessonName,
        ),
        body: AppLocalizationsManager.localizations.strInRoomX(
          lessonRoom,
        ),
      );
    }

    final notification = SchoolLessonNotification(
      dayIndex: weekDayIndex,
      lessonIndex: lessonIndex,
      notificationID: id,
      scheduledMonday: monday,
      scheduledTime: scheduledDateTime,
      lessonName: lessonName,
      lessonRoom: lessonRoom,
    );

    notificationsToSchedule.add(notification);
  }
}
