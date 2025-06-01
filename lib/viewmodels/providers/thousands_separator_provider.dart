import 'package:budgify/initialization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeparatorState {
  final bool isSeparatorEnabled;
  SeparatorState({required this.isSeparatorEnabled});
}

class SeparatorNotifier extends StateNotifier<SeparatorState> {
  // Default separator state (e.g., false or based on setupDefaultSettings)
  SeparatorNotifier() : super(SeparatorState(isSeparatorEnabled: false)) {
    loadSeparatorState(); // Call public method in constructor
  }

  // Make this method public
  Future<void> loadSeparatorState() async {
    bool? storedValue = sharedPreferences.getBool('separatorEnabled'); // Key used in setupDefaultSettings
    // Set default if null (e.g., false)
    state = SeparatorState(isSeparatorEnabled: storedValue ?? false);
  }

  void toggleSeparator(bool value) async {
    state = SeparatorState(isSeparatorEnabled: value);
    await sharedPreferences.setBool('separatorEnabled', value); // Ensure key matches load/setup
  }
}

final separatorProvider =
    StateNotifierProvider<SeparatorNotifier, SeparatorState>(
  (ref) => SeparatorNotifier(),
);