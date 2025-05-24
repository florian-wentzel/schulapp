import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
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

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      "channelId",
      "todos",
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

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

    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      payload: payload ?? "$id",
      TZDateTime.from(scheduledDateTime, local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancleNotification(int id) async {
    if (!Platform.isIOS && !Platform.isAndroid && !Platform.isWindows) {
      return;
    }

    if (id > maxIdNum) return;

    return notificationsPlugin.cancel(id);
  }
}
