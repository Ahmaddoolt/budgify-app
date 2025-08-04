// lib/viewmodels/providers/multi_currency_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/initialization.dart';

class MultiCurrencyNotifier extends StateNotifier<bool> {
  MultiCurrencyNotifier() : super(false) {
    // Default to off
    _loadState();
  }

  // Load the saved state from shared preferences
  void _loadState() {
    final isEnabled =
        sharedPreferences.getBool('isMultiCurrencyEnabled') ?? false;
    state = isEnabled;
  }

  // Toggle the switch and save the new state
  Future<void> toggleMultiCurrency(bool isEnabled) async {
    state = isEnabled;
    await sharedPreferences.setBool('isMultiCurrencyEnabled', isEnabled);
  }
}

final multiCurrencyProvider =
    StateNotifierProvider<MultiCurrencyNotifier, bool>((ref) {
  return MultiCurrencyNotifier();
});
