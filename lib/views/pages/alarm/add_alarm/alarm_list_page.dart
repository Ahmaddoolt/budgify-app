import 'package:budgify/views/navigation/app_routes.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/notifications/notification_handlers.dart'; // For alarmListRefreshTrigger and alarmListRefreshKey
import 'package:budgify/views/pages/alarm/add_alarm/alarm_list_form.dart';
import 'package:budgify/views/pages/alarm/add_alarm/alarm_list_view.dart';
import 'package:budgify/views/pages/alarm/add_alarm/constants.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_handlers.dart'; // For loadStoppedAlarmSettings, loadStoppedAlarms
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
// Ensure alarm_list_utils.dart is imported if _pruneOrphanedRepeatingIds uses it
import 'package:budgify/views/pages/alarm/add_alarm/alarm_list_utils.dart'
    as alarm_utils;

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({super.key});

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage>
    with WidgetsBindingObserver {
  List<AlarmSettings> _alarms = [];
  bool _loadingAlarms = true;
  Set<int> _repeatingAlarmIds = {};

  @override
  void initState() {
    super.initState();
    debugPrint("PAGE: initState called");
    WidgetsBinding.instance.addObserver(this);
    alarmListRefreshTrigger.addListener(
      _onAlarmListRefreshNeeded,
    ); // Listen to notifier

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initial load, also checks and consumes SharedPreferences refresh flag
      await _loadAlarmsAndRepeatingStatus(isInitialLoad: true);
      // No need for _checkRefreshSignal separately if _loadAlarmsAndRepeatingStatus handles the flag.
      // await _debugSharedPreferences(); // For debugging if needed
    });
  }

  void _onAlarmListRefreshNeeded() {
    debugPrint("PAGE: ValueNotifier triggered refresh for AlarmListPage.");
    if (mounted) {
      // Don't pass isInitialLoad: true here, as this is a subsequent refresh.
      // _loadAlarmsAndRepeatingStatus will check the SharedPreferences flag anyway if needed,
      // but primary trigger here is the notifier.
      _loadAlarmsAndRepeatingStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['refreshAlarms'] == true) {
      debugPrint(
        "PAGE: Refresh signal received via arguments, reloading alarms.",
      );
      _loadAlarmsAndRepeatingStatus();
    }
    // _checkRefreshSignal(); // This might be redundant now.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("PAGE: App resumed, forcing alarm reload.");
      _loadAlarmsAndRepeatingStatus();
    }
  }

  // Removed _checkRefreshSignal as its logic is integrated into _loadAlarmsAndRepeatingStatus

  Future<void> _loadAlarmsAndRepeatingStatus({
    bool isInitialLoad = false,
  }) async {
    if (!mounted) return;
    debugPrint(
      "PAGE: Loading alarms and repeating status. Initial: $isInitialLoad",
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensure we have the latest prefs

    // Check and consume the SharedPreferences refresh flag
    // This ensures that if the flag was set while the page wasn't active or listening,
    // it's still acted upon when loading occurs.
    if (prefs.getBool(alarmListRefreshKey) ?? false) {
      debugPrint(
        "PAGE: SharedPreferences refresh flag detected and consumed by _loadAlarmsAndRepeatingStatus.",
      );
      await prefs.setBool(alarmListRefreshKey, false);
      // No need to reload prefs again immediately, as _loadAlarms/_loadRepeatingAlarmIds will do so or use this instance.
    }

    await _loadRepeatingAlarmIds(
      prefs,
    ); // Pass prefs to avoid multiple getInstance calls
    await _loadAlarms(prefs); // Pass prefs
  }

  Future<void> _loadRepeatingAlarmIds(SharedPreferences prefs) async {
    // No need to setState for _loadingAlarms here, _loadAlarms will handle it.
    try {
      await prefs.reload(); // Reload before reading
      final List<String> idStrings =
          prefs.getStringList(repeatMonthlyPrefsKey) ?? [];
      final ids = idStrings.map((id) => int.parse(id)).toSet();
      if (mounted) {
        setState(() {
          _repeatingAlarmIds = ids;
        });
      }
      debugPrint("PAGE: Loaded repeating IDs: $ids");
    } catch (e) {
      debugPrint("PAGE: Error loading repeating alarm IDs: $e");
      if (mounted) {
        _showFeedbackSnackbar("Error loading repeating status.", isError: true);
        setState(() {
          _repeatingAlarmIds = {};
        });
      }
    }
  }

  Future<void> _loadAlarms(SharedPreferences prefs) async {
    if (!mounted) return;
    debugPrint("PAGE: Starting _loadAlarms");
    setState(() {
      _loadingAlarms = true;
    });

    try {
      // Ensure prefs is fresh before these calls or that they reload internally
      // `loadStoppedAlarmSettings` and `loadStoppedAlarms` from `alarm_handlers.dart`
      // should internally call `prefs.reload()` if they take `prefs` as an argument,
      // or we rely on the reload done at the start of _loadAlarmsAndRepeatingStatus.
      // For safety, let's assume they handle their own reload if necessary or use the passed fresh `prefs`.

      final List<AlarmSettings> activeAlarms = await Alarm.getAlarms();
      debugPrint(
        "PAGE: Active alarms from Alarm.getAlarms(): ${activeAlarms.map((a) => 'ID=${a.id}, Title=${a.notificationSettings.title}, Date=${a.dateTime}').toList()}",
      );

      final List<AlarmSettings> stoppedAlarmsSettingsList =
          await loadStoppedAlarmSettings(prefs);
      debugPrint(
        "PAGE: Stopped alarms from loadStoppedAlarmSettings: ${stoppedAlarmsSettingsList.map((a) => 'ID=${a.id}, Title=${a.notificationSettings.title}, Date=${a.dateTime}').toList()}",
      );

      final Map<int, Map<String, dynamic>> stoppedAlarmsDataMap =
          await loadStoppedAlarms(prefs);
      debugPrint(
        "PAGE: Stopped alarms map from loadStoppedAlarms: ${stoppedAlarmsDataMap.map((k, v) => MapEntry(k, 'ID=$k, Title=${v['notificationSettings']?['title']}, StopTime=${v['stopTime']}'))}",
      );

      // final Set<int> stoppedAlarmsIdsFromSettings =
      //     stoppedAlarmsSettingsList.map((a) => a.id).toSet();

      // Combine active alarms and stopped alarms
      // An alarm is "active" if Alarm.getAlarms() returns it.
      // An alarm is "stopped" if it's in our SharedPreferences stopped list AND NOT in Alarm.getAlarms().
      // If Alarm.getAlarms() still lists an alarm that's also in our stopped prefs, prioritize Alarm.getAlarms() as "active"
      // and investigate why Alarm.stop() might not have removed it from there, or why it's in both lists.
      // However, the typical expectation is that Alarm.stop() removes it from Alarm.getAlarms().

      List<AlarmSettings> combinedAlarms = [];
      Set<int> activeAlarmIds = activeAlarms.map((a) => a.id).toSet();

      // Add all active alarms
      combinedAlarms.addAll(activeAlarms);

      // Add alarms from stopped list that are not in the active list
      for (var stoppedAlarmSetting in stoppedAlarmsSettingsList) {
        if (!activeAlarmIds.contains(stoppedAlarmSetting.id)) {
          combinedAlarms.add(stoppedAlarmSetting);
        } else {
          // This case is problematic: an alarm is "active" according to the plugin,
          // but we also have it as "stopped" in prefs. This indicates a potential sync issue.
          // For now, we've already added it from activeAlarms. Log this.
          debugPrint(
            "PAGE: WARNING - Alarm ID ${stoppedAlarmSetting.id} is in Alarm.getAlarms() AND in stopped SharedPreferences. Treating as active.",
          );
        }
      }

      // Sort alarms: active ones first (by date), then stopped ones (by stop time descending or original date).
      // The existing sort logic seems to handle this with isAStopped/isBStopped.
      // We need the `stoppedAlarmsDataMap` to get the stopTime for sorting.
      combinedAlarms.sort((a, b) {
        // Use stoppedAlarmsDataMap to check if an alarm is truly marked as stopped in our system.
        // An alarm in combinedAlarms might have come from activeAlarms or stoppedAlarmsSettingsList.
        final isAEffectivelyStopped =
            stoppedAlarmsDataMap.containsKey(a.id) &&
            !activeAlarmIds.contains(a.id);
        final isBEffectivelyStopped =
            stoppedAlarmsDataMap.containsKey(b.id) &&
            !activeAlarmIds.contains(b.id);

        if (isAEffectivelyStopped && isBEffectivelyStopped) {
          final stopTimeA = DateTime.fromMillisecondsSinceEpoch(
            stoppedAlarmsDataMap[a.id]?['stopTime'] as int? ??
                a
                    .dateTime
                    .millisecondsSinceEpoch, // fallback to original time if stopTime missing
          );
          final stopTimeB = DateTime.fromMillisecondsSinceEpoch(
            stoppedAlarmsDataMap[b.id]?['stopTime'] as int? ??
                b.dateTime.millisecondsSinceEpoch,
          );
          return stopTimeB.compareTo(stopTimeA); // Most recently stopped first
        } else if (isAEffectivelyStopped) {
          return 1; // Stopped alarms after active ones
        } else if (isBEffectivelyStopped) {
          return -1; // Active alarms before stopped ones
        }
        // Both are active, sort by datetime
        return a.dateTime.compareTo(b.dateTime);
      });

      if (mounted) {
        setState(() {
          _alarms = combinedAlarms;
          _loadingAlarms = false;
        });
        debugPrint(
          "PAGE: Set state with ${_alarms.length} alarms. Active: ${activeAlarms.length}, Stopped in UI: ${_alarms.where((a) => stoppedAlarmsDataMap.containsKey(a.id) && !activeAlarmIds.contains(a.id)).length}",
        );
        _pruneOrphanedRepeatingIds();
      }
    } catch (e, s) {
      debugPrint("PAGE: Error loading alarms: $e\n$s");
      if (mounted) {
        setState(() {
          _loadingAlarms = false;
          _alarms = []; // Clear alarms on error
        });
        _showFeedbackSnackbar("Error loading alarms: $e", isError: true);
      }
    }
  }

  // Future<void> _debugSharedPreferences() async {
  //   // Removed 'prefs' argument, get instance inside
  //   final prefsInstance = await SharedPreferences.getInstance();
  //   await prefsInstance.reload();
  //   final stoppedAlarmsList =
  //       prefsInstance.getStringList('stoppedAlarms') ?? [];
  //   final refreshFlagValue =
  //       prefsInstance.getBool(alarmListRefreshKey) ?? false;
  //   debugPrint(
  //     'PAGE: SharedPreferences Debug: stoppedAlarms=${stoppedAlarmsList.take(5).join(", ")}..., refreshFlag=$refreshFlagValue',
  //   );
  // }

  // Future<void> _inspectSharedPreferences() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.reload();
  //   final stoppedAlarmsList = prefs.getStringList('stoppedAlarms') ?? [];
  //   final refreshFlagValue = prefs.getBool(alarmListRefreshKey) ?? false;
  //   final repeatingIds = prefs.getStringList(repeatMonthlyPrefsKey) ?? [];
  //   final message =
  //       'SharedPreferences Contents:\n'
  //       'Stopped Alarms (first 5): ${stoppedAlarmsList.take(5).join(" | ")}...\n'
  //       'Refresh Flag: $refreshFlagValue\n'
  //       'Repeating IDs: $repeatingIds';
  //   _showFeedbackSnackbar(message, durationSeconds: 10);
  //   debugPrint('PAGE: Inspect SharedPreferences: $message');
  // }

  // Future<void> _clearSharedPreferences() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('stoppedAlarms'); // Clear specific keys instead of all
  //   await prefs.remove(alarmListRefreshKey);
  //   await prefs.remove(repeatMonthlyPrefsKey);
  //   // Add other keys if necessary
  //   debugPrint('PAGE: Cleared specific alarm-related SharedPreferences');
  //   await _loadAlarmsAndRepeatingStatus(); // Reload after clearing
  //   _showFeedbackSnackbar('Cleared alarm data from SharedPreferences.'.tr);
  // }

  void _pruneOrphanedRepeatingIds() {
    // Using the imported alarm_utils
    alarm_utils.pruneOrphanedRepeatingIds(_alarms, _repeatingAlarmIds, (
      updatedIds,
    ) {
      if (mounted) {
        setState(() {
          _repeatingAlarmIds = updatedIds;
        });
        _saveRepeatingAlarmIds(); // Save them back after pruning
      }
    });
  }

  void _showFeedbackSnackbar(
    String message, {
    bool isError = false,
    int durationSeconds = 3,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.accentColor2 : AppColors.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius * 0.8),
        ),
        margin: const EdgeInsets.all(kPadding),
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }

  Future<void> _deleteAlarm(int id) async {
    debugPrint("PAGE: Attempting to delete alarm ID: $id");
    try {
      final bool stopSuccess = await Alarm.stop(id);
      debugPrint("PAGE: Alarm.stop result for ID $id: $stopSuccess");

      // Regardless of stopSuccess, try to remove from our persisted states
      bool changed = false;
      if (_repeatingAlarmIds.remove(id)) {
        await _saveRepeatingAlarmIds();
        changed = true;
        debugPrint("PAGE: Removed repeating ID $id.");
      }

      final prefs = await SharedPreferences.getInstance();
      final stoppedAlarmsMap = await loadStoppedAlarms(
        prefs,
      ); // loadStoppedAlarms reloads prefs
      if (stoppedAlarmsMap.remove(id) != null) {
        await saveStoppedAlarms(
          stoppedAlarmsMap,
          prefs,
        ); // saveStoppedAlarms reloads prefs
        changed = true;
        debugPrint(
          "PAGE: Removed stopped alarm ID $id from SharedPreferences.",
        );
      }

      // If the alarm was in the current UI list, remove it.
      // Check if it was actually removed from _alarms to decide if setState is needed.
      final initialAlarmsLength = _alarms.length;
      _alarms.removeWhere((alarm) => alarm.id == id);
      if (_alarms.length < initialAlarmsLength) {
        changed = true;
        debugPrint("PAGE: Removed alarm ID $id from UI list.");
      }

      if (changed || stopSuccess) {
        _showFeedbackSnackbar('Payment reminder deleted.', isError: false);
      } else {
        _showFeedbackSnackbar(
          'Reminder not found or already handled.',
          isError: true,
        );
      }

      if (changed && mounted) {
        setState(() {}); // Refresh UI if any state impacting the list changed
      } else if (!changed && stopSuccess) {
        // If only Alarm.stop() succeeded but no local state changed, still might need a full reload
        // to reflect the change from Alarm.getAlarms()
        await _loadAlarmsAndRepeatingStatus();
      }
    } catch (e) {
      debugPrint("PAGE: Error deleting alarm $id: $e");
      if (mounted) {
        _showFeedbackSnackbar(
          'An error occurred deleting the reminder.',
          isError: true,
        );
        await _loadAlarmsAndRepeatingStatus(); // Reload to ensure consistent state
      }
    }
  }

  Future<void> _saveRepeatingAlarmIds() async {
    // Using the imported alarm_utils
    await alarm_utils.saveRepeatingAlarmIds(_repeatingAlarmIds);
    debugPrint(
      "PAGE: Saved repeating IDs via alarm_utils: $_repeatingAlarmIds",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color appBarColor =
        theme.appBarTheme.backgroundColor ?? theme.primaryColor;
    debugPrint(
      "PAGE: Building UI with ${_alarms.length} alarms, loading: $_loadingAlarms, repeating IDs: $_repeatingAlarmIds.value",
    );

    return PopScope(
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (didPop) {
          debugPrint(
            "PAGE: Pop invoked (system back), signaling potential refresh to previous screen if needed.",
          );
          // If AlarmListPage is popped, the caller might need to refresh.
          // Get.find<PreviousPageController>().needsRefresh = true; (example)
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              debugPrint(
                "PAGE: Back button pressed, canPop: ${Navigator.of(context).canPop()}",
              );
              if (Navigator.of(context).canPop()) {
                debugPrint(
                  "PAGE: Popping with 'refresh' signal (or let caller decide).",
                );
                Navigator.of(
                  context,
                ).pop('refresh'); // Good practice to signal refresh
              } else {
                debugPrint(
                  "PAGE: Cannot pop, navigating to home route (YourAppRoutes.homeScreen).",
                );
                Get.offAllNamed(
                  YourAppRoutes.homeScreen,
                ); // Ensure YourAppRoutes.homeScreen is defined
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text('Payment Reminders'.tr),
          elevation: 1.0,
          backgroundColor: appBarColor,
          foregroundColor:
              theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,

          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.info_outline, color: Colors.white),
          //     onPressed: _inspectSharedPreferences,
          //     tooltip: 'Inspect SharedPreferences',
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white), // Changed icon
          //     onPressed: _clearSharedPreferences,
          //     tooltip: 'Clear Alarm Data',
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.refresh, color: Colors.white),
          //     onPressed: () => _loadAlarmsAndRepeatingStatus(), // Directly call
          //     tooltip: 'Refresh Alarms',
          //   ),
          // ],
        ),
        body: Column(
          children: [
            AlarmListForm(
              onAlarmSet: () async {
                debugPrint("PAGE: Alarm set via form, reloading alarms.");
                await _loadAlarmsAndRepeatingStatus(); // Reload after new alarm set
              },
              onFeedback: _showFeedbackSnackbar,
              repeatingAlarmIds: _repeatingAlarmIds,
              updateRepeatingAlarmIds: (newIds) {
                if (mounted) {
                  setState(() {
                    _repeatingAlarmIds = newIds;
                  });
                  _saveRepeatingAlarmIds(); // Persist change immediately
                  debugPrint(
                    "PAGE: Updated repeating IDs from form: $_repeatingAlarmIds",
                  );
                }
              },
            ),
            Divider(
              height: kPadding, // Use constant
              thickness: 1,
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.5),
              indent: kPadding,
              endIndent: kPadding,
            ),
            Expanded(
              child: AlarmListView(
                alarms: _alarms,
                loadingAlarms: _loadingAlarms,
                repeatingAlarmIds: _repeatingAlarmIds,
                onDelete: (id) async {
                  await _deleteAlarm(id);
                },
                onFeedback: _showFeedbackSnackbar,
                updateRepeatingAlarmIds: (newIds) {
                  if (mounted) {
                    // Ensure widget is still in the tree
                    setState(() {
                      _repeatingAlarmIds = newIds;
                    });
                    _saveRepeatingAlarmIds(); // Persist change immediately
                    debugPrint(
                      "PAGE: Updated repeating IDs from AlarmListView: $_repeatingAlarmIds",
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("PAGE: Disposing AlarmListPage");
    WidgetsBinding.instance.removeObserver(this);
    alarmListRefreshTrigger.removeListener(
      _onAlarmListRefreshNeeded,
    ); // Unlisten
    super.dispose();
  }
}
