import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart'; // Changed from foundation.dart for ValueNotifier & debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_handlers.dart'; // Ensure this path is correct

// Awesome Notifications constants
const String awesomeAlarmChannelKey = 'budgify_alarm_channel';
const String awesomeStopActionKey = 'BUDGIFY_STOP_ALARM';
const String awesomePayloadAlarmIdKey = 'alarmId';
const String awesomeExtraAlarmTitleKey = "title";
const String alarmListRefreshKey = 'alarm_list_needs_refresh';

// Global ValueNotifier to trigger UI refresh in AlarmListPage
// Value is an integer that increments on each trigger.
final ValueNotifier<int> alarmListRefreshTrigger = ValueNotifier(0);

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
  debugPrint('NOTIFICATION_HANDLERS: Notification created: ID ${receivedNotification.id}, Channel: ${receivedNotification.channelKey}, Payload: ${receivedNotification.payload}');
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
  debugPrint('NOTIFICATION_HANDLERS: Notification displayed: ID ${receivedNotification.id}, Channel: ${receivedNotification.channelKey}');
}

Future<void> _handleAlarmStop({
  required int alarmId,
  required String? title,
  required SharedPreferences prefs,
  required Map<String, String?>? payload,
  int? notificationId,
}) async {
  debugPrint('NOTIFICATION_HANDLERS: Handling stop for alarm ID $alarmId, Title: $title');

  try {
    // Fetch original AlarmSettings
    AlarmSettings alarmSettings;
    final activeAlarms = await Alarm.getAlarms();
    final matchingAlarm = activeAlarms.firstWhere(
      (alarm) => alarm.id == alarmId,
      orElse: () {
        debugPrint('NOTIFICATION_HANDLERS: Alarm ID $alarmId not found in active alarms. Using fallback settings.');
        return AlarmSettings(
          id: alarmId,
          dateTime: DateTime.now(),
          assetAudioPath: 'assets/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          androidFullScreenIntent: true,
          notificationSettings: NotificationSettings(
            title: title ?? payload?[awesomeExtraAlarmTitleKey] ?? 'Payment Reminder',
            body: 'Payment Reminder!',
            stopButton: 'Stop',
          ),
        );
      },
    );
    alarmSettings = matchingAlarm;
    debugPrint('NOTIFICATION_HANDLERS: Using AlarmSettings for ID $alarmId: Title=${alarmSettings.notificationSettings.title}, Date=${alarmSettings.dateTime}');

    // Call stopAndMarkAlarm
    await stopAndMarkAlarm(
      alarmId: alarmId,
      alarmSettings: alarmSettings,
      prefs: prefs,
      notificationId: notificationId,
    );

    debugPrint('NOTIFICATION_HANDLERS: Completed stopAndMarkAlarm for ID $alarmId');

    // Verify SharedPreferences (stopAndMarkAlarm already does this, but an extra check here is fine)
    await prefs.reload(); // Ensure prefs is up-to-date before this check
    final stoppedAlarms = await loadStoppedAlarms(prefs); // loadStoppedAlarms should also reload prefs
    if (stoppedAlarms.containsKey(alarmId)) {
      final notificationSettingsMap = stoppedAlarms[alarmId]?['notificationSettings'] as Map<String, dynamic>?;
      final savedTitle = notificationSettingsMap?['title'] as String? ?? 'Unknown';
      debugPrint('NOTIFICATION_HANDLERS: Verified stopped alarm ID $alarmId saved: Title=$savedTitle');
    } else {
      debugPrint('NOTIFICATION_HANDLERS: ERROR: Stopped alarm ID $alarmId not found in SharedPreferences after stopAndMarkAlarm');
    }

    // Trigger UI refresh for AlarmListPage if it's listening
    // This happens AFTER SharedPreferences has been updated by stopAndMarkAlarm
    alarmListRefreshTrigger.value++;
    debugPrint('NOTIFICATION_HANDLERS: Incremented alarmListRefreshTrigger to ${alarmListRefreshTrigger.value} for alarm ID $alarmId');


  } catch (e) {
    debugPrint('NOTIFICATION_HANDLERS: Critical error handling alarm $alarmId: $e');
    if (notificationId != null) {
      await AwesomeNotifications().dismiss(notificationId);
    }
  }
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint('NOTIFICATION_HANDLERS: Notification dismissed: ID ${receivedAction.id}, Payload: ${receivedAction.payload}');
  if (receivedAction.channelKey == awesomeAlarmChannelKey &&
      receivedAction.payload != null &&
      receivedAction.payload!.containsKey(awesomePayloadAlarmIdKey)) {
    final alarmIdStr = receivedAction.payload![awesomePayloadAlarmIdKey];
    if (alarmIdStr != null) {
      try {
        final alarmId = int.parse(alarmIdStr);
        final prefs = await SharedPreferences.getInstance();
        // No need to reload prefs here if _handleAlarmStop reloads as necessary
        await _handleAlarmStop(
          alarmId: alarmId,
          title: receivedAction.payload![awesomeExtraAlarmTitleKey],
          prefs: prefs,
          payload: receivedAction.payload,
          notificationId: receivedAction.id,
        );
        // alarmListRefreshTrigger is incremented inside _handleAlarmStop
      } catch (e) {
        debugPrint('NOTIFICATION_HANDLERS: Error parsing alarm ID $alarmIdStr from dismiss: $e');
        if (receivedAction.id != null) {
          await AwesomeNotifications().dismiss(receivedAction.id!);
        }
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint('NOTIFICATION_HANDLERS: Action received: Button: "${receivedAction.buttonKeyPressed}", Payload: ${receivedAction.payload}, ID: ${receivedAction.id}');
  if (receivedAction.channelKey == awesomeAlarmChannelKey &&
      receivedAction.payload != null &&
      receivedAction.payload!.containsKey(awesomePayloadAlarmIdKey)) {
    final alarmIdStr = receivedAction.payload![awesomePayloadAlarmIdKey];

    if (receivedAction.buttonKeyPressed == awesomeStopActionKey) {
      if (alarmIdStr == null) {
        debugPrint('NOTIFICATION_HANDLERS: Missing alarmId in payload for stop action');
        if (receivedAction.id != null) {
          await AwesomeNotifications().dismiss(receivedAction.id!);
        }
        return;
      }
      try {
        final alarmId = int.parse(alarmIdStr);
        final prefs = await SharedPreferences.getInstance();
        // No need to reload prefs here if _handleAlarmStop reloads as necessary
        await _handleAlarmStop(
          alarmId: alarmId,
          title: receivedAction.payload![awesomeExtraAlarmTitleKey],
          prefs: prefs,
          payload: receivedAction.payload,
          notificationId: receivedAction.id,
        );
        // alarmListRefreshTrigger is incremented inside _handleAlarmStop
      } catch (e) {
        debugPrint('NOTIFICATION_HANDLERS: Error processing stop action for ID $alarmIdStr: $e');
        if (receivedAction.id != null) {
          await AwesomeNotifications().dismiss(receivedAction.id!);
        }
      }
    } else if (alarmIdStr != null) {
      // Handle other actions, e.g., tapping notification body to open app
      debugPrint('NOTIFICATION_HANDLERS: Notification body tapped for alarm $alarmIdStr. App should open.');
      // Typically, AwesomeNotifications handles opening the app by default when body is tapped
      // unless a specific action (like a button) is defined and pressed.
      // If you want to navigate to a specific page or pass data, you might need to add
      // 'actionType: ActionType.Default' to your notification creation
      // and then handle it here or ensure MainActivity/AppDelegate handles the intent.
    }
  }
}