import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgify/core/themes/app_colors.dart';

// Constants for daily notification
const String dailyNotificationChannelKey = 'basic_channel';
const String dailyNotificationPrefsKey = 'notification_enabled'; // Unified key
const int dailyNotificationId = 0; // Unified ID, matching NotificationNotifier

Future<void> scheduleDailyNotification(SharedPreferences prefs) async {
  debugPrint("NOTIFICATION_SERVICE: Checking daily notification scheduling...");

  // Check if already scheduled to avoid duplicates
  final bool isScheduled = prefs.getBool(dailyNotificationPrefsKey) ?? false;
  if (isScheduled) {
    debugPrint("NOTIFICATION_SERVICE: Daily notification already scheduled.");
    // Verify if notification exists
    final scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();
    final isNotificationScheduled = scheduledNotifications.any((n) => n.content?.id == dailyNotificationId);
    if (isNotificationScheduled) {
      debugPrint("NOTIFICATION_SERVICE: Confirmed: Notification ID $dailyNotificationId is scheduled.");
      return;
    } else {
      debugPrint("NOTIFICATION_SERVICE: SharedPreferences says scheduled, but notification not found. Rescheduling...");
      await prefs.setBool(dailyNotificationPrefsKey, false);
    }
  }

  // Check notification permissions
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    debugPrint("NOTIFICATION_SERVICE: Notification permissions not granted. Skipping scheduling.");
    return;
  }

  try {
    // Cancel any existing notifications with old or conflicting IDs
    await AwesomeNotifications().cancel(0); // Current ID
    await AwesomeNotifications().cancel(9999); // Old ID from previous version
    debugPrint("NOTIFICATION_SERVICE: Canceled notifications with IDs 0 and 9999");

    // Schedule daily notification at 13:30
    final now = DateTime.now();
    DateTime notificationTime = DateTime(now.year, now.month, now.day, 13, 30);
    if (notificationTime.isBefore(now)) {
      notificationTime = notificationTime.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: dailyNotificationId,
        channelKey: dailyNotificationChannelKey,
        title: "Daily Budget Reminder".tr,
        body: "Check your expenses & Incomes and stay on track!".tr,
        category: NotificationCategory.Reminder,
        wakeUpScreen: false,
        fullScreenIntent: false,
        autoDismissible: true,
        locked: false,
        badge: 1,
        color: AppColors.accentColor,
      ),
      schedule: NotificationCalendar(
        hour: 20,
        minute: 00,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );

    // Mark as scheduled in SharedPreferences
    await prefs.setBool(dailyNotificationPrefsKey, true);
    await prefs.reload();
    // debugPrint("NOTIFICATION_SERVICE: Scheduled daily notification at 13:30. Marked as scheduled in SharedPreferences.");
  } catch (e) {
    debugPrint("NOTIFICATION_SERVICE: Error scheduling daily notification: $e");
  }
}