import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notifications are only supported on Android in this app. `dart:io`'s
  // Platform is unavailable on web, so guard with kIsWeb before touching it.
  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static Future<void> init() async {
    // Timezones and notifications are only needed on Android. On web/other
    // platforms there is nothing to set up, so bail out early.
    if (!_isAndroid) return;

    tz.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_isAndroid) return;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'assignments_channel',
          'Assignments Notifications',
          channelDescription: 'Notifications for assignment reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String assignmentTitle,
    required DateTime dueDate,
  }) async {
    if (!_isAndroid) return;
    final DateTime reminderDate = dueDate.subtract(const Duration(days: 1));

    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'assignment_reminders_channel',
          'Assignment Reminders',
          channelDescription: 'Reminder one day before assignment deadline',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id: assignmentId.hashCode,
      title: 'Assignment Reminder',
      body: '$assignmentTitle is due tomorrow.',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelAssignmentReminder(String assignmentId) async {
    if (!_isAndroid) return;
    await _notifications.cancel(id: assignmentId.hashCode);
  }
}
