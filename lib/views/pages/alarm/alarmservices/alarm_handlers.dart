import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_display_service.dart';
import 'package:budgify/views/pages/alarm/add_alarm/constants.dart';
import 'package:budgify/core/notifications/notification_handlers.dart';
import 'package:path_provider/path_provider.dart';

StreamSubscription<AlarmSettings>? globalAlarmSubscription;
const String _platformChannelName = "com.example.budgify/alarm";
const MethodChannel _platformChannel = MethodChannel(_platformChannelName);
const String nativeExtraAlarmIdKeyFromMainKt = "alarmId";
const String nativeExtraAlarmTitleKeyFromMainKt = "title";
const String nativeExtraIntentTypeKeyFromMainKt = "type";
const String nativeIntentTypeAlarmValueFromMainKt = "alarm";
const String _stoppedAlarmsPrefsKey = 'stoppedAlarms';
const String _fallbackStoppedAlarmsFile = 'stopped_alarms_fallback.json';

Future<void> markAlarmAsStopped(int alarmId, AlarmSettings settings, SharedPreferences prefs) async {
  debugPrint('ALARM_HANDLERS: Marking alarm ID $alarmId as stopped, Title: ${settings.notificationSettings.title}');
  try {
    final stoppedAlarms = await loadStoppedAlarms(prefs);
    final settingsJson = {
      'id': settings.id,
      'dateTime': settings.dateTime.toIso8601String(),
      'assetAudioPath': settings.assetAudioPath,
      'loopAudio': settings.loopAudio,
      'vibrate': settings.vibrate,
      'androidFullScreenIntent': settings.androidFullScreenIntent,
      'notificationSettings': {
        'title': settings.notificationSettings.title,
        'body': settings.notificationSettings.body,
        'stopButton': settings.notificationSettings.stopButton,
      },
      'stopTime': DateTime.now().millisecondsSinceEpoch,
    };
    stoppedAlarms[alarmId] = settingsJson;
    bool saveSuccess = false;
    for (int attempt = 1; attempt <= 10; attempt++) {
      try {
        await saveStoppedAlarms(stoppedAlarms, prefs);
        // Verify the write
        final updatedStoppedAlarms = await loadStoppedAlarms(prefs);
        if (updatedStoppedAlarms.containsKey(alarmId)) {
          saveSuccess = true;
          // Fix 1: Defensive null checking for notificationSettings and title
          final notificationSettings = settingsJson['notificationSettings'] as Map<String, dynamic>?;
          final title = notificationSettings != null ? notificationSettings['title'] as String? ?? 'Unknown' : 'Unknown';
          debugPrint('ALARM_HANDLERS: Verified stopped alarm ID $alarmId saved: Title=$title');
          break;
        } else {
          debugPrint('ALARM_HANDLERS: Attempt $attempt: Stopped alarm ID $alarmId not found in SharedPreferences');
        }
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Attempt $attempt failed to save stopped alarm ID $alarmId: $e');
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (!saveSuccess) {
      debugPrint('ALARM_HANDLERS: Failed to save to SharedPreferences after 10 attempts. Using fallback file.');
      await _saveToFallbackFile(stoppedAlarms);
    }
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error marking alarm ID $alarmId as stopped: $e');
    // Fix 2: Ensure correct map structure for fallback (same as settingsJson)
    await _saveToFallbackFile({
      alarmId: {
        'id': settings.id,
        'dateTime': settings.dateTime.toIso8601String(),
        'assetAudioPath': settings.assetAudioPath,
        'loopAudio': settings.loopAudio,
        'vibrate': settings.vibrate,
        'androidFullScreenIntent': settings.androidFullScreenIntent,
        'notificationSettings': {
          'title': settings.notificationSettings.title,
          'body': settings.notificationSettings.body,
          'stopButton': settings.notificationSettings.stopButton,
        },
        'stopTime': DateTime.now().millisecondsSinceEpoch,
      }
    });
    throw Exception('Failed to mark alarm as stopped: $e');
  }
}

Future<void> _saveToFallbackFile(Map<int, Map<String, dynamic>> stoppedAlarms) async {
  try {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$_fallbackStoppedAlarmsFile');
    await file.writeAsString(jsonEncode(stoppedAlarms));
    debugPrint('ALARM_HANDLERS: Saved stopped alarms to fallback file: ${file.path}');
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error saving to fallback file: $e');
  }
}

Future<Map<int, Map<String, dynamic>>> _loadFromFallbackFile() async {
  try {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$_fallbackStoppedAlarmsFile');
    if (await file.exists()) {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(int.parse(key), value as Map<String, dynamic>));
    }
    return {};
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error loading from fallback file: $e');
    return {};
  }
}

Future<void> saveStoppedAlarms(Map<int, Map<String, dynamic>> stoppedAlarms, SharedPreferences prefs) async {
  debugPrint('ALARM_HANDLERS: Saving stopped alarms: ${stoppedAlarms.keys}');
  try {
    final stoppedAlarmsList = stoppedAlarms.entries.map((e) => '${e.key}:${jsonEncode(e.value)}').toList();
    bool success = false;
    for (int attempt = 1; attempt <= 10; attempt++) {
      try {
        success = await prefs.setStringList(_stoppedAlarmsPrefsKey, stoppedAlarmsList);
        await prefs.reload();
        final savedList = prefs.getStringList(_stoppedAlarmsPrefsKey) ?? [];
        if (savedList.length == stoppedAlarmsList.length) {
          debugPrint('ALARM_HANDLERS: Attempt $attempt: Successfully saved ${savedList.length} stopped alarms');
          break;
        } else {
          debugPrint('ALARM_HANDLERS: Attempt $attempt: Saved list length (${savedList.length}) does not match expected (${stoppedAlarmsList.length})');
        }
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Attempt $attempt failed to save stopped alarms: $e');
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (!success) {
      debugPrint('ALARM_HANDLERS: Failed to save stopped alarms to SharedPreferences after 10 attempts');
      await _saveToFallbackFile(stoppedAlarms);
      throw Exception('Failed to save stopped alarms to SharedPreferences');
    }
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error saving stopped alarms: $e');
    await _saveToFallbackFile(stoppedAlarms);
    throw Exception('Failed to save stopped alarms: $e');
  }
}

Future<Map<int, Map<String, dynamic>>> loadStoppedAlarms(SharedPreferences prefs) async {
  debugPrint('ALARM_HANDLERS: Loading stopped alarms');
  try {
    await prefs.reload();
    final List<String> stoppedAlarmsList = prefs.getStringList(_stoppedAlarmsPrefsKey) ?? [];
    debugPrint('ALARM_HANDLERS: Raw stopped alarms: $stoppedAlarmsList');
    final Map<int, Map<String, dynamic>> stoppedAlarms = {};
    for (var entry in stoppedAlarmsList) {
      try {
        final parts = entry.split(':');
        if (parts.length < 2 || parts[0].isEmpty) {
          debugPrint('ALARM_HANDLERS: Skipping invalid entry: $entry');
          continue;
        }
        final id = int.tryParse(parts[0]);
        final jsonStr = parts.sublist(1).join(':');
        if (id == null || jsonStr.isEmpty) {
          debugPrint('ALARM_HANDLERS: Invalid ID or JSON in entry: $entry');
          continue;
        }
        final settingsJson = jsonDecode(jsonStr) as Map<String, dynamic>;
        stoppedAlarms[id] = settingsJson;
        final notificationSettings = settingsJson['notificationSettings'] as Map<String, dynamic>?;
        final title = notificationSettings != null ? notificationSettings['title'] as String? ?? 'Unknown' : 'Unknown';
        debugPrint('ALARM_HANDLERS: Loaded stopped alarm ID $id: Title=$title');
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Error parsing stopped alarm entry: $entry, Error: $e');
      }
    }
    // Merge with fallback file
    final fallbackAlarms = await _loadFromFallbackFile();
    stoppedAlarms.addAll(fallbackAlarms);
    if (fallbackAlarms.isNotEmpty) {
      await saveStoppedAlarms(stoppedAlarms, prefs); // Sync fallback to SharedPreferences
      debugPrint('ALARM_HANDLERS: Merged ${fallbackAlarms.length} alarms from fallback file');
    }
    debugPrint('ALARM_HANDLERS: Loaded ${stoppedAlarms.length} stopped alarms: ${stoppedAlarms.keys}');
    return stoppedAlarms;
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error loading stopped alarms: $e');
    return await _loadFromFallbackFile();
  }
}

Future<List<AlarmSettings>> loadStoppedAlarmSettings(SharedPreferences prefs) async {
  debugPrint('ALARM_HANDLERS: Loading stopped alarm settings');
  try {
    final stoppedAlarmsMap = await loadStoppedAlarms(prefs);
    final List<AlarmSettings> settingsList = [];
    for (var entry in stoppedAlarmsMap.entries) {
      final json = entry.value;
      try {
        final settings = AlarmSettings(
          id: json['id'] as int,
          dateTime: DateTime.parse(json['dateTime'] as String),
          assetAudioPath: json['assetAudioPath'] as String? ?? 'assets/alarm.mp3',
          loopAudio: json['loopAudio'] as bool? ?? true,
          vibrate: json['vibrate'] as bool? ?? true,
          androidFullScreenIntent: json['androidFullScreenIntent'] as bool? ?? true,
          notificationSettings: NotificationSettings(
            title: json['notificationSettings']['title'] as String? ?? 'Payment Reminder',
            body: json['notificationSettings']['body'] as String? ?? 'Payment Reminder!',
            stopButton: json['notificationSettings']['stopButton'] as String? ?? 'Stop',
          ),
        );
        settingsList.add(settings);
        debugPrint('ALARM_HANDLERS: Reconstructed AlarmSettings ID ${entry.key}: Title=${settings.notificationSettings.title}');
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Error reconstructing AlarmSettings ID ${entry.key}: $e');
      }
    }
    debugPrint('ALARM_HANDLERS: Loaded ${settingsList.length} stopped AlarmSettings');
    return settingsList;
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error loading stopped alarm settings: $e');
    return [];
  }
}

Future<void> stopAndMarkAlarm({
  required int alarmId,
  required AlarmSettings alarmSettings,
  required SharedPreferences prefs,
  int? notificationId,
}) async {
  debugPrint('ALARM_HANDLERS: stopAndMarkAlarm ID $alarmId, Title: ${alarmSettings.notificationSettings.title}, Date: ${alarmSettings.dateTime}');
  try {
    // Verify alarm exists
    final activeAlarms = await Alarm.getAlarms();
    if (!activeAlarms.any((alarm) => alarm.id == alarmId)) {
      debugPrint('ALARM_HANDLERS: Alarm ID $alarmId not found in active alarms. Still marking as stopped.');
    }

    // Stop the alarm
    bool stopped = false;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        stopped = await Alarm.stop(alarmId);
        debugPrint('ALARM_HANDLERS: Alarm.stop($alarmId) attempt $attempt result: $stopped');
        break;
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Attempt $attempt failed to stop alarm ID $alarmId: $e');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Handle repeating or non-repeating alarm
    final repeatingIds = await loadRepeatingAlarmIds(prefs);
    if (repeatingIds.contains(alarmId)) {
      await handleGlobalAlarmRing(alarmSettings, prefs);
      debugPrint('ALARM_HANDLERS: Handled repeating alarm ID $alarmId via handleGlobalAlarmRing');
    } else {
      await markAlarmAsStopped(alarmId, alarmSettings, prefs);
      debugPrint('ALARM_HANDLERS: Marked non-repeating alarm ID $alarmId as stopped');
    }

    // Dismiss notification
    if (notificationId != null) {
      try {
        await AwesomeNotifications().dismiss(notificationId);
        debugPrint('ALARM_HANDLERS: Dismissed notification ID $notificationId');
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Error dismissing notification ID $notificationId: $e');
      }
    }

    // Set refresh flag
    bool refreshSuccess = false;
    for (int attempt = 1; attempt <= 10; attempt++) {
      try {
        refreshSuccess = await prefs.setBool(alarmListRefreshKey, true);
        await prefs.reload();
        if (refreshSuccess && (prefs.getBool(alarmListRefreshKey) ?? false)) {
          debugPrint('ALARM_HANDLERS: Successfully set refresh flag on attempt $attempt');
          break;
        }
        debugPrint('ALARM_HANDLERS: Attempt $attempt failed to verify refresh flag');
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Attempt $attempt failed to set refresh flag: $e');
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (!refreshSuccess) {
      debugPrint('ALARM_HANDLERS: Failed to set refresh flag after 10 attempts');
    }

    // Final verification
    final stoppedAlarms = await loadStoppedAlarms(prefs);
    if (stoppedAlarms.containsKey(alarmId)) {
      final notificationSettings = stoppedAlarms[alarmId]?['notificationSettings'] as Map<String, dynamic>?;
      final title = notificationSettings != null ? notificationSettings['title'] as String? ?? 'Unknown' : 'Unknown';
      debugPrint('ALARM_HANDLERS: Final verification: Stopped alarm ID $alarmId saved: Title=$title');
    } else {
      debugPrint('ALARM_HANDLERS: ERROR: Stopped alarm ID $alarmId not found in SharedPreferences after operation');
    }
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Critical error in stopAndMarkAlarm ID $alarmId: $e');
    // Ensure refresh flag is set even on error
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await prefs.setBool(alarmListRefreshKey, true);
        await prefs.reload();
        debugPrint('ALARM_HANDLERS: Set refresh flag on error recovery attempt $attempt');
        break;
      } catch (e) {
        debugPrint('ALARM_HANDLERS: Error setting refresh flag on attempt $attempt: $e');
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    // Fix 2: Construct correct map for fallback using alarmSettings
    await _saveToFallbackFile({
      alarmId: {
        'id': alarmId,
        'dateTime': alarmSettings.dateTime.toIso8601String(),
        'assetAudioPath': alarmSettings.assetAudioPath,
        'loopAudio': alarmSettings.loopAudio,
        'vibrate': alarmSettings.vibrate,
        'androidFullScreenIntent': alarmSettings.androidFullScreenIntent,
        'notificationSettings': {
          'title': alarmSettings.notificationSettings.title,
          'body': alarmSettings.notificationSettings.body,
          'stopButton': alarmSettings.notificationSettings.stopButton,
        },
        'stopTime': DateTime.now().millisecondsSinceEpoch,
      }
    });
  }
}

Future<Map<String, dynamic>?> getInitialAlarmNativeData() async {
  try {
    final Map<dynamic, dynamic>? data = await _platformChannel.invokeMethod('getInitialIntent');
    if (data != null && data[nativeExtraIntentTypeKeyFromMainKt] == nativeIntentTypeAlarmValueFromMainKt) {
      final id = data[nativeExtraAlarmIdKeyFromMainKt] as int?;
      final title = data[nativeExtraAlarmTitleKeyFromMainKt] as String?;
      if (id != null && title != null) {
        return {'id': id, 'title': title};
      }
    }
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error in getInitialAlarmNativeData: $e');
  }
  return null;
}

Future<void> checkStoredAlarmState() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    bool wasAlarmScreenActive = prefs.getBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive) ?? false;
    int? storedAlarmId = prefs.getInt('current_ringing_alarm_id');
    String? storedAlarmTitle = prefs.getString('current_ringing_alarm_title');
    if (wasAlarmScreenActive && storedAlarmId != null && storedAlarmTitle != null) {
      Get.routing.args = {'id': storedAlarmId, 'title': storedAlarmTitle};
      debugPrint('ALARM_HANDLERS: Restored ALARMSCREEN with args: ${Get.routing.args}');
    } else {
      await prefs.setBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive, false);
      await prefs.remove('current_ringing_alarm_id');
      await prefs.remove('current_ringing_alarm_title');
      debugPrint('ALARM_HANDLERS: Cleared stored alarm data');
    }
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error in checkStoredAlarmState: $e');
  }
}

Future<void> handleGlobalAlarmRing(AlarmSettings ringingAlarm, SharedPreferences prefs) async {
  debugPrint('ALARM_HANDLERS: handleGlobalAlarmRing ID ${ringingAlarm.id}');
  await prefs.setBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive, true);
  await prefs.setInt('current_ringing_alarm_id', ringingAlarm.id);
  await prefs.setString('current_ringing_alarm_title', ringingAlarm.notificationSettings.title.isNotEmpty ? ringingAlarm.notificationSettings.title : 'Payment Reminder');
  await prefs.reload();
  Set<int> repeatingIds = await loadRepeatingAlarmIds(prefs);
  if (repeatingIds.contains(ringingAlarm.id)) {
    repeatingIds.remove(ringingAlarm.id);
    DateTime nextDateTime = calculateNextMonth(ringingAlarm.dateTime);
    DateTime now = DateTime.now();
    if (nextDateTime.isBefore(now.add(const Duration(seconds: 30)))) {
      DateTime safeStartDate = now.add(const Duration(minutes: 1));
      safeStartDate = DateTime(safeStartDate.year, safeStartDate.month, ringingAlarm.dateTime.day, ringingAlarm.dateTime.hour, ringingAlarm.dateTime.minute);
      nextDateTime = calculateNextMonth(safeStartDate);
    }
    final newAlarmId = DateTime.now().millisecondsSinceEpoch % 1000000;
    final nextAlarmSettings = AlarmSettings(
      id: newAlarmId,
      dateTime: nextDateTime,
      assetAudioPath: ringingAlarm.assetAudioPath,
      loopAudio: ringingAlarm.loopAudio,
      vibrate: ringingAlarm.vibrate,
      androidFullScreenIntent: true,
      notificationSettings: ringingAlarm.notificationSettings,
    );
    try {
      final success = await Alarm.set(alarmSettings: nextAlarmSettings);
      if (success) {
        repeatingIds.add(newAlarmId);
        await saveRepeatingAlarmIds(repeatingIds, prefs);
        debugPrint('ALARM_HANDLERS: Rescheduled repeating alarm ID $newAlarmId');
      }
    } catch (e) {
      debugPrint('ALARM_HANDLERS: Error rescheduling repeating alarm: $e');
    }
  }
}

Future<Set<int>> loadRepeatingAlarmIds(SharedPreferences prefs) async {
  try {
    await prefs.reload();
    final List<String> idStrings = prefs.getStringList(repeatMonthlyPrefsKey) ?? [];
    final ids = idStrings.map((id) => int.parse(id)).toSet();
    debugPrint('ALARM_HANDLERS: Loaded repeating IDs: $ids');
    return ids;
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error loading repeating IDs: $e');
    return {};
  }
}

Future<void> saveRepeatingAlarmIds(Set<int> ids, SharedPreferences prefs) async {
  try {
    final List<String> idStrings = ids.map((id) => id.toString()).toList();
    bool success = await prefs.setStringList(repeatMonthlyPrefsKey, idStrings);
    await prefs.reload();
    if (!success) {
      debugPrint('ALARM_HANDLERS: Retry saving repeating IDs');
      await Future.delayed(const Duration(milliseconds: 300));
      success = await prefs.setStringList(repeatMonthlyPrefsKey, idStrings);
      await prefs.reload();
    }
    debugPrint('ALARM_HANDLERS: Saved repeating IDs: $idStrings');
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error saving repeating IDs: $e');
  }
}

DateTime calculateNextMonth(DateTime dt) {
  int year = dt.year;
  int month = dt.month + 1;
  int day = dt.day;
  if (month > 12) {
    month = 1;
    year += 1;
  }
  int daysInNextMonth = DateTime(year, month + 1, 0).day;
  if (day > daysInNextMonth) {
    day = daysInNextMonth;
  }
  return DateTime(year, month, day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
}

Future<void> cleanupOldAlarms() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final stoppedAlarms = await loadStoppedAlarms(prefs);
    final now = DateTime.now().millisecondsSinceEpoch;
    const maxAgeDays = 30;
    stoppedAlarms.removeWhere((id, settings) {
      final stopTime = settings['stopTime'] as int? ?? 0;
      final ageDays = (now - stopTime) / (1000 * 60 * 60 * 24);
      return ageDays > maxAgeDays;
    });
    await saveStoppedAlarms(stoppedAlarms, prefs);
    debugPrint('ALARM_HANDLERS: Cleaned up old stopped alarms. Remaining: ${stoppedAlarms.keys}');
  } catch (e) {
    debugPrint('ALARM_HANDLERS: Error cleaning up old alarms: $e');
  }
}