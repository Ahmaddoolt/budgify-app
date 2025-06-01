import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budgify/core/notifications/notification_handlers.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_handlers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_display_service.dart';
import 'package:budgify/views/navigation/app_routes.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:alarm/alarm.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  final int id;
  final String title;

  const AlarmScreen({super.key, required this.id, required this.title});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      "AlarmScreen: initState for ID ${widget.id}, Title '${widget.title}'",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        ref
            .read(alarmDisplayServiceProvider.notifier)
            .setAlarmScreenActive(true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          AlarmDisplayService.prefsKeyIsAlarmScreenActive,
          true,
        );
        await prefs.setInt('current_ringing_alarm_id', widget.id);
        await prefs.setString('current_ringing_alarm_title', widget.title);
        debugPrint(
          "AlarmScreen: Set SharedPreferences: isActive=true, ID=${widget.id}, Title='${widget.title}'",
        );
      }
    });
  }

  Future<void> _stopAlarmActions() async {
    debugPrint("AlarmScreen: Dismiss button pressed for ID ${widget.id}");

    final prefs = await SharedPreferences.getInstance();

    // Load repeating alarm IDs
    final initialRepeatingIds = await loadRepeatingAlarmIds(prefs);
    final bool isRepeating = initialRepeatingIds.contains(widget.id);
    debugPrint("AlarmScreen: Alarm ID ${widget.id} isRepeating: $isRepeating");

    try {
      // Retrieve AlarmSettings
      final activeAlarms = await Alarm.getAlarms();
      AlarmSettings? alarmSettingsToStop = activeAlarms.firstWhere(
        (alarm) => alarm.id == widget.id,
        orElse: () {
          debugPrint(
            "AlarmScreen: Alarm ID ${widget.id} not found in active alarms. Using fallback settings.",
          );
          return AlarmSettings(
            id: widget.id,
            dateTime: DateTime.now(),
            assetAudioPath: 'assets/alarm.mp3',
            loopAudio: true,
            vibrate: true,
            androidFullScreenIntent: true,
            notificationSettings: NotificationSettings(
              title: widget.title,
              body: 'Payment Reminder!',
              stopButton: 'Stop',
            ),
          );
        },
      );

      // Stop the alarm sound/vibration
      final bool stoppedSound = await Alarm.stop(widget.id);
      debugPrint("AlarmScreen: Alarm.stop(${widget.id}) result: $stoppedSound");

      // Dismiss any related AwesomeNotification
      try {
        await AwesomeNotifications().dismiss(widget.id);
        debugPrint(
          "AlarmScreen: Dismissed AwesomeNotification for ID ${widget.id}",
        );
      } catch (e) {
        debugPrint(
          "AlarmScreen: Error dismissing AwesomeNotification ${widget.id}: $e",
        );
      }

      // Handle repeating alarms
      if (isRepeating) {
        DateTime nextDateTime = calculateNextMonth(
          alarmSettingsToStop.dateTime,
        );
        DateTime now = DateTime.now();
        if (nextDateTime.isBefore(now.add(const Duration(seconds: 30)))) {
          DateTime safeStartDate = now.add(const Duration(minutes: 1));
          safeStartDate = DateTime(
            safeStartDate.year,
            safeStartDate.month,
            alarmSettingsToStop.dateTime.day,
            alarmSettingsToStop.dateTime.hour,
            alarmSettingsToStop.dateTime.minute,
          );
          nextDateTime = calculateNextMonth(safeStartDate);
          debugPrint(
            "AlarmScreen: Adjusted next repeat to $nextDateTime because original next was too soon.",
          );
        }

        final nextAlarmSettings = AlarmSettings(
          id: widget.id, // Use same ID
          dateTime: nextDateTime,
          assetAudioPath: alarmSettingsToStop.assetAudioPath,
          loopAudio: alarmSettingsToStop.loopAudio,
          vibrate: alarmSettingsToStop.vibrate,
          androidFullScreenIntent: true,
          notificationSettings: NotificationSettings(
            title: alarmSettingsToStop.notificationSettings.title,
            body: alarmSettingsToStop.notificationSettings.body,
            stopButton: alarmSettingsToStop.notificationSettings.stopButton,
          ),
        );

        final success = await Alarm.set(alarmSettings: nextAlarmSettings);
        if (success) {
          debugPrint(
            "AlarmScreen: Rescheduled repeating alarm ID ${widget.id} to $nextDateTime",
          );
        } else {
          debugPrint(
            "AlarmScreen: Failed to reschedule repeating alarm ID ${widget.id}",
          );
        }
      } else {
        await markAlarmAsStopped(widget.id, alarmSettingsToStop, prefs);
        debugPrint(
          "AlarmScreen: Marked non-repeating alarm ID ${widget.id} as stopped.",
        );
      }

      // Set refresh flag
      await prefs.setBool(alarmListRefreshKey, true);
      await prefs.reload();
      debugPrint(
        "AlarmScreen: Set '$alarmListRefreshKey' to true in SharedPreferences.",
      );

      // Clear alarm screen state
      ref
          .read(alarmDisplayServiceProvider.notifier)
          .setAlarmScreenActive(false);
      await prefs.setBool(
        AlarmDisplayService.prefsKeyIsAlarmScreenActive,
        false,
      );
      await prefs.remove('current_ringing_alarm_id');
      await prefs.remove('current_ringing_alarm_title');
      debugPrint(
        "AlarmScreen: Cleared alarm screen state and SharedPreferences.",
      );

      // Navigate back
      if (mounted) {
        if (Navigator.canPop(context)) {
          debugPrint("AlarmScreen: Popping to refresh AlarmListPage.");
          Navigator.pop(context, 'refresh');
        } else {
          debugPrint("AlarmScreen: Cannot pop, navigating to AlarmListPage.");
          Get.offAllNamed(YourAppRoutes.alarmListPage);
        }
      }
    } catch (e) {
      debugPrint(
        "AlarmScreen: Error during stop actions for ID ${widget.id}: $e",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping alarm: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Ensure refresh flag is set even on error
      await prefs.setBool(alarmListRefreshKey, true);
      ref
          .read(alarmDisplayServiceProvider.notifier)
          .setAlarmScreenActive(false);
      await prefs.setBool(
        AlarmDisplayService.prefsKeyIsAlarmScreenActive,
        false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: deprecated_member_use
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (didPop) return;
        debugPrint("AlarmScreen: Pop attempt prevented by PopScope");
      },
      child: Scaffold(
        backgroundColor: applyOpacity(AppColors.accentColor, 0.1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 60 * textScaleFactor,
                color: AppColors.accentColor,
                semanticLabel: 'Payment Reminder Icon',
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.title.isNotEmpty ? widget.title : 'Payment Reminder',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        theme.textTheme.headlineLarge?.color ?? Colors.black87,
                    fontSize: 28 * textScaleFactor,
                  ),
                  textAlign: TextAlign.center,
                  semanticsLabel:
                      'Payment reminder: ${widget.title.isNotEmpty ? widget.title : 'Payment Reminder'}',
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Your payment is due!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        // ignore: deprecated_member_use
                        theme.textTheme.titleMedium?.color?.withOpacity(0.7) ??
                        Colors.black54,
                    fontSize: 18 * textScaleFactor,
                  ),
                  textAlign: TextAlign.center,
                  semanticsLabel: 'Your payment is due',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, size: 32),
                label: const Text(
                  'Dismiss Reminder',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: applyOpacity(Colors.black, 0.2),
                ),
                onPressed: _stopAlarmActions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("AlarmScreen: dispose() called for ID ${widget.id}");
    super.dispose();
  }
}
