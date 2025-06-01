import 'package:budgify/initialization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyState {
  final String currencySymbol;

  CurrencyState({required this.currencySymbol});
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  CurrencyNotifier() : super(CurrencyState(currencySymbol: '\$')) {
    loadStoredValues();
  }

  Future<void> loadStoredValues() async {
    String? storedCurrency = sharedPreferences.getString('currency');
    state = CurrencyState(
      currencySymbol: storedCurrency ?? '\$',
    );
  }

  void setCurrencySymbol(String symbol) async {
    state = CurrencyState(currencySymbol: symbol);
    await sharedPreferences.setString('currency', symbol);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  return CurrencyNotifier();
});