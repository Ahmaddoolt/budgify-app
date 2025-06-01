import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budgify/core/notifications/notification_service.dart'; // Import the shared scheduling function
import 'package:shared_preferences/shared_preferences.dart';

class NotificationState {
  final bool isEnabled;
  NotificationState({required this.isEnabled});
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState(isEnabled: true)) {
    loadNotificationState();
  }

  Future<void> loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? storedValue = prefs.getBool('notification_enabled');
    bool initialState = storedValue ?? true;
    state = NotificationState(isEnabled: initialState);
    if (initialState) {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (isAllowed) {
        await scheduleDailyNotification(prefs); // Use shared function
      } else {
        debugPrint("Notifications were enabled in prefs but permission not granted.");
      }
    } else {
      await AwesomeNotifications().cancel(dailyNotificationId);
      debugPrint("Daily notification canceled during initialization (disabled in preferences).");
    }
  }

  Future<void> toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        debugPrint("Attempted to enable notifications, but permission not granted.");
        return;
      }
    }

    state = NotificationState(isEnabled: value);
    await prefs.setBool('notification_enabled', value);

    if (value) {
      await scheduleDailyNotification(prefs); // Use shared function
    } else {
      await AwesomeNotifications().cancel(dailyNotificationId);
      debugPrint("Daily notification canceled via toggle.");
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(),
);