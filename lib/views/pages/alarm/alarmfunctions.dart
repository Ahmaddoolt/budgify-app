// budgify/lib/views/alarm/alarmfunctions.dart

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart'; // For debugPrint

Future<void> setAlarm(DateTime dateTime, int id, String title) async {
  final alarmSettings = AlarmSettings(
    id: id,
    dateTime: dateTime,
    assetAudioPath: 'assets/alarm.mp3', // Ensure this asset exists in pubspec.yaml and assets folder
    loopAudio: true,
    vibrate: true,
    androidFullScreenIntent: true, // <<< KEY CHANGE: Enable full-screen intent via package:alarm
    notificationSettings: NotificationSettings(
      title: title, // This will be the title used by package:alarm's notification
      body: 'Payment Reminder!', // Body for package:alarm's notification
      // package:alarm (v4+) uses "id" and "notificationTitle" as keys for extras
      // when androidFullScreenIntent is true. MainActivity needs to read these.
      stopButton: 'Stop', // <<< ADDED: package:alarm will add a stop button to its notification
    ),
  );
  try {
    bool success = await Alarm.set(alarmSettings: alarmSettings);
    if (success) {
      debugPrint('Alarm set for ID $id at $dateTime with androidFullScreenIntent: true (package:alarm)');
    } else {
      debugPrint('Alarm.set returned false for ID $id at $dateTime');
    }
  } catch (e) {
    debugPrint('Error setting alarm for ID $id at $dateTime: $e');
  }
}