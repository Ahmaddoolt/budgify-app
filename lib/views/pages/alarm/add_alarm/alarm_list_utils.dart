import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/views/pages/alarm/add_alarm/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:alarm/alarm.dart';
import 'package:budgify/initialization.dart';

Future<void> loadRepeatingAlarmIds(BuildContext context, Function(Set<int>) updateRepeatingAlarmIds) async {
  debugPrint("UTILS: Loading repeating alarm IDs...");
  try {
    final List<String> idStrings = sharedPreferences.getStringList(repeatMonthlyPrefsKey) ?? [];
    final ids = idStrings.map((id) => int.parse(id)).toSet();
    updateRepeatingAlarmIds(ids);
    debugPrint("UTILS: Loaded repeating IDs: $ids");
  } catch (e) {
    debugPrint("UTILS: Error loading repeating alarm IDs: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading repeating status."),
          backgroundColor: AppColors.accentColor2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius * 0.8),
          ),
          margin: const EdgeInsets.all(kPadding),
          duration: const Duration(seconds: 5),
        ),
      );
    }
    updateRepeatingAlarmIds({});
  }
}

Future<void> saveRepeatingAlarmIds(Set<int> repeatingAlarmIds) async {
  debugPrint("UTILS: Saving repeating alarm IDs: $repeatingAlarmIds");
  try {
    final List<String> idStrings = repeatingAlarmIds.map((id) => id.toString()).toList();
    await sharedPreferences.setStringList(repeatMonthlyPrefsKey, idStrings);
    debugPrint("UTILS: Saved repeating IDs successfully.");
  } catch (e) {
    debugPrint("UTILS: Error saving repeating alarm IDs: $e");
  }
}

void pruneOrphanedRepeatingIds(List<AlarmSettings> alarms, Set<int> repeatingAlarmIds, Function(Set<int>) updateRepeatingAlarmIds) {
  final currentAlarmIds = alarms.map((a) => a.id).toSet();
  final initialCount = repeatingAlarmIds.length;

  repeatingAlarmIds.retainWhere((id) => currentAlarmIds.contains(id));

  final finalCount = repeatingAlarmIds.length;

  if (initialCount != finalCount) {
    debugPrint(
      "UTILS: Pruned orphaned repeating IDs (Count changed from $initialCount to $finalCount). Current repeating IDs: $repeatingAlarmIds",
    );
    saveRepeatingAlarmIds(repeatingAlarmIds);
    updateRepeatingAlarmIds(repeatingAlarmIds);
  }
}

String formatAlarmListItemTime(DateTime dt) {
  return DateFormat('hh:mm a').format(dt);
}

String formatAlarmListItemDate(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final alarmDate = DateTime(dt.year, dt.month, dt.day);

  if (alarmDate == today) return 'Today'.tr;
  if (alarmDate == tomorrow) return 'Tomorrow'.tr;
  return DateFormat('EEE, MMM d, yyyy').format(dt);
}