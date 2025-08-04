// lib/data/repo/budget_repository.dart

import 'package:hive/hive.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';

class BudgetRepository {
  late final Box<Budget> _budgetBox;
  final List<Category> categories;

  BudgetRepository(this.categories);

  // Initialization method to open the box
  Future<void> init() async {
    _budgetBox = await Hive.openBox<Budget>('budgets');
  }

  // Add a new budget to the box
  Future<void> addBudget(Budget budget) async {
    await _budgetBox.add(budget);
  }

  // --- THE FIX: This method now requires a currencyCode to be accurate ---
  /// Checks if a budget already exists for a given category AND currency.
  bool doesBudgetExistForCategory(String categoryId, String currencyCode) {
    return _budgetBox.values.any((budget) =>
        budget.categoryId == categoryId && budget.currencyCode == currencyCode);
  }

  // Load all budgets (useful for refreshing the budget list)
  List<Budget> loadBudgets() {
    return _budgetBox.values.toList();
  }
}
