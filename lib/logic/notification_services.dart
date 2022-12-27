import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../utils/app_colors.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  //init
  Future<void> initializePlatformNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/android12splash');

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      settings,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    log('called notificaiton');
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'chitchat',
      'Chats',
      groupKey: 'com.android.chitchat',
      channelDescription: 'Notifications for user chats',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('notification'),
      color: AppColors().primaryColor,
      playSound: true,
    );
    return NotificationDetails(android: androidNotificationDetails);
  }

  //showing notificaion function
  Future<void> showNotification({
    required int id,
    required String message,
    required String user,
  }) async {
    final detail = await _notificationDetails();

    await _notifications.show(id, user, message, detail);
  }

  Future<void> cancelNotification({required int id}) async {
    await _notifications.cancel(id);
  }
}
