// lib/domain/models/budget.dart

import 'package:hive/hive.dart';

// Since there is a TypeAdapter, it's best practice for the model
// to extend HiveObject to allow for efficient updates and deletions.
class Budget extends HiveObject {
  final String categoryId;
  double budgetAmount;

  // --- THE FIX: Store both code and symbol ---
  final String currencyCode;
  final String currencySymbol;

  Budget({
    required this.categoryId,
    required this.budgetAmount,
    required this.currencyCode,
    required this.currencySymbol,
  });
}
