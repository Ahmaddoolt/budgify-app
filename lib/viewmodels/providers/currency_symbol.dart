// lib/viewmodels/providers/currency_symbol.dart

import 'package:budgify/core/constants/currencies.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/initialization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- THE FIX: A dedicated state class to hold the full Currency object. ---
class AppCurrencyState {
  // This makes it clear that this is the full Currency object currently
  // being used for display and filtering.
  final Currency displayCurrency;

  AppCurrencyState({required this.displayCurrency});
}

class CurrencyNotifier extends StateNotifier<AppCurrencyState> {
  CurrencyNotifier()
      // Initialize with a default state before loading the user's preference.
      : super(AppCurrencyState(displayCurrency: findCurrencyByCode('USD'))) {
    loadStoredValues();
  }

  /// Loads the user's permanently saved default currency from storage.
  Future<void> loadStoredValues() async {
    String? storedCurrencyCode = sharedPreferences.getString('currency_code');
    state = AppCurrencyState(
      displayCurrency: findCurrencyByCode(storedCurrencyCode ?? 'USD'),
    );
  }

  /// Sets the user's PERMANENT default currency.
  /// This should ONLY be called from the settings page.
  /// It updates the state and saves the code to SharedPreferences.
  Future<void> saveDefaultCurrency(String currencyCode) async {
    final newCurrency = findCurrencyByCode(currencyCode);
    state = AppCurrencyState(displayCurrency: newCurrency);
    // This line makes the change permanent for future app launches.
    await sharedPreferences.setString('currency_code', currencyCode);
  }

  /// Changes the TEMPORARY currency for the current session.
  /// This is what UI elements like the HomePage dropdown should use.
  /// It does NOT save the change permanently.
  void changeDisplayCurrency(String currencyCode) {
    final newCurrency = findCurrencyByCode(currencyCode);
    state = AppCurrencyState(displayCurrency: newCurrency);
  }
}

// --- THE FIX: The provider now clearly provides an AppCurrencyState. ---
final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, AppCurrencyState>(
  (ref) => CurrencyNotifier(),
);
