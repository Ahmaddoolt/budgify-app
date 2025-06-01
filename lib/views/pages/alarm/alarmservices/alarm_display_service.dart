import 'package:budgify/initialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final alarmDisplayServiceProvider = StateNotifierProvider<AlarmDisplayService, bool>((ref) {
  // Ensure sharedPreferences from main.dart is initialized and accessible
  // This relies on the global `sharedPreferences` being initialized in main.dart before this provider is first read.
  return AlarmDisplayService(sharedPreferences)..loadInitialState();
});

class AlarmDisplayService extends StateNotifier<bool> {
  AlarmDisplayService(this._prefsInstance) : super(false);

  final SharedPreferences _prefsInstance;
  static const String prefsKeyIsAlarmScreenActive = 'isBudgifyAlarmScreenActive_v1';

  Future<void> loadInitialState() async {
    // Ensure _prefsInstance is valid.
    // If it's coming from a global variable, it must be initialized first.
    state = _prefsInstance.getBool(prefsKeyIsAlarmScreenActive) ?? false;
    debugPrint('AlarmDisplayService: Loaded initial state from prefs. isAlarmScreenActive: $state');
  }

  void setAlarmScreenActive(bool value) {
    if (state == value) {
        debugPrint('AlarmDisplayService: setAlarmScreenActive called with same value $value. No change.');
        return; 
    }
    state = value;
    _prefsInstance.setBool(prefsKeyIsAlarmScreenActive, value); 
    debugPrint('AlarmDisplayService: Set isAlarmScreenActive to $value (Riverpod State and SharedPreferences)');
    
    // If screen is becoming INACTIVE, clear the stored ID and title.
    // If screen is becoming ACTIVE, the ID/Title should be set by the caller (e.g., AlarmScreen.initState or _handleGlobalAlarmRing).
    if (!value) {
        _prefsInstance.remove('current_ringing_alarm_id');
        _prefsInstance.remove('current_ringing_alarm_title');
        debugPrint('AlarmDisplayService: Cleared current_ringing_alarm_id and title from prefs because screen became inactive.');
    }
  }

  bool isScreenActive() {
    // The Riverpod state `state` is the primary source of truth for the UI.
    return state;
  }
}