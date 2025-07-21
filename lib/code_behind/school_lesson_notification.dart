class SchoolLessonNotification {
  static const String notificationsIdKey = "id";
  static const String scheduledMondayKey = "monday";
  static const String scheduledTimeKey = "time";
  static const String lessonNameKey = "name";
  static const String lessonRoomKey = "room";
  static const String lessonIndexKey = "lessonIndex";
  static const String dayIndexKey = "dayIndex";

  final int notificationID;
  final DateTime scheduledMonday; //der montag der woche zeit ist egal
  final DateTime
      scheduledTime; //der Zeitpunkt wann die Nachricht kommt falls sich etwas ändert
  final int lessonIndex;
  final int dayIndex;
  final String lessonName;
  final String lessonRoom;

  SchoolLessonNotification({
    required this.notificationID,
    required this.scheduledMonday,
    required this.scheduledTime,
    required this.dayIndex,
    required this.lessonIndex,
    required this.lessonName,
    required this.lessonRoom,
  });

  Map<String, dynamic> toJson() {
    return {
      notificationsIdKey: notificationID,
      scheduledMondayKey: scheduledMonday.millisecondsSinceEpoch,
      scheduledTimeKey: scheduledTime.millisecondsSinceEpoch,
      lessonNameKey: lessonName,
      lessonRoomKey: lessonRoom,
      lessonIndexKey: lessonIndex,
      dayIndexKey: dayIndex,
    };
  }

  static SchoolLessonNotification fromJson(Map<String, dynamic> json) {
    final int id = json[notificationsIdKey] ?? 0;
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      json[scheduledMondayKey] ?? 0,
      isUtc: true,
    );
    final DateTime scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      json[scheduledTimeKey] ?? 0,
      isUtc: true,
    );
    final int lessonIndex = json[lessonIndexKey] ?? 0;
    final int dayIndex = json[dayIndexKey] ?? 0;
    final String subjectName = json[lessonNameKey] ?? "";
    final String subjectRoom = json[lessonRoomKey] ?? "";

    return SchoolLessonNotification(
      notificationID: id,
      scheduledMonday: dateTime,
      scheduledTime: scheduledTime,
      lessonName: subjectName,
      lessonRoom: subjectRoom,
      dayIndex: dayIndex,
      lessonIndex: lessonIndex,
    );
  }
}
