// lib/domain/models/expense.dart  (or wherever your CashFlow model is)

import 'package:budgify/domain/models/category.dart';
import 'package:budgify/domain/models/wallet.dart';

class CashFlow {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  // --- THE FIX: Store BOTH the code and the symbol ---
  final String
      currencyCode; // The unique identifier for logic (e.g., "USD", "EUR")
  final String currencySymbol; // The display string for UI (e.g., "$", "€")

  final String? notes;
  final bool isIncome;
  final Wallet walletType;

  CashFlow({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.currencyCode,
    required this.currencySymbol,
    this.notes,
    required this.isIncome,
    required this.walletType,
  });
}
