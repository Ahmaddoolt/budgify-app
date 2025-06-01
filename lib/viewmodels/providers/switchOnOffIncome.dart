// ignore_for_file: file_names

import 'package:budgify/initialization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwitchState {
  final bool isSwitched;
  SwitchState({required this.isSwitched});
}

class SwitchNotifier extends StateNotifier<SwitchState> {
  // Default to true as per setupDefaultSettings logic might be better? Or handle default there.
  // Let's assume default is false based on original code.
  SwitchNotifier() : super(SwitchState(isSwitched: false)) {
    loadSwitchState(); // Call the public method in constructor
  }

  // Make this method public
  Future<void> loadSwitchState() async {
    // Ensure sharedPreferences is initialized before accessing
    // It might be safer to get instance here if main.dart initialization order isn't guaranteed
    // final prefs = await SharedPreferences.getInstance();
    // bool? storedValue = prefs.getBool('switchState');
    bool? storedValue = sharedPreferences.getBool('switchState');
    // Set a default if null, e.g., true based on setupDefaultSettings
    state = SwitchState(isSwitched: storedValue ?? true);
  }

  void toggleSwitch(bool value) async {
    state = SwitchState(isSwitched: value);
    await sharedPreferences.setBool('switchState', value);
  }
}

final switchProvider = StateNotifierProvider<SwitchNotifier, SwitchState>(
  (ref) => SwitchNotifier(),
);