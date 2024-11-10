import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart';

class NotificationManager {
  static final NotificationManager _instance =
      NotificationManager._privateConstructor();
  NotificationManager._privateConstructor();

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

  Future<void> initNotifications() async {
    //um logo zu ändern: https://youtu.be/26TTYlwc6FM?t=146
    const initializationSettingsAndroid = AndroidInitializationSettings("icon");

    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<Map<Permission, PermissionStatus>?> askForPermission() async {
    try {
      return [Permission.scheduleExactAlarm, Permission.notification].request();
    } catch (_) {
      return null;
    }
  }

  Future<void> showNotifications(
      {required int id, required String title, String? body}) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }
    await askForPermission();
    return notificationsPlugin.show(id, title, body, _notificationDetails);
  }

  Future<void> scheduleNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDateTime,
  }) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }
    if (scheduledDateTime.isBefore(DateTime.now())) return;

    await askForPermission();
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(scheduledDateTime, local),
      _notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancleNotification(int id) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }
    return notificationsPlugin.cancel(id);
  }
}
