//lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_timezone/flutter_timezone.dart';

import 'notification_texts.dart';

import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);

    // 🔔 permiso Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // 🔥 PERMISO EXACT ALARM
    if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final granted = await androidImplementation
          ?.requestExactAlarmsPermission();

      debugPrint("🚨 EXACT ALARM: $granted");
    }

    _initialized = true;
  }

  /// ⏰ "8:00 PM" → DateTime
  static DateTime? _parseTime(String time) {
    try {
      final now = DateTime.now();

      final normalized = time
          .replaceAll('a. m.', 'AM')
          .replaceAll('p. m.', 'PM')
          .replaceAll('a.m.', 'AM')
          .replaceAll('p.m.', 'PM')
          .replaceAll('am', 'AM')
          .replaceAll('pm', 'PM')
          .trim();

      final parts = normalized.split(" ");
      final hm = parts[0].split(":");

      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);

      final period = parts[1].toUpperCase();

      if (period == "PM" && hour != 12) {
        hour += 12;
      }

      if (period == "AM" && hour == 12) {
        hour = 0;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      debugPrint("ERROR PARSE TIME: $e");
      return null;
    }
  }

  /// 🔔 PROGRAMAR
  static Future<void> scheduleNotification({
    required String id,
    required String title,
    required String time,
  }) async {
    final parsed = _parseTime(time);

    if (parsed == null) {
      debugPrint("❌ parsed NULL");
      return;
    }

    final now = DateTime.now();

    debugPrint("🕒 AHORA: $now");
    debugPrint("🕒 PARSED: $parsed");

    final scheduled = parsed.isBefore(now)
        ? parsed.add(const Duration(days: 1))
        : parsed;

    debugPrint("🚀 PROGRAMADA PARA: $scheduled");

    final tzTime = tz.TZDateTime.from(scheduled, tz.local);

    await _notifications.zonedSchedule(
      id.hashCode,
      NotificationTexts.notificationTitle("normal"),
      NotificationTexts.notificationBody(title),
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationTexts.channelId,
          NotificationTexts.channelName,
          channelDescription: NotificationTexts.channelDescription,

          importance: Importance.max,
          priority: Priority.high,

          playSound: true,
          enableVibration: true,

          visibility: NotificationVisibility.public,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint("✅ NOTIFICACIÓN PROGRAMADA");
  }

  /// ❌ CANCELAR
  static Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> testNotification() async {
    await _notifications.show(
      999,
      'TEST',
      'Notificación funcionando 🚀',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'Recordatorios de tareas diarias',

          importance: Importance.max,
          priority: Priority.high,

          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}
